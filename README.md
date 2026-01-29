# tungwong-protos

Shared Protocol Buffers definitions for Tungwong microservices.

## Structure

```
tungwong-protos/
├── proto/
│   └── video/
│       └── video_service.proto    # Video worker ↔ Video Management gRPC contract
├── gen/                            # Generated code (gitignored)
│   └── go/
│       └── video/
│           └── v1/
└── scripts/
    └── generate.sh                 # Code generation script
```

## Usage

### Generate Go code

```bash
# Install protoc-gen-go and protoc-gen-go-grpc
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# Generate
./scripts/generate.sh
```

### Import in Go projects

```go
import videov1 "github.com/phnormalguy/tungwong-protos/gen/go/video/v1"
```

## Services

### VideoManagementService

Contract between `tungwong-video-worker` and `tungwong-video-management-api`.

**RPCs:**
1. **UpdateVideoStatus** - Worker reports successful encoding completion
2. **HandleVideoFailure** - Worker reports processing failure
3. **MarkVideoProcessing** - Worker sends heartbeat when starting (prevents timeout rollback)

## Status Flow

```
pending → processing → done
    ↓
  failed (soft delete)
```

## Error Handling Strategy

- **Success**: Worker calls `UpdateVideoStatus` with HLS path
- **Failure**: Worker calls `HandleVideoFailure` with error details
- **Timeout**: Video-management auto-marks as `failed` after 60 minutes of no heartbeat
- **Retry**: Configurable retry logic with exponential backoff
