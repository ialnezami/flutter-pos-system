# Use the official Flutter image as base
FROM ghcr.io/cirruslabs/flutter:stable

# Set working directory
WORKDIR /app

# Install additional dependencies for web development
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Enable Flutter web
RUN flutter config --enable-web

# Copy pubspec files first for better Docker layer caching
COPY pubspec.yaml pubspec.lock ./

# Get dependencies
RUN flutter pub get

# Copy the rest of the application code
COPY . .

# Build the web app
RUN flutter build web --release

# Expose port 8080
EXPOSE 8080

# Start a simple HTTP server to serve the web app
CMD ["python3", "-m", "http.server", "8080", "--directory", "build/web"]
