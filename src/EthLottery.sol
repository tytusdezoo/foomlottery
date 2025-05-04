pragma solidity ^0.8.0;


import "./FoomLottery.sol";

/**
 * @title FOOM Lottery in ETH
 */
contract EthLottery is FoomLottery {
    constructor(IWithdraw _Withdraw,ICancel _Cancel,IHasher _Hasher,address _Token,uint _BetMin)
        FoomLottery(_Withdraw,_Cancel,_Hasher,_Token,_BetMin) {}

    function _balance() internal override returns (uint) {
        return(this.balance);
    }

    function _deposit(uint amount) internal override returns (uint) {
        return(msg.value);
    }

    function _withdraw(address who,uint amount) internal override {
        who.call{ value: _amount }("");
    }
}
