# Quick install script for protoc and Go plugins

Write-Host "🔧 Installing Protocol Buffers compiler..." -ForegroundColor Cyan

# Check if protoc is installed
if (!(Get-Command protoc -ErrorAction SilentlyContinue)) {
    Write-Host "⚠️  protoc not found. Please install it first:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Option 1 - Using Chocolatey:" -ForegroundColor White
    Write-Host "  choco install protoc" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Option 2 - Using Scoop:" -ForegroundColor White
    Write-Host "  scoop install protobuf" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Option 3 - Manual download:" -ForegroundColor White
    Write-Host "  https://github.com/protocolbuffers/protobuf/releases" -ForegroundColor Gray
    Write-Host ""
    exit 1
} else {
    $protocVersion = (protoc --version)
    Write-Host "✅ protoc is installed: $protocVersion" -ForegroundColor Green
}

Write-Host ""
Write-Host "🔧 Installing Go protobuf plugins..." -ForegroundColor Cyan

go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ protoc-gen-go installed" -ForegroundColor Green
}

go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ protoc-gen-go-grpc installed" -ForegroundColor Green
}

Write-Host ""
Write-Host "🎉 Setup complete! Run: pwsh .\scripts\generate.ps1" -ForegroundColor Green
