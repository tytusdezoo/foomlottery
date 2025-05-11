pragma solidity ^0.8.0;


import "./Lottery.sol";

/**
 * @title FOOM Lottery
 */
contract FoomLottery is Lottery {
    constructor(IWithdraw _Withdraw,ICancel _Cancel,IUpdate _Update,IERC20 _Token,uint _BetMin)
        Lottery(_Withdraw,_Cancel,_Update,_Token,_BetMin) {}

    function _balance() internal view override returns (uint) {
        return(token.balanceOf(address(this)));
    }

    function _deposit(uint _amount) internal override returns (uint) {
        token.transferFrom(msg.sender, address(this), _amount); /* success tests inside token contract */
        return(_amount);
    }

    function _withdraw(address _who,uint _amount) internal override {
        token.transferFrom(address(this), _who, _amount); /* success tests inside token contract */
    }
}
