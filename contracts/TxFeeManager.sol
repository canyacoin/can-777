pragma solidity ^0.4.24;

import "./imports/Ownable.sol";
import { SafeMath } from "./imports/SafeMath.sol";

contract TxFeeManager is Ownable {
    
    using SafeMath for uint256;
    
    bool public publicCanWhitelist = true;                      // Allow public to whitelist
    uint256 public maxRefundableGasPrice = 10000000000;         // 10 GWEI
    uint256 public transferFeePercentTenths = 10;               // 1%
    uint256 public transferFeeFlat = 0;                         // default 0
    address public feeRecipient;                                // Asset Contract

    uint256 public totalFees = 0;
    uint256 public totalTX = 0; 
    uint256 public totalTXCount = 0;
    
    mapping(address => bool) feeWhitelist_;                     // Map whitelist permission
    
    constructor(address _feeRecipient) public {
        feeRecipient = _feeRecipient;
        feeWhitelist_[address(this)] = true;
    }


    // Calculates the CanYa Network Fee
    // Tracks gas spent, below a mas gas price threshold (prevents attacks)
    // Checks if in the whitelist (does not apply the fee)
    // Adds a base gas amount to account for the processes outside of the tracking
    // Exits gracefully if no ether in this contract
    modifier refundable () {
        uint256 _startGas = gasleft();
        _;
        if(feeWhitelist_[msg.sender]) return;
        if(isRegularAddress(msg.sender) == false) return;
        uint256 gasPrice = tx.gasprice;
        if (gasPrice > maxRefundableGasPrice) gasPrice = maxRefundableGasPrice;
        uint256 _endGas = gasleft();
        uint256 _gasUsed = _startGas.sub(_endGas).add(31000);
        uint256 weiRefund = _gasUsed.mul(gasPrice);
        if (address(this).balance >= weiRefund) msg.sender.transfer(weiRefund);
    }

    /// @notice Check whether an address is a regular address or not.
    /// @param _addr Address of the contract that has to be checked
    /// @return `true` if `_addr` is a regular address (not a contract)
    function isRegularAddress(address _addr) internal view returns(bool) {
        if (_addr == 0) { return false; }
        uint size;
        assembly { size := extcodesize(_addr) } // solium-disable-line security/no-inline-assembly
        return size == 0;
    }
    
    //Fee is in %, where 10 = 1%
    function setFeePercentTenths (uint256 _feePercent) public onlyOwner {
        transferFeePercentTenths = _feePercent;
    }

    //Fee is flat
    function setFeeFlat (uint256 _feeFlat) public onlyOwner {
        transferFeeFlat = _feeFlat;
    }

    // Set the recipient of fees - should be Asset Contract
    function setFeeRecipient (address _feeRecipient) public onlyOwner {
        feeRecipient = _feeRecipient;
    }

    // Change the anti-sybil attack threshold
    function setMaxRefundableGasPrice (uint256 _newMax) public onlyOwner {
        maxRefundableGasPrice = _newMax;
    }

    // Allows owner to exempt others
    function exemptFromFees (address _exempt) public onlyOwner {
        feeWhitelist_[_exempt] = true;
    }

    // Allows owner to revoke others in case of abuse
    function revokeFeeExemption (address _notExempt) public onlyOwner {
        feeWhitelist_[_notExempt] = false;
    }

    // Allows owner to disable/enable public whitelisting
    function setPublicWhitelistAbility (bool _canWhitelist) public onlyOwner {
        publicCanWhitelist = _canWhitelist;
    }

    // Allows public to opt-out of CanYa Network Fee
    function exemptMeFromFees () 
    public {
        if (publicCanWhitelist) {
            feeWhitelist_[msg.sender] = true;
        }
    }
        // Calculate fee amount 
    function _getTransferFeeAmount(address _from, uint256 _value) 
    internal 
    view
    returns (uint256) {
        if (!feeWhitelist_[_from]) {
            if (transferFeePercentTenths > 0){
                return (_value.mul(transferFeePercentTenths)).div(1000) + transferFeeFlat;
            } else {
                return transferFeeFlat; 
            }
        }
        return 0;
    }
}