#!/bin/bash

set -eu

# $1 Android SDK version
# $2 build.gradle file location
# $3 iOS SDK version
# $4 podspec file location
# $5 New Flutter SDK version
# $6 pubspec file location


perl -pi -e "s/(?<=roktsdk:)(.*)(?=\")/$1/g" "$2"
perl -pi -e "s/(?<='Rokt-Widget', '~> )(.*)(?=')/$3/g" "$4"
perl -pi -e "s/(?<=  s.version          = ')(.*)(?=')/$5/g" "$4"
perl -pi -e "s/(?<=version: )(.*)(?=\n)/$5/g" "$6"