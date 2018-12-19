pragma solidity 0.4.25;

import "./imports/SafeMath.sol";

 /** @dev ERC20 Functions used in this contract */
contract ERC20 {
    function transferFrom (address _from, address _to, uint256 _value) public returns (bool success);
    function balanceOf(address _owner) constant public returns (uint256 balance);
}

 /** @dev ERC223 Functions used in this contract */
contract ERC223 {
    function transfer (address _to, uint256 _value) public returns (bool success);
}

 /** 
  * @title TokenSwap
  * @dev Swaps CAN20 to CAN223. 
  * Burns CAN20 and issues CAN223 at 1:1 ratio
  */
contract TokenSwap {

    using SafeMath for uint256;
    
    // Public Variables
    ERC223 public CAN223;
    ERC20 public CAN20;
    address public addrCAN20Burn = 0x000000000000000000000000000000000000dEaD;
    uint256 public totalSwapped = 0;
    
    // Events
    event Swapped(uint256 _swapped);
    
    // Accepts ether from anyone (to fund the transfers)
    function() 
    public 
    payable {
    } 

    // Sets initial variables
    constructor (address _can223, address _can20) 
    public {
        CAN223 = ERC223(_can223);
        CAN20 = ERC20(_can20);
    }

    // Swap function
    // CAN223 is 18 decimals, CAN20 is 6 decimals, hence a 1000000000000 multiplier
    function swap () 
    public {
        uint256 value = CAN20.balanceOf(msg.sender);
        require(CAN20.transferFrom(msg.sender, addrCAN20Burn, value));
        require(CAN223.transfer(msg.sender, value.mul(1000000000000)));
        totalSwapped += value; //in 6 decimals
        emit Swapped(value);
    }
}