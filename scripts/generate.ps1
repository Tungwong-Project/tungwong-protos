# Generate Go code from proto files
# Run this script: pwsh generate.ps1

$ErrorActionPreference = "Stop"

$PROTO_DIR = "./proto"
$OUT_DIR = "./gen/go"

# Create output directory
New-Item -ItemType Directory -Force -Path $OUT_DIR | Out-Null

Write-Host "🔨 Generating Go code from proto files..." -ForegroundColor Cyan

# Find all .proto files
$protoFiles = Get-ChildItem -Path $PROTO_DIR -Filter "*.proto" -Recurse

foreach ($protoFile in $protoFiles) {
    Write-Host "  Generating: $($protoFile.Name)" -ForegroundColor Gray
    
    # Run protoc
    protoc `
        --go_out=$OUT_DIR `
        --go_opt=paths=source_relative `
        --go-grpc_out=$OUT_DIR `
        --go-grpc_opt=paths=source_relative `
        --proto_path=$PROTO_DIR `
        $protoFile.FullName
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to generate from $($protoFile.Name)" -ForegroundColor Red
        exit 1
    }
}

Write-Host "✅ Proto generation complete!" -ForegroundColor Green
Write-Host "📁 Generated files in: $OUT_DIR" -ForegroundColor Green
