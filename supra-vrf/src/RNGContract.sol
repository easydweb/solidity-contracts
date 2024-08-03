// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface ISupraRouter {
    function generateRequest(
        string memory _functionSig,
        uint8 _rngCount,
        uint256 _numConfirmations,
        uint256 _clientSeed,
        address _clientWalletAddress
    ) external returns (uint256);

    function generateRequest(
        string memory _functionSig,
        uint8 _rngCount,
        uint256 _numConfirmations,
        address _clientWalletAddress
    ) external returns (uint256);
}

contract RNGContract {
    address supraAddr;
    address supraClientAddress;

    mapping(uint256 => uint256[]) rngForNonce;

    constructor(address supraSC) {
        supraAddr = supraSC;
        supraClientAddress = msg.sender;
    }

    function rng() external returns (uint256) {
        // Amount of random numbers to request
        uint8 rngCount = 5;
        // Amount of confirmations before the request is considered complete/final
        uint256 numConfirmations = 1;
        uint256 nonce = ISupraRouter(supraAddr).generateRequest(
            "requestCallback(uint256,uint256[])",
            rngCount,
            numConfirmations,
            supraClientAddress
        );
        return nonce;
    }

    function requestCallback(
        uint256 _nonce,
        uint256[] memory _rngList
    ) external {
        require(
            msg.sender == supraAddr,
            "Only the Supra Router can call this function."
        );
        uint8 i = 0;
        uint256[] memory x = new uint256[](_rngList.length);
        rngForNonce[_nonce] = x;
        for (i = 0; i < _rngList.length; i++) {
            rngForNonce[_nonce][i] = _rngList[i] % 100;
        }
    }

    function viewRngForNonce(
        uint256 nonce
    ) external view returns (uint256[] memory) {
        return rngForNonce[nonce];
    }
}
