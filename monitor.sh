#!/bin/bash

# Path to your setup script
SETUP_SCRIPT="./forge-script/setup.sh"
FORGE_COMMIT_HASH="62cdea8"
# Function to install Foundry if not already installed and run anvil
function install_foundry_and_run_anvil {
    # Always install the specific version of Foundry
    echo "[LOG] Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    rustup update stable
    echo "[LOG] Installing Foundry version with commit $FORGE_COMMIT_HASH..."
    curl -L https://foundry.paradigm.xyz | bash
    source ~/.bashrc
    foundryup --commit $FORGE_COMMIT_HASH

    echo "[LOG] Running forge install..."
    forge install

    echo "[LOG] Starting anvil..."
    anvil &
    ANVIL_PID=$!

    # Wait for Anvil to start
    echo "Waiting for Anvil to start..."
    sleep 1  # Adjust this if necessary

    if ps -p $ANVIL_PID > /dev/null
    then
        echo "Anvil is running. Proceeding with setup..."
    else
        echo "Failed to start Anvil. Exiting."
        exit 1
    fi
}


# Function to check if anvil is running
function is_anvil_running {
    if pgrep -x "anvil" > /dev/null
    then
        return 0
    else
        return 1
    fi
}

# Function to check memory usage of anvil
function check_anvil_memory {
    local pid=$(pgrep -x "anvil")
    echo "[LOG] Anvil PID: $pid"
    if [ -z "$pid" ]; then
        return 1
    fi

    # Get memory usage in kilobytes
    local mem_usage=$(ps -o rss= -p $pid)
    echo "[LOG] Anvil memory usage: $((mem_usage / 1024)) MB"
    # Convert to megabytes and check if it exceeds a threshold (e.g., 500 MB)
    if [ $((mem_usage / 1024)) -gt 30 ]; then
        return 1
    else
        return 0
    fi
}

# Function to restart anvil and run setup.sh
function restart_anvil {
    echo "[LOG] Restarting anvil and running setup.sh..."
    pkill -f "anvil"
    install_foundry_and_run_anvil
    $SETUP_SCRIPT
}

# Main monitoring loop
while true; do
    if ! is_anvil_running || ! check_anvil_memory; then
        restart_anvil
    else
        echo "[LOG] Anvil is running smoothly."
    fi
    sleep 5  # Check every 60 seconds
done
