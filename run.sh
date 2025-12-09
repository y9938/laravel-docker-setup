#!/bin/bash
set -euo pipefail

# Help
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 {build|load} [source]"
    echo "  build               - Build image and save archive"
    echo "  load [source]       - Load image from:"
    echo "                         (no arg)  - Use archive or build from source"
    echo "                         URL       - download from URL then load"
    echo "                         file      - load from specified file via docker load command"
    echo ""
    echo "Archive location: \${IMAGE_NAME}_\$IMAGE_TAG.tar.gz in current directory"
    exit 0
fi

# Load config
[[ ! -f .env ]] && cp .env.example .env
source .env

# Validate
if [[ -z "${IMAGE_NAME:-}" ]] || [[ -z "${IMAGE_TAG:-}" ]] || [[ -z "${PHP_VERSION:-}" ]]; then
    echo "Error: IMAGE_NAME or IMAGE_TAG or PHP_VERSION not set in .env"
    echo "Please add to .env (check vars in .env.example):"
    echo "PHP_VERSION=8.3-fpm  # Used in Dockerfile"
    echo "IMAGE_NAME=your-image-name"
    echo "IMAGE_TAG=\${PHP_VERSION}  # Or custom tag"
    exit 1
fi

IMAGE="$IMAGE_NAME:$IMAGE_TAG"
TAR_FILE="${IMAGE_NAME}_$IMAGE_TAG.tar.gz"

ACTION="${1:-}"
SOURCE="${2:-}"

case "$ACTION" in
  build)
    docker build -f docker/Dockerfile --build-arg PHP_VERSION=$PHP_VERSION -t "$IMAGE" .
    docker save "$IMAGE" | gzip > "$TAR_FILE"
    ;;
  load)
    if [[ -f "$TAR_FILE" ]]; then
      docker load < "$TAR_FILE"
    elif [[ -n "$SOURCE" ]]; then
      if [[ "$SOURCE" =~ ^https?:// ]]; then
        curl -L "$SOURCE" -o "$TAR_FILE"
        docker load < "$TAR_FILE"
      else
        # Handle local file path
        docker load < "$SOURCE"
      fi
    else
      docker build -f docker/Dockerfile --build-arg PHP_VERSION=$PHP_VERSION -t "$IMAGE" .
    fi
    ;;
  *)
    echo "Error: Unknown action '$ACTION'"
    echo "Usage: $0 {build|load} [source]"
    exit 1
    ;;
esac
