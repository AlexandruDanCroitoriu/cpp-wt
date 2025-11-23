#!/usr/bin/env bash
# Build optimized Alpine-based Wt application for production
# Usage: ./build.sh [--no-cache] [--push] [--tag TAG]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Default values
NO_CACHE=""
PUSH_IMAGE=false
IMAGE_NAME="wt-app"
TAG="latest"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-cache)
            NO_CACHE="--no-cache"
            shift
            ;;
        --push)
            PUSH_IMAGE=true
            shift
            ;;
        --tag)
            TAG="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--no-cache] [--push] [--tag TAG]"
            exit 1
            ;;
    esac
done

echo "🐋 Building optimized Alpine-based Wt application"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Remove previous images if they exist
echo ""
echo "🧹 Cleaning up previous images..."
docker rmi -f "$IMAGE_NAME:$TAG" 2>/dev/null || true
docker rmi -f builder 2>/dev/null || true

# Build the builder image
echo ""
echo "📦 Building Wt Alpine builder image..."
docker build $NO_CACHE \
    -t builder \
    -f "$SCRIPT_DIR/Dockerfile.builder" \
    "$PROJECT_ROOT"

# Build the production image
echo ""
echo "🚀 Building production image..."
docker build $NO_CACHE \
    -t "$IMAGE_NAME:$TAG" \
    -f "$SCRIPT_DIR/Dockerfile" \
    "$SCRIPT_DIR"

# Show image info
echo ""
echo "✅ Build completed successfully!"
echo ""
echo "📊 Image Information:"
docker images | grep -E "REPOSITORY|$IMAGE_NAME"

# Push if requested
if [ "$PUSH_IMAGE" = true ]; then
    echo ""
    echo "📤 Pushing image to registry..."
    docker push "$IMAGE_NAME:$TAG"
    echo "✅ Image pushed successfully!"
fi

echo ""
echo "🎯 Run the container:"
echo "   docker run -p 9020:9020 --rm --name wt-app $IMAGE_NAME:$TAG"
echo ""
