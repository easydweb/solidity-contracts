// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract VerkleTree {
    struct Node {
        bytes32 hash;
        mapping(uint8 => Node) children;
    }

    Node public root;

    constructor() {
        root.hash = 0;
    }

    function insert(bytes32 _hash, uint8[] memory _path) public {
        Node storage currentNode = root;
        for (uint256 i = 0; i < _path.length; i++) {
            if (currentNode.children[_path[i]].hash == bytes32(0)) {
                currentNode.children[_path[i]].hash = keccak256(
                    abi.encodePacked(currentNode.hash, _path[i])
                );
            }
            currentNode = currentNode.children[_path[i]];
        }
        currentNode.hash = _hash;
    }

    function verify(
        bytes32 _hash,
        uint8[] memory _path,
        bytes32[] memory _proof
    ) public view returns (bool) {
        Node storage currentNode = root;
        for (uint256 i = 0; i < _path.length; i++) {
            if (i < _proof.length) {
                if (currentNode.children[_path[i]].hash != _proof[i]) {
                    return false;
                }
            }
            currentNode = currentNode.children[_path[i]];
        }
        return currentNode.hash == _hash;
    }
}
