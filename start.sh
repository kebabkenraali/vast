#!/bin/bash

# ---- Default ComfyUI provisioning ----
source /opt/ai-dock/etc/environment.sh
source /opt/ai-dock/bin/venv-set.sh comfyui

# Default packages and nodes
APT_PACKAGES=( 
    #"package-1"
    #"package-2"
)
PIP_PACKAGES=(
    #"package-1"
    #"package-2"
)
NODES=(
    "https://github.com/ltdrdata/ComfyUI-Manager"
    "https://github.com/cubiq/ComfyUI_essentials"
)

CHECKPOINT_MODELS=(
    "https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.ckpt"
    "https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors"
    "https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors"
)
UNET_MODELS=()
LORA_MODELS=()
VAE_MODELS=(
    "https://huggingface.co/stabilityai/sd-vae-ft-ema-original/resolve/main/vae-ft-ema-560000-ema-pruned.safetensors"
    "https://huggingface.co/stabilityai/sd-vae-ft-mse-original/resolve/main/vae-ft-mse-840000-ema-pruned.safetensors"
    "https://huggingface.co/stabilityai/sdxl-vae/resolve/main/sdxl_vae.safetensors"
)
ESRGAN_MODELS=(
    "https://huggingface.co/ai-forever/Real-ESRGAN/resolve/main/RealESRGAN_x4.pth"
)
CONTROLNET_MODELS=(
    "https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/diffusers_xl_canny_mid.safetensors"
)

# ---- Append your custom nodes/models/packages ----
APT_PACKAGES+=(
    #"package-1"
    #"package-2"
)
PIP_PACKAGES+=(
    #"package-1"
    #"package-2"
)

NODES+=(
    "https://github.com/Gourieff/comfyui-reactor-node"
    "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite"
    "https://github.com/Fannovel16/ComfyUI-Frame-Interpolation"
    "https://github.com/kijai/ComfyUI-WanVideoWrapper"
)

CHECKPOINT_MODELS+=(
    "https://huggingface.co/Phr00t/WAN2.2-14B-Rapid-AllInOne/resolve/main/Mega-v3/wan2.2-rapid-mega-nsfw-aio-v3.1.safetensors"
    "https://huggingface.co/Phr00t/WAN2.2-14B-Rapid-AllInOne/resolve/main/v10/wan2.2-i2v-rapid-aio-v10-nsfw.safetensors"
    "https://huggingface.co/Wan-AI/Wan2.2-I2V-A14B/resolve/main/wan2.2_i2v_a14b.safetensors"
)

LORA_MODELS+=(
    "https://huggingface.co/lopi999/Wan2.2-I2V_General-NSFW-LoRA/resolve/main/Wan2.2-I2V_General-NSFW-LoRA.safetensors"
)

VAE_MODELS+=(
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors"
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

TEXT_ENCODERS=(
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors"
)

### ---- Start provisioning ----
function provisioning_start() {
    # Default provisioning start
    default_provisioning_start

    # Custom directories for additional models
    mkdir -p "${COMFYUI_DIR}/models/insightface/models"
    provisioning_get_files "${COMFYUI_DIR}/models/insightface/models" "${INSIGHTFACE_MODELS[@]}"

    mkdir -p "${COMFYUI_DIR}/models/facedetection"
    provisioning_get_files "${COMFYUI_DIR}/models/facedetection" "${FACEDETECTION_MODELS[@]}"

    mkdir -p "${COMFYUI_DIR}/models/facerestore_models"
    provisioning_get_files "${COMFYUI_DIR}/models/facerestore_models" "${FACERESTORE_MODELS[@]}"

    mkdir -p "${COMFYUI_DIR}/models/frame_interpolation"
    provisioning_get_files "${COMFYUI_DIR}/models/frame_interpolation" "${FRAME_INTERPOLATION_MODELS[@]}"

    mkdir -p "${COMFYUI_DIR}/models/text_encoders"
    provisioning_get_files "${COMFYUI_DIR}/models/text_encoders" "${TEXT_ENCODERS[@]}"
}

# Run provisioning
if [[ ! -f /.noprovisioning ]]; then
    provisioning_start
fi
