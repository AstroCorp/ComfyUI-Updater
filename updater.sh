#!/bin/bash

COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_BLUE='\033[0;34m'
COLOR_DEFAULT='\033[0m'

read -p "Target version: " COMFYUI_VERSION
read -p "Current ComfyUI path (example: C:/Users/user/Documents/ComfyUI_windows_portable): " COMFYUI_PATH

# Validate version (not empty or only spaces)
if [[ -z "${COMFYUI_VERSION// }" ]]; then
	echo "Error: You must specify a target version."
	exit
fi

# Validate version format (X.X.X)
if ! [[ "$COMFYUI_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
	echo "Error: Target version must be in format X.X.X (e.g. 1.2.3)."
	exit
fi

DOWNLOAD_URL="https://github.com/comfyanonymous/ComfyUI/releases/download/v$COMFYUI_VERSION/ComfyUI_windows_portable_nvidia.7z"

# Validate path (not empty or only spaces)
if [[ -z "${COMFYUI_PATH// }" ]]; then
	echo "Error: ComfyUI path cannot be empty or only spaces."
	exit
fi

# Check required directories
DIRS=("ComfyUI" "python_embeded" "update")

for dir in "${DIRS[@]}"; do
	if [ ! -d "$COMFYUI_PATH/$dir" ]; then
		echo "Error: Directory '$dir' not found in '$COMFYUI_PATH'."
		exit
	fi
done

# Check required files
FILES=("run_cpu.bat" "run_nvidia_gpu.bat")

for file in "${FILES[@]}"; do
	if [ ! -f "$COMFYUI_PATH/$file" ]; then
		echo "Error: File '$file' not found in $COMFYUI_PATH."
		exit
	fi
done

# Create 'updating' directory
UPDATING_PATH="$COMFYUI_PATH/updating"
rm -rf "$UPDATING_PATH"
mkdir -p "$UPDATING_PATH"

# Download the file to the 'updating' directory
DOWNLOAD_FILE="$UPDATING_PATH/ComfyUI_windows_portable_nvidia.7z"
echo "Downloading to $DOWNLOAD_FILE..."
curl -L "$DOWNLOAD_URL" -o "$DOWNLOAD_FILE"

# Extract the file to the 'updating' directory
echo "Extracting..."
7z x "$DOWNLOAD_FILE" -o"$UPDATING_PATH"

# Move directories from ../ComfyUI/models to ../updating/ComfyUI_windows_portable/ComfyUI/models
MODELS_DIRS=("checkpoints" "controlnet" "inpaint" "loras" "upscale_models")

for model_dir in "${MODELS_DIRS[@]}"; do
	if [ -d "$COMFYUI_PATH/ComfyUI/models/$model_dir" ]; then
		echo "Preparing to move $model_dir..."
 		rm -rf "$UPDATING_PATH/ComfyUI_windows_portable/ComfyUI/models/$model_dir"

		echo "Moving $model_dir..."
 		mv "$COMFYUI_PATH/ComfyUI/models/$model_dir" "$UPDATING_PATH/ComfyUI_windows_portable/ComfyUI/models/"
	fi
done

# Move content from ../ComfyUI/output to ../updating/ComfyUI_windows_portable/ComfyUI/output
if [ -d "$COMFYUI_PATH/ComfyUI/output" ]; then
	echo "Moving output..."
 	mv "$COMFYUI_PATH/ComfyUI/output/"* "$UPDATING_PATH/ComfyUI_windows_portable/ComfyUI/output/"
fi

# Setup ComfyUI-Manager
echo "Cloning ComfyUI-Manager into custom_nodes..."
git clone https://github.com/ltdrdata/ComfyUI-Manager "$UPDATING_PATH/ComfyUI_windows_portable/ComfyUI/custom_nodes/comfyui-manager"
