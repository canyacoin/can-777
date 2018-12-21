var CAN777 = artifacts.require("./CAN777.sol");

module.exports = function(deployer) {
  deployer.deploy(CAN777, "CanYaCoin", "CAN", "sdjhsdf", 1, [], "0x70235310a5fc78c4367592f6cdcc531b2d1c4bc6", 100000000000000);
};
