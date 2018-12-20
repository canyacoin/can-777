pragma solidity ^0.4.24;

import "./imports/SafeMath.sol";
import { ERC777ERC20BaseToken } from "./imports/ERC777ERC20BaseToken.sol";

 /** 
  * @title CanYaCoin
  * @dev ERC777 Implementation including ERC20 compatibility
  * Base implementation: https://github.com/jacquesd/ERC777
  * Custom functionality include 
  */
contract CanYaCoin is ERC777ERC20BaseToken {

    event ERC20Enabled();
    event ERC20Disabled();

    /** @dev additional */
    string internal mURI;

    constructor(
        string _name,
        string _symbol,
        string _uri,
        uint256 _granularity,
        address[] _defaultOperators,
        address _feeRecipient,
        uint256 _initialSupply
    )
        public ERC777ERC20BaseToken(_name, _symbol, _granularity, _defaultOperators, _feeRecipient)
    {
        mURI = _uri;
        doMint(msg.sender, _initialSupply, "");
    }

    function updateDetails(string _updatedName, string _updatedSymbol, string _updatedURI) 
    public 
    onlyOwner {
        mName = _updatedName;
        mSymbol = _updatedSymbol;
        mURI = _updatedURI;
    }

    function URI() public view returns (string) { return mURI; }

    /** 
     * @dev From 777 Reference Implementation
     */  

    /** @notice Disables the ERC20 interface */
    function disableERC20() public onlyOwner {
        mErc20compatible = false;
        setInterfaceImplementation("ERC20Token", 0x0);
        emit ERC20Disabled();
    }

    /** @notice Re enables the ERC20 interface. */
    function enableERC20() public onlyOwner {
        mErc20compatible = true;
        setInterfaceImplementation("ERC20Token", this);
        emit ERC20Enabled();
    }


    function doMint(address _tokenHolder, uint256 _amount, bytes _operatorData) private {
        requireMultiple(_amount);
        mTotalSupply = mTotalSupply.add(_amount);
        mBalances[_tokenHolder] = mBalances[_tokenHolder].add(_amount);

        callRecipient(msg.sender, 0x0, _tokenHolder, _amount, "", _operatorData, true);

        emit Minted(msg.sender, _tokenHolder, _amount, _operatorData);
        if (mErc20compatible) { emit Transfer(0x0, _tokenHolder, _amount); }
    }
}