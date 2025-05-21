pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IWithdraw { // 48439 constraints
  function verifyProof( uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[7] calldata _pubSignals) external view returns (bool); // 240419 gas
}
interface ICancel { // 686 c
  function verifyProof( uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[1] calldata _pubSignals) external view returns (bool); // 198961 g
}
interface IUpdate1 { // 86817 c (3s)
  function verifyProof( uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[5] calldata _pubSignals) external view returns (bool); // 222057 g
}
interface IUpdate3 { // 175585 c (6s)
  function verifyProof( uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[7] calldata _pubSignals) external view returns (bool); // 235470 g
}
interface IUpdate5 { // 264353 c (9s)
  function verifyProof( uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[9] calldata _pubSignals) external view returns (bool); // 248887 g
}
interface IUpdate11 { // 530657 c (16s)
  function verifyProof( uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[15] calldata _pubSignals) external view returns (bool); // 289131 g
}
interface IUpdate21 { // 974497 c (24s)
  function verifyProof( uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[25] calldata _pubSignals) external view returns (bool); // 356104 g
}
interface IUpdate44 { // 1995329 c (340GvRAM+15GRAM,49s)
  function verifyProof( uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[48] calldata _pubSignals) external view returns (bool); // 510074 g
}
interface IUpdate89 { // 3992609 c (380GvRAM+29GRAM,96s)
  function verifyProof( uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[93] calldata _pubSignals) external view returns (bool); // 811439 g
}
interface IUpdate179 { // 7987169 c (380vRAM+56GRAM,172s) // cpp: 7GRAM, 20s (5m user)
  function verifyProof( uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[183] calldata _pubSignals) external view returns (bool); // 1415063 g
}

/**
 * @title FOOM Lottery
 */
contract Lottery {
    IERC20 public immutable token; // FOOM token
    IWithdraw public immutable withdraw;
    ICancel public immutable cancel;
    IUpdate1 public immutable update1;
    IUpdate3 public immutable update3;
    IUpdate5 public immutable update5;
    IUpdate11 public immutable update11;
    IUpdate21 public immutable update21;
    IUpdate44 public immutable update44;
    IUpdate89 public immutable update89;
    IUpdate179 public immutable update179;

    uint public constant FIELD_SIZE = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    uint public constant merkleTreeLevels = 32 ; // number of Merkle Tree levels
    uint public constant periodBlocks = 16384 ; // number of blocks in a period
    uint public          betMin; // TODO: set to constant later !
    uint public constant betPower1 = 10; // power of the first bet = 1024
    uint public constant betPower2 = 16; // power of the second bet = 65536
    uint public constant betPower3 = 22; // power of the third bet = 4194304
    uint public constant betsMax = 250; // maximum number of bets in queue, max 8bit
    uint public constant maxUpdate = 179; // maximum number of bets in queue to insert
    uint public constant dividendFeePerCent = 4; // 4% of dividends go to the shareholders
    uint public constant generatorFeePerCent = 1; // 1% of dividends go to the generator
    uint public constant maxBalance = 2**108; // maximum balance of a user and maximum size of bets in period
    uint private constant _open = 1;
    uint private constant _closed = 2;

    // keep together
    struct Data {
        uint64 periodStartBlock;
        uint64 commitBlock;
        uint32 nextIndex;
        uint32 dividendPeriod; // current dividend period
        uint8 betsStart; // index of last commited bet
        uint8 betsIndex; // index of the next slot in bet queue (>=1)
        uint8 commitIndex; // number of bets to insert into tree + 1 (>=1)
        uint8 status;
    }
    Data public D;
    uint128 public currentBalance = 1; // sum of available funds in wallets
    uint public lastRoot; // current tree root
    uint public commitHash; //
    uint public commitBlockHash; //
    address public owner;
    address public generator;

    // investment parameters
    struct Wallet {
        uint112 shares; // last balance eligible for dividend
        uint112 balance; // current balance of user
    	uint16 lastDividendPeriod; // last processed dividend period of user's tokens
    	uint16 nextWithdrawPeriod; // next withdrawal possible after this period
    }
    mapping (address => Wallet) wallets;
    struct Period {
        uint128 bets; // total bet volume in period
        uint128 shares; // total eligible funds in period
    }
    mapping(uint => Period) public periods;
    // betting parameters
    mapping(uint => uint) public bets;
    mapping (uint => uint) public nullifier; // nullifier hash for each bet
    // mertkeltree
    mapping(uint => uint) public roots;

    // constructor
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
                uint _BetMin) {
        withdraw = _Withdraw;
        cancel = _Cancel;
        update1 = _Update1;
        update3 = _Update3;
        update5 = _Update5;
        update11 = _Update11;
        update21 = _Update21;
        update44 = _Update44;
        update89 = _Update89;
        update179 = _Update179;
        token = _Token;
        betMin = _BetMin;
        owner = msg.sender;
        generator = msg.sender;
        D.periodStartBlock = uint64(block.number);
        D.dividendPeriod = uint32(1);
        D.status = uint8(_open);
        D.nextIndex = uint32(1);
        commitHash = _open;
        commitBlockHash = _open;
        wallets[owner] = Wallet(uint112(1),uint112(1),uint16(D.dividendPeriod),uint16(0));
        periods[D.dividendPeriod]=Period(1,1);
        // 16660660614175348086322821347366010925591495133565739687589833680199500683712
        // leaf=0x24d599883f039a5cb553f9ec0e5998d58d8816e823bd556164f72aef0ef7d9c0 mimcsponge([keccak(foom)<<4,0,0])
        for(uint i=0;i<betsMax;i++){ // no more gaspump
            // 5830730410484677323135938457349698867014480012952733190564065746678058771744 sha256("foom")<<4
            bets[i]=0x0ce413930404e34f411b5117deff2a1a062c27b1dba271e133a9ffe91eeae520; // sha256("foom")<<4
        }
        lastRoot=0x25439a05239667bccd12fc3bd280a29a02728ed44410446cbd51a27cda333b00;
        //for(uint i=0;i<rootsMax;i++){
        //    // 16855017158405950531512674278374442951963327874331982618070277997451625577216
        //    roots[i] = 0x25439a05239667bccd12fc3bd280a29a02728ed44410446cbd51a27cda333b00;
        //}
        emit LogBetIn(0,0x0ce413930404e34f411b5117deff2a1a062c27b1dba271e133a9ffe91eeae520);
        //emit LogBetHash(0,0x0ce413930404e34f411b5117deff2a1a062c27b1dba271e133a9ffe91eeae520,0);
    }

