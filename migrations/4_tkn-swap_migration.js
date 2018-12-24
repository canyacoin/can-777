var TokenSwap = artifacts.require("./TokenSwap.sol");

module.exports = function(deployer) {
  deployer.deploy(TokenSwap, "0x64AB7e8fdDd8EEaD231aEA73efEa8AB61Ec54d2e", "0x38d89a3bd248f238fc467cd8a45c548a5b70659e");
};
