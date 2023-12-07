// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/utils/math/Math.sol";

library MerkleTree {
    struct Tree {
        bytes32 root;
        uint length;
    }

    // *
    // Merkle functions
    // *

    // create a new merkle tree from an array of leaves
    function create(bytes32[] memory _leaves) public pure returns (Tree memory) {
        require(_leaves.length > 0, "MerkleTree: empty tree");

        // We don't require input leaves to be a power of 2, but we will pad the
        // array with zero hashes to make it a complete binary tree.
        uint d = Math.log2(_leaves.length, Math.Rounding.Ceil);
        uint size = 2 ** d;
        bytes32[] memory nodes = new bytes32[](2 * size - 1);

        // Copy input leaves into the first part of the nodes array.
        for (uint i = 0; i < _leaves.length; i++) {
            nodes[i] = _leaves[i];
        }

        uint j = size;
        for (uint i = 0; i < nodes.length - 1; i += 2) {
            nodes[j] = keccak256(abi.encodePacked(nodes[i], nodes[i + 1]));
            j++;
        }

        return Tree(nodes[nodes.length - 1], _leaves.length);
    }

    // get the root of a merkle tree with given proof
    function root(uint xPos, bytes32[] memory proof) private pure returns (bytes32) {
        // we are assuming the proof starts with the leaf node
        // and ends with the root node
        bytes32 node = proof[0];
        uint i = 1;
        while (i < proof.length) {
            if (xPos % 2 == 0) {
                node = keccak256(abi.encodePacked(node, proof[i]));
            } else {
                node = keccak256(abi.encodePacked(proof[i], node));
            }
            xPos /= 2;
            i++;
        }
        return node;
    }


    // *
    // Tree functions
    // *

    // append a leaf to the tree
    function append(Tree storage tree, bytes32 leaf, bytes32[] memory proof) internal {
        // first account for empty tree
        if (tree.length == 0) {
            tree.root = leaf;
            tree.length = 1;
            return;
        }

        // check that the proof is valid
        require(proof.length == depth(tree), "MerkleTree: invalid proof");

        if (tree.length & (tree.length - 1) == 0) {
            // if the tree is a power of 2, we need to add a new layer
            Tree memory leftTree = tree;

            // create a new tree with the new leaf
            bytes32[] memory leaves = new bytes32[](1);
            leaves[0] = leaf;
            Tree memory rightTree = create(leaves);

            tree.root = keccak256(abi.encodePacked(leftTree.root, rightTree.root));
            tree.length += 1;
        }

        require(root(tree.length, proof) == tree.root, "MerkleTree: invalid proof");
        require(proof[0] == bytes32(0), "MerkleTree: leaf already exists");

        // add leaf to proof
        proof[0] = leaf;
        tree.root = root(tree.length, proof);
        tree.length += 1;
    }

    // verify a proof
    function verify(Tree storage tree, bytes32 leaf, bytes32[] memory proof) internal view returns (bool) {
        // first account for empty tree
        if (tree.length == 0) {
            return false;
        }

        // check that the proof is valid
        require(proof.length == depth(tree), "MerkleTree: invalid proof");

        // check that the root of the proof is the root of the tree
        if (root(tree.length, proof) != tree.root) {
            return false;
        }

        // check that the leaf is in the proof
        if (proof[0] != leaf) {
            return false;
        }

        return true;
    }

    function depth(Tree storage tree) private view returns (uint) {
        return Math.log2(tree.length, Math.Rounding.Ceil) + 1;
    }
}
