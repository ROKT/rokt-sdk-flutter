# Release steps

## Creating a release

The draft workflow uses the shared `generate-changelog` action to generate the
new version section from merged pull request titles since the previous release
tag. Conventional Commit prefixes group the entries into categories such as
Added and Fixed. The generated `release-notes` output also populates the release
pull request, and the publish workflow extracts the same changelog section for
the GitHub release. Maintain pull request titles instead of hand-writing new
changelog entries.

1. Run the workflow called "Create draft release" which will:
   - Open a PR targeting main branch
   - Bump the `VERSION` file
   - Update the version in `pubspec.yaml`
2. Once approved by relevant owners, merge the PR to main
3. Once merged the following will occur:
   - Update changelog - unreleased section moved to correct version number
   - Release made on Github with relevant build files
   - Commit tagged with version number

## Checks before publishing

The publish workflow runs on every pushed tag that starts with `v`. Its first job runs
`.github/scripts/verify-tag-on-main.sh`, which stops the run before anything is built or
published unless the tagged commit is on `main`. Tags created by the release flow above are
always on `main`, so they pass.

Changelog versions use bare numbers, while new Git tags use a `v` prefix. The draft
workflow sets `tag-prefix: v` when generating comparison links. The publish workflow
reads the matching version's comparison URL from the generated changelog and adds it
to the GitHub release as a Full Changelog link.

Historical comparisons retain existing unprefixed tags and use verified version commits
where a tag is unavailable. A version with no verifiable commit keeps its notes without
a linked heading.

## Environments

Release jobs run in two GitHub environments, configured in the repository settings:

- `pub-dev`: the job that publishes to pub.dev. It runs only for tags, so the environment's
  deployment rule must allow tags matching `v*`; a branch-only rule blocks every release.
- `release`: the jobs that use the release GitHub App, which open the release pull request, tag
  the release and open the release notes pull request. The App's credentials belong in this
  environment's secrets, and its deployment rule must allow the `main` branch and tags matching `v*`.
