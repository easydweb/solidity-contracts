//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/FunctionsClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/libraries/FunctionsRequest.sol";

contract apiCall is FunctionsClient, ConfirmedOwner {
    using FunctionsRequest for FunctionsRequest.Request;

    constructor() FunctionsClient(router) ConfirmedOwner(msg.sender) {}

    address router = 0xC22a79eBA640940ABB6dF0f7982cc119578E11De;
    uint64 subscriptionId = 290;
    bytes32 donID = 0x66756e2d706f6c79676f6e2d616d6f792d310000000000000000000000000000;

    bytes32 public s_lastRequestId;
    bool isFulfilled = true;
    
    error UnexpectedRequestID(bytes32 requestId);

    uint32 gasLimit = 300000;

    string APIScript =
        "const email = args[1];"
        "const apiResponse = await Functions.makeHttpRequest({"
        "url: `https://promptreality.onrender.com/latestGeneration/${email}`"
        "});"
        "if (apiResponse.error) {"
        "throw Error('Request failed');"
        "}"
        "const { data } = apiResponse;"
        "return Functions.encodeString(data.generation);";

    function apiCallMinAsset(
        string[] calldata args
    ) public returns (bytes32 requestId) {
        isFulfilled = false;
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(APIScript);
        
        if (args.length > 0) req.setArgs(args);
        s_lastRequestId = _sendRequest(
            req.encodeCBOR(),
            subscriptionId,
            gasLimit,
            donID
        );
        return s_lastRequestId;
    }

    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) internal override {
        isFulfilled = true;
    }
}