/* most important functions */

    /**
     * @dev Pray to the terrestrial God !!!
     * To pray effectively, begin by finding a quiet space, addressing God respectfully, expressing gratitude for blessings, and acknowledging your needs and concerns.
     * Prayers can be done out loud or silently, and sincerity is more important than elaborate language. End your prayer by reaffirming your faith.
     * A well conducted prayer increases your odds in the lottery significantly.
     */
    function pray(bytes32[] calldata prayer) payable external {
        emit LogPrayer(prayer);
    }

/* lottery functions */

    /**
     * @dev Calculate ticket price
     */
    function getAmount(uint _power) view public returns (uint) {
        return(betMin * (2 + 2**_power));
    }

    /**
     * @dev Play in lottery
     */
    function play(uint _secrethash,uint _power) payable external { // unchecked {
        require(D.nextIndex < 2 ** merkleTreeLevels - 1 - betsMax, "No more bets allowed");
        require(0<_secrethash && _secrethash < FIELD_SIZE && _secrethash & 0x1F == 0, "illegal hash");
        require(_power<=betPower3, "Invalid bet amount");
        _deposit(getAmount(_power));
        uint newHash = _secrethash + _power + 1;
        uint pos = (uint(D.betsStart) + uint(D.betsIndex)) % betsMax;
        bets[pos] = newHash;
        emit LogBetIn(D.nextIndex+D.betsIndex,newHash);
        D.betsIndex++;
    } // }

    /**
     * @dev collect the reward
     */
    function collect(
        uint[2] calldata _pA,
        uint[2][2] calldata _pB,
        uint[2] calldata _pC,
        uint _root,
        uint _nullifierHash,
        address _recipient,
        address _relayer,
        uint _fee,
        uint _refund,
        uint _rewardbits,
        uint _invest) payable external nonReentrant {
        require(nullifier[_nullifierHash] == 0, "Incorrect nullifier");
        nullifier[_nullifierHash] = 1;
        require(msg.value == _refund, "Incorrect refund amount received by the contract");
        uint reward =  betMin * ( (_rewardbits&0x1>0?1:0) * 2**betPower1 + (_rewardbits&0x2>0?1:0) * 2**betPower2 + (_rewardbits&0x4>0?1:0) * 2**betPower3 );
        reward = reward * (100 - dividendFeePerCent - generatorFeePerCent) / 100;
        require(reward >= _fee, "Insufficient reward");
        require(roots[_root]>0, "Cannot find your merkle root");
        uint balance = _balance();
        require(balance >= _fee, "Insufficient balance");
        require(withdraw.verifyProof( _pA, _pB, _pC, [ _root, _nullifierHash, _rewardbits, uint(uint160(_recipient)), uint(uint160(_relayer)), _fee, _refund ]), "Invalid withdraw proof");
        collectDividend(_recipient);
        if(_invest>0 && wallets[_recipient].balance < maxBalance) {
            if(_invest > reward - _fee) {
                _invest = reward - _fee;
            }
            currentBalance += uint128(_invest);
            wallets[_recipient].balance += uint112(_invest);
            reward -= _invest;
        }
        /* process withdrawal */
        if(balance < reward) {
            _invest = reward - balance/2;
            currentBalance += uint128(_invest);
            wallets[_recipient].balance += uint112(_invest);
            wallets[_recipient].nextWithdrawPeriod = uint16(D.dividendPeriod + 1); // wait 1 period for more funds
            reward -= _invest;
        }
        if (reward - _fee > 0) {
            _withdraw(_recipient,reward - _fee);
        }
        if (_fee > 0) {
            if(_relayer!=address(0)){
                _withdraw(_relayer,_fee);}
            else{
                _withdraw(msg.sender,_fee);}
        }
        if (_refund > 0) {
          (bool ok,)=_recipient.call{ value: uint(_refund) }("");
          if(!ok){ (ok,)=generator.call{ value: uint(_refund) }(""); }
          if(!ok){ (ok,)=owner.call{ value: uint(_refund) }(""); }
          require(ok,"failed to refund");
        }
        rememberHash();
        emit LogWin(uint(_nullifierHash),reward,_recipient);
    }

   /**
     * @dev cancel bet, no privacy !
     */
    function cancelbet( // do not change bets[1] add nullifier !!!
        uint[2] calldata _pA,
        uint[2][2] calldata _pB,
        uint[2] calldata _pC,
        uint _betIndex,
        address _recipient) external nonReentrant {
        require(D.nextIndex+D.commitIndex<=_betIndex && _betIndex<D.nextIndex+D.betsIndex, "Bet probably processed");
        uint pos = (uint(D.betsStart)+(_betIndex-D.nextIndex)) % betsMax;
        uint power1=bets[pos]&0x1f;
        require(power1>0);
        require(cancel.verifyProof( _pA, _pB, _pC, [uint(bets[pos]-power1)]), "Invalid cancel proof");
        uint reward=getAmount(power1-1);
        bets[pos]=0x20;
        uint balance = _balance();
        require(balance >= reward,"Not anough funds");
        _withdraw(_recipient,reward);
        rememberHash();
        emit LogCancel(_betIndex); // TODO: remember to update tree leaves !!!
    }

