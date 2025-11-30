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
# ---- Model lists ----
##############################################

CHECKPOINT_MODELS=(
    "https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.ckpt"
    "https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors"
    "https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors"

    # Your added WAN 2.2 checkpoints
    "https://huggingface.co/Phr00t/WAN2.2-14B-Rapid-AllInOne/resolve/main/Mega-v3/wan2.2-rapid-mega-nsfw-aio-v3.1.safetensors"
    "https://huggingface.co/Phr00t/WAN2.2-14B-Rapid-AllInOne/resolve/main/v10/wan2.2-i2v-rapid-aio-v10-nsfw.safetensors"
    "https://huggingface.co/Wan-AI/Wan2.2-I2V-A14B/resolve/main/wan2.2_i2v_a14b.safetensors"
)

UNET_MODELS=(
    # WAN 2.1 UNET
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_fun_control_1.3B_bf16.safetensors"
)

VAE_MODELS=(
    "https://huggingface.co/stabilityai/sd-vae-ft-ema-original/resolve/main/vae-ft-ema-560000-ema-pruned.safetensors"
    "https://huggingface.co/stabilityai/sd-vae-ft-mse-original/resolve/main/vae-ft-mse-840000-ema-pruned.safetensors"
    "https://huggingface.co/stabilityai/sdxl-vae/resolve/main/sdxl_vae.safetensors"

    # WAN 2.1 VAE
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors"
)

TEXT_ENCODERS=(
    # WAN 2.1 text encoder
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors"
)

CLIP_MODELS=(
    # WAN 2.1 CLIP vision
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors"
)

LORA_MODELS=(
    "https://huggingface.co/lopi999/Wan2.2-I2V_General-NSFW-LoRA/resolve/main/Wan2.2-I2V_General-NSFW-LoRA.safetensors"
)

CONTROLNET_MODELS=(
    "https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/diffusers_xl_canny_mid.safetensors"
)

ESRGAN_MODELS=(
    "https://huggingface.co/ai-forever/Real-ESRGAN/resolve/main/RealESRGAN_x4.pth"
)

INSIGHTFACE_MODELS=(
    "https://github.com/deepinsight/insightface/releases/download/1.0.0/inswapper_128.onnx"
)

FACEDETECTION_MODELS=(
    "https://github.com/biubug6/Pytorch_Retinaface/releases/download/0.0.1/retinaface_resnet50.onnx"
)

FACERESTORE_MODELS=(
    "https://github.com/TencentARC/GFPGAN/releases/download/v1.3.8/GPEN-BFR-512.onnx"
)

FRAME_INTERPOLATION_MODELS=(
    "https://github.com/hzwer/arXiv2023-RIFE/releases/download/v4.7/rife47.pth"
)

##############################################
# ---- Download everything ----
##############################################

echo "Downloading checkpoints..."
for m in "${CHECKPOINT_MODELS[@]}"; do
    download "$m" "$COMFYUI_DIR/models/checkpoints"
done

echo "Downloading UNETs..."
for m in "${UNET_MODELS[@]}"; do
    download "$m" "$COMFYUI_DIR/models/unet"
done

echo "Downloading VAEs..."
for m in "${VAE_MODELS[@]}"; do
    download "$m" "$COMFYUI_DIR/models/vae"
done

echo "Downloading text encoders..."
for m in "${TEXT_ENCODERS[@]}"; do
    download "$m" "$COMFYUI_DIR/models/text_encoders"
done

echo "Downloading CLIP models..."
for m in "${CLIP_MODELS[@]}"; do
    download "$m" "$COMFYUI_DIR/models/clip_vision"
done

echo "Downloading LoRAs..."
for m in "${LORA_MODELS[@]}"; do
    download "$m" "$COMFYUI_DIR/models/loras"
done

echo "Downloading ControlNet..."
for m in "${CONTROLNET_MODELS[@]}"; do
    download "$m" "$COMFYUI_DIR/models/controlnet"
done

echo "Downloading ESRGAN..."
for m in "${ESRGAN_MODELS[@]}"; do
    download "$m" "$COMFYUI_DIR/models/upscale_models"
done

echo "Downloading InsightFace..."
for m in "${INSIGHTFACE_MODELS[@]}"; do
    download "$m" "$COMFYUI_DIR/models/insightface/models"
done

echo "Downloading face detection..."
for m in "${FACEDETECTION_MODELS[@]}"; do
    download "$m" "$COMFYUI_DIR/models/facedetection"
done

echo "Downloading face restore..."
for m in "${FACERESTORE_MODELS[@]}"; do
    download "$m" "$COMFYUI_DIR/models/facerestore_models"
done

echo "Downloading frame interpolation..."
for m in "${FRAME_INTERPOLATION_MODELS[@]}"; do
    download "$m" "$COMFYUI_DIR/models/frame_interpolation"
done

##############################################
# Install custom ComfyUI nodes
##############################################

echo "=== Installing custom nodes ==="
cd "$COMFYUI_DIR/custom_nodes"

NODES=(
    "https://github.com/ltdrdata/ComfyUI-Manager"
    "https://github.com/cubiq/ComfyUI_essentials"
    "https://github.com/Gourieff/comfyui-reactor-node"
    "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite"
    "https://github.com/Fannovel16/ComfyUI-Frame-Interpolation"
    "https://github.com/kijai/ComfyUI-WanVideoWrapper"
)

for repo in "${NODES[@]}"; do
    dir=$(basename "$repo")
    if [ ! -d "$dir" ]; then
        echo "[GIT] Cloning $repo"
        git clone "$repo"
    else
        echo "[GIT] $dir already exists"
    fi
done

echo "=== Provisioning complete ==="
