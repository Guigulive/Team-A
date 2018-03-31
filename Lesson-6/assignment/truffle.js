module.exports = {
  migrations_directory: "./migrations",
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      gas: 6712390,
      network_id: "*" // Match any network id
    }
  }
};
