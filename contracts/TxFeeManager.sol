pragma solidity ^0.4.24;

import { SafeMath } from "./external/SafeMath.sol";
import { Ownable } from "./external/Ownable.sol";

 /** 
  * @title TxFeeManager
  * @dev Manages transaction fees associated with token transfers
  * Gas costs for transfers are refunded (up to a certain amount), and a 
  * transfer fee is deducted from the token transfer, going to a fee collector.
  * Whitelisted addresses do not receive gas refunds or transfer fee
  */
contract TxFeeManager is Ownable {
    
    using SafeMath for uint256;
    
    /** @dev Allow the public to whitelist address */
    bool public publicCanWhitelist = true;        

    /** @dev Max gas price refund - 10 GWEI */             
    uint256 public maxRefundableGasPrice = 10000000000;

    /** @dev Fee to deduct from token transfers (0.1% increments) */
    uint256 public transferFeePercentTenths = 10;

    /** @dev Flat transfer fee */
    uint256 public transferFeeFlat = 0;
    
    /** @dev Address to receive collected fees */
    address public feeRecipient;

    /** @dev Total transaction fees collected */
    uint256 public totalFees = 0;
    
    /** @dev Addresses who will not recieve refunds or tx fees */
    mapping(address => bool) feeWhitelist_;
    
    /**
     * @dev Constructor
     * @param _feeRecipient Address to receive collected fees
     */
    constructor(address _feeRecipient) public {
        feeRecipient = _feeRecipient;
        feeWhitelist_[address(this)] = true;
    }

    /**
     * @dev Modifier to apply the CanYa Network refund
     * Tracks gas spent, below a max gas price threshold
     * Checks if in the whitelist (does not apply the fee)
     * Adds a base gas amount to account for the processes outside of the tracking
     * Exits gracefully if no ether in this contract
     */
    modifier refundable() {
        uint256 _startGas = gasleft();
        _;
        if(!applyFeeToAddress(msg.sender)) return;
        uint256 gasPrice = tx.gasprice;
        if (gasPrice > maxRefundableGasPrice) gasPrice = maxRefundableGasPrice;
        uint256 _endGas = gasleft();
        uint256 _gasUsed = _startGas.sub(_endGas).add(31000);
        uint256 weiRefund = _gasUsed.mul(gasPrice);
        if (address(this).balance >= weiRefund) msg.sender.transfer(weiRefund);
    }

    /**
     * @dev Bool to determine whether or not an address should have a refund and tx fee applied
     * @param _address Address to check
     */
    function applyFeeToAddress(address _address)
    internal
    view
    returns (bool) {
        return isRegularAddress(_address) && !feeWhitelist_[_address];
    }

    /** 
     *  @notice Check whether an address is a regular address or not.
     *  @param _addr Address of the contract that has to be checked
     *  @return `true` if `_addr` is a regular address (not a contract)
     */
    function isRegularAddress(address _addr) 
    internal 
    view 
    returns(bool) {
        if (_addr == 0) {
            return false; 
        }
        uint size;
        assembly { size := extcodesize(_addr) } // solium-disable-line security/no-inline-assembly
        return size == 0;
    }
    
    /**
     * @dev Set the rate with which to calculate tx fee
     * @param _feePercent Percentage of fee to collect, in 10ths. Where 10 = 1%
     */
    function setFeePercentTenths(uint256 _feePercent) 
    public 
    onlyOwner {
        transferFeePercentTenths = _feePercent;
    }

    /**
     * @dev Set the flat transaction fee rate
     * @param _feeFlat Value of flat fee
     */
    function setFeeFlat(uint256 _feeFlat) 
    public 
    onlyOwner {
        transferFeeFlat = _feeFlat;
    }

    /**
     * @dev Update the recipient of fees
     * @param _feeRecipient Recipient address
     */
    function setFeeRecipient(address _feeRecipient) 
    public 
    onlyOwner {
        feeRecipient = _feeRecipient;
    }

    /**
     * @dev Change the anti-sybil attack threshold
     * @param _newMax Max gas price in wei
     */
    function setMaxRefundableGasPrice(uint256 _newMax) 
    public 
    onlyOwner {
        maxRefundableGasPrice = _newMax;
    }

    /**
     * @dev Allows owner to add addresses to the fee whitelist
     * @param _exempt Address to whitelist
     */
    function exemptFromFees(address _exempt) 
    public 
    onlyOwner {
        feeWhitelist_[_exempt] = true;
    }

    /**
     * @dev Allows owner to revoke others in case of abuse
     * @param _notExempt Address to remove from the whitelist
     */
    function revokeFeeExemption(address _notExempt) 
    public 
    onlyOwner {
        feeWhitelist_[_notExempt] = false;
    }

    /**
     * @dev Allows owner to disable/enable public whitelisting
     * @param _canWhitelist Bool which sets ability for the public to whitelist
     */
    function setPublicWhitelistAbility(bool _canWhitelist) 
    public 
    onlyOwner {
        publicCanWhitelist = _canWhitelist;
    }

    /**
     * @dev Allows public to opt-out of CanYa Network Fee
     */
    function exemptMeFromFees() 
    public {
        if (publicCanWhitelist) {
            feeWhitelist_[msg.sender] = true;
        }
    }

    /**
     * @dev Calculate transfer fee amount 
     * @param _operator Address that is executing the transfer
     * @param _value Amount of tokens being transferred
     */
    function _getTransferFeeAmount(address _operator, uint256 _value) 
    internal 
    view
    returns (uint256) {
        if (!applyFeeToAddress(_operator)){
            return 0;
        }
        if (transferFeePercentTenths > 0){
            return (_value.mul(transferFeePercentTenths)).div(1000) + transferFeeFlat;
        }
        return transferFeeFlat; 
    }
}