/* random number generator functions */

    /**
     * @dev commit the generator secret
     */
    function commit(uint _commitHash,uint _maxUpdate) external onlyGenerator {
        require(D.betsIndex >0 , "No bets");
        require(_commitHash > _closed, "Commit hash already set");
        require(commitHash == _open, "Commit hash already set");
        require(D.commitBlock == 0, "Commit block already set");
        require(_maxUpdate<=maxUpdate, "Commit size too large");
        D.commitBlock = uint64(block.number);
        D.commitIndex = uint8(D.betsIndex<_maxUpdate?D.betsIndex:_maxUpdate);
        commitHash = _commitHash;
        commitBlockHash = _open;
        emit LogCommit(D.nextIndex,D.commitIndex,commitHash);
    }

    /**
     * @dev remember commitBlockHash
     */
    function rememberHash() public {
        if(D.commitBlock != 0 && commitBlockHash == _open){
          commitBlockHash = uint(blockhash(D.commitBlock));
          if(commitBlockHash==0){
            commitBlockHash=_open;}
          else{
            emit LogHash(commitBlockHash);}
        } 
    }

    /**
     * @dev reveal the generator secret without updating the tree
     */
    function secret(uint _revealSecret) public {
        rememberHash();
        require(uint(keccak256(abi.encodePacked(_revealSecret))) == commitHash, "Invalid reveal secret");
        emit LogSecret(lastRoot,_revealSecret);
    }

    /**
     * @dev reveal the generator secret
     */
    function reveal( // unchecked {
        uint _revealSecret,
        uint[2] calldata _pA,
        uint[2][2] calldata _pB,
        uint[2] calldata _pC,
        uint _newRoot) external {
        require(uint(keccak256(abi.encodePacked(_revealSecret))) == commitHash, "Invalid reveal secret");
        rememberHash();
        require(commitBlockHash > _closed, "Commit block hash not found");
        uint newRand = uint128(uint(keccak256(abi.encodePacked(_revealSecret,commitBlockHash))));
        uint newBets = 0;
        if(D.commitIndex==1){
            uint[4+1] memory pubdata;
            pubdata[0]=lastRoot;
            pubdata[1]=uint(_newRoot);
            pubdata[2]=uint(D.nextIndex-1);
            pubdata[3]=uint(newRand);
            uint pos = D.betsStart;
            uint power=bets[pos]&0x1f;
            pubdata[4]=bets[pos];
            //bets[pos]=0; // no more gaspump
            if(power>0){
                newBets+=uint128(getAmount(power-1));}
            require(update1.verifyProof( _pA, _pB, _pC, pubdata), "Invalid update proof");}
        else if(D.commitIndex<=3){
            uint[4+3] memory pubdata;
            pubdata[0]=lastRoot;
            pubdata[1]=uint(_newRoot);
            pubdata[2]=uint(D.nextIndex-1);
            pubdata[3]=uint(newRand);
            for(uint i=0;i<D.commitIndex; i++){
                uint pos = (uint(D.betsStart)+i) % betsMax;
                uint power=bets[pos]&0x1f;
                pubdata[4+i]=bets[pos];
                //bets[pos]=0; // no more gaspump
                if(power>0){
                    newBets+=uint128(getAmount(power-1));}}
            require(update3.verifyProof( _pA, _pB, _pC, pubdata), "Invalid update proof");}
        else if(D.commitIndex<=5){
            uint[4+5] memory pubdata;
            pubdata[0]=lastRoot;
            pubdata[1]=uint(_newRoot);
            pubdata[2]=uint(D.nextIndex-1);
            pubdata[3]=uint(newRand);
            for(uint i=0;i<D.commitIndex; i++){
                uint pos = (uint(D.betsStart)+i) % betsMax;
                uint power=bets[pos]&0x1f;
                pubdata[4+i]=bets[pos];
                //bets[pos]=0; // no more gaspump
                if(power>0){
                    newBets+=uint128(getAmount(power-1));}}
            require(update5.verifyProof( _pA, _pB, _pC, pubdata), "Invalid update proof");}
        else if(D.commitIndex<=11){
            uint[4+11] memory pubdata;
            pubdata[0]=lastRoot;
            pubdata[1]=uint(_newRoot);
            pubdata[2]=uint(D.nextIndex-1);
            pubdata[3]=uint(newRand);
            for(uint i=0;i<D.commitIndex; i++){
                uint pos = (uint(D.betsStart)+i) % betsMax;
                uint power=bets[pos]&0x1f;
                pubdata[4+i]=bets[pos];
                //bets[pos]=0; // no more gaspump
                if(power>0){
                    newBets+=uint128(getAmount(power-1));}}
            require(update11.verifyProof( _pA, _pB, _pC, pubdata), "Invalid update proof");}
        else if(D.commitIndex<=21){
            uint[4+21] memory pubdata;
            pubdata[0]=lastRoot;
            pubdata[1]=uint(_newRoot);
            pubdata[2]=uint(D.nextIndex-1);
            pubdata[3]=uint(newRand);
            for(uint i=0;i<D.commitIndex; i++){
                uint pos = (uint(D.betsStart)+i) % betsMax;
                uint power=bets[pos]&0x1f;
                pubdata[4+i]=bets[pos];
                //bets[pos]=0; // no more gaspump
                if(power>0){
                    newBets+=uint128(getAmount(power-1));}}
            require(update21.verifyProof( _pA, _pB, _pC, pubdata), "Invalid update proof");}
        else if(D.commitIndex<=44){
            uint[4+44] memory pubdata;
            pubdata[0]=lastRoot;
            pubdata[1]=uint(_newRoot);
            pubdata[2]=uint(D.nextIndex-1);
            pubdata[3]=uint(newRand);
            for(uint i=0;i<D.commitIndex; i++){
                uint pos = (uint(D.betsStart)+i) % betsMax;
                uint power=bets[pos]&0x1f;
                pubdata[4+i]=bets[pos];
                //bets[pos]=0; // no more gaspump
                if(power>0){
                    newBets+=uint128(getAmount(power-1));}}
            require(update44.verifyProof( _pA, _pB, _pC, pubdata), "Invalid update proof");}
        else if(D.commitIndex<=89){
            uint[4+89] memory pubdata;
            pubdata[0]=lastRoot;
            pubdata[1]=uint(_newRoot);
            pubdata[2]=uint(D.nextIndex-1);
            pubdata[3]=uint(newRand);
            for(uint i=0;i<D.commitIndex; i++){
                uint pos = (uint(D.betsStart)+i) % betsMax;
                uint power=bets[pos]&0x1f;
                pubdata[4+i]=bets[pos];
                //bets[pos]=0; // no more gaspump
                if(power>0){
                    newBets+=uint128(getAmount(power-1));}}
            require(update89.verifyProof( _pA, _pB, _pC, pubdata), "Invalid update proof");}
        else if(D.commitIndex<=179){
            uint[4+179] memory pubdata;
            pubdata[0]=lastRoot;
            pubdata[1]=uint(_newRoot);
            pubdata[2]=uint(D.nextIndex-1);
            pubdata[3]=uint(newRand);
            for(uint i=0;i<D.commitIndex; i++){
                uint pos = (uint(D.betsStart)+i) % betsMax;
                uint power=bets[pos]&0x1f;
                pubdata[4+i]=bets[pos];
                //bets[pos]=0; // no more gaspump
                if(power>0){
                    newBets+=uint128(getAmount(power-1));}}
            require(update179.verifyProof( _pA, _pB, _pC, pubdata), "Invalid update proof");}
        else{
            revert("fatal error, resetcommit and close");}
        periods[uint(D.dividendPeriod)].bets+=uint128(newBets);
        D.nextIndex+=D.commitIndex;
        D.betsStart =uint8((uint(D.betsStart)+uint(D.commitIndex)) % betsMax);
        D.betsIndex-=D.commitIndex;
        D.commitIndex = 0;
        D.commitBlock = 0;
        commitHash = _open;
        commitBlockHash = _open;
        roots[_newRoot]=D.nextIndex;
        lastRoot=_newRoot;
        collectDividend(msg.sender);
        uint generatorReward = newBets * generatorFeePerCent / 100;
        currentBalance += uint128(generatorReward);
        wallets[msg.sender].balance += uint112(generatorReward);
        updateDividendPeriod();
        emit LogUpdate(uint(D.nextIndex),newRand,_newRoot);
    } // }

