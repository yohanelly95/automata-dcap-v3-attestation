# Use an official Ubuntu base image
FROM ubuntu:latest

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl build-essential pkg-config libssl-dev git

# # Install Rust and Cargo
# RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
# ENV PATH="/root/.cargo/bin:${PATH}"

# Install Foundry
RUN curl -L https://foundry.paradigm.xyz | bash && \
    /bin/bash -c "/root/.foundry/bin/foundryup && /root/.foundry/bin/forge --version"

# Add Foundry binaries to PATH
ENV PATH="/root/.foundry/bin:$PATH"

# Copy the project files into the container
COPY . /usr/src/app
WORKDIR /usr/src/app

# Make the scripts executable
RUN chmod +x monitor.sh forge-script/setup.sh verify_attestation.sh

# Create .env from .env.example
RUN cp .env.example .env

# Run forge build before running monitor.sh
RUN forge build

# Set the entrypoint to the monitor script
ENTRYPOINT ["./monitor.sh"]
