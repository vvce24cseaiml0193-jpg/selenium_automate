# Step 1: Maven build stage to compile tests
FROM maven:3.8.6-openjdk-17-slim AS build
WORKDIR /app

# Copy pom.xml and pre-fetch dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code and compile tests
COPY src ./src
COPY webpage ./webpage
RUN mvn test-compile

# Step 2: Runtime environment with Chromium for headless execution
FROM openjdk:17-slim
WORKDIR /app

# Install stable dependencies and Chromium browser
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    curl \
    unzip \
    libglib2.0-0 \
    libnss3 \
    libgconf-2-4 \
    libfontconfig1 \
    chromium \
    && rm -rf /var/lib/apt/lists/*

# Copy compiled app files from build stage
COPY --from=build /app /app

# Set environment variable targeting Chromium binary
ENV CHROME_BIN=/usr/bin/chromium

# Default command to run TestNG tests
CMD ["mvn", "test"]