/* investment functions */

    /**
     * @dev Update dividend period
     */
    function updateDividendPeriod() public {
        if(block.number >= D.periodStartBlock + periodBlocks || periods[D.dividendPeriod].bets > maxBalance) {
            currentBalance += uint128(uint(periods[D.dividendPeriod].bets)*dividendFeePerCent/100);
            D.periodStartBlock = uint64(block.number);
            D.dividendPeriod++;
            periods[D.dividendPeriod].shares=currentBalance;
        }
    }

    /**
     * @dev Commit remaining dividends before balance changes
     */
    function collectDividend(address _who) public {
        updateDividendPeriod();
        uint last = wallets[_who].lastDividendPeriod;
        if(last==0){
            wallets[_who].lastDividendPeriod=uint16(D.dividendPeriod);
            return;
        }
        if(last==D.dividendPeriod) {
            return;
        }
        uint balance=uint(wallets[_who].balance);
        if(periods[last].shares>0){
            balance += uint(wallets[_who].shares) * periods[last].bets * dividendFeePerCent / (periods[last].shares * 100);}
        for(last++;last<D.dividendPeriod;last++) {
            if(periods[last].shares>0){
                balance += balance * periods[last].bets * dividendFeePerCent / (periods[last].shares * 100);}
        }
        wallets[_who].balance = uint112(balance);
        wallets[_who].shares = uint112(balance);
        wallets[_who].lastDividendPeriod = uint16(D.dividendPeriod);
    }

    /**
     * @dev Pay out balance from wallet
     */

    function payOut() public nonReentrant {
        collectDividend(msg.sender);
        require(D.dividendPeriod >= wallets[msg.sender].nextWithdrawPeriod, "Wait till the next dividend period");
        uint _amount = wallets[msg.sender].balance;
        /*if(betMin * 2**betPower2 < _amount) { // limit max withdrawal
            _amount = betMin * 2**betPower2;
            wallets[msg.sender].nextWithdrawPeriod = uint16(D.dividendPeriod + 1);
        }*/
        uint balance = _balance();
        if(_amount > balance) {
            _amount = balance/2;
            wallets[msg.sender].nextWithdrawPeriod = uint16(D.dividendPeriod + 1); // wait 1 period for more funds
        }
        wallets[msg.sender].balance -= uint112(_amount);
        if(currentBalance>uint128(_amount)){
            currentBalance -= uint128(_amount);}
        else{
            currentBalance = 0;}
        if(wallets[msg.sender].balance<wallets[msg.sender].shares) {
            uint reduce = uint128(wallets[msg.sender].shares - wallets[msg.sender].balance);
            if(periods[D.dividendPeriod].shares>reduce){
                periods[D.dividendPeriod].shares -= uint128(reduce);}
            else{
                periods[D.dividendPeriod].shares = 0;}
            wallets[msg.sender].shares = uint112(wallets[msg.sender].balance);
        }
        _withdraw(payable(msg.sender),_amount);
    }

