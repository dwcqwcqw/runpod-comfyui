#!/bin/bash

# Build and Push Script for Fixed RunPod ComfyUI Worker
# =====================================================

set -e

# Configuration
DOCKER_USERNAME="dwcqwcqw"  # Change this to your Docker Hub username
IMAGE_NAME="runpod-comfyui-fixed"
VERSION="5.2.0-fixed"

echo "🐳 Building Docker image..."
echo "Image: ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}"
echo "========================================"

# Build the image
docker build -t ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION} .
docker tag ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION} ${DOCKER_USERNAME}/${IMAGE_NAME}:latest

echo "✅ Build completed successfully!"
echo ""
echo "🚀 Pushing to Docker Hub..."
echo "========================================"

# Push to Docker Hub
docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}
docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:latest

echo "✅ Push completed successfully!"
echo ""
echo "📋 Usage Instructions:"
echo "========================================"
echo "1. Use this image in RunPod: ${DOCKER_USERNAME}/${IMAGE_NAME}:latest"
echo "2. Set environment variable: COMFYUI_URL=http://0.0.0.0:8188"
echo "3. Container Start Command: python -u handler.py"
echo ""
echo "🔍 The handler will now print: 'worker-comfyui - Using ComfyUI host: 0.0.0.0:8188'"
echo "This confirms the environment variable is being respected!" 