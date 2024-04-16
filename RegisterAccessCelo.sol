// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// import "@openzeppelin/contracts@4.6.0/token/ERC20/ERC20.sol";

struct Contributor {
    uint256 _id;
    address _address;
    string _username;
}

struct Saving {
    uint256 _id;
    address _creatingContributor;
}

contract PamojaApp {
    Contributor[] private allContributors;
    uint256 private contributorId;
    mapping(address => bool) private contributorExists;

    Saving[] private allSavings;
    uint256 private savingId;

    mapping(uint256 => mapping(uint256 => address))
        private allContributorsInSavings;
    mapping(uint256 => mapping(uint256 => uint256))
        private allContributionsOfSavings;
    mapping(uint256 => uint256) private allRoundsOfSavings;
    mapping(uint256 => uint256) private allNumberOfContributorsInSavings;
    mapping(uint256 => uint256) private allAmountsHeldInSavings;

    Saving[] private contributorSavings;

    // ERC20 CUSD = ERC20(0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1);

    event GetContributor(uint256 _id, address _address, string _username);

    event GetSaving(uint256 _id, address _creatingContributor);

    function addContributorToDirectory(
        string memory _username,
        address _contributorAddress
    ) public returns (Contributor memory) {
        if (checkIfContributorExists(_contributorAddress)) {
            Contributor
                memory existingContributor = getContributorFromDirectory(
                    _contributorAddress
                );

            return existingContributor;
        } else {
            allContributors.push(
                Contributor(contributorId++, _contributorAddress, _username)
            );
            contributorExists[_contributorAddress] = true;
            Contributor memory newContributor = getContributorFromDirectory(
                _contributorAddress
            );
            return newContributor;
        }
    }

    function getContributorFromDirectory(address _address)
        public
        view
        returns (Contributor memory)
    {
        if (!checkIfContributorExists(_address)) {
            revert("Contributor does not exist.");
        }

        uint256 contributorIndex = _getContributorIndex(_address);

        Contributor memory fetchedContributor = allContributors[
            contributorIndex
        ];

        return fetchedContributor;
    }

    function createAmountInSaving(uint256 _amount, address _creatingContributor)
        public
        returns (Saving memory)
    {
        if (!checkIfContributorExists(_creatingContributor))
            revert("Contributor does not exist.");

        Saving memory newSaving;
        newSaving._id = savingId++;
        newSaving._creatingContributor = _creatingContributor;
        allSavings.push(newSaving);

        allContributorsInSavings[newSaving._id][0] = _creatingContributor;
        allContributionsOfSavings[newSaving._id][0] = _amount;

        allRoundsOfSavings[newSaving._id] = 0;

        allNumberOfContributorsInSavings[newSaving._id] = 1;

        allAmountsHeldInSavings[newSaving._id] = _amount;

        return newSaving;
    }

    function updateContributorInSaving(
        uint256 _savingId,
        address _creatingContributor,
        address _newContributor,
        uint256 _amount
    ) public returns (Saving memory) {
        if (
            !checkIfContributorExists(_creatingContributor) ||
            !checkIfContributorExists(_newContributor)
        ) revert("Contributor does not exist.");

        uint256 oldNumberOfContributorsInSaving = allNumberOfContributorsInSavings[
                _savingId
            ];

        allContributorsInSavings[_savingId][
            oldNumberOfContributorsInSaving
        ] = _newContributor;

        uint256 oldAmountCurrentlyHeldInSavings = allAmountsHeldInSavings[
            _savingId
        ];
        uint256 newAmountCurrentlyHeldInSavings = oldAmountCurrentlyHeldInSavings +
                _amount;

        allContributionsOfSavings[_savingId][
            oldNumberOfContributorsInSaving
        ] = newAmountCurrentlyHeldInSavings;

        uint256 newNumberOfContributorsInSavings = allNumberOfContributorsInSavings[
                _savingId
            ];

        allNumberOfContributorsInSavings[
            _savingId
        ] = newNumberOfContributorsInSavings;

        allAmountsHeldInSavings[_savingId] = newAmountCurrentlyHeldInSavings;

        return allSavings[_savingId];
    }

    function getSaving(uint256 _savingId, address _savingCreator)
        public
        view
        returns (Saving memory)
    {
        if (!checkIfContributorExists(_savingCreator)) {
            revert("Contributor does not exist.");
        }

        uint256 savingIndex = _getSavingIndex(_savingId, _savingCreator);

        return allSavings[savingIndex];
    }

    function getAllSavings() public view returns (Saving[] memory) {
        return allSavings;
    }

    function getContributionsOfContributor(address _contributorAddress)
        public
        view
        returns (uint256[] memory)
    {
        uint256[] memory contributions = new uint256[](savingId);
        uint256 contributionsIndex = 0;

        for (
            uint256 savingsIndex = 0;
            savingsIndex < savingId;
            savingsIndex++
        ) {
            for (
                uint256 contributorIndex = 0;
                contributorIndex <
                allNumberOfContributorsInSavings[savingsIndex];
                contributorIndex++
            ) {
                if (
                    allContributorsInSavings[savingsIndex][contributorIndex] ==
                    _contributorAddress
                ) {
                    contributions[
                        contributionsIndex
                    ] = allContributionsOfSavings[savingsIndex][
                        contributorIndex
                    ];
                    contributionsIndex++;
                }
            }
        }

        return contributions;
    }

    function getContributionsOfSavings(uint256 _savingId)
        public
        view
        returns (uint256[] memory)
    {
        uint256[] memory contributions = new uint256[](
            allNumberOfContributorsInSavings[_savingId]
        );

        for (
            uint256 contributorIndex = 0;
            contributorIndex < allNumberOfContributorsInSavings[_savingId];
            contributorIndex++
        ) {
            contributions[contributorIndex] = allContributionsOfSavings[
                _savingId
            ][contributorIndex];
        }

        return contributions;
    }

    // function getContributors(uint256 _savingId)
    //     public
    //     view
    //     returns (uint256[] memory)
    // {
    //     uint256[] memory contributions = new uint256[](savingId);
    //     uint256 contributionsIndex = 0;

    //     for (
    //         uint256 savingsIndex = 0;
    //         savingsIndex < savingId;
    //         savingsIndex++
    //     ) {
    //         for (
    //             uint256 contributorIndex = 0;
    //             contributorIndex <
    //             allNumberOfContributorsInSavings[savingsIndex];
    //             contributorIndex++
    //         ) {
    //             if (
    //                 allContributorsInSavings[savingsIndex][contributorIndex] ==
    //                 _contributorAddress
    //             ) {
    //                 contributions[
    //                     contributionsIndex
    //                 ] = allContributionsOfSavings[savingsIndex][
    //                     contributorIndex
    //                 ];
    //                 contributionsIndex++;
    //             }
    //         }
    //     }

    //     return contributions;
    // }

    function getAllContributors() public view returns (Contributor[] memory) {
        return allContributors;
    }

    // function getallNumberOfContributorsInSavings()
    //     public
    //     view
    //     returns (mapping(uint256 => uint256) memory)
    // {
    //     return allNumberOfContributorsInSavings;
    // }

    function checkIfContributorExists(address _address)
        public
        view
        returns (bool)
    {
        return contributorExists[_address];
    }

    function _getNumberOfContributorSavings(address _contributor)
        private
        view
        returns (uint256)
    {
        uint256 numberOfContributorSavings = 0;

        for (
            uint256 savingIndex = 0;
            savingIndex < allSavings.length;
            savingIndex++
        ) {
            Saving memory runningSaving = allSavings[savingIndex];

            if (runningSaving._creatingContributor == _contributor) {
                numberOfContributorSavings++;
                continue;
            }

            for (
                uint256 contributorIndex = 0;
                contributorIndex < 5;
                contributorIndex++
            ) {
                address runningContributor = msg.sender;

                if (_contributor == runningContributor) {
                    numberOfContributorSavings++;
                    break;
                }
            }
        }

        return numberOfContributorSavings;
    }

    function _getContributorIndex(address _contributorAddress)
        private
        view
        returns (uint256)
    {
        uint256 locationIndex = 0;

        for (uint256 index = 0; index < allContributors.length; index++) {
            if (allContributors[index]._address == _contributorAddress) {
                locationIndex = index;
                break;
            }
        }

        return locationIndex;
    }

    function _getSavingIndex(uint256 _savingId, address _creatingContributor)
        private
        view
        returns (uint256)
    {
        uint256 savingIndex = 0;

        for (uint256 index = 0; index < allContributors.length; index++) {
            Saving memory runningSaving = allSavings[index];
            if (
                runningSaving._id == _savingId &&
                runningSaving._creatingContributor == _creatingContributor
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

// _username: andrewkimjoseph
// _contributorAddress: 0xdaB7EB2409fdD974CF93357C61aEA141729AEfF5

// _username: chrisbakke
// _contributorAddress: 0xE49B05F2c7DD51f61E415E1DFAc10B80074B001A

// _amount: 5
// _creatingContributor: 0xdaB7EB2409fdD974CF93357C61aEA141729AEfF5

// _savingId: 0
// _creatingContributor: 0xdaB7EB2409fdD974CF93357C61aEA141729AEfF5
// _newContributor: 0xE49B05F2c7DD51f61E415E1DFAc10B80074B001A
// _amount: 10