/* administrative functions */

    function _balance() internal virtual returns (uint) {
    }

    function _deposit(uint _amount) internal virtual returns (uint) {
    }

    function _withdraw(address _who,uint _amount) internal virtual {
    }

    function exec(address _who,bytes[] calldata _data) payable external onlyOwner {
        (bool ok,) =_who.call{ value: msg.value }(abi.encode(_data));
        require(ok);
    }

    function betSum() view public returns (uint){
        uint betsum=0;
        for(uint i=0;i<D.commitIndex;i++){
            uint pos = (uint(D.betsStart)+i) % betsMax;
            uint power=bets[pos]&0x1f;
            if(power>0){
                betsum+=getAmount(power-1);}}
        return(betsum);
    }

    /**
     * @dev deposit security deposit to reset commit
     */
    function resetcommit() payable external onlyOwner {
        uint betsum=betSum();
        _deposit(betsum);
        D.commitIndex = 0;
        D.commitBlock = 0;
        commitHash = _open;
        commitBlockHash = _open;
        emit LogResetCommit(msg.sender);
    }

    /**
     * @dev close the lottery
     */
    function close() external onlyOwner {
        require(D.betsIndex==0, "Open bets");
        commitHash = _closed;
        D.commitBlock = uint64(block.number);
        D.betsIndex = uint8(betsMax);
        emit LogClose(msg.sender);
    }

    /**
     * @dev reopen the lottery again
     */
    function reopen() external onlyOwner {
        require(commitHash==_closed, "Lottery open");
        commitHash = _open;
        D.commitBlock = 0;
        D.betsIndex = 0;
        emit LogReopen(msg.sender);
    }

    /**
     * @dev withdraw the remaining balance
     */
    function adminwithdraw() external onlyOwner {
        require(commitHash==_closed, "Lottery open");
        require(block.number > D.commitBlock + 4*60*24*365*2, "Not enough blocks passed"); // wait 2 years (in Ethereum)
        if(address(this).balance > 0){
            payable(msg.sender).transfer(address(this).balance);
        }
        if(address(token)!=address(0)){
            _withdraw(msg.sender,uint(token.balanceOf(address(this))));
        }
        emit LogWithdraw(msg.sender);
    }

    /*fallback() payable external {
        revert("Invalid call");
    }*/

    receive() external payable {
        revert("Invalid call");
    }

    modifier onlyOwner() {
        assert(msg.sender == owner);
        _;
    }

    modifier onlyGenerator() {
        assert(msg.sender == generator);
        _;
    }

    modifier nonReentrant() {
        require(D.status != _closed, "ReentrancyGuard: reentrant call");
        D.status = uint8(_closed);
        _;
        D.status = uint8(_open);
    }

    /**
     * @dev Change owner.
     * @param _who The address of new owner.
     */
    function changeOwner(address _who) external onlyOwner {
        assert(_who != address(0));
        collectDividend(msg.sender);
        collectDividend(_who);
        owner = _who;
        emit LogChangeOwner(msg.sender, _who);
    }

    /**
     * @dev Change generator.
     * @param _who The address of new generator.
     */
    function changeGenerator(address _who) external onlyOwner {
        assert(_who != address(0));
        collectDividend(generator);
        collectDividend(_who);
        if(wallets[generator].balance>=1 && wallets[generator].shares>=1){
            wallets[generator].balance-=1;
            wallets[_who].balance+=1;
            wallets[generator].shares-=1;
            wallets[_who].shares+=1;}
        generator = _who;
        emit LogChangeGenerator(msg.sender, _who);
    }

