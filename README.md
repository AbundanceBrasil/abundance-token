# Abundance Token (ATK)

## Description

The Abundance Token (ATK) is an ERC20 smart contract project designed to represent stakes in forests, symbolizing the number of trees planted. Each ATK token is a nature-based asset, backed by real native trees, promoting sustainability and reforestation. This project utilizes advanced smart contract technologies, including upgrade capabilities, token burning, pausing, and access control, providing a secure and flexible infrastructure for the tokenization of natural assets.

## Technologies Used

- **Ethereum Blockchain**: For the creation and management of ERC20 digital tokens.
- **Solidity ^0.8.20**: Programming language for writing smart contracts.
- **OpenZeppelin Contracts**: Used to implement secure and upgradable token standards, access control, token burning, and pausing.
- **Hardhat**: Ethereum development environment for compiling, testing, and deploying smart contracts.
- **TypeScript**: For deployment scripts and tests, offering a more robust and secure development experience.
- **Node.js and npm**: For dependency management and execution of development scripts.

## Environment Setup

Ensure you have Node.js (v14.x or higher) and npm installed. To install the contract dependencies, including OpenZeppelin libraries:

```bash
npm install
```

## Installation and Usage

### Compilation

To compile the contracts and ensure they are correct:

```bash
npx hardhat compile
```

### Testing

Run the tests to ensure the contracts' security and expected functionality:

```bash
npx hardhat test
```

### Deployment

To deploy the contracts on a test network (e.g., Rinkeby):

```bash
npx hardhat run scripts/deploy.js --network rinkeby
```

## Contract Functions

### Minting Tokens with Customer ID and Transaction ID

- **mintWithCustomerIdAndTransactionId(address to, uint256 amount, string calldata customerId, string calldata transactionId)**

  This function allows minting new ATK tokens by associating them with a customer ID and a transaction ID. Only accounts with the minter role (`MINTER_ROLE`) can perform this action. Minting is limited by the total supply limit of the token, and both the customer ID and transaction ID must be provided and cannot be repeated or empty.

  - `to`: Address that will receive the minted tokens.
  - `amount`: Amount of tokens to be minted.
  - `customerId`: Customer ID associated with the minted tokens.
  - `transactionId`: Transaction ID associated with the minted tokens.

### Balance Inquiry by Customer ID

- **balanceOfCustomerId(string calldata customerId) → uint256**

  Returns the balance of a customer's tokens based on their customer ID. This function is useful for verifying the amount of tokens associated with a specific customer.

### Minted Amount Inquiry by Transaction ID

- **mintedAmountByTransactionId(string calldata transactionId) → uint256**

  Provides the amount of ATK tokens minted associated with a specific transaction ID. This function is essential for verifying whether a specific transaction was used to mint tokens and the associated amount of tokens.

## Contribution

Contributions are encouraged, especially to expand the application of ATK in new areas of sustainability and reforestation. See `CONTRIBUTING.md` for more details.

## License

Licensed under the MIT License. See `LICENSE` for more information.
