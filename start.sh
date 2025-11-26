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

# Asenna riippuvuudet (CUDA 12.1 esimerkkinä)
pip install --upgrade pip
pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu121
pip install -r requirements.txt

# Asenna custom nodeja (esim. Manager ja WanVideoWrapper)
cd custom_nodes
git clone https://github.com/ltdrdata/ComfyUI-Manager
git clone https://github.com/kijai/ComfyUI-WanVideoWrapper
git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite  # Videotuki
cd ..

# Lataa Wan 2.2 NSFW-mallit (perusversiot ilman tunnistautumista Hugging Facesta)
mkdir -p models/vae models/diffusion_models models/text_encoders models/loras
wget -P models/diffusion_models https://huggingface.co/Phr00t/WAN2.2-14B-Rapid-AllInOne/resolve/main/Mega-v3/wan2.2-rapid-mega-nsfw-aio-v3.1.safetensors
wget -P models/diffusion_models https://huggingface.co/Phr00t/WAN2.2-14B-Rapid-AllInOne/resolve/main/v10/wan2.2-i2v-rapid-aio-v10-nsfw.safetensors
wget -P models/loras https://huggingface.co/lopi999/Wan2.2-I2V_General-NSFW-LoRA/resolve/main/Wan2.2-I2V_General-NSFW-LoRA.safetensors
wget -P models/diffusion_models https://huggingface.co/Wan-AI/Wan2.2-I2V-A14B/resolve/main/wan2.2_i2v_a14b.safetensors
wget -P models/vae https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors  # Sama VAE kuin 2.1, yhteensopiva
wget -P models/text_encoders https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors  # Sama text encoder

# Tapa portti, jos käytössä
fuser -k 3000/tcp

# Käynnistä ComfyUI
python main.py --listen 0.0.0.0 --port 3000
