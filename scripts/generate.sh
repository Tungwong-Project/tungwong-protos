#!/bin/bash

# Generate Go code from proto files

set -e

PROTO_DIR="./proto"
OUT_DIR="./gen/go"

# Create output directory
mkdir -p "$OUT_DIR"

# Generate Go code
protoc \
  --go_out="$OUT_DIR" \
  --go_opt=paths=source_relative \
  --go-grpc_out="$OUT_DIR" \
  --go-grpc_opt=paths=source_relative \
  --proto_path="$PROTO_DIR" \
  $(find "$PROTO_DIR" -name "*.proto")

echo "✅ Proto generation complete!"
echo "Generated files in: $OUT_DIR"
