#!/bin/bash

# Odota käynnistystä
sleep 10

# Päivitä järjestelmä
apt update -y
apt install -y git python3-venv python3-pip psmisc  # psmisc fuser:ia varten

# Kloonaa ComfyUI, jos ei ole
if [ ! -d "/workspace/ComfyUI" ]; then
  cd /workspace
  git clone https://github.com/comfyanonymous/ComfyUI
fi

# Luo ja aktivoi venv
cd /workspace/ComfyUI
if [ ! -d "venv" ]; then
  python3 -m venv venv
fi
source venv/bin/activate

# Asenna riippuvuudet (CUDA 12.1)
pip install --upgrade pip
pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu121
pip install -r requirements.txt

# Asenna custom nodeja
cd custom_nodes
git clone https://github.com/ltdrdata/ComfyUI-Manager
git clone https://github.com/kijai/ComfyUI-WanVideoWrapper
git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite
git clone https://github.com/Fannovel16/ComfyUI-Frame-Interpolation
git clone https://github.com/Gourieff/comfyui-reactor-node
cd ..

#############################################
# 📌 Mallit FaceSwap / Detection / Restore / RIFE
#############################################

# Luo mallihakemistot
mkdir -p models/insightface/models
mkdir -p models/facedetection
mkdir -p models/facerestore_models
mkdir -p models/frame_interpolation

# FaceSwap
wget -O models/insightface/models/inswapper_128.onnx \
  https://github.com/deepinsight/insightface/releases/download/1.0.0/inswapper_128.onnx

# Detection
wget -O models/facedetection/retinaface_resnet50.onnx \
  https://github.com/biubug6/Pytorch_Retinaface/releases/download/0.0.1/retinaface_resnet50.onnx

# Restoration
wget -O models/facerestore_models/GPEN-BFR-512.onnx \
  https://github.com/TencentARC/GFPGAN/releases/download/v1.3.8/GPEN-BFR-512.onnx

# RIFE Interpolation
wget -O models/frame_interpolation/rife47.pth \
  https://github.com/hzwer/arXiv2023-RIFE/releases/download/v4.7/rife47.pth

#############################################
# 📌 WAN 2.2 ja 2.1 mallit
#############################################

mkdir -p models/vae models/diffusion_models models/text_encoders models/loras

# WAN 2.2 diffusion models
wget -P models/diffusion_models \
  https://huggingface.co/Phr00t/WAN2.2-14B-Rapid-AllInOne/resolve/main/Mega-v3/wan2.2-rapid-mega-nsfw-aio-v3.1.safetensors

#wget -P models/diffusion_models \
 # https://huggingface.co/Phr00t/WAN2.2-14B-Rapid-AllInOne/resolve/main/v10/wan2.2-i2v-rapid-aio-v10-nsfw.safetensors

#wget -P models/diffusion_models \
 # https://huggingface.co/Wan-AI/Wan2.2-I2V-A14B/resolve/main/wan2.2_i2v_a14b.safetensors

# WAN 2.2 LoRA
wget -P models/loras \
  https://huggingface.co/lopi999/Wan2.2-I2V_General-NSFW-LoRA/resolve/main/Wan2.2-I2V_General-NSFW-LoRA.safetensors

# WAN 2.1 VAE
#wget -P models/vae \
  https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors

# WAN 2.1 text encoder
#wget -P models/text_encoders \
  https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors

#############################################

# Tapa portti, jos käytössä
fuser -k 3000/tcp

# Käynnistä ComfyUI
python main.py --listen 0.0.0.0 --port 3000
