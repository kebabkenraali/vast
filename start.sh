#!/bin/bash
# Odota käynnistystä
sleep 10
# Päivitä järjestelmä
apt update -y
apt install -y git python3-venv python3-pip psmisc # psmisc fuser:ia varten
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
# Asenna custom nodeja (pidetään toistaiseksi, mutta ilman malleja; jos ongelmia, kommentoi pois)
mkdir -p custom_nodes # Varmista hakemisto
cd custom_nodes
if [ ! -d "ComfyUI-Manager" ]; then
  git clone https://github.com/ltdrdata/ComfyUI-Manager
fi
if [ ! -d "ComfyUI-WanVideoWrapper" ]; then
  git clone https://github.com/kijai/ComfyUI-WanVideoWrapper
fi
if [ ! -d "ComfyUI-VideoHelperSuite" ]; then
  git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite
fi
if [ ! -d "ComfyUI-Frame-Interpolation" ]; then
  git clone https://github.com/Fannovel16/ComfyUI-Frame-Interpolation
fi
if [ ! -d "comfyui-reactor-node" ]; then
  git clone https://github.com/Gourieff/comfyui-reactor-node
fi
cd ..
# Tapa portti, jos käytössä
fuser -k 3000/tcp
# Käynnistä ComfyUI
python main.py --listen 0.0.0.0 --port 3000
