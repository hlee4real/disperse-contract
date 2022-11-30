// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Disperse is ReentrancyGuard {
    using SafeERC20 for IERC20;
    function disperseNative(address[] memory recipients, uint256[] memory values) external payable {
        for (uint256 i = 0; i < recipients.length; i++){
            (bool sent, ) = (recipients[i]).call{value: values[i]}("");
            require(sent, "Transfer token failed due to errors");
        }
        uint256 balance = address(this).balance;
        if (balance > 0){
            (bool sent, ) = (msg.sender).call{value: balance}("");
            require(sent, "Transfer token failed due to errors");
        }
    }

    function disperseToken(IERC20 token, address[] memory recipients, uint256[] memory values) external nonReentrant {
        uint256 total = 0;
        for (uint256 i = 0; i < recipients.length; i++){
            total += values[i];
        }
        token.safeTransferFrom(msg.sender, address(this), total);
        for (uint256 i = 0; i < recipients.length; i++){
            token.safeTransfer(recipients[i], values[i]);
        }
    }

    function disperseTokenSimple(IERC20 token, address[] memory recipients, uint256[] memory values) external nonReentrant{
        for (uint256 i = 0; i < recipients.length; i++){
            token.safeTransferFrom(msg.sender, recipients[i], values[i]);
        }
    }
}