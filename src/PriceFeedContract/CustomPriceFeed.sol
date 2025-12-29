// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract Pricefeed is AggregatorV3Interface {
    struct Round {
        int256 answer;
        uint256 startedAt;
        uint256 updatedAt;
        uint80 answeredInRound;
    }

    uint8 private constant DECIMALS = 8;
    uint256 private constant VERSION = 4;

    uint80 private s_latestRoundId;
    mapping(uint80 => Round) private s_rounds;

    constructor(int256 initialAnswer) {
        _newRound(initialAnswer);
    }

    /* ========== ORACLE CONTROL (YOU) ========== */

    function updateAnswer(int256 newAnswer) external {
        _newRound(newAnswer);
    }

    function _newRound(int256 answer) internal {
        s_latestRoundId++;
        s_rounds[s_latestRoundId] = Round({
            answer: answer,
            startedAt: block.timestamp,
            updatedAt: block.timestamp,
            answeredInRound: s_latestRoundId
        });
    }

    /* ========== AggregatorV3Interface ========== */

    function decimals() external pure override returns (uint8) {
        return DECIMALS;
    }

    function description() external pure override returns (string memory) {
        return "My Custom Aggregator V3 (Manual Oracle)";
    }

    function version() external pure override returns (uint256) {
        return VERSION;
    }

    function latestRoundData()
        external
        view
        override
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        Round memory r = s_rounds[s_latestRoundId];
        return (
            s_latestRoundId,
            r.answer,
            r.startedAt,
            r.updatedAt,
            r.answeredInRound
        );
    }

    function getRoundData(
        uint80 _roundId
    )
        external
        view
        override
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        Round memory r = s_rounds[_roundId];
        require(r.updatedAt != 0, "No data for round");
        return (
            _roundId,
            r.answer,
            r.startedAt,
            r.updatedAt,
            r.answeredInRound
        );
    }
}
