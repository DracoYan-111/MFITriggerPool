const path = require("path");

module.exports = {
    description: "Meta finance trigger pool contract",
    authors: ["LongYan <https://github.com/YanLong-111>"],
    contracts_build_directory: path.join(__dirname, "app/src/contracts"),
    license: "MIT",
    compilers: {
        solc: {
            version: "0.8.6",
            settings: {
                optimizer: {
                    enabled: true,
                    runs: 200
                }
            }
        }
    },
    networks: {
        develop: {
            host: "127.0.0.1",
            port: 8545,
            network_id: "*"
        }
    },
    dashboard: {
        port: 25012,
        host: "localhost",
        verbose: true
    }
};
