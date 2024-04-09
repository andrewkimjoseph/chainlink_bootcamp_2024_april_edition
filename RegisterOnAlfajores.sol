// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
 
contract RegisterOnAlfajores {
    string private info;

    function getInfo() public view returns (string memory) {
        return info;
    }

    function setInfo(string memory _info) public {
        info = _info;
    }
}


// Network Deployed: Celo Alfajores
// Address Deployed: 0x5bc103a9bC610a10ad5E036c5c8E3bf64D7d9Edb

