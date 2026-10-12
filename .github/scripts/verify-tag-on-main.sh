#!/usr/bin/env bash

# Confirms that a release tag points at a commit on main before the release
# workflow builds, tests or publishes anything from it.
#
# Usage: verify-tag-on-main.sh <tag> [<main-ref>]
#   <tag>       the tag name, for example v4.10.0 (github.ref_name in the workflow)
#   <main-ref>  the ref that stands for main; refs/remotes/origin/main when omitted
#
# Exit 0 when the tagged commit is on the main ref's history (or is that commit),
# 1 when it is not, and 2 when either look-up fails. Both look-ups need the full
# history, so the workflow checks out with fetch-depth 0 before calling this.

set -euo pipefail

tag="${1-}"
# Fully qualified so it cannot resolve to a tag of the same name.
main_ref="${2:-refs/remotes/origin/main}"

if [[ -z ${tag} ]]; then
	echo "::error::verify-tag-on-main.sh needs the tag name as its first argument." >&2
	exit 2
fi

# Look-up one: the commit the tag points at. ^{commit} peels an annotated tag.
if ! tagged_commit=$(git rev-parse --verify --quiet "refs/tags/${tag}^{commit}"); then
	echo "::error::Tag '${tag}' was not found in this checkout." >&2
	exit 2
fi

# Look-up two: the commit main is at.
if ! main_commit=$(git rev-parse --verify --quiet "${main_ref}^{commit}"); then
	echo "::error::Ref '${main_ref}' was not found in this checkout." >&2
	exit 2
fi

# The one test: the tagged commit is on main's history. Anything else, a commit
# on an unmerged branch or on top of main, stops the run.
if git merge-base --is-ancestor "${tagged_commit}" "${main_commit}"; then
	printf 'Tag %s points at %s, which is on %s (%s).\n' \
		"${tag}" "${tagged_commit}" "${main_ref}" "${main_commit}"
	exit 0
fi

echo "::error::Tag '${tag}' points at ${tagged_commit}, which is not on ${main_ref} (${main_commit}). Release tags come from the tag workflow at a merged commit on main; this run stops here." >&2
exit 1
