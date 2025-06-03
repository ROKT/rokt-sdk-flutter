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
