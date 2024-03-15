// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Imports the necessary libraries and contracts from OpenZeppelin for contract implementation.
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/**
 * @title Abundance Token (ATK)
 * @notice The Abundance Token represents a share of a forest, symbolizing the number of trees planted in a specific forest.
 * Each ATK is a nature-based asset backed by real native trees that generate environmental benefits, such as carbon removal credits, over time.
 * @dev This contract manages the creation, pausing, burning, and upgrading of ATK tokens.
 * @custom:security-contact ti@abundancebrasil.com
 */
contract AbundanceToken is
    Initializable,
    ERC20Upgradeable,
    ERC20BurnableUpgradeable,
    ERC20PausableUpgradeable,
    AccessControlUpgradeable,
    ERC20PermitUpgradeable,
    UUPSUpgradeable
{
    /**
     * @notice The role that allows pausing the contract.
     */
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /**
     * @notice The role that allows minting new tokens.
     */
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /**
     * @notice The role that allows upgrading the contract.
     */
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    /**
     * @notice The maximum total supply limit for ATK tokens.
     */
    uint256 public totalSupplyLimit;

    /**
     * @notice A mapping that tracks the balances of tokens by customer ID.
     */
    mapping(string => uint256) private _balancesByCustomerId;

    /**
     * @notice A mapping that tracks the minted amount of tokens by transaction ID.
     */
    mapping(string => uint256) private _mintedAmountByTransactionId;

    /**
     * @notice Gap to ensure upgrade compatibility.
     * @dev This gap is added to allow future upgrades to the contract without affecting storage layout.
     */
    uint256[50] private __gap;

    /**
     * @notice Emitted when tokens are minted and assigned to an address.
     * @param to The address receiving the minted tokens.
     * @param amount The amount of tokens minted.
     */
    event TokensMinted(address indexed to, uint256 amount);

    /**
     * @notice Emitted when tokens are minted and assigned to an address with a customer ID.
     * @param to The address receiving the minted tokens.
     * @param amount The amount of tokens minted.
     * @param customerId The customer ID associated with the minted tokens.
     */
    event TokensMintedWithCustomerId(
        address indexed to,
        uint256 amount,
        string customerId
    );

    /**
     * @notice Emitted when tokens are minted and assigned to an address with a transaction ID.
     * @param to The address receiving the minted tokens.
     * @param amount The amount of tokens minted.
     * @param transactionId The transaction ID associated with the minted tokens.
     */
    event TokensMintedWithTransactionId(
        address indexed to,
        uint256 amount,
        string transactionId
    );

    /**
     * @notice Contract constructor.
     * @custom:oz-upgrades-unsafe-allow constructor
     */
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the contract with required roles and total supply limit.
     * @param defaultAdmin The address of the default admin.
     * @param pauser The address with the pauser role.
     * @param minter The address with the minter role.
     * @param upgrader The address with the upgrader role.
     * @param maxSupplyLimit The maximum total supply limit for ATK tokens.
     * @dev This function should be called only once during contract deployment to set up roles and supply limit.
     */
    function initialize(
        address defaultAdmin,
        address pauser,
        address minter,
        address upgrader,
        uint256 maxSupplyLimit
    ) public initializer {
        __ERC20_init("Abundance Token", "ATK");
        __ERC20Burnable_init();
        __ERC20Pausable_init();
        __AccessControl_init();
        __ERC20Permit_init("Abundance Token");
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(PAUSER_ROLE, pauser);
        _grantRole(MINTER_ROLE, minter);
        _grantRole(UPGRADER_ROLE, upgrader);

        require(maxSupplyLimit > 0, "Supply limit must be greater than zero.");
        totalSupplyLimit = maxSupplyLimit * 10**uint256(decimals());
    }

    /**
     * @notice Pauses the contract, preventing token transfers.
     * Only the account with the pauser role can call this function.
     * @dev This function is used to pause the contract in case of emergencies or upgrades.
     */
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /**
     * @notice Unpauses the contract, allowing token transfers.
     * Only the account with the pauser role can call this function.
     * @dev This function is used to resume normal contract operations after pausing.
     */
    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /**
     * @notice Mints new ATK tokens and assigns them to the specified address.
     * Only the account with the minter role can call this function.
     * @param to The address to receive the minted tokens.
     * @param amount The amount of tokens to mint.
     * @dev This function is used to create new ATK tokens.
     */
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        require(
            totalSupply() + amount <= totalSupplyLimit,
            "Minting exceeds supply limit."
        );
        _mint(to, amount);
        emit TokensMinted(to, amount);
    }

    /**
     * @notice Mints new ATK tokens with customer ID and transaction ID.
     * Only the account with the minter role can call this function.
     * @param to The address to receive the minted tokens.
     * @param amount The amount of tokens to mint.
     * @param customerId The customer ID associated with the minted tokens.
     * @param transactionId The transaction ID associated with the minted tokens.
     * @dev This function is used to mint tokens with additional metadata.
     */
    function mintWithCustomerIdAndTransactionId(
        address to,
        uint256 amount,
        string calldata customerId,
        string calldata transactionId
    ) public onlyRole(MINTER_ROLE) {
        require(
            totalSupply() + amount <= totalSupplyLimit,
            "Minting exceeds supply limit."
        );
        require(bytes(customerId).length > 0, "Empty Customer ID.");
        require(bytes(transactionId).length > 0, "Empty Transaction ID.");
        require(
            _mintedAmountByTransactionId[transactionId] == 0,
            "Transaction ID already used."
        );
        _mint(to, amount);
        _balancesByCustomerId[customerId] += amount;
        _mintedAmountByTransactionId[transactionId] = amount;
        emit TokensMintedWithCustomerId(to, amount, customerId);
        emit TokensMintedWithTransactionId(to, amount, transactionId);
    }

    /**
     * @notice Returns the balance of a customer's tokens based on their customer ID.
     * @param customerId The customer ID for which to check the balance.
     * @return The balance of tokens associated with the customer ID.
     * @dev This function provides the balance of tokens for a specific customer ID.
     */
    function balanceOfCustomerId(string calldata customerId)
        external
        view
        returns (uint256)
    {
        return _balancesByCustomerId[customerId];
    }

    /**
     * @notice Returns the minted amount of tokens for a given transaction ID.
     * @param transactionId The transaction ID for which to check the minted amount.
     * @return The amount of tokens minted for the transaction ID.
     * @dev This function provides the minted amount of tokens for a specific transaction ID.
     */
    function mintedAmountByTransactionId(string calldata transactionId)
        external
        view
        returns (uint256)
    {
        return _mintedAmountByTransactionId[transactionId];
    }

    /**
     * @notice Authorizes the upgrade to a new implementation contract.
     * Only the account with the upgrader role can call this function.
     * @dev This function is used to authorize the upgrade to a new contract implementation.
     */
    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(UPGRADER_ROLE)
    {}

    /**
     * @dev Updates internal token balances when transfers occur.
     */
    function _update(
        address from,
        address to,
        uint256 value
    ) internal override(ERC20Upgradeable, ERC20PausableUpgradeable) {
        super._update(from, to, value);
    }
}
