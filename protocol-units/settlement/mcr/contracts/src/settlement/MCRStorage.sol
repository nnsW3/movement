// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "forge-std/console.sol";
import "../staking/MovementStaking.sol";

contract MCRStorage {

    IMovementStaking public stakingContract;

    // the number of blocks that can be submitted ahead of the lastAcceptedBlockHeight
    // this allows for things like batching to take place without some attesters locking down the attester set by pushing too far ahead
    // ? this could be replaced by a 2/3 stake vote on the block height to epoch assignment
    // ? however, this protocol becomes more complex as you to take steps to ensure that...
    // ? 1. Block heights have a non-decreasing mapping to epochs
    // ? 2. Votes get accumulated reasonable near the end of the epoch (i.e., your vote is cast for the epoch you vote fore and the next)
    // ? if howevever, you simply allow a race with the tolerance below, both of these are satisfied without the added complexity
    uint256 public leadingBlockTolerance;

    // track the last accepted block height, so that we can require blocks are submitted in order and handle staking effectively
    uint256 public lastAcceptedBlockHeight;

    struct BlockCommitment {
        // currently, to simplify the api, we'll say 0 is uncommitted all other numbers are legitimate heights
        uint256 height;
        bytes32 commitment;
        bytes32 blockId;
    }

    // map each block height to an epoch
    mapping(uint256 => uint256) public blockHeightEpochAssignments;

    // track each commitment from each attester for each block height
    mapping(uint256 => mapping(address => BlockCommitment)) public commitments;

    // track the total stake accumulate for each commitment for each block height
    mapping(uint256 => mapping(bytes32=> uint256)) public commitmentStakes;

    // map block height to accepted block hash 
    mapping(uint256 => BlockCommitment) public acceptedBlocks;

    uint256[50] internal __gap;

}