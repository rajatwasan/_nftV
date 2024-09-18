import type { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox-viem";
import { config as dotEnvConfig } from "dotenv";
dotEnvConfig();

const config: HardhatUserConfig = {
  solidity: "0.8.24",
  networks: {
    hedera: {
      url: "https://testnet.hashio.io/api",
      // url: "http://localhost:7546",
      accounts:
        process.env.HEDERA_PRIVATE_KEY !== undefined
          ? [process.env.HEDERA_PRIVATE_KEY]
          : [],

      timeout: 80000,
    },
    amoy: {
      url: process.env.AMOY_RPC,
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    sepolia: {
      url: process.env.SEPOLIA_RPC,
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    dev: {
      url: "http://127.0.0.1:8545/",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    hardhat: {
      // chainId: 80002,
      // allowUnlimitedContractSize: true,
      forking: {
        //   url: "https://rpc-amoy.polygon.technology",
        url:
          process.env.POLYGON_RPC !== undefined
            ? process.env.POLYGON_RPC
            : "https://polygon-rpc.com",
        blockNumber: 57444979,
      },
    },
    // hardhat: {
    //   forking: {
    //     url: "https://testnet.hashio.io/api",
    //     blockNumber: 1333680,
    //   },
    // },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
};

export default config;
