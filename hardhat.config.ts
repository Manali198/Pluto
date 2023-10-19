import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

require('solidity-coverage')

const PRIVATE_KEY = "37b101a3c67aaf0dbcf6f73d2722466222cc909dad639c43edbc78d49223376a";

 
  module.exports = {
    solidity: {
      version: "0.8.20",
      settings: {
        optimizer: { 
          enabled: true,
          runs: 200,
        },
      },

    },
    
    networks: {
      sepolia: {
        url: "https://sepolia.infura.io/v3/0796658a2cb947e48489f739cd3c6784",
        chainId: 11155111,
        accounts: [PRIVATE_KEY],
      }
    },

    etherscan: {
      apiKey: {
        sepolia  : "FGXX2WTEVRBK1UX4SBA2NI4WX3YBDSNBZ9"
      }
    }
  };