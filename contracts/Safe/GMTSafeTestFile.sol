pragma solidity 0.4.15;

/*
  Abstract contract for the full ERC 20 Token standard
  https://github.com/ethereum/EIPs/issues/20
*/

// @title Abstract token contract - Functions to be implemented by token contracts

contract Token {

    /* Total amount of tokens */
    uint256 public totalSupply;

    /*
     * Events
     */
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    /*
     * Public functions
     */

    // @notice send `value` token to `to` from `msg.sender`
    // @param to The address of the recipient
    // @param value The amount of token to be transferred
    // @return Whether the transfer was successful or not
    function transfer(address to, uint value) public returns (bool);

    // @notice send `value` token to `to` from `from` on the condition it is approved by `from`
    // @param from The address of the sender
    // @param to The address of the recipient
    // @param value The amount of token to be transferred
    // @return Whether the transfer was successful or not
    function transferFrom(address from, address to, uint value) public returns (bool);

    // @notice `msg.sender` approves `spender` to spend `value` tokens
    // @param spender The address of the account able to transfer the tokens
    // @param value The amount of tokens to be approved for transfer
    // @return Whether the approval was successful or not
    function approve(address spender, uint value) public returns (bool);

    // @param owner The address from which the balance will be retrieved
    // @return The balance
    function balanceOf(address owner) public constant returns (uint);

    // @param owner The address of the account owning tokens
    // @param spender The address of the account able to transfer the tokens
    // @return Amount of remaining tokens allowed to spent
    function allowance(address owner, address spender) public constant returns (uint);
}



/*
  Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20
  See ./AbstractToken.sol for detailed descriptions.
*/

contract StandardToken is Token {
    /*
     *  Storage
     */
    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowances;

    /*
     *  Public functions
     */

    function transfer(address to, uint value) public returns (bool) {
        if (balances[msg.sender] < value)
            revert();  // Balance too low
        balances[msg.sender] -= value;
        balances[to] += value;
        Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) public returns (bool) {
        if (balances[from] < value || allowances[from][msg.sender] < value)
            revert(); // Balance or allowance too low
        balances[to] += value;
        balances[from] -= value;
        allowances[from][msg.sender] -= value;
        Transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint value) public returns (bool) {
        allowances[msg.sender][spender] = value;
        Approval(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public constant returns (uint) {
        return allowances[owner][spender];
    }

    function balanceOf(address owner) public constant returns (uint) {
        return balances[owner];
    }
}




contract GMTSafe {

  /*
    *  GMTSafe parameters
  */
  mapping (address => uint256) allocations;
  uint256 public unlockDate;
  address public gmtAddress;
  uint256 public constant decimals = 18;


  function GMTSafe(address _gmtAddress) {
    require(_gmtAddress != 0x0);

    gmtAddress = _gmtAddress;
    unlockDate = now + 6 * 30 days;

    // TODO: Add allocations
    allocations[0x77db2bebba79db42a978f896968f4afce746ea1f] = 100;
  }

  function correctAllocations() external returns (uint256) {
      return allocations[msg.sender];
  }

  function unlock() external returns (bool) {
    assert(now >= unlockDate);

    uint256 entitled = allocations[msg.sender];
    allocations[msg.sender] = 0;

    if(!StandardToken(gmtAddress).transfer(msg.sender, entitled * 10**decimals)) {
      // Revert state due to unsuccessful refund
      allocations[msg.sender] += entitled;
      return false; 
    }

    return true;
  }
}