// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)


// File: contracts/RedToken.sol


pragma solidity ^0.8.9;

import "./Ownable.sol";
import "./ERC20.sol";


contract BlueToken is ERC20, Ownable {
    constructor() ERC20("BlueToken", "BLUE") {}
    uint256 public classSize;
    mapping (uint256 => address) public fetchParticipant;
    mapping (address => bool) public participants;
    mapping (address => uint256) public mintBalance;

    function addParticipant(address par) public onlyOwners {
        participants[par] = true;
        fetchParticipant[classSize] = par;
        classSize += 1;
    }
    function mint(address to, uint256 amount) public {
        require(isOwners(msg.sender) || (participants[msg.sender]), "only patriciapants and owners allowed");
        if (!isOwners(msg.sender)) {
            require(mintBalance[to]+amount <= 10**20, "mint limit reached");
            require(msg.sender==to,"partcipants can only mint for themselves");
        }
        
        _mint(to, amount);
        mintBalance[to]+=amount;
    }
    function courseFinished() public onlyOwners {
        _courseFinished();
    }

}
