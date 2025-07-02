#!/bin/bash

# Fix and Start Script for RunPod ComfyUI Worker
# ==============================================
# This script dynamically fixes the hardcoded COMFY_HOST issue at runtime

echo "🔧 RunPod ComfyUI Worker - Dynamic Fix"
echo "======================================"

# Find the handler.py file
HANDLER_PATH=""
for path in "/handler.py" "/app/handler.py" "/workspace/handler.py" "/comfyui/handler.py"; do
    if [ -f "$path" ]; then
        HANDLER_PATH="$path"
        echo "✅ Found handler.py at: $HANDLER_PATH"
        break
    fi
done

if [ -z "$HANDLER_PATH" ]; then
    echo "❌ handler.py not found! Checking all locations..."
    find / -name "handler.py" -type f 2>/dev/null | head -5
    echo "Continuing with original startup..."
    exec python -u handler.py
    exit 1
fi

# Backup original handler.py
cp "$HANDLER_PATH" "${HANDLER_PATH}.backup"
echo "💾 Backed up original handler.py"

# Apply the fix
echo "🛠️  Applying dynamic fix..."

# Create the fixed version
cat > "${HANDLER_PATH}.tmp" << 'EOF'
import os
import sys

# Read the original handler.py
with open(sys.argv[1] + '.backup', 'r') as f:
    content = f.read()

# Apply the fix
original_line = 'COMFY_HOST = "127.0.0.1:8188"'
fixed_code = '''# Support environment variables for flexible deployment
COMFYUI_URL = os.environ.get("COMFYUI_URL", "http://127.0.0.1:8188")
COMFYUI_HOST = os.environ.get("COMFYUI_HOST", "127.0.0.1:8188")

# Parse COMFYUI_URL if provided, otherwise use COMFYUI_HOST
if COMFYUI_URL != "http://127.0.0.1:8188":
    from urllib.parse import urlparse
    parsed = urlparse(COMFYUI_URL)
    COMFY_HOST = f"{parsed.hostname}:{parsed.port}"
else:
    COMFY_HOST = COMFYUI_HOST

print(f"worker-comfyui - Using ComfyUI host: {COMFY_HOST}")'''

if original_line in content:
    content = content.replace(original_line, fixed_code)
    print("✅ Applied hardcoded COMFY_HOST fix")
else:
    print("⚠️  Original hardcoded line not found, handler may already be fixed")

# Write the fixed content
with open(sys.argv[1], 'w') as f:
    f.write(content)

print("🎯 Handler.py has been dynamically fixed!")
EOF

# Run the fix script
python "${HANDLER_PATH}.tmp" "$HANDLER_PATH"

# Clean up temp file
rm "${HANDLER_PATH}.tmp"

# Show the environment variables being used
echo ""
echo "🌍 Environment Variables:"
echo "COMFYUI_URL: ${COMFYUI_URL:-not set}"
echo "COMFYUI_HOST: ${COMFYUI_HOST:-not set}"
echo ""

# Start the fixed handler
echo "🚀 Starting fixed handler..."
exec python -u "$HANDLER_PATH" 