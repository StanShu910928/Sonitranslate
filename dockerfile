# Use an official Python runtime as a parent image
FROM python:3.10.12

# Set the working directory in the container
WORKDIR /app

# Install git and git-lfs
RUN apt-get update && apt-get install -y git git-lfs && git lfs install

# Install pip version 23.1.2
RUN python -m pip install --upgrade pip==23.1.2

# Clone the SoniTranslate repository
RUN git clone https://github.com/r3gm/SoniTranslate.git /app/SoniTranslate

# Change directory to the SoniTranslate repository
WORKDIR /app/SoniTranslate

# Uninstall unnecessary packages
RUN pip uninstall chex pandas-stubs ibis-framework albumentations albucore -y -q

# Replace whisperX requirement to use cuda_12_x branch
RUN sed -i 's|git+https://github.com/R3gm/whisperX.git@cuda_11_8|git+https://github.com/R3gm/whisperX.git@cuda_12_x|' requirements_base.txt

# Install base requirements
RUN pip install -r requirements_base.txt

# Install extra requirements
RUN pip install -r requirements_extra.txt

# Install ort-nightly-gpu
RUN pip install ort-nightly-gpu --index-url=https://aiinfra.pkgs.visualstudio.com/PublicPackages/_packaging/ort-cuda-12-nightly/pypi/simple/

# Install TTS dependencies based on flags
ARG INSTALL_PIPER_TTS=True
ARG INSTALL_Coqui_XTTS=True

RUN if [ "$INSTALL_PIPER_TTS" = "True" ]; then pip install piper-tts==1.2.0; fi
RUN if [ "$INSTALL_Coqui_XTTS" = "True" ]; then pip install -r requirements_xtts.txt && pip install TTS==0.21.1 --no-deps; fi

# Set environment variables
ARG YOUR_HF_TOKEN
ENV YOUR_HF_TOKEN=${YOUR_HF_TOKEN}

# Run the web app with the specified parameters
CMD ["python", "app_rvc.py", "--theme", "${theme}", "--verbosity_level", "${verbosity_level}", "--language", "${interface_language}", "--public_url"]

