#!/bin/bash

source .env

DEPLOY_SCRIPT="DeployDCAPScript"
CONFIGURE_SCRIPT="ConfigureDcapAttestationScript"
FORGE_COMMAND_SUFFIX="--broadcast --rpc-url $RPC_URL"


# Ensure the .deployed-contract-addresses.txt file exists and truncate it to make sure it is empty
touch .deployed-contract-addresses.txt
: > .deployed-contract-addresses.txt

echo "[LOG] Deploying P256Verifier contract..."
P256_VERIFIER_OUTPUT=$(forge script $DEPLOY_SCRIPT --sig "deployP256Verifier()" $FORGE_COMMAND_SUFFIX | grep LOG)
export P256_VERIFIER_ADDRESS=$(echo $P256_VERIFIER_OUTPUT | grep -oE '0x[0-9A-Fa-f]+')
echo "P256_VERIFIER_ADDRESS=$P256_VERIFIER_ADDRESS" >> .deployed-contract-addresses.txt
echo $P256_VERIFIER_OUTPUT

echo "[LOG] Deploying SigVerifyLib..."
SIGVERIFY_LIB_OUTPUT=$(forge script $DEPLOY_SCRIPT --sig "deploySigVerifyLib()" $FORGE_COMMAND_SUFFIX | grep LOG)
export SIGVERIFY_LIB_ADDRESS=$(echo $SIGVERIFY_LIB_OUTPUT | grep -oE '0x[0-9A-Fa-f]+')
echo "SIGVERIFY_LIB_ADDRESS=$SIGVERIFY_LIB_ADDRESS" >> .deployed-contract-addresses.txt
# sed -i "" "${STARTING_LINE}i\\$SIGVERIFY_LIB_ADDRESS" .env
echo $SIGVERIFY_LIB_OUTPUT

echo "[LOG] Deploying PEMCertChainLib..."
PEMCERT_LIB_OUTPUT=$(forge script $DEPLOY_SCRIPT --sig "deployPemCertLib()" $FORGE_COMMAND_SUFFIX | grep LOG)
export PEMCERT_LIB_ADDRESS=$(echo $PEMCERT_LIB_OUTPUT | grep -oE '0x[0-9A-Fa-f]+')
echo "PEMCERT_LIB_ADDRESS=$PEMCERT_LIB_ADDRESS" >> .deployed-contract-addresses.txt
echo $PEMCERT_LIB_OUTPUT

echo "[LOG] Deploying AutomataDcapV3Attestation..."
DCAP_ATTESTATION_OUTPUT=$(forge script $DEPLOY_SCRIPT --sig "deployAttestation()" $FORGE_COMMAND_SUFFIX | grep LOG)
export DCAP_ATTESTATION_ADDRESS=$(echo $DCAP_ATTESTATION_OUTPUT | grep -oE '0x[0-9A-Fa-f]+')
echo "DCAP_ATTESTATION_ADDRESS=$DCAP_ATTESTATION_ADDRESS" >> .deployed-contract-addresses.txt
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



echo "[LOG] ANVIL RUNNING WITH REQUIRED DEPLOYED CONTRACTS"