/* getters */
    
    /**
     * @dev Show current balance eligible for dividend.
     * @param _owner The address of the account.
     */
    function walletSharesOf(address _owner) public view returns (uint) {
        uint last = wallets[_owner].lastDividendPeriod;
        if(last<D.dividendPeriod){
            return walletBalanceOf(_owner);}
        return uint(wallets[_owner].shares);
    }
    
    /**
     * @dev Show balance of wallet (including unpaid dividends).
     * @param _owner The address of the account.
     */
    function walletBalanceOf(address _owner) public view returns (uint) {
        uint last = wallets[_owner].lastDividendPeriod;
        uint balance=uint(wallets[_owner].balance);
        if(periods[last].shares>0){
            balance += uint(wallets[_owner].shares) * periods[last].bets * dividendFeePerCent / (periods[last].shares * 100);}
        for(last++;last<D.dividendPeriod;last++) {
            if(periods[last].shares>0){
                balance += balance * periods[last].bets * dividendFeePerCent / (periods[last].shares * 100);}
        }
        return(balance);
    }

    /**
     * @dev Show last dividend period processed.
     * @param _owner The address of the account.
     */
    function walletDividendPeriodOf(address _owner) public view returns (uint) {
        return uint(wallets[_owner].lastDividendPeriod);
    }
    
    /**
     * @dev Show block number when withdraw can continue.
     * @param _owner The address of the account.
     */
    function walletWithdrawPeriodOf(address _owner) public view returns (uint) {
        return uint(wallets[_owner].nextWithdrawPeriod);
    }

    /**
     * @dev Show dividend Period
     */
    function dividendPeriod() public view returns (uint) {
        return uint(D.dividendPeriod);
    }

    /**
     * @dev Show total Bets in dividend Period
     */
    function periodBets(uint period) public view returns (uint) {
        return uint(periods[period].bets);
    }

    /**
     * @dev Show total Shares in dividend Period
     */
    function periodShares(uint period) public view returns (uint) {
        return uint(periods[period].shares);
    }

    /**
     * @dev Show number of Bets to process
     */
    function commitIndex() public view returns (uint) {
        return uint(D.commitIndex);
    }

    /**
     * @dev Show next betIndex
     */
    function nextIndex() public view returns (uint) {
        return uint(D.nextIndex);
    }

    /**
     * @dev Show number of waiting bets in queue
     */
    function betsIndex() public view returns (uint) {
        return uint(D.betsIndex);
    }

    // events
    event LogPrayer(bytes32[] prayer);
    event LogBetIn(uint indexed index,uint indexed newHash);
    event LogCancel(uint indexed index);
    event LogCommit(uint indexed index,uint indexed commitIndex,uint indexed commitHash);
    event LogHash(uint indexed commitBlockHash);
    event LogSecret(uint indexed lastRoot,uint indexed revealSecret);
    event LogUpdate(uint indexed index,uint indexed newRand,uint indexed newRoot);
    event LogWin(uint indexed nullifierHash, uint indexed reward,address indexed recipient);
    event LogWithdraw(address indexed owner);
    event LogClose(address indexed owner);
    event LogReopen(address indexed owner);
    event LogResetCommit(address indexed owner);
    event LogChangeOwner(address indexed owner, address indexed newOwner);
    event LogChangeGenerator(address indexed owner, address indexed newGenerator);
}
