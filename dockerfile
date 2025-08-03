# Use Python 3.11.5
FROM python:3.11.5

# Set working directory
WORKDIR /app

# Avoid Python bytecode files & enable unbuffered logs
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies needed for librosa, soundfile, etc.
RUN apt-get update && apt-get install -y \
    ffmpeg \
    libsndfile1 \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first (to use Docker cache)
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the project
COPY . .

# Ensure models folder exists (if you plan to mount or pre-download)
RUN mkdir -p models/v1/hi/fastpitch models/v1/hi/hifigan

# Expose Flask port
EXPOSE 5000

# Run Flask app on 0.0.0.0 so Railway can access it
CMD ["python", "app.py"]
