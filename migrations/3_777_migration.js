var CAN777 = artifacts.require("./CAN777.sol");

module.exports = function(deployer) {
  deployer.deploy(CAN777, "CanYaCoin", "CAN", "http://canya.io", 1, [], "0x200C0dDbf0467bEF9F284d35902C8ABc9a566790", "100000000000000000000000000");
};
