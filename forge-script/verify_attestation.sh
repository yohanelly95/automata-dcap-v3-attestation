#!/bin/bash

# Source the .env file to get the deployed addresses
source .env

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

SAMPLE_QUOTE=$1

# Run the cast command
cast call $DCAP_ATTESTATION_ADDRESS "verifyAttestation(bytes)" $SAMPLE_QUOTE --rpc-url $RPC_URL 