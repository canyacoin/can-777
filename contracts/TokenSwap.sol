pragma solidity 0.4.25;

import { SafeMath } from "./external/SafeMath.sol";

 /** @dev ERC20 Functions used in this contract */
contract ERC20 {
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function balanceOf(address _owner) public view returns (uint256 balance);
}

 /** @dev ERC777 Functions used in this contract */
contract ERC777 {
    function transfer(address to, uint256 amount) public returns (bool);
}

 /** 
  * @title TokenSwap
  * @dev Swaps CAN20 to CAN777. 
  * Burns CAN20 and issues CAN777 at 1:1 ratio
  */
contract TokenSwap {

    using SafeMath for uint256;
    
    /** @dev Public Variables */
    ERC777 public CAN777;
    ERC20 public CAN20;
    address public addrCAN20Burn = 0x000000000000000000000000000000000000dEaD;
    uint256 public totalSwapped = 0;
    
    /** @dev Events */
    event Swapped(uint256 _swapped);
    
    /** @dev Payable fallback function */
    function() public payable {} 

    /** @dev Constructor - Sets initial variables */
    constructor (address _can777, address _can20) 
    public {
        CAN777 = ERC777(_can777);
        CAN20 = ERC20(_can20);
    }
 
    /** 
     *  @dev Execute a swap, CAN20 for CAN777
     *  CAN223 is 18 decimals, CAN20 is 6 decimals, hence a 1000000000000 multiplier
     */
    function swap () 
    public {
        uint256 value = CAN20.balanceOf(msg.sender);
        require(CAN20.transferFrom(msg.sender, addrCAN20Burn, value), "Contract must have approval to transfer CAN20");
        require(CAN777.transfer(msg.sender, value.mul(1000000000000)), "Contract must have sufficient CAN777 to transfer");
        totalSwapped += value; //in 6 decimals
        emit Swapped(value);
    }
}