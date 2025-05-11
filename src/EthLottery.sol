pragma solidity ^0.8.0;


import "./Lottery.sol";

/**
 * @title FOOM Lottery in ETH
 */
contract EthLottery is Lottery {
    constructor(IWithdraw _Withdraw,ICancel _Cancel,IUpdate _Update,IERC20 _Token,uint _BetMin)
        Lottery(_Withdraw,_Cancel,_Update,_Token,_BetMin) {}

    function _balance() internal view override returns (uint) {
        return(address(this).balance);
    }

    function _deposit(uint amount) internal override returns (uint) {
        require(amount==msg.value);
        return(msg.value);
    }

    function _withdraw(address who,uint amount) internal override {
        (bool ok,)=who.call{ value: amount }("");
        require(ok);
    }
}
