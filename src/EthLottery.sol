pragma solidity ^0.8.0;

import "./Lottery.sol";
import {Test, console} from "forge-std/Test.sol";

/**
 * @title FOOM Lottery in ETH
 */
contract EthLottery is Lottery {
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
        return(address(this).balance);
    }

    function _deposit(uint amount) internal override returns (uint) {
        require(amount==msg.value);
        return(msg.value);
    }

    function _withdraw(address who,uint amount) internal override {
        (bool ok,)=who.call{ value: amount }("");
        if(ok){ return;}
        (ok,)=generator.call{ value: amount }("");
        if(ok){ return;}
        (ok,)=owner.call{ value: amount }("");
        revert("failed to send funds");
    }
}
