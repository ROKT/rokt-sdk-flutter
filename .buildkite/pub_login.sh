#!/bin/bash

# This script creates/updates credentials.json file which is used
# to authorize publisher when publishing packages to pub.dev

# Checking whether the secrets are available as environment
# variables or not.
if [[ -z ${PUB_DEV_PUBLISH_ACCESS_TOKEN} ]]; then
	echo "Missing PUB_DEV_PUBLISH_ACCESS_TOKEN environment variable"
	exit 1
fi

if [[ -z ${PUB_DEV_PUBLISH_REFRESH_TOKEN} ]]; then
	echo "Missing PUB_DEV_PUBLISH_REFRESH_TOKEN environment variable"
	exit 1
fi

if [[ -z ${PUB_DEV_PUBLISH_TOKEN_ENDPOINT} ]]; then
	echo "Missing PUB_DEV_PUBLISH_TOKEN_ENDPOINT environment variable"
	exit 1
fi

if [[ -z ${PUB_DEV_PUBLISH_EXPIRATION} ]]; then
	echo "Missing PUB_DEV_PUBLISH_EXPIRATION environment variable"
	exit 1
fi

# Create folder
mkdir -p ~/Library/Application\ Support/dart/
# Create pub-credentials.json file.
cat <<EOF >~/Library/Application\ Support/dart/pub-credentials.json
{
  "accessToken":"${PUB_DEV_PUBLISH_ACCESS_TOKEN}",
  "refreshToken":"${PUB_DEV_PUBLISH_REFRESH_TOKEN}",
  "tokenEndpoint":"${PUB_DEV_PUBLISH_TOKEN_ENDPOINT}",
  "scopes":["https://www.googleapis.com/auth/userinfo.email","openid"],
  "expiration":${PUB_DEV_PUBLISH_EXPIRATION}
}
EOF
