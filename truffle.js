module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
    networks: {
        development: {
            host: "127.0.0.1",
            port: 6545,
            network_id: "*" // Match any network id
        }
    }
};