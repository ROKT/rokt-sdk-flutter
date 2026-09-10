#!/usr/bin/env bash

set -euo pipefail

docs=false
android=false
ios=false
flutter=false
full=false

set_full() {
	local reason="$1"
	docs=true
	android=true
	ios=true
	flutter=true
	full=true
	printf 'Selecting both platform suites: %s\n' "${reason}" >&2
}

select_shared() {
	android=true
	ios=true
	flutter=true
}

classify_path() {
	local path="${1#./}"

	case "${path}" in
	.github/workflows/release-*.yml | CHANGELOG.md | VERSION)
		docs=true
		;;
	.github/workflows/test-android.yml)
		android=true
		flutter=true
		;;
	.github/workflows/test-ios.yml)
		ios=true
		flutter=true
		;;
	.github/workflows/* | .github/actions/* | .github/dependabot.yml | \
		.github/scripts/* | .trunk/* | analysis_options.yaml | .metadata)
		set_full "validation or build-system file changed: ${path}"
		;;
	pubspec.yaml | pubspec.lock | lib/* | test/* | integration_test/* | \
		example/pubspec.yaml | example/pubspec.lock | example/lib/* | \
		example/test/* | example/integration_test/*)
		select_shared
		;;
	example/android/* | android/*)
		android=true
		flutter=true
		;;
	Gemfile | Gemfile.lock | example/Gemfile | example/Gemfile.lock | \
		example/ios/* | ios/*)
		ios=true
		flutter=true
		;;
	*.md | docs/* | documentation/* | .cortex/* | .github/ISSUE_TEMPLATE/* | \
		.github/CODEOWNERS | LICENSE | NOTICE | .gitignore | .editorconfig)
		docs=true
		;;
	*)
		set_full "unclassified path changed: ${path}"
		;;
	esac
}

if [[ ${1-} == "--full" ]]; then
	set_full "${2:-explicit full-validation request}"
else
	path_count=0
	while IFS=$'\t' read -r status path extra_path; do
		[[ -z ${status} ]] && continue
		path_count=$((path_count + 1))

		case "${status}" in
		A | M | D)
			if [[ -z ${path-} || -n ${extra_path-} ]]; then
				set_full "malformed changed-path record"
				continue
			fi
			classify_path "${path}"
			;;
		R[0-9]* | C[0-9]*)
			set_full "rename or copy detected"
			;;
		*)
			if [[ -z ${path-} ]]; then
				set_full "malformed changed-path record"
			else
				set_full "unsupported change status detected: ${status}"
			fi
			;;
		esac
	done

	if [[ ${path_count} -eq 0 ]]; then
		set_full "no changed paths were available"
	fi
fi

printf 'docs=%s\n' "${docs}"
printf 'android=%s\n' "${android}"
printf 'ios=%s\n' "${ios}"
printf 'flutter=%s\n' "${flutter}"
printf 'full=%s\n' "${full}"
