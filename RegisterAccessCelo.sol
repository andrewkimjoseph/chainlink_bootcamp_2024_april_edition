// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
 
contract RegisterAccessCelo {
        string[] private info;
        address public owner;
        mapping (address => bool) public allowlist;
 
        constructor() {
            owner = msg.sender;
            allowlist[msg.sender] = true;
        } 
 
        event InfoChange(string oldInfo, string newInfo); 
 
        modifier onlyOwner {
            require(msg.sender == owner,"Only owner");
            _;
        }
 
        modifier onlyAllowlist {
            require(allowlist[msg.sender] == true, "Only allowlist");
            _;
        } 
 
        function getInfo(uint index) public view returns (string memory) {
            return info[index];
        }
 
        function setInfo(uint index, string memory _info) public onlyAllowlist {
            emit InfoChange (info[index], _info);
            info[index] = _info;
        }
 
        function addInfo(string memory _info) public onlyAllowlist returns (uint index) {
            info.push(_info);
            index = info.length - 1;
        }
   
        function listInfo() public view returns (string[] memory) {
            return info;
        }
 
        function addMember (address _member) public onlyOwner {        
            allowlist[_member] = true;
        }
 
        function delMember (address _member) public onlyOwner {
            allowlist[_member] = false;
        }    
}


// Network Deployed: Celo Alfajores
// Address Deployed:
// 1. 0xDE2116AB07393F2F03B5dB3dc6aB3946a488641a

// 0x0Ea89A815b8fCB113FC7525F1e720CEF392ceFdB
