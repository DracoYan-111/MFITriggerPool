const path = require("path");

module.exports = {
    // See <http://truffleframework.com/docs/advanced/configuration>
    // to customize your Truffle configuration!
    contracts_build_directory: path.join(__dirname, "app/src/contracts"),
    license: "MIT",
    networks: {
        develop: { // default with truffle unbox is 7545, but we can use develop to test changes, ex. truffle migrate --network develop
            host: "127.0.0.1",
            port: 8545,
            network_id: "*"
        }
    },
    compilers: {
        solc: {
            version: "^0.8.6"
        }
    },
    dashboard: {
        port: 25012,
        host: "localhost",
        verbose: true
    }
    // ,bsc:{
    //     host: "178.25.19.88", // Random IP for example purposes (do not use)
    //     port: 80,
    //     network_id: 1,
    // }
};
