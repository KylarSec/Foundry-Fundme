# Foundry FundMe

A Solidity project built using **Foundry** to understand smart contract development, testing, deployment, and interactions across **local Anvil**, **Sepolia**, and **zkSync** environments.

This project follows a learning-first approach while using real-world tooling and workflows.

---

## 🧠 What this project covers

- Writing Solidity smart contracts (`FundMe`)
- Unit testing with Foundry
- Deploying contracts using Foundry scripts
- Interacting with deployed contracts (fund / withdraw)
- Managing environments (local, Sepolia, zkSync)
- Handling EVM vs zkSync VM differences
- Basic DevOps patterns for Web3 projects

---

## 📁 Project structure

```

.
├── src/ # Application contracts
│ ├── FundMe.sol
│ ├── PriceConverter.sol
│ └── exampleContracts/
│ └── FunWithStorage.sol
│
├── script/ # Deployment & interaction scripts
│ ├── DeployFundMe.s.sol
│ ├── DeployPriceFeed.s.sol
│ ├── HelperConfig.s.sol
│ ├── DeployStorageFun.sol
│ └── Interaction.s.sol
│
├── test/ # Tests
│ ├── unit/
│ │ ├── FundMeTest.t.sol
│ │ └── ZKSyncDevOps.t.sol
│ │
│ ├── integration/
│ │ └── FundMeTestIntegration.t.sol
│ │
│ └── Mock/
│ └── CustomPriceFeed.sol
│
├── lib/ # External dependencies (git submodules)
│ ├── forge-std/ # Foundry standard library
│ ├── foundry-devops/ # DevOps & zkSync helpers
│ └── chainlink-brownie-contracts/ # Chainlink contracts (VRF, feeds, etc.)
│
│
├── foundry.toml # Foundry configuration
├── Makefile # Project command shortcuts
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

## 🔐 Environment setup

Create a `.env` file (do NOT commit it):

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

## 🧪 Common commands (via Makefile)

### Install dependencies

```bash
make install
```

### Start local blockchain

```bash
make anvil
```

### Deploy locally

```bash
make deploy
```

### Fund contract (local)

```bash
make fund-local
```

### Withdraw funds (local)

```bash
make withdraw-local
```

### Deploy & verify on Sepolia

```bash
make deploy_and_verify
```

### zkSync

```bash
make zkbuild
make zktest
```

### Help

```bash
make help
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

## 🚧 Status

This is an **active learning project**.

- Code may evolve
- Infrastructure may change
- Focus is on understanding, not polish

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
