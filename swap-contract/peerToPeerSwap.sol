// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;
import "./TransferHelper.sol";
import "./SafeMath.sol";
contract peerToPeerSwap{
    using SafeMath  for uint;

    struct Amount {
        uint256 token0AmountLocked;
        uint256 token1AmountExpected;
        uint256 timestamp;
    }
    uint constant lockPeriod = 86400; //seconds in a day 
    /**
    * token1 is swapped-in, token0 is swapped-out
    * token0 locker locks in assets, then token1 swapper swaps in token1 in exchange for token0
    * The following hashmap maps KECCAK(token0,token1) => token0Locker => token1Swapper => Amount 
    * 
    */
    mapping (uint256 => mapping(address => mapping (address => Amount))) public swapAccount;
    /**
     * @dev token0 locker locks in token
     */
    function lockToken(address token0, address token1, address swapper, uint256 token0Amount, uint256 token1Amount) public {
        uint256 pair = uint(keccak256(abi.encodePacked(token0,token1)));
        TransferHelper.safeTransferFrom(token0, msg.sender, address(this), token0Amount);
        require(swapAccount[pair][msg.sender][swapper].token0AmountLocked == 0);
        swapAccount[pair][msg.sender][swapper].token0AmountLocked = token0Amount;
        swapAccount[pair][msg.sender][swapper].token1AmountExpected = token1Amount;
        swapAccount[pair][msg.sender][swapper].timestamp = block.timestamp;
    }

    function withdrawTokens(address token0, address token1, address swapper, address to) public {
        uint256 pair = uint(keccak256(abi.encodePacked(token0,token1)));
        require(block.timestamp >= swapAccount[pair][msg.sender][swapper].timestamp.add(lockPeriod));
        TransferHelper.safeTransfer(token0, to, swapAccount[pair][msg.sender][swapper].token0AmountLocked);
        swapAccount[pair][msg.sender][swapper].token0AmountLocked = 0;
        swapAccount[pair][msg.sender][swapper].token1AmountExpected = 0;
        
    }    
    function swap(address token0, address token1, address locker, uint256 token1Amount, address to) public {
        uint256 pair = uint(keccak256(abi.encodePacked(token0,token1)));
        require(block.timestamp < swapAccount[pair][locker][msg.sender].timestamp.add(lockPeriod));
        require(token1Amount >= swapAccount[pair][locker][msg.sender].token1AmountExpected);
        TransferHelper.safeTransferFrom(token1, msg.sender, locker, token1Amount);
        TransferHelper.safeTransfer(token0, to, swapAccount[pair][locker][msg.sender].token0AmountLocked);
        swapAccount[pair][locker][msg.sender].token0AmountLocked = 0;
        swapAccount[pair][locker][msg.sender].token1AmountExpected = 0;
    }
}