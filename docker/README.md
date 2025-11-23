# Production Docker Setup

Optimized Alpine-based Docker image for Wt application with SQLite.

## Features

- **Alpine Linux 3.19** - Minimal base image
- **Multi-stage build** - Separate build and runtime
- **SQLite only** - No PostgreSQL/MySQL overhead
- **Stripped binaries** - Debug symbols removed
- **Non-root user** - Security best practice
- **~150-180MB** - Optimized image size

## Build

```bash
./docker/build.sh
```

Options:
- `--no-cache` - Build without cache
- `--tag TAG` - Custom image tag
- `--push` - Push to registry

## Run

```bash
docker run -d -p 9020:9020 --name wt-app wt-app:latest
```

With persistent data:
```bash
docker run -d \
  -p 9020:9020 \
  -v wt-data:/apps/cv/data \
  --name wt-app \
  wt-app:latest
```

## Files

- `Dockerfile.builder` - Build stage (Wt + application)
- `Dockerfile` - Runtime stage (minimal dependencies)
- `build.sh` - Build script

## Configuration

The image uses:
- MinSizeRel build type
- SQLite database
- HTTP connector (port 9020)
- Health checks via netcat
