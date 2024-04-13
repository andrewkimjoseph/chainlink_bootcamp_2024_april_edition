// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

struct Contributor {
    address id;
    string username;
}

struct Saving {
    uint256 id;
    address creator;
    address[4] contributors;
    uint256[4] contributions;
    uint256 currentRecipientIndex;
}

enum TransactionNature {
    DEPOSIT,
    WITHDRAWAL
}

struct Transaction {
    Contributor contributor;
    Saving saving;
    TransactionNature nature;
}

contract PamojaAppSavingsContract {
    Contributor[] public contributors;
    mapping(address => bool) public contributorExistsInContributors;
    uint256 public savingId;

    Saving[] public savings;
    mapping(address => bool) public contributorExistsInSavings;

    IERC20 CUSDAlfajoresContract =
        IERC20(0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1);

    function addContributor(string memory username) public {
        if (contributorExistsInContributors[msg.sender]) {
            revert("Contributor already exists.");
        }
        contributors.push(Contributor(msg.sender, username));
    }

    function getContributor(address id)
        public
        view
        returns (Contributor memory)
    {
        if (!contributorExistsInContributors[msg.sender]) {
            revert("Contributor does not exist.");
        }

        uint256 locationIndex = 0;

        for (uint256 index = 0; index < contributors.length; index++) {
            if (contributors[index].id == id) {
                locationIndex = index;
            }
        }

        return contributors[locationIndex];
    }

    function createSaving(uint256 contribution) public {
        bool success = CUSDAlfajoresContract.transfer(
            address(this),
            contribution
        );

        if (!success) {
            revert("Savings creation failed.");
        }

        Saving memory newSaving;
        newSaving.id = savingId++;
        newSaving.creator = msg.sender;
        newSaving.contributors[0] = msg.sender;
        newSaving.currentRecipientIndex = 0;
        savings.push(newSaving);
    }

    function withdrawSaving(Saving memory saving, address recipient)
        public
        returns (bool)
    {
        if (msg.sender != saving.creator) {
            revert("Only the creator of a saving can make a withdrawal.");
        }

        if (recipient == msg.sender && saving.currentRecipientIndex > 0) {
            revert("It seems you already withdrew to your account.");
        }

        uint256 withdrawalAmount = 0;

        for (uint256 index = 0; index < saving.contributions.length; index++) {
            withdrawalAmount += saving.contributions[index];
        }

        bool success = CUSDAlfajoresContract.transfer(
            address(this),
            withdrawalAmount
        );

        if (success) {
            for (
                uint256 index = 0;
                index < savings.length;
                index++
            ) {
                if (saving.id ==savings[index].id){
                    savings[index].currentRecipientIndex++
                }
            }
        }

        return success;
    }
}
