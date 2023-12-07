// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./Tree.sol";

contract DynamicWhitelist {
    using MerkleTree for MerkleTree.Tree;

    // *
    // Events
    // *

    event AddedToWhitelist(address indexed account, uint position);

    // *
    // Storage
    // *

    // The merkle tree containing the whitelist
    MerkleTree.Tree public whitelist;

    constructor(address[] memory _initialAccounts) {
        bytes32[] memory leaves = new bytes32[](_initialAccounts.length);
        for (uint i = 0; i < _initialAccounts.length; i++) {
            leaves[i] = keccak256(abi.encodePacked(_initialAccounts[i]));
        }
        whitelist = MerkleTree.create(leaves);
    }

    // *
    // Public functions
    // *

    // Add an account to the whitelist
    function addToWhitelist(address _account, bytes32[] memory _proof) public {
        // maybe here we would do some more validation on eligibility for
        // whitelisting, e.g. check that the account has a certain balance

        // Add the account to the whitelist.
        whitelist.append(keccak256(abi.encodePacked(_account)), _proof);
        emit AddedToWhitelist(_account, whitelist.length);
    }

    // Check if an account is whitelisted
    function isWhitelisted(address _account, bytes32[] memory _proof) external view returns (bool) {
        return whitelist.verify(keccak256(abi.encodePacked(_account)), _proof);
    }
}