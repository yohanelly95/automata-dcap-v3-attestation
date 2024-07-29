#!/bin/bash

# Source the .env file to get the deployed addresses
source .env

# Path to the deployed-contract-addresses.txt file
DEPLOYED_ADDRESSES_FILE=".deployed-contract-addresses.txt"

# Check if the deployed addresses file exists
if [ ! -f "$DEPLOYED_ADDRESSES_FILE" ]; then
    echo "Error: $DEPLOYED_ADDRESSES_FILE does not exist. Make sure you've run setup.sh first."
    exit 1
fi

# Extract the DCAP_ATTESTATION_ADDRESS from the deployed addresses file
DCAP_ATTESTATION_ADDRESS=$(grep 'DCAP_ATTESTATION_ADDRESS=' "$DEPLOYED_ADDRESSES_FILE" | cut -d '=' -f 2)


# Check if DCAP_ATTESTATION_ADDRESS is set
if [ -z "$DCAP_ATTESTATION_ADDRESS" ]; then
    echo "Error: DCAP_ATTESTATION_ADDRESS is not set. Make sure you've run setup.sh first."
    exit 1
fi

# Check if a sample quote was provided
if [ -z "$1" ]; then
    echo "Error: No sample quote provided. Usage: ./verify_attestation.sh <sample_quote>"
    exit 1
fi

# Ensure the .deployed-contract-addresses file exists and truncate it to make sure it is empty
touch .output.txt
: > .output.txt

SAMPLE_QUOTE=$1

# Run the cast command
OUTPUT=$(cast call $DCAP_ATTESTATION_ADDRESS "verifyAttestation(bytes)" $SAMPLE_QUOTE --rpc-url $RPC_URL | grep -oE '0x[0-9A-Fa-f]+')
echo "OUTPUT=$OUTPUT"
echo "OUTPUT=$OUTPUT" >> .output.txt