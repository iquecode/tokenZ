// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "./BEP20Token.sol";

contract TokenZ is  BEP20Token {

  struct Lock {
    uint256 amount;
    uint256 start;
    uint256 end;
  }
  mapping (address => Lock) internal _locks;

  event setLockEvent(address indexed wallet, uint256 amount, uint256 start, uint256 end);

  constructor() {
    _name = "TokenZ2";
    _symbol = "ZZ2";
    _decimals = 6;
    _totalSupply = 200000000 * 10 ** 6;
    _balances[msg.sender] = _totalSupply;

    emit Transfer(address(0), msg.sender, _totalSupply);
  }


   /**
   * @dev set lock in a address.
   */
  function setLock(address wallet, uint256 amount, uint256 start, uint256 end) external onlyOwner {
    _locks[wallet].amount = amount;
    _locks[wallet].end    = end;
    _locks[wallet].start   = start;
    emit setLockEvent( wallet, amount, start, end);
  }


  /**
   * @dev Returns the lock info of a address.
   */
  function getLockInfo(address wallet) external view returns (uint256, uint256, uint256) {
    uint256 amount = _locks[wallet].amount;
    uint256 start = _locks[wallet].start;
    uint256 end = _locks[wallet].end;

    return (amount, start, end);
  }
  
  
   function _transfer(address sender, address recipient, uint256 amount) internal override {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
  
    if (block.timestamp > _locks[sender].end) {
      _locks[sender].amount = 0;
      _locks[sender].start  = 0;
      _locks[sender].end    = 0;
    }
    uint256 balance     = _balances[sender];
    uint256 balanceLock = _locks[sender].amount;
    uint256 balanceFree = balance - balanceLock;
    require(balanceFree >= amount, "BEP20: transfer amount exceeds balance free");
    
    //require(balance >= amount, "BEP20: transfer amount exceeds balance");
    //require(balanceLock < amount, "BEP20: transfer amount exceeds balance free");
    _balances[sender] -= amount;
    _balances[recipient] += amount;
    emit Transfer(sender, recipient, amount);
  }
  
  
  
  



}