#!/bin/bash

# Wrapper script to run DB Migration Manager in Docker
# Works on Linux, macOS, and Windows (Git Bash/WSL)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IMAGE_NAME="database-migration-manager"
CONTAINER_NAME="database-migration-manager"

# Load utility functions
source "$SCRIPT_DIR/lib/log.lib.sh"

log_header "DB Migration Manager - Docker Mode"
echo ""

# Check if Docker is installed
if ! check_docker; then
    echo "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop"
    exit 1
fi

# Check if image exists, if not build it
if ! docker_image_exists "$IMAGE_NAME"; then
    log_info "Building Docker image (first time only)..."
    docker build -t "$IMAGE_NAME" "$SCRIPT_DIR"
    if [ $? -eq 0 ]; then
        log_success "Image built successfully!"
    else
        log_error "Failed to build image"
        exit 1
    fi
else
    log_success "Docker image found"
fi

log_info "Starting DB Migration Manager..."
echo ""

# Create dumps directory if it doesn't exist
ensure_dir "$SCRIPT_DIR/dumps"

# Detect OS and set Docker socket path
DOCKER_SOCKET="/var/run/docker.sock"
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    # Windows (Git Bash)
    DOCKER_SOCKET="//var/run/docker.sock"
    log_warning "Windows detected: Docker socket mount may not work in all environments"
fi

# Run the container with:
# - Interactive terminal with UTF-8 support
# - Docker socket mounted (for Docker-in-Docker)
# - Config volume for persistent configuration
# - Dumps volume for database files
# - Auto-remove after exit
docker run -it --rm \
    --name "$CONTAINER_NAME" \
    -e LANG=C.UTF-8 \
    -e LC_ALL=C.UTF-8 \
    -v "$DOCKER_SOCKET:/var/run/docker.sock" \
    -v "$SCRIPT_DIR/.config:/app/.config" \
    -v "$SCRIPT_DIR/dumps:/dumps" \
    --network host \
    "$IMAGE_NAME"

echo ""
log_success "Session ended"
