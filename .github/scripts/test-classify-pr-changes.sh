#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CLASSIFIER="${SCRIPT_DIR}/classify-pr-changes.sh"

assert_selection() {
	local name="$1"
	local expected_true="$2"
	shift 2

	local output
	if [[ $# -eq 0 ]]; then
		output=$(printf '' | "${CLASSIFIER}" 2>/dev/null)
	else
		output=$(printf '%s\n' "$@" | "${CLASSIFIER}" 2>/dev/null)
	fi

	local key expected actual
	for key in docs android ios flutter full; do
		expected=false
		if [[ ",${expected_true}," == *",${key},"* ]]; then
			expected=true
		fi
		actual=$(printf '%s\n' "${output}" | awk -F= -v key="${key}" '$1 == key { print $2 }')
		if [[ ${actual:-missing} != "${expected}" ]]; then
			printf 'FAIL: %s expected %s=%s, got %s\n' \
				"${name}" "${key}" "${expected}" "${actual:-missing}" >&2
			exit 1
		fi
	done

	printf 'PASS: %s\n' "${name}"
}

assert_selection "documentation only" "docs" $'M\tREADME.md' $'A\tdocs/integration.md'
assert_selection "release workflow only" "docs" $'M\t.github/workflows/release-publish.yml'
assert_selection "shared Dart" "android,ios,flutter" $'M\tlib/rokt_sdk.dart'
assert_selection "pubspec" "android,ios,flutter" $'M\tpubspec.yaml'
assert_selection "shared integration" "android,ios,flutter" $'M\texample/integration_test/app_test.dart'
assert_selection "Android only" "android,flutter" $'M\tandroid/src/main/kotlin/RoktSdkPlugin.kt'
assert_selection "Android workflow only" "android,flutter" $'M\t.github/workflows/test-android.yml'
assert_selection "iOS only" "ios,flutter" $'M\tios/rokt_sdk/Sources/RoktSdkPlugin.swift'
assert_selection "iOS workflow only" "ios,flutter" $'M\t.github/workflows/test-ios.yml'
assert_selection "mixed platforms" "android,ios,flutter" $'M\tandroid/build.gradle' $'M\tios/rokt_sdk.podspec'
assert_selection "build workflow is conservative" "docs,android,ios,flutter,full" $'M\t.github/workflows/pull_request.yml'
assert_selection "unknown is conservative" "docs,android,ios,flutter,full" $'A\tunexpected/config.toml'
assert_selection "rename is conservative" "docs,android,ios,flutter,full" $'R100\tREADME.md\tdocs/README.md'
assert_selection "empty diff is conservative" "docs,android,ios,flutter,full"
