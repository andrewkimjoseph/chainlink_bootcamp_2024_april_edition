// Begin

// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
 
contract Register {
    string private info;

    function getInfo() public view returns (string memory) {
        return info;
    }

    function setInfo(string memory _info) public {
        info = _info;
    }
}

// Deployed at: 0xd840216413385AbD22C022fE0A6c68f79D98D3f7

// End