// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./IERC20.sol";

error ADDRESS_ZERO();
error INVALID_AMOUNT();
error INSUFFICIENT_AMOUNT();
error USER_HAS_NO_STAKE();
error NO_REWARD_TO_CLIAM();

contract Staking {

    address token;
    uint8 rewardRate;

    event stakingSuccessful (address _staker, uint256 _amount); 
    event claimSuccessful (address _staker, uint256 _amount); 
    event unStakeSuccessful (address _staker, uint _amount);

    constructor (uint8 _rewardRate,address _token) {
        rewardRate = _rewardRate;
        token = _token;
    }

    struct StakeInfo {
        uint256 amountStaked;
        uint256 timeStaked;
        uint256 reward;
    }

    mapping(address => StakeInfo) stakes;

    // function stake
    function stake (uint256 _amount) external {
        if(msg.sender == address(0)) {
            revert ADDRESS_ZERO();
        }

        if(_amount <= 0) {
            revert INVALID_AMOUNT();
        }

        if(IERC20(token).balanceOf(msg.sender) < _amount) {
            revert INSUFFICIENT_AMOUNT();
        }

        require(IERC20(token).transferFrom(msg.sender, address(this), _amount), "failed to transfer");

        stakes[msg.sender] = StakeInfo(_amount, block.timestamp, 0);

        emit stakingSuccessful(msg.sender, _amount);
    }

    // calculate reward func
    function calculateReward () public view returns (uint256) {
        
        uint256 _callerStake = stakes[msg.sender].amountStaked;

        if(_callerStake <= 0) {
            revert USER_HAS_NO_STAKE(); 
        }

        return (block.timestamp - stakes[msg.sender].timeStaked) * rewardRate * _callerStake ;
    }

    // unstake function
    function unStake () external {

        if(msg.sender == address(0)) {
            revert ADDRESS_ZERO();
        }

        if(stakes[msg.sender].amountStaked <= 0) {
            revert USER_HAS_NO_STAKE();
        }

        StakeInfo memory _staker = stakes[msg.sender];
        uint256 _reward = _staker.reward + calculateReward();

        stakes[msg.sender].reward = 0;
        stakes[msg.sender].timeStaked = 0;
        stakes[msg.sender].amountStaked = 0;

        IERC20(token).transfer(msg.sender, _staker.amountStaked + _reward);
    }

    // cliam reward function
    function cliamReward () external {

        if(stakes[msg.sender].amountStaked <= 0) {
            revert NO_REWARD_TO_CLIAM();
        }

        uint256 _reward = stakes[msg.sender].reward + calculateReward();

        stakes[msg.sender].reward = 0;
        stakes[msg.sender].timeStaked = block.timestamp;

        IERC20(token).transfer(msg.sender, _reward);

        emit claimSuccessful(msg.sender, _reward);
    }

    // checkUserStakeInfo
    function checkUserStakeInfo (address _user) external view returns (StakeInfo memory) {
        return stakes[_user];
    }

}