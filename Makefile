-include .env

.PHONY: all install anvil deploy deploy_and_verify fund_local fund_sepolia withdraw zkbuild zktest

# all: clean remove install update build

install :
	forge install cyfrin/foundry-devops@0.2.2 && \
	forge install smartcontractkit/chainlink-brownie-contracts@1.1.1 && \
	forge install foundry-rs/forge-std@v1.8.2



# Starts local Ethereum node
# Deterministic accounts
# 10 second block time
# Step tracing enabled (for debugging)
anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 10

# Network arguments for forge script commands
NETWORK_ARGS := --rpc-url http:localhost:8545 --private-key $(PRIVATE_KEY) --broadcast
S_NETWORK_ARGS := --rpc-url $(RPC_URL_SEPOLIA) --private-key $(S_PRIVATE_KEY) --broadcast

deploy:
	@forge script script/DeployFundMe.s.sol:DeployFundMe $(NETWORK_ARGS)

deploy_sepolia:
	@forge script script/DeployFundMe.s.sol:DeployFundMe $(S_NETWORK_ARGS)

deploy_and_verify:
	@forge script script/DeployFundMe.s.sol:DeployFundMe $(S_NETWORK_ARGS) --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv


# For deploying Interactions.s.sol:FundFundMe as well as for Interactions.s.sol:WithdrawFundMe we have to include a sender's address `--sender <ADDRESS>`
# Sepolia Sender address
S_SENDER_ADDRESS := 0x3CA74f78b5c6Fe9776fB9761262754f16dB6eB10

# Local Sender address
SENDER_ADDRESS := 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266


 
fund_local:
	@forge script script/Interaction.s.sol:FundFundMe --sender $(SENDER_ADDRESS) $(NETWORK_ARGS)

fund_sepolia:
	@forge script script/Interaction.s.sol:FundFundMe --sender $(S_SENDER_ADDRESS) $(S_NETWORK_ARGS)

withdraw_local:
	@forge script script/Interaction.s.sol:WithdrawFundMe --sender $(SENDER_ADDRESS) $(NETWORK_ARGS)

withdraw_sepolia:
	@forge script script/Interaction.s.sol:WithdrawFundMe --sender $(S_SENDER_ADDRESS) $(S_NETWORK_ARGS)


zkbuild :; forge build --zksync

zktest :; foundryup-zksync && forge test --zksync && foundryup

# #Another way to choose network
# ifeq ($(NETWORK),sepolia)
# 	ACTIVE_NETWORK_ARGS := $(S_NETWORK_ARGS)
# else
# 	ACTIVE_NETWORK_ARGS := $(NETWORK_ARGS)
# endif

# fund:
# 	@forge script script/Interactions.s.sol:FundFundMe --sender $(SENDER_ADDRESS) $(ACTIVE_NETWORK_ARGS)