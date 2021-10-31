#!/bin/sh

SCHEME="ICloutKit"
DESTINATION="platform=iOS Simulator,name=iPhone 13"
GRAPHS_PATH="iclout-kit-symbol-graphs"

mkdir -p .build/symbol-graphs && \
  swift build --target "$SCHEME" \
    -Xswiftc -emit-symbol-graph \
    -Xswiftc -emit-symbol-graph-dir -Xswiftc .build/symbol-graphs

mkdir .build/"$GRAPHS_PATH" \
  && mv .build/symbol-graphs/"$SCHEME"* .build/"$GRAPHS_PATH"

export DOCC_HTML_DIR="$(dirname $(xcrun --find docc))/../share/docc/render"

cd Scripts/GenerateDocumentation/swift-docc-render

npm run build

export DOCC_HTML_DIR="dist"

../swift-docc/.build/debug/docc preview ../../../Sources/"$SCHEME"/"$SCHEME".docc \
  --fallback-display-name "$SCHEME" \
  --fallback-bundle-identifier io.kamaal."$SCHEME" \
  --fallback-bundle-version 1.0.0 \
  --additional-symbol-graph-dir .build/"$GRAPHS_PATH"
