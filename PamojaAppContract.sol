// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts@4.6.0/token/ERC20/ERC20.sol";

struct Contributor {
    uint256 _id;
    address _address;
    string _username;
}

struct Saving {
    uint256 _id;
    address _creator;
    address[4] _contributors;
    uint256[4] _contributions;
    uint256 _currentRecipientIndex;
    uint256 _amount;
}

contract PamojaAppContract {
    Contributor[] public contributors;
    uint256 public contributorId;
    mapping(address => bool) public contributorExistsInContributors;

    Saving[] public savings;
    uint256 public savingId;

    ERC20 CUSDAlfajoresContract =
        ERC20(0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1);

    event GetContributor(
        uint256 _id,
        address _address,
        string _username,
        bool _isCreated
    );

    event GetSaving(
        uint256 _id,
        address _creator,
        address[4] _contributors,
        uint256[4] _contributions,
        uint256 _amount
    );

    function addContributorToDirectory(string memory _username)
        public
        returns (Contributor memory)
    {
        if (contributorExistsInContributors[msg.sender]) {
            Contributor
                memory _existingConstributor = getContributorFromDirectory(
                    msg.sender
                );
            emit GetContributor(
                _existingConstributor._id,
                _existingConstributor._address,
                _existingConstributor._username,
                false
            );
            return _existingConstributor;
        } else {
            contributors.push(
                Contributor(contributorId++, msg.sender, _username)
            );
            contributorExistsInContributors[msg.sender] = true;
            Contributor memory _newContributor = getContributorFromDirectory(
                msg.sender
            );
            emit GetContributor(
                _newContributor._id,
                _newContributor._address,
                _newContributor._username,
                true
            );
            return _newContributor;
        }
    }

    function getContributorFromDirectory(address _address)
        public
        returns (Contributor memory)
    {
        if (!contributorExistsInContributors[msg.sender]) {
            revert("Contributor does not exist.");
        }

        uint256 contributorIndex = _getContributorIndex(_address);

        Contributor memory fetchedContributor = contributors[contributorIndex];

        emit GetContributor(
            fetchedContributor._id,
            fetchedContributor._address,
            fetchedContributor._username,
            true
        );

        return fetchedContributor;
    }

    function createAmountInSaving(uint256 _amount)
        public
        returns (Saving memory)
    {
        if (!contributorExistsInContributors[msg.sender])
            revert("Contributor does not exist.");

        Saving memory newSaving;
        newSaving._amount = _amount;
        newSaving._id = savingId++;
        newSaving._creator = msg.sender;
        newSaving._contributors[0] = msg.sender;
        newSaving._currentRecipientIndex = 0;
        savings.push(newSaving);

        emit GetSaving(
            newSaving._id,
            newSaving._creator,
            newSaving._contributors,
            newSaving._contributions,
            newSaving._amount
        );

        return newSaving;
    }

    function updateContributorInSaving(
        address _newContributor,
        address _savingCreator,
        uint256 _savingId
    ) public returns (Saving memory) {
        if (!contributorExistsInContributors[_newContributor])
            revert("Contributor does not exist.");

        uint256 savingIndex = 0;

        for (uint256 index = 0; index < contributors.length; index++) {
            Saving memory runningSaving = savings[index];
            if (
                runningSaving._id == _savingId &&
                runningSaving._creator == _savingCreator
            ) {
                savingIndex = index;
                break;
            }
        }

        Saving memory _oldSaving = savings[savingIndex];

        uint256 newContributorIndex = _oldSaving._contributors.length + 1;
        _oldSaving._contributors[newContributorIndex] = _newContributor;

        Saving memory updatedSaving = _oldSaving;

        emit GetSaving(
            updatedSaving._id,
            updatedSaving._creator,
            updatedSaving._contributors,
            updatedSaving._contributions,
            updatedSaving._amount
        );

        return updatedSaving;
    }

    function updateAmountInSaving(uint256 _savingId, address _savingCreator)
        public
        returns (Saving memory)
    {
        if (!contributorExistsInContributors[msg.sender])
            revert("Contributor does not exist.");

        uint256 savingIndex = 0;

        for (uint256 index = 0; index < contributors.length; index++) {
            Saving memory runningSaving = savings[index];
            if (
                runningSaving._id == _savingId &&
                runningSaving._creator == _savingCreator
            ) {
                savingIndex = index;
                break;
            }
        }

        Saving memory _oldSaving = savings[savingIndex];

        uint256 newContributorIndex = _oldSaving._contributors.length + 1;
        _oldSaving._contributors[newContributorIndex] = msg.sender;
        _oldSaving._contributions[newContributorIndex] = _oldSaving._amount;

        Saving memory updatedSaving = _oldSaving;

        emit GetSaving(
            updatedSaving._id,
            updatedSaving._creator,
            updatedSaving._contributors,
            updatedSaving._contributions,
            updatedSaving._amount
        );

        return updatedSaving;
    }

    function getSaving(uint256 _savingId, address _savingCreator)
        public
        returns (Saving memory)
    {
        if (!contributorExistsInContributors[msg.sender]) {
            revert("Contributor does not exist.");
        }
        uint256 savingIndex = _getSavingIndex(_savingId, _savingCreator);

        Saving memory updatedSaving = savings[savingIndex];

        emit GetSaving(
            updatedSaving._id,
            updatedSaving._creator,
            updatedSaving._contributors,
            updatedSaving._contributions,
            updatedSaving._amount
        );
        return updatedSaving;
    }

    function getSavingsOfContributor(address _contributor)
        public
    {
        for (
            uint256 savingIndex = 0;
            savingIndex < savings.length;
            savingIndex++
        ) {
            Saving memory runningSaving = savings[savingIndex];

            if (runningSaving._creator == _contributor) {
                emit GetSaving(
                    runningSaving._id,
                    runningSaving._creator,
                    runningSaving._contributors,
                    runningSaving._contributions,
                    runningSaving._amount
                );
                continue;
            }

            for (
                uint256 contributorIndex = 0;
                contributorIndex < runningSaving._contributors.length;
                contributorIndex++
            ) {
                address runningContributor = runningSaving._contributors[
                    contributorIndex
                ];

                if (_contributor == runningContributor) {
                    emit GetSaving(
                        runningSaving._id,
                        runningSaving._creator,
                        runningSaving._contributors,
                        runningSaving._contributions,
                        runningSaving._amount
                    );
                    break;
                }
            }
        }
    }

    function _getContributorIndex(address _contributorAddress)
        private
        view
        returns (uint256)
    {
        uint256 locationIndex = 0;

        for (uint256 index = 0; index < contributors.length; index++) {
            if (contributors[index]._address == _contributorAddress) {
                locationIndex = index;
                break;
            }
        }

        return locationIndex;
    }

    function _getSavingIndex(uint256 _savingId, address _savingCreator)
        private
        view
        returns (uint256)
    {
        uint256 savingIndex = 0;

        for (uint256 index = 0; index < contributors.length; index++) {
            Saving memory runningSaving = savings[index];
            if (
                runningSaving._id == _savingId &&
                runningSaving._creator == _savingCreator
            ) {
                savingIndex = index;
                break;
            }
        }

        return savingIndex;
    }

    // function _checkIfSenderAlreadyContributed(Saving memory _oldSaving)
    //     private
    //     view
    //     returns (bool)
    // {
    //     bool senderAlreadyContributed;

    //     for (uint256 i = 0; i < _oldSaving._contributors.length; i++) {
    //         if (_oldSaving._contributors[i] == msg.sender) {
    //             senderAlreadyContributed = true;
    //             break;
    //         }
    //     }
    //     return senderAlreadyContributed;
    // }
}
