#!/bin/sh

SCHEME="ICloutKit"
XCODE_PATH="/Applications/Xcode.app"
DESTINATION="platform=iOS Simulator,name=iPhone 13"

rm -rf Documentation
mkdir Documentation
set -o pipefail && SCHEME="$SCHEME" XCODE_PATH="$XCODE_PATH" DESTINATION="$DESTINATION" \
    go run Scripts/GenerateDocumentation/main.go || exit 1
