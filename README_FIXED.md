# RunPod ComfyUI Worker - Fixed Version

This is a fixed version of the official [runpod-workers/worker-comfyui](https://github.com/runpod-workers/worker-comfyui) that resolves the hardcoded connection issue.

## 🐛 Bug Fixed

**Problem**: The original `handler.py` had a hardcoded `COMFY_HOST = "127.0.0.1:8188"` that ignored all environment variables.

**Solution**: Modified `handler.py` to properly support environment variables:

### Environment Variables Supported

- `COMFYUI_URL`: Full URL to ComfyUI server (e.g., `http://0.0.0.0:8188`)
- `COMFYUI_HOST`: Host and port for ComfyUI (e.g., `0.0.0.0:8188`)

### Priority Order

1. If `COMFYUI_URL` is set and not default, parse hostname:port from URL
2. Otherwise, use `COMFYUI_HOST` 
3. Fallback to `127.0.0.1:8188` if neither is set

## 🔧 Changes Made

**File**: `handler.py` (lines 37-49)

**Before**:
```python
# Host where ComfyUI is running
COMFY_HOST = "127.0.0.1:8188"
```

**After**:
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

## 🚀 Usage with RunPod

### Environment Variables for RunPod Serverless:

```bash
COMFYUI_URL=http://0.0.0.0:8188
```

Or alternatively:

```bash
COMFYUI_HOST=0.0.0.0:8188
```

### Container Start Command:

```bash
python -u handler.py
```

## 📦 Building Custom Docker Image

```bash
# Build the image
docker build -t your-username/runpod-comfyui-fixed:latest .

# Push to Docker Hub
docker push your-username/runpod-comfyui-fixed:latest
```

## ✅ Verification

The handler will now print the actual host being used:
```
worker-comfyui - Using ComfyUI host: 0.0.0.0:8188
```

This confirms that environment variables are being properly respected.

---

**Original Repository**: https://github.com/runpod-workers/worker-comfyui  
**Fixed By**: dwcqwcqw  
**Issue**: Hardcoded COMFY_HOST ignoring environment variables  
**Status**: ✅ Fixed 