# Use Python 3.11.5
FROM python:3.11.5

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    libsndfile1 \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install gdown for Google Drive downloads
RUN pip install --no-cache-dir gdown

# Copy requirements first
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY . .

# Create target folders
RUN mkdir -p models/v1/hi/fastpitch && \
    mkdir -p models/v1/hi/hifigan

# Build argument for controlling model download (default: true) gautam please change it , if not testing
ARG DOWNLOAD_MODELS=true
ENV DOWNLOAD_MODELS=${DOWNLOAD_MODELS}

# Conditionally download models
RUN if [ "$DOWNLOAD_MODELS" = "true" ]; then \
    echo "📥 Downloading FastPitch models..." && \
    gdown --folder https://drive.google.com/drive/folders/1ZKBX16Q_ZjIt7F-Iy41Pmot8LdJc801P -O models/v1/hi/fastpitch && \
    echo "✅ FastPitch models downloaded:" && \
    ls -lh models/v1/hi/fastpitch && \
    echo "📥 Downloading HiFiGAN models..." && \
    gdown --folder https://drive.google.com/drive/folders/1TA1lQdD96a05FwpGfghJwWwZ-clu8SN0 -O models/v1/hi/hifigan && \
    echo "✅ HiFiGAN models downloaded:" && \
    ls -lh models/v1/hi/hifigan; \
    else \
    echo "⚠️ Skipping model download (DOWNLOAD_MODELS=$DOWNLOAD_MODELS)"; \
    fi

# Expose Flask port
EXPOSE 5000

# Start Flask app
CMD ["python", "app.py"]
