FROM pytorch/pytorch:2.6.0-cuda12.4-cudnn9-runtime

WORKDIR /app

# First install gnupg
RUN apt-get update || true && \
    apt-get install -y --no-install-recommends gnupg && \
    apt-get clean || true

# Update apt sources with retry
RUN for i in $(seq 1 3); do apt-get update -y && break || sleep 5; done

# Install system dependencies including build essentials for wheel building
RUN apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    python3-dev \
    libasound2-dev \
    libportaudio2 \
    libsndfile1 \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create necessary directories
RUN mkdir -p outputs static

# Expose the default port
EXPOSE 5005

# Set environment variables
ENV PYTHONUNBUFFERED=1

# Run the application
CMD ["python", "app.py"]