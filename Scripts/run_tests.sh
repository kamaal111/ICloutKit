#!/bin/sh

WORKSPACE=".swiftpm/xcode/package.xcworkspace"

DESTINATIONS=(
  "platform=iOS Simulator,name=iPhone 13 Pro Max"
)

SCHEME="ICloutKit"

xcode_test() {
    set -o pipefail && xcodebuild test -workspace "$WORKSPACE" -scheme "$SCHEME" -destination "$1" | bundle exec xcpretty || exit 1
}

test_all_destinations() {
  time {
    for destination in "${DESTINATIONS[@]}"
    do 
    xcode_test "$destination"
    done
  }
}

test_all_destinations
