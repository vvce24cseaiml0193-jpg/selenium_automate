# Step 1: Build & Compile Stage using JDK 17
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Copy pom.xml and download dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code and compile tests
COPY src ./src
COPY webpage ./webpage
RUN mvn test-compile -B

# Step 2: Execution Stage with Headless Chrome runtime
FROM eclipse-temurin:17-jre-jammy AS runtime
WORKDIR /app

# Install dependencies and Google Chrome for headless execution
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    curl \
    unzip \
    libglib2.0-0 \
    libnss3 \
    libgconf-2-4 \
    libfontconfig1 \
    ca-certificates \
    fonts-liberation \
    && rm -rf /var/lib/apt/lists/* \
    && curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-linux-signing-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-linux-signing-keyring.gpg] http://dl.google.com/linux/chrome/deb/stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# Copy built resources from build stage
COPY --from=build /app /app

ENV CHROME_BIN=/usr/bin/google-chrome-stable

# Command to execute TestNG tests inside container
CMD ["mvn", "test"]