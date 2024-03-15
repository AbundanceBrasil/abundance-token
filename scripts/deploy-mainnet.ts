import { ethers, upgrades } from 'hardhat'

require('dotenv').config()

async function main() {
    const ContractFactory = await ethers.getContractFactory('AbundanceToken')

    const address = process.env.POLYGON_MAINNET_PUBLIC_KEY
    const maxSupplyLimit = 1000000
    const instance = await upgrades.deployProxy(ContractFactory, [
        address,
        address,
        address,
        address,
        maxSupplyLimit,
    ])
    await instance.waitForDeployment()

    console.log(`Proxy deployed to ${await instance.getAddress()}`)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
