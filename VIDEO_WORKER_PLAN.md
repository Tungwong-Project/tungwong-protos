# tungwong-video-worker

Video encoding worker service that processes uploaded videos using FFmpeg and converts them to HLS format.

## Architecture

```
NATS JetStream → Video Worker → FFmpeg → gRPC → Video Management API
```

## Features

- ✅ Consumes video upload events from NATS JetStream
- ✅ Encodes videos to HLS (.m3u8) format using FFmpeg
- ✅ Generates thumbnails from video frames
- ✅ Reports processing status via gRPC to video-management-api
- ✅ Handles failures with retry logic
- ✅ Graceful shutdown and job recovery

## Recommended Structure

```
tungwong-video-worker/
├── main.go
├── go.mod
├── Dockerfile
├── configs/
│   └── config.go              # Configuration management
├── internal/
│   ├── worker/
│   │   ├── worker.go          # Main worker orchestrator
│   │   └── processor.go       # Video processing logic
│   ├── ffmpeg/
│   │   ├── encoder.go         # FFmpeg HLS encoding
│   │   └── thumbnail.go       # Thumbnail generation
│   ├── grpc/
│   │   └── client.go          # gRPC client for video-management
│   └── nats/
│       ├── consumer.go        # NATS JetStream consumer
│       └── handler.go         # Message handler
├── pkg/
│   └── logger/
│       └── logger.go          # Structured logging
└── README.md
```

## Environment Variables

```env
NATS_URL=nats://localhost:4222
NATS_STREAM=VIDEO_UPLOADS
NATS_SUBJECT=video.upload.created
NATS_CONSUMER=video-worker-group
NATS_DURABLE=video-worker

VIDEO_MANAGEMENT_GRPC_URL=localhost:50051
WORKER_ID=worker-1
MAX_CONCURRENT_JOBS=3

# FFmpeg settings
FFMPEG_HLS_TIME=10              # Segment duration (seconds)
FFMPEG_PRESET=medium            # ultrafast, fast, medium, slow
FFMPEG_CRF=23                   # Quality (18-28, lower=better)

# Paths
INPUT_VIDEO_PATH=/app/uploads/videos
OUTPUT_HLS_PATH=/app/outputs/hls
OUTPUT_THUMBNAIL_PATH=/app/outputs/thumbnails

# Retry
MAX_RETRIES=3
RETRY_BACKOFF_SECONDS=60
```

## NATS Message Format

Worker expects messages in this format:

```json
{
  "video_id": "550e8400-e29b-41d4-a716-446655440000",
  "file_name": "video.mp4",
  "upload_file_path": "/uploads/videos/550e8400_1234567890.mp4",
  "original_format": "mp4",
  "uploader_id": "user-uuid",
  "title": "My Video",
  "description": "Video description"
}
```

## Processing Flow

1. **Receive Message** from NATS JetStream
2. **Call gRPC**: `MarkVideoProcessing()` → Update status to "processing"
3. **FFmpeg Encoding**:
   - Convert to HLS format (.m3u8 + .ts segments)
   - Generate thumbnail (frame at 5 seconds)
4. **On Success**: 
   - Call gRPC: `UpdateVideoStatus()` with HLS path
   - Ack NATS message
5. **On Failure**:
   - Call gRPC: `HandleVideoFailure()` with error details
   - Nack NATS message (for retry)

## FFmpeg Commands

### HLS Encoding
```bash
ffmpeg -i input.mp4 \
  -c:v libx264 -preset medium -crf 23 \
  -c:a aac -b:a 128k \
  -hls_time 10 \
  -hls_playlist_type vod \
  -hls_segment_filename "segment_%03d.ts" \
  output.m3u8
```

### Thumbnail Generation
```bash
ffmpeg -i input.mp4 -ss 00:00:05 -vframes 1 thumbnail.jpg
```

## Error Handling

| Error Type | Action | Retry? |
|------------|--------|--------|
| FFmpeg encoding failed | Call HandleVideoFailure | Yes (3x) |
| File not found | Call HandleVideoFailure | No |
| gRPC connection error | Log & retry gRPC call | Yes |
| Worker crash | Video-management timeout rollback | - |

## Timeout Protection

**Problem**: Worker dies during processing without calling gRPC

**Solution**: Video-management-api runs background job:
```go
// Every 5 minutes, check for stuck videos
SELECT * FROM videos 
WHERE upload_status = 'processing' 
AND processing_started_at < NOW() - INTERVAL '60 minutes'
// Auto-update to 'failed' status
```

## Installation

```bash
# Clone repo
git clone <repo-url>
cd tungwong-video-worker

# Install dependencies
go mod download

# Run
go run main.go
```

## Docker

```dockerfile
FROM golang:1.22-alpine AS builder

# Install FFmpeg
RUN apk add --no-cache ffmpeg

WORKDIR /app
COPY . .
RUN go build -o worker main.go

FROM alpine:latest
RUN apk add --no-cache ffmpeg
COPY --from=builder /app/worker /app/worker

CMD ["/app/worker"]
```

## Next Steps

1. ✅ Implement NATS consumer
2. ✅ Add FFmpeg encoding logic
3. ✅ Integrate gRPC client
4. ✅ Add graceful shutdown
5. ✅ Implement retry logic
6. ✅ Add monitoring/metrics
