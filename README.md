# Foundry FundMe

A Solidity project built with **Foundry** that demonstrates:

- ETH funding with a minimum USD value
- Chainlink price feeds (real + mock)
- Environment-aware deployment (Anvil / Sepolia)
- Script-based deployment & interactions
- Unit and integration testing
- Basic DevOps patterns using `foundry-devops`

This project is intentionally kept **educational but realistic**, mirroring how real-world smart contract projects are structured.

---

## 🧠 What this project demonstrates

- Writing a production-style Solidity contract (`FundMe`)
- Using Chainlink price feeds to convert ETH → USD
- Handling different environments (local vs testnet)
- Deploying contracts with Foundry scripts
- Interacting with deployed contracts using scripts
- Using mocks for local testing
- Integration testing end-to-end flows (fund → withdraw)
- Managing zkSync / EVM differences (optional)

---

## 📁 Project Structure

```

.
├── src/                            # Application contracts
│   ├── FundMe.sol                  # Main funding contract
│   ├── PriceConverter.sol          # ETH → USD conversion library
│   └── exampleContracts/
│       └── FunWithStorage.sol      # Example / practice contract
│
├── script/                         # Deployment & interaction scripts
│   ├── DeployFundMe.s.sol          # Deploys FundMe using HelperConfig
│   ├── DeployPriceFeed.s.sol       # (Optional) Price feed deployment
│   ├── DeployStorageFun.sol        # Example deploy script
│   ├── HelperConfig.s.sol          # Network-aware config (Anvil / Sepolia)
│   └── Interaction.s.sol           # Fund & Withdraw scripts
│
├── test/                           # Tests
│   ├── unit/
│   │   ├── FundMeTest.t.sol        # Unit tests for FundMe
│   │   └── ZKSyncDevOps.t.sol      # zkSync / Foundry environment checks
│   │
│   ├── integration/
│   │   └── FundMeTestIntegration.t.sol # End-to-end fund & withdraw test
│   │
│   └── Mock/
│       └── CustomPriceFeed.sol     # Mock Chainlink price feed
│
├── lib/                            # External dependencies (submodules)
│   ├── forge-std                   # Foundry standard library
│   ├── foundry-devops              # Deployment & environment helpers
│   └── chainlink-brownie-contracts # Chainlink contracts
│
│
├── foundry.toml                    # Foundry configuration
├── Makefile                        # Project command shortcuts
├── README.md
└── .gitignore

```

---

## ⚙️ Requirements

- Foundry installed

```bash
  curl -L https://foundry.paradigm.xyz | bash
  foundryup
```

- (Optional) zkSync Foundry

```bash
  foundryup-zksync
```

---

## 🏗️ Core Contracts

### `FundMe.sol`

- Accepts ETH from users
- Converts ETH to USD using Chainlink price feeds
- Enforces a minimum funding amount (`MINIMUM_USD`)
- Tracks:
  - Funders
  - Total contributions
  - Contribution count per address
- Allows **only the owner** to withdraw funds
- Uses:
  - Custom errors
  - Library-based price conversion
  - `receive` and `fallback` for ETH transfers

---

### `PriceConverter.sol`

- Library for converting ETH → USD
- Reads price data from a Chainlink Aggregator
- Used by `FundMe` to enforce minimum funding

---

## 🚀 Deployment Flow

### `HelperConfig.s.sol`

- Determines configuration based on `block.chainid`
- Supports:
  - **Sepolia (11155111)** → uses real Chainlink ETH/USD feed
  - **Local Anvil (31337)** → deploys a mock price feed
- Ensures the same deployment script works across environments

---

### `DeployFundMe.s.sol`

- Uses `HelperConfig` to select the correct price feed
- Deploys `FundMe` with the correct constructor argument
- Returns the deployed contract instance

---

## 🔁 Interaction Scripts

### `Interaction.s.sol`

Provides two scripts:

#### `FundFundMe`

- Fetches the most recently deployed `FundMe` contract
- Sends a fixed ETH amount to `fund()`

#### `WithdrawFundMe`

- Fetches the most recently deployed `FundMe`
- Calls `withdraw()` as the owner

Uses `foundry-devops` to automatically locate deployments.

---

## 🧪 Testing

### Unit Tests

- Validate individual contract behavior
- Ensure funding logic, ownership, and state updates work as expected

### Integration Test (`FundMeTestIntegration.t.sol`)

- Deploys the contract
- Simulates a real user funding the contract
- Owner withdraws funds
- Verifies balance changes end-to-end

This test mirrors **real usage**, not just isolated functions.

---

## ⚙️ Common Commands (via Makefile)

```bash
make install              # Install dependencies
make anvil                # Start local Anvil chain
make deploy               # Deploy FundMe locally
make fund-local           # Fund FundMe on local Anvil
make withdraw-local       # Withdraw funds locally
make deploy_and_verify    # Deploy & verify on Sepolia
make zkbuild              # Build for zkSync
make zktest               # Run zkSync tests
make help                 # Show available commands
```

---

## 🔐 Environment Variables

Create a `.env` file (do not commit):

```env
# Local Anvil
ANVIL_PRIVATE_KEY=0x...
SENDER_ADDRESS=0x...

# Sepolia
RPC_URL_SEPOLIA=https://...
SEPOLIA_PRIVATE_KEY=0x...
ETHERSCAN_API_KEY=...
```

---

## 🔍 Notes on zkSync

- zkSync uses a different VM than standard EVM
- Some opcodes and behaviors differ
- This repo demonstrates how to **safely skip or enable tests** depending on:

  - Chain (EVM vs zkSync)
  - Foundry version (vanilla vs zkSync Foundry)

See `ZkSyncDevOps.t.sol` for examples using:

- `skipZkSync`
- `onlyZkSync`
- `onlyVanillaFoundry`

---

## 🧭 Project Status

This is an **active learning project**.

- Code may evolve
- Infrastructure may change
- Focus is on understanding real workflows, not polish

---

## 🧭 Goal

To build strong fundamentals in:

- Solidity
- Smart contract testing
- Deployment pipelines
- Web3 DevOps practices

---

## 📜 License

MIT
