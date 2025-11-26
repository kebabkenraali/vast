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

# Lataa malleja (esim. Wan 2.1, korvaa URL:it)
mkdir -p models/vae models/diffusion_models models/text_encoders models/loras
wget -P models/vae https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors
# Lisää muut wget-komennot edellisestä skriptistäsi

# Tapa portti, jos käytössä
fuser -k 3000/tcp

# Käynnistä ComfyUI
python main.py --listen 0.0.0.0 --port 3000
