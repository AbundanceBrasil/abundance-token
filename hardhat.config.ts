import { HardhatUserConfig } from 'hardhat/config'
import '@nomicfoundation/hardhat-toolbox'
import '@openzeppelin/hardhat-upgrades'

require('dotenv').config()

const {
    INFURA_PROJECT_ID,
    POLYGON_MUMBAI_PRIVATE_KEY,
    POLYGON_MAINNET_PRIVATE_KEY,
    POLYGONSCAN_MUMBAI_API_KEY,
    POLYGONSCAN_MAINNET_API_KEY,
} = process.env

const config: HardhatUserConfig = {
    solidity: {
        // Solidity version configuration
        version: '0.8.20',
        settings: {
            optimizer: {
                enabled: true,
            },
        },
    },
    networks: {
        // Network configurations
        mumbai: {
            url: `https://polygon-mumbai.infura.io/v3/${INFURA_PROJECT_ID}`,
            accounts: [POLYGON_MUMBAI_PRIVATE_KEY],
        },
        polygon: {
            url: `https://polygon-mainnet.infura.io/v3/${INFURA_PROJECT_ID}`,
            accounts: [POLYGON_MAINNET_PRIVATE_KEY],
        },
    },
    etherscan: {
        // Etherscan configuration for contract verification
        apiKey: {
            polygonMumbai: POLYGONSCAN_MUMBAI_API_KEY,
            polygon: POLYGONSCAN_MAINNET_API_KEY,
        },
    },
    sourcify: {
        // Additional configurations, if Sourcify is used
        enabled: true,
    },
}

export default config
