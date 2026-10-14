# Release steps

## Creating a release

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

## Environments

Release jobs run in two GitHub environments, configured in the repository settings:

- `pub-dev`: the job that publishes to pub.dev. It runs only for tags, so the environment's
  deployment rule must allow tags matching `v*`; a branch-only rule blocks every release.
- `release`: the jobs that use the release GitHub App, which open the release pull request, tag
  the release and open the release notes pull request. The App's credentials belong in this
  environment's secrets, and its deployment rule must allow the `main` branch and tags matching `v*`.
