#!/bin/bash

source .env

DEPLOY_SCRIPT="DeployDCAPScript"
CONFIGURE_SCRIPT="ConfigureDcapAttestationScript"
FORGE_COMMAND_SUFFIX="--broadcast --rpc-url $RPC_URL"

# STARTING_LINE=6
# Start Anvil in the background with the specified RPC URL
anvil &

# Get the PID of the Anvil process
ANVIL_PID=$!

# Wait for Anvil to start
echo "Waiting for Anvil to start..."
sleep 5  # Adjust this if necessary

if ps -p $ANVIL_PID > /dev/null
then
   echo "Anvil is running. Proceeding with setup..."
else
   echo "Failed to start Anvil. Exiting."
   exit 1
fi

# Ensure the .deployed-contract-addresses file exists and truncate it to make sure it is empty
touch .deployed-contract-addresses
: > .deployed-contract-addresses

echo "[LOG] Deploying P256Verifier contract..."
P256_VERIFIER_OUTPUT=$(forge script $DEPLOY_SCRIPT --sig "deployP256Verifier()" $FORGE_COMMAND_SUFFIX | grep LOG)
export P256_VERIFIER_ADDRESS=$(echo $P256_VERIFIER_OUTPUT | grep -oE '0x[0-9A-Fa-f]+')
echo "P256_VERIFIER_ADDRESS=$P256_VERIFIER_ADDRESS" >> .deployed-contract-addresses
echo $P256_VERIFIER_OUTPUT

echo "[LOG] Deploying SigVerifyLib..."
SIGVERIFY_LIB_OUTPUT=$(forge script $DEPLOY_SCRIPT --sig "deploySigVerifyLib()" $FORGE_COMMAND_SUFFIX | grep LOG)
export SIGVERIFY_LIB_ADDRESS=$(echo $SIGVERIFY_LIB_OUTPUT | grep -oE '0x[0-9A-Fa-f]+')
echo "SIGVERIFY_LIB_ADDRESS=$SIGVERIFY_LIB_ADDRESS" >> .deployed-contract-addresses
# sed -i "" "${STARTING_LINE}i\\$SIGVERIFY_LIB_ADDRESS" .env
echo $SIGVERIFY_LIB_OUTPUT

echo "[LOG] Deploying PEMCertChainLib..."
PEMCERT_LIB_OUTPUT=$(forge script $DEPLOY_SCRIPT --sig "deployPemCertLib()" $FORGE_COMMAND_SUFFIX | grep LOG)
export PEMCERT_LIB_ADDRESS=$(echo $PEMCERT_LIB_OUTPUT | grep -oE '0x[0-9A-Fa-f]+')
echo "PEMCERT_LIB_ADDRESS=$PEMCERT_LIB_ADDRESS" >> .deployed-contract-addresses
echo $PEMCERT_LIB_OUTPUT

echo "[LOG] Deploying AutomataDcapV3Attestation..."
DCAP_ATTESTATION_OUTPUT=$(forge script $DEPLOY_SCRIPT --sig "deployAttestation()" $FORGE_COMMAND_SUFFIX | grep LOG)
export DCAP_ATTESTATION_ADDRESS=$(echo $DCAP_ATTESTATION_OUTPUT | grep -oE '0x[0-9A-Fa-f]+')
echo "DCAP_ATTESTATION_ADDRESS=$DCAP_ATTESTATION_ADDRESS" >> .deployed-contract-addresses
echo $DCAP_ATTESTATION_OUTPUT

echo "[LOG] Contract Deployment is complete. Setting up the attestation contract..."

echo "[LOG] Configuring TCBInfo..."
TCB_INFO_OUTPUT=$(forge script $CONFIGURE_SCRIPT --sig "configureTcb(string)" "" $FORGE_COMMAND_SUFFIX | grep Hash)
echo $TCB_INFO_OUTPUT

echo "[LOG] Configuring QeIdentity..."
QE_ID_OUTPUT=$(forge script $CONFIGURE_SCRIPT --sig "configureQeIdentity(string)" "" $FORGE_COMMAND_SUFFIX | grep Hash)
echo $QE_ID_OUTPUT

echo "[LOG] Adding revoked PCK serial numbers from the provided CRL..."
CRL_OUTPUT=$(forge script $CONFIGURE_SCRIPT --sig "configureCrl(uint256)" 0 $FORGE_COMMAND_SUFFIX | grep Hash)
echo $CRL_OUTPUT

# # Check if DCAP_ATTESTATION_ADDRESS is set
# if [ -z "$DCAP_ATTESTATION_ADDRESS" ]; then
#     echo "Error: DCAP_ATTESTATION_ADDRESS is not set. Make sure you've run setup.sh first."
#     exit 1
# fi

# Check if a sample quote was provided
if [ -z "$1" ]; then
    echo "Error: No sample quote provided. Usage: ./verify_attestation.sh <sample_quote>"
    exit 1
fi

SAMPLE_QUOTE=$1

# Run the cast command
cast call $DCAP_ATTESTATION_ADDRESS "verifyAttestation(bytes)" $SAMPLE_QUOTE --rpc-url $RPC_URL 

kill $ANVIL_PID
    echo "Anvil stopped."