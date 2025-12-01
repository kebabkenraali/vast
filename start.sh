#!/bin/bash

echo "=== Starting ComfyUI provisioning on vast.ai ==="

# Source ai-dock environment if present
if [ -f /opt/ai-dock/etc/environment.sh ]; then
    source /opt/ai-dock/etc/environment.sh
fi
if [ -f /opt/ai-dock/bin/venv-set.sh ]; then
    source /opt/ai-dock/bin/venv-set.sh comfyui
fi

# Fallback ComfyUI path for vast.ai if env vars missing
if [ -z "$COMFYUI_DIR" ]; then
    export COMFYUI_DIR="/workspace/ComfyUI"
fi

mkdir -p "$COMFYUI_DIR/models"
echo "Using COMFYUI_DIR=$COMFYUI_DIR"

##############################################
# Install SageAttention
##############################################
echo "=== Installing SageAttention ==="
pip install sageattention

##############################################
# Helper function for downloading files
##############################################
download() {
    url="$1"
    outdir="$2"
    mkdir -p "$outdir"
    filename=$(basename "$url" | cut -d'?' -f1)

    if [ -f "$outdir/$filename" ]; then
        echo "[SKIP] $filename already exists"
    else
        echo "[DL] $filename"
        wget -q --show-progress -O "$outdir/$filename" "$url"
    fi
}

##############################################
# ---- Model lists (only from workflow) ----
##############################################

CHECKPOINT_MODELS=(
    "https://huggingface.co/Phr00t/WAN2.2-14B-Rapid-AllInOne/resolve/main/v10/wan2.2-i2v-rapid-aio-v10-nsfw.safetensors"
    "https://huggingface.co/seekart/seed-vr2/resolve/main/seedvr2_ema_3b_fp8_e4m3fn.safetensors"
)

VAE_MODELS=(
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors"
)

CLIP_MODELS=(
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors"
)

TEXT_ENCODERS=(
    "https://huggingface.co/NSFW-API/NSFW-Wan-UMT5-XXL/resolve/main/n_wan_umt5-xxl_fp8_scaled.safetensors"
)

LORA_MODELS=(
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/CineScale/Wan2.1_T2V_14B_CineScale_ntk20_lora_rank16_fp16.safetensors"
)

##############################################
# ---- Download everything ----
##############################################

echo "Downloading checkpoints..."
for m in "${CHECKPOINT_MODELS[@]}"; do
    download "$m" "$COMFYUI_DIR/models/checkpoints"
done

echo "Downloading VAEs..."
for m in "${VAE_MODELS[@]}"; do
    download "$m" "$COMFYUI_DIR/models/vae"
done

echo "Downloading CLIP models..."
for m in "${CLIP_MODELS[@]}"; do
    download "$m" "$COMFYUI_DIR/models/clip_vision"
done

echo "Downloading text encoders..."
for m in "${TEXT_ENCODERS[@]}"; do
    download "$m" "$COMFYUI_DIR/models/clip"
done

echo "Downloading LoRAs..."
for m in "${LORA_MODELS[@]}"; do
    download "$m" "$COMFYUI_DIR/models/loras"
done

##############################################
# Install custom ComfyUI nodes (only required for this workflow)
##############################################

echo "=== Installing custom nodes ==="
cd "$COMFYUI_DIR/custom_nodes"

NODES=(
    "https://github.com/cubiq/ComfyUI_essentials"
    "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite"
    "https://github.com/kijai/ComfyUI-WanVideoWrapper"
    "https://github.com/chrisgoringe/cg-use-everywhere"
    "https://github.com/chflame163/ComfyUI_LayerStyle"
    "https://github.com/jamesWalker55/comfyui-various"
    "https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes"
    "https://github.com/numz/ComfyUI-SeedVR2_VideoUpscaler"
    "https://github.com/kijai/ComfyUI-KJNodes"
    "https://github.com/ltdrdata/ComfyUI-Impact-Pack"
)

for repo in "${NODES[@]}"; do
    dir=$(basename "$repo" .git)
    if [ ! -d "$dir" ]; then
        echo "[GIT] Cloning $repo"
        git clone "$repo"
    else
        echo "[GIT] Updating $dir"
        cd "$dir"
        git pull
        cd ..
    fi
    
    if [ -f "$dir/requirements.txt" ]; then
        echo "Installing requirements for $dir"
        pip install -r "$dir/requirements.txt"
    fi
    
    if [ -f "$dir/install.py" ]; then
        echo "Running install.py for $dir"
        python "$dir/install.py"
    fi
done

echo "=== Provisioning complete ==="
