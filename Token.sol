// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "./BEP20Token.sol";

contract TokenZ is BEP20Token {

  struct Wallet {
    address holders;
    address operation;
    address growth;
    address fundation;
  }
  Wallet internal _wallet; 

  struct Fee {
    uint256 holders;
    uint256 operation;
    uint256 growth;
    uint256 fundation; 
  }
  Fee internal _fee;

  struct Lock {
    uint256 amount;
    uint256 start;
    uint256 end;
  }

  mapping (address => Lock) internal _locks;
  mapping (address => bool) internal _noFee;

  event setLockEvent(address indexed wallet, uint256 amount, uint256 start, uint256 end);
  
  constructor() {
    _name = "TokenZ2";
    _symbol = "ZZ2";
    _decimals = 6;
    _totalSupply = 200000000 * 10 ** 6;
    _balances[msg.sender] = _totalSupply;

    _wallet.holders   = 0x0A098Eda01Ce92ff4A4CCb7A4fFFb5A43EBC70DC;
    _wallet.operation = 0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB;
    _wallet.growth    = 0x583031D1113aD414F02576BD6afaBfb302140225;
    _wallet.fundation = 0xdD870fA1b7C4700F2BD7f44238821C26f7392148;   

    _fee.holders   = 3;
    _fee.operation = 2;
    _fee.growth    = 2;
    _fee.fundation = 1;

    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  /**
   * @dev set wallets.
   */
  function setWallet(address holders, address operation, address growth, address fundation) external onlyOwner {
    _wallet.holders   = holders;
    _wallet.operation = operation;
    _wallet.growth    = growth;
    _wallet.fundation = fundation;
  }

  /**
   * @dev get Fee transactions.
   */
  function getWallet() external view returns (address, address, address, address)  {
    return (_wallet.holders, _wallet.operation, _wallet.growth, _wallet.fundation);
  }

  /**
   * @dev set Fee transactions.
   */
  function setFee(uint256 holders, uint256 operation, uint256 growth, uint256 fundation) external onlyOwner {
    _fee.holders   = holders;
    _fee.operation = operation;
    _fee.growth    = growth;
    _fee.fundation = fundation;
  }

  /**
   * @dev get Fee transactions.
   */
  function getFee() external view returns (uint256, uint256, uint256, uint256)  {
    return (_fee.holders, _fee.operation, _fee.growth, _fee.fundation);
  }

  /**
   * @dev set address without transaction fee implications (true) or with fee (false).
   */
  function setNoFee(address wallet, bool noFee) external onlyOwner {
    _noFee[wallet] = noFee;
  }

  /**
   * @dev returns fee status of an address
   */
  function getNoFee(address wallet) external view returns (bool)  {
    return (_noFee[wallet]);
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
    
    uint256 amountFree = amount;
    if (_noFee[sender] == false) {
      uint256 amountHolders   = amount * ( _fee.holders / 100 );
      uint256 amountOperation = amount * ( _fee.operation / 100 );
      uint256 amountGrowth    = amount * ( _fee.growth / 100 );
      uint256 amountFundation = amount * ( _fee.fundation / 100 );
      amountFree = amount - amountHolders - amountOperation - amountGrowth - amountFundation;
      _balances[_wallet.holders] += amountHolders;
      _balances[_wallet.operation] += amountOperation;
      _balances[_wallet.growth] += amountGrowth;
      _balances[_wallet.fundation] += amountFundation;
    }

    //require(balance >= amount, "BEP20: transfer amount exceeds balance");
    //require(balanceLock < amount, "BEP20: transfer amount exceeds balance free");
    _balances[sender] -= amountFree;
    _balances[recipient] += amountFree;
    emit Transfer(sender, recipient, amountFree);
  }
  
}