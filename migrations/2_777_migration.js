var CAN777 = artifacts.require("./CAN777.sol");

module.exports = function(deployer) {
  deployer.deploy(CAN777, "CanYaCoin", "CAN", "sdjhsdf", 1, [], 0x3a9026af384923d9d2aa589ceaa7845cf572d045, 1000000000000000000000);
};
