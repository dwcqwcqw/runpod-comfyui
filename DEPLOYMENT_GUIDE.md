# 🚀 RunPod ComfyUI Worker - Fixed Version Deployment Guide

This guide will help you deploy the fixed version of the RunPod ComfyUI worker that resolves the hardcoded connection issue.

## 📋 Overview

**Problem Solved**: The original `runpod/worker-comfyui:5.2.0-base` had a hardcoded `COMFY_HOST = "127.0.0.1:8188"` that ignored all environment variables.

**Solution**: Our fixed version properly supports environment variables for flexible deployment.

## 🛠️ Option 1: Use Pre-built Image (Recommended)

### Step 1: Build and Push to Docker Hub

```bash
# Clone your fixed repository
git clone https://github.com/dwcqwcqw/runpod-comfyui.git
cd runpod-comfyui

# Login to Docker Hub
docker login

# Build and push (modify username in script if needed)
./build-and-push.sh
```

### Step 2: Configure RunPod Serverless

1. **Container Image**: `dwcqwcqw/runpod-comfyui-fixed:latest`

2. **Environment Variables**:
   ```
   COMFYUI_URL=http://0.0.0.0:8188
   COMFYUI_MODEL_PATH=/workspace/comfyui/models
   COMFYUI_WORKFLOWS_PATH=/workspace/comfyui/workflows
   COMFYUI_PORT=8188
   SERVE_API_LOCALLY=true
   COMFYUI_API_HOST=0.0.0.0
   COMFYUI_API_PORT=8188
   COMFYUI_SERVER_ADDRESS=0.0.0.0
   COMFYUI_SERVER_PORT=8188
   COMFYUI_LISTEN=0.0.0.0
   ```

3. **Container Start Command**: `python -u handler.py`

4. **Network Volume**: Your existing volume with models

## 🛠️ Option 2: Use GitHub Container Registry

If you prefer using GitHub Container Registry:

```bash
# Build and tag for GitHub
docker build -t ghcr.io/dwcqwcqw/runpod-comfyui-fixed:latest .

# Login to GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u dwcqwcqw --password-stdin

# Push to GitHub
docker push ghcr.io/dwcqwcqw/runpod-comfyui-fixed:latest
```

Then use `ghcr.io/dwcqwcqw/runpod-comfyui-fixed:latest` as your container image.

## ✅ Verification

After deployment, check the logs for this message:
```
worker-comfyui - Using ComfyUI host: 0.0.0.0:8188
```

This confirms that the environment variable is being properly respected!

## 🧪 Testing

Create a test script to verify the fix:

```python
import requests
import json

# Your RunPod API configuration
RUNPOD_API_KEY = "your_api_key"
ENDPOINT_ID = "your_endpoint_id"

# Simple test workflow
test_workflow = {
    "4": {
        "inputs": {"ckpt_name": "PhotonicFusion_SDXL_V3.safetensors"},
        "class_type": "CheckpointLoaderSimple"
    },
    "5": {
        "inputs": {"width": 512, "height": 512, "batch_size": 1},
        "class_type": "EmptyLatentImage"
    },
    "6": {
        "inputs": {"text": "a beautiful landscape", "clip": ["4", 1]},
        "class_type": "CLIPTextEncode"
    },
    "7": {
        "inputs": {"text": "", "clip": ["4", 1]},
        "class_type": "CLIPTextEncode"
    },
    "3": {
        "inputs": {
            "seed": 42, "steps": 20, "cfg": 7.0,
            "sampler_name": "euler", "scheduler": "normal", "denoise": 1.0,
            "model": ["4", 0], "positive": ["6", 0], "negative": ["7", 0], "latent_image": ["5", 0]
        },
        "class_type": "KSampler"
    },
    "8": {
        "inputs": {"samples": ["3", 0], "vae": ["4", 2]},
        "class_type": "VAEDecode"
    },
    "9": {
        "inputs": {"images": ["8", 0]},
        "class_type": "SaveImage"
    }
}

# Submit job
response = requests.post(
    f"https://api.runpod.ai/v2/{ENDPOINT_ID}/runsync",
    headers={
        "Authorization": f"Bearer {RUNPOD_API_KEY}",
        "Content-Type": "application/json"
    },
    json={"input": {"workflow": test_workflow}},
    timeout=300
)

print(f"Status: {response.status_code}")
print(f"Response: {response.json()}")
```

## 🔧 What Was Fixed

### Before (Broken):
```python
# Host where ComfyUI is running
COMFY_HOST = "127.0.0.1:8188"  # HARDCODED!
```

### After (Fixed):
```python
# Host where ComfyUI is running
# Support environment variables for flexible deployment
COMFYUI_URL = os.environ.get("COMFYUI_URL", "http://127.0.0.1:8188")
COMFYUI_HOST = os.environ.get("COMFYUI_HOST", "127.0.0.1:8188")

# Parse COMFYUI_URL if provided, otherwise use COMFYUI_HOST
if COMFYUI_URL != "http://127.0.0.1:8188":
    from urllib.parse import urlparse
    parsed = urlparse(COMFYUI_URL)
    COMFY_HOST = f"{parsed.hostname}:{parsed.port}"
else:
    COMFY_HOST = COMFYUI_HOST

print(f"worker-comfyui - Using ComfyUI host: {COMFY_HOST}")
```

## 🎯 Expected Results

With the fixed version:
- ✅ Jobs will progress from IN_QUEUE → IN_PROGRESS → COMPLETED
- ✅ No more "127.0.0.1:8188 not reachable" errors
- ✅ Environment variables are properly respected
- ✅ ComfyUI server connection works correctly

## 🆘 Troubleshooting

If you still encounter issues:

1. **Check the logs** for the connection message
2. **Verify environment variables** are set correctly
3. **Ensure your models** exist in the Network Volume
4. **Test with a simple workflow** first

## 📞 Support

- **GitHub Repository**: https://github.com/dwcqwcqw/runpod-comfyui
- **Original Issue**: Hardcoded COMFY_HOST ignoring environment variables
- **Status**: ✅ Fixed and tested

---

**Happy deploying! 🎉** 