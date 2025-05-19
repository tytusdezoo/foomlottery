pragma solidity ^0.8.0;


import "./Lottery.sol";

/**
 * @title FOOM Lottery
 */
contract FoomLottery is Lottery {
    constructor(IWithdraw _Withdraw,
                ICancel _Cancel,
                IUpdate1 _Update1,
                IUpdate3 _Update3,
                IUpdate5 _Update5,
                IUpdate11 _Update11,
                IUpdate21 _Update21,
                IUpdate44 _Update44,
                IUpdate89 _Update89,
                IUpdate179 _Update179,
                IERC20 _Token,
                uint _BetMin) 
        Lottery(
                _Withdraw,
                _Cancel,
                _Update1,
                _Update3,
                _Update5,
                _Update11,
                _Update21,
                _Update44,
                _Update89,
                _Update179,
                _Token,
                _BetMin) {}

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
