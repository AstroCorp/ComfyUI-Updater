#!/bin/bash

COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_BLUE='\033[0;34m'
COLOR_DEFAULT='\033[0m'

# Stop script on Ctrl+C
trap 'echo -e "${COLOR_RED}\nProcess stopped by user.${COLOR_DEFAULT}"; exit 130' SIGINT

read -p "Target version (example: 0.3.59): " COMFYUI_VERSION
read -p "Current ComfyUI path (example: C:/Users/your_user/Documents/ComfyUI_windows_portable): " COMFYUI_PATH

# Validate version (not empty or only spaces)
if [[ -z "${COMFYUI_VERSION// }" ]]; then
	echo -e "${COLOR_RED}Error: You must specify a target version.${COLOR_DEFAULT}"
	exit
fi

# Validate version format (X.X.X)
if ! [[ "$COMFYUI_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
	echo -e "${COLOR_RED}Error: Target version must be in format X.X.X (e.g. 0.3.59).${COLOR_DEFAULT}"
	exit
fi

DOWNLOAD_URL="https://github.com/comfyanonymous/ComfyUI/releases/download/v$COMFYUI_VERSION/ComfyUI_windows_portable_nvidia.7z"

# Validate path (not empty or only spaces)
if [[ -z "${COMFYUI_PATH// }" ]]; then
	echo -e "${COLOR_RED}Error: ComfyUI path cannot be empty or only spaces.${COLOR_DEFAULT}"
	exit
fi

# Check required directories
DIRS=("ComfyUI" "python_embeded" "update")

for dir in "${DIRS[@]}"; do
	if [ ! -d "$COMFYUI_PATH/$dir" ]; then
		echo -e "${COLOR_RED}Error: Directory '$dir' not found in '$COMFYUI_PATH'.${COLOR_DEFAULT}"
		exit
	fi
done

# Check required files
FILES=("run_cpu.bat" "run_nvidia_gpu.bat")

for file in "${FILES[@]}"; do
	if [ ! -f "$COMFYUI_PATH/$file" ]; then
		echo -e "${COLOR_RED}Error: File '$file' not found in $COMFYUI_PATH.${COLOR_DEFAULT}"
		exit
	fi
done

# Create 'updating' directory
UPDATING_PATH="$COMFYUI_PATH/updating"
COMFY_UPDATING_PATH="$UPDATING_PATH/ComfyUI_windows_portable"

rm -rf "$UPDATING_PATH"
mkdir -p "$UPDATING_PATH"

# Download the file to the 'updating' directory
DOWNLOAD_FILE="$UPDATING_PATH/ComfyUI_windows_portable_nvidia.7z"
echo -e "${COLOR_BLUE}Downloading to $DOWNLOAD_FILE...${COLOR_YELLOW}"
curl -L "$DOWNLOAD_URL" -o "$DOWNLOAD_FILE"

# Extract the file to the 'updating' directory
echo -e "${COLOR_BLUE}Extracting...${COLOR_YELLOW}"
7z x "$DOWNLOAD_FILE" -o"$UPDATING_PATH"

# Move directories from ../ComfyUI/models to ../updating/ComfyUI_windows_portable/ComfyUI/models
MODELS_DIRS=("checkpoints" "controlnet" "inpaint" "loras" "upscale_models")

for model_dir in "${MODELS_DIRS[@]}"; do
	if [ -d "$COMFYUI_PATH/ComfyUI/models/$model_dir" ]; then
		echo -e "${COLOR_BLUE}Preparing to move $model_dir...${COLOR_DEFAULT}"
 		rm -rf "$COMFY_UPDATING_PATH/ComfyUI/models/$model_dir"

		echo -e "${COLOR_BLUE}Moving $model_dir...${COLOR_DEFAULT}"
 		mv "$COMFYUI_PATH/ComfyUI/models/$model_dir" "$COMFY_UPDATING_PATH/ComfyUI/models/"
	else
		echo -e "${COLOR_YELLOW}Directory '$model_dir' does not exist in source. Skipping...${COLOR_DEFAULT}"
	fi
done

# Move content from ../ComfyUI/output to ../updating/ComfyUI_windows_portable/ComfyUI/output
if [ -d "$COMFYUI_PATH/ComfyUI/output" ]; then
	echo -e "${COLOR_BLUE}Moving output...${COLOR_DEFAULT}"
 	mv "$COMFYUI_PATH/ComfyUI/output/"* "$COMFY_UPDATING_PATH/ComfyUI/output/"
fi

# Setup ComfyUI-Manager
echo -e "${COLOR_BLUE}Cloning ComfyUI-Manager into custom_nodes...${COLOR_YELLOW}"
git clone https://github.com/ltdrdata/ComfyUI-Manager "$COMFY_UPDATING_PATH/ComfyUI/custom_nodes/comfyui-manager"

# Remove old files
echo -e "${COLOR_BLUE}Removing old files...${COLOR_DEFAULT}"

for item in "$COMFY_UPDATING_PATH"/*; do
	name=$(basename "$item")
	target="$COMFYUI_PATH/$name"

	if [ -e "$target" ]; then
		echo -e "${COLOR_BLUE}Removing $target...${COLOR_DEFAULT}"
		rm -rf "$target"
	fi

	echo -e "${COLOR_BLUE}Moving $item to $COMFYUI_PATH/...${COLOR_DEFAULT}"
	mv "$item" "$COMFYUI_PATH/"
done

echo -e "${COLOR_BLUE}Removing $UPDATING_PATH...${COLOR_DEFAULT}"
rm -rf "$UPDATING_PATH"

echo -e "${COLOR_GREEN}Update to version $COMFYUI_VERSION completed successfully!${COLOR_DEFAULT}"
