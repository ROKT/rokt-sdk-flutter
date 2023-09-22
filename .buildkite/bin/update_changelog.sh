#!/bin/bash

set -eu

# $1 CHANGELOG.md file
# $2 New version
# $3 Changelog text

if [ -z "$3" ]; 
then
    echo "Empty changelog text provided. Using default"
    CHANGELOG_TEXT="Updated Rokt SDKs and interfaces"
else
    CHANGELOG_TEXT="$3"
fi

echo -e "## $2\n* $CHANGELOG_TEXT\n" | cat - $1 > /tmp/out
mv /tmp/out $1