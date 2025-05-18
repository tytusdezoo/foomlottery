pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Test, console} from "forge-std/Test.sol";

interface IWithdraw { // 48439 c
  function verifyProof( uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[7] calldata _pubSignals) external view returns (bool); // 240419 gas
}
interface ICancel { // 686 c
  function verifyProof( uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[1] calldata _pubSignals) external view returns (bool); // 198961 g
}
interface IUpdate1 { // 86817 c
  function verifyProof( uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[5] calldata _pubSignals) external view returns (bool); // 226598 g
}
interface IUpdate5 { // 264353 c
  function verifyProof( uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[9] calldata _pubSignals) external view returns (bool); // 254252 g
}
interface IUpdate11 { // 530657 c
  function verifyProof( uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[9] calldata _pubSignals) external view returns (bool); // g
}
interface IUpdate21 { // 974497 c
  function verifyProof( uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[25] calldata _pubSignals) external view returns (bool); // 364897 g
}
interface IUpdate44 { // 1995329 c
  function verifyProof( uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[48] calldata _pubSignals) external view returns (bool); // 519083 g
}
interface IUpdate89 { // 3992609 c
  function verifyProof( uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[48] calldata _pubSignals) external view returns (bool); // g
}


/**
 * @title FOOM Lottery
 */
contract Lottery {
    IERC20 public immutable token; // FOOM token
    IWithdraw public immutable withdraw;
    ICancel public immutable cancel;
    IUpdate1 public immutable update1;
    IUpdate5 public immutable update5;
    IUpdate21 public immutable update21;
    IUpdate44 public immutable update44;

    uint public constant FIELD_SIZE = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    uint public constant merkleTreeLevels = 32 ; // number of Merkle Tree levels
    uint public constant periodBlocks = 16384 ; // number of blocks in a period
    uint public          betMin; // TODO: set to constant later !
    uint public constant betPower1 = 10; // power of the first bet = 1024
    uint public constant betPower2 = 16; // power of the second bet = 65536
    uint public constant betPower3 = 22; // power of the third bet = 4194304
    uint public constant betsMax = 128; //128; // maximum number of bets in queue, max 8bit
    uint public constant maxUpdate = 44; // maximum number of bets in queue to insert
    uint public constant dividendFeePerCent = 4; // 4% of dividends go to the shareholders (wall)
    uint public constant generatorFeePerCent = 1; // 1% of dividends go to the generator
    uint public constant maxBalance = 2**108; // maximum balance of a user and maximum size of bets in period
    //uint public constant rootsMax = 32;
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
        //uint8 currentRootIndex; // now all roots saved
        uint8 status;
    }
    Data public D;
    uint128 public currentBalance = 1; // sum of funds in wallets
    uint128 public currentBets = 1; // total bet volume in current period
    uint128 public currentShares = 1; // sum of funds eligible for dividend in current period
    //uint128 public oldRand =0; // 
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
    constructor(IWithdraw _Withdraw,ICancel _Cancel,IUpdate1 _Update1,IUpdate5 _Update5,IUpdate21 _Update21,IUpdate44 _Update44,IERC20 _Token,uint _BetMin) {
        withdraw = _Withdraw;
        cancel = _Cancel;
        update1 = _Update1;
        update5 = _Update5;
        update21 = _Update21;
        update44 = _Update44;
        token = _Token;
        betMin = _BetMin;
        owner = msg.sender;
        generator = msg.sender;
        D.periodStartBlock = uint64(block.number);
        D.dividendPeriod = uint32(1);
        D.status = uint8(_open);
        D.nextIndex = uint32(1);
        //D.betsStart = uint8(0);
        //D.betsIndex = uint8(0);
        //D.commitIndex = uint8(0);
        commitHash = _open;
        commitBlockHash = _open;
        wallets[owner] = Wallet(uint112(1),uint112(1),uint16(D.dividendPeriod),uint16(0));
        //periods[0]=Period(0,0); // not needed
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
        require(0<_secrethash && _secrethash < FIELD_SIZE && _secrethash & 0x1F == 0, "illegal hash");
        require(D.betsIndex < betsMax && D.nextIndex + D.betsIndex < 2 ** merkleTreeLevels - 1, "No more bets allowed");
        require(_power >= 0 && _power<=betPower3, "Invalid bet amount");
        _deposit(getAmount(_power));
        uint newHash = _secrethash + _power + 1;
        uint pos = (D.betsStart + D.betsIndex) % betsMax;
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
        require(msg.value == _refund, "Incorrect refund amount received by the contract");
        //require(isKnownRoot(_root), "Cannot find your merkle root"); // Make sure to use a recent one
        require(roots[_root]>0, "Cannot find your merkle root");
        require(withdraw.verifyProof( _pA, _pB, _pC, [ _root, _nullifierHash, _rewardbits, uint(uint160(_recipient)), uint(uint160(_relayer)), _fee, _refund ]), "Invalid withdraw proof");
        nullifier[_nullifierHash] = 1;
        uint reward =  betMin * ( (_rewardbits&0x1>0?1:0) * 2**betPower1 + (_rewardbits&0x2>0?1:0) * 2**betPower2 + (_rewardbits&0x4>0?1:0) * 2**betPower3 );
        emit LogWin(uint(_nullifierHash),reward);
        //currentBets += uint128(reward);
        collectDividend(_recipient);
        reward = reward * (100 - dividendFeePerCent - generatorFeePerCent) / 100;
        uint balance = _balance();
        require(reward >= _fee, "Insufficient reward");
        require(balance >= _fee, "Insufficient balance");
        if(_invest>0 && wallets[_recipient].balance < maxBalance) {
            if(_invest > reward - _fee) {
                _invest = reward - _fee;
            }
            currentBalance += uint128(_invest);
            wallets[_recipient].balance += uint112(_invest);
            reward -= _invest;
        }
        /* process withdrawal */
        /*if(betMin * 2**betPower2 < reward ) { // limit max withdrawal
            _invest = reward - (betMin * 2**betPower2);
            currentBalance += uint128(_invest);
            wallets[_recipient].balance += uint112(_invest);
            wallets[_recipient].nextWithdrawPeriod = uint16(D.dividendPeriod + 1); // wait 1 period for more funds
            reward -= _invest;
        }*/
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
          (bool ok,) =_recipient.call{ value: uint(_refund) }("");
          require(ok);
        }
        rememberHash();
    }

   /**
     * @dev cancel bet, no privacy !
     */
    function cancelbet( // do not change bets[1] add nullifier !!!
        uint[2] calldata _pA,
        uint[2][2] calldata _pB,
        uint[2] calldata _pC,
        uint _betIndex,
        address _recipient) payable external nonReentrant {
        require(D.nextIndex<=_betIndex && _betIndex-D.nextIndex<D.betsIndex, "Bet probably processed");
        rememberHash();
        require(D.commitBlock != 0 || _betIndex-D.nextIndex>=D.commitIndex, "Commit in progress"); // do not allow generator to cancel bets after selecting commitBlock for random index
        uint pos = (D.betsStart+(_betIndex-D.nextIndex)) % betsMax;
        uint power1=bets[pos]&0x1f;
        require(power1>0);
        require(cancel.verifyProof( _pA, _pB, _pC, [uint(bets[pos]-power1)]), "Invalid cancel proof");
        uint reward=getAmount(power1-1);
        bets[pos]=0x20;
        emit LogCancel(_betIndex); // TODO: remember to update tree leaves !!!
        uint balance = _balance();
        require(balance >= reward,"Not anough funds");
        _withdraw(_recipient,reward);
    }

    /**
     * @dev Whether the root is present in the root history
    function isKnownRoot(uint _root) public view returns (bool) {
        if (_root == 0) {
            return false;
        }
        uint _currentRootIndex = D.currentRootIndex;
        uint i = _currentRootIndex;
        do {
            if (_root == roots[i]) {
                return true;
            }
            if (i == 0) {
                i = rootsMax;
            }
            i--;
        } while (i != _currentRootIndex);
        return false;
    }
     */

/* random number generator functions */

    /**
     * @dev commit the generator secret
     */
    function commit(uint _commitHash) external onlyGenerator {
        require(D.betsIndex >0 , "No bets");
        require(_commitHash > _closed, "Commit hash already set");
        require(commitHash == _open, "Commit hash already set");
        require(D.commitBlock == 0, "Commit block already set");
        D.commitBlock = uint64(block.number);
        D.commitIndex = uint8(D.betsIndex<maxUpdate?D.betsIndex:maxUpdate);
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
              /* rest is for testing only , TODO remove later */
              if(commitBlockHash == 0 && D.commitBlock<block.number && D.commitBlock>block.number-256){
                commitBlockHash=uint(keccak256(abi.encodePacked(D.commitBlock)));}
          if(commitBlockHash==0){
            commitBlockHash=_open;}
          //TODO, log hash
        } 
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
            pubdata[0]=lastRoot;//uint(roots[D.currentRootIndex]);
            pubdata[1]=uint(_newRoot);
            pubdata[2]=uint(D.nextIndex-1);
            pubdata[3]=uint(newRand);
            uint pos = (D.betsStart) % betsMax;
            uint power=bets[pos]&0x1f;
            pubdata[4]=bets[pos];
            //bets[pos]=0; // no more gaspump
            if(power>0){
                newBets+=uint128(getAmount(power-1));}
            require(update1.verifyProof( _pA, _pB, _pC, pubdata), "Invalid update proof");}
        else if(D.commitIndex<=5){
            uint[4+5] memory pubdata;
            pubdata[0]=lastRoot;//uint(roots[D.currentRootIndex]);
            pubdata[1]=uint(_newRoot);
            pubdata[2]=uint(D.nextIndex-1);
            pubdata[3]=uint(newRand);
            for(uint i=0;i < D.commitIndex; i++){
                uint pos = (D.betsStart+i) % betsMax;
                uint power=bets[pos]&0x1f;
                pubdata[4+i]=bets[pos];
                //bets[pos]=0; // no more gaspump
                if(power>0){
                    newBets+=uint128(getAmount(power-1));}}
            require(update5.verifyProof( _pA, _pB, _pC, pubdata), "Invalid update proof");}
        else if(D.commitIndex<=21){
            uint[4+21] memory pubdata;
            pubdata[0]=lastRoot;//uint(roots[D.currentRootIndex]);
            pubdata[1]=uint(_newRoot);
            pubdata[2]=uint(D.nextIndex-1);
            pubdata[3]=uint(newRand);
            for(uint i=0;i < D.commitIndex; i++){
                uint pos = (D.betsStart+i) % betsMax;
                uint power=bets[pos]&0x1f;
                pubdata[4+i]=bets[pos];
                //bets[pos]=0; // no more gaspump
                if(power>0){
                    newBets+=uint128(getAmount(power-1));}}
            require(update21.verifyProof( _pA, _pB, _pC, pubdata), "Invalid update proof");}
        else{
            uint[4+44] memory pubdata;
            pubdata[0]=lastRoot;//uint(roots[D.currentRootIndex]);
            pubdata[1]=uint(_newRoot);
            pubdata[2]=uint(D.nextIndex-1);
            pubdata[3]=uint(newRand);
            for(uint i=0;i < 44 && i<D.commitIndex; i++){
                uint pos = (D.betsStart+i) % betsMax;
                uint power=bets[pos]&0x1f;
                pubdata[4+i]=bets[pos];
                //bets[pos]=0; // no more gaspump
                if(power>0){
                    newBets+=uint128(getAmount(power-1));}}
            require(update44.verifyProof( _pA, _pB, _pC, pubdata), "Invalid update proof");}
        currentBets+=uint128(newBets);
        D.nextIndex+=D.commitIndex;
        D.betsStart =(D.betsStart+D.commitIndex) % uint8(betsMax);
        D.betsIndex-=D.commitIndex;
        D.commitIndex = 0;
        D.commitBlock = 0;
        commitHash = _open;
        commitBlockHash = _open;
        roots[_newRoot]=D.nextIndex;
        lastRoot=_newRoot;
        //D.currentRootIndex = uint8((D.currentRootIndex + 1) % rootsMax);
        //roots[D.currentRootIndex] = _newRoot;
        collectDividend(generator);
        uint generatorReward = newBets * generatorFeePerCent / 100;
        currentBalance += uint128(generatorReward);
        wallets[generator].balance += uint112(generatorReward);
        emit LogUpdate(uint(D.nextIndex),newRand,_newRoot);
    } // }

/* investment functions */

    /**
     * @dev Update dividend period
     */
    function updateDividendPeriod() public {
        if(block.number >= D.periodStartBlock + periodBlocks || currentBets > maxBalance) {
            periods[D.dividendPeriod]=Period(currentBets,currentShares);
            currentShares = currentBalance;
            currentBets = 0;
            D.periodStartBlock = uint64(block.number);
            D.dividendPeriod++;
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
        uint shares = uint(wallets[_who].shares) * 0xffffffff;
        uint betshares = shares * periods[last].bets / periods[last].shares;
        shares = uint(wallets[_who].balance) * 0xffffffff;
        for(last++;last<D.dividendPeriod;last++) {
            betshares += shares * periods[last].bets / periods[last].shares;
        }
        uint dividend = betshares * dividendFeePerCent / 100 / 0xffffffff;
        currentBalance += uint128(dividend);
        currentShares += uint128(dividend);
        wallets[_who].balance += uint112(dividend);
        wallets[_who].shares = uint112(wallets[_who].balance);
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
        currentBalance -= uint128(_amount);
        if(wallets[msg.sender].balance<wallets[msg.sender].shares) {
            currentShares -= uint128(wallets[msg.sender].shares - wallets[msg.sender].balance);
            wallets[msg.sender].shares = uint112(wallets[msg.sender].balance);
        }
        _withdraw(msg.sender,_amount);
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
            uint pos = (D.betsStart+i) % betsMax;
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
        collectDividend(msg.sender);
        collectDividend(_who);
        generator = _who;
        emit LogChangeGenerator(msg.sender, _who);
    }

/* getters */
    
    /**
     * @dev Show balance of wallet.
     * @param _owner The address of the account.
     */
    function walletSharesOf(address _owner) public view returns (uint) {
        return uint(wallets[_owner].shares);
    }
    
    /**
     * @dev Show last balance eligible for dividend.
     * @param _owner The address of the account.
     */
    function walletBalanceOf(address _owner) public view returns (uint) {
        return uint(wallets[_owner].balance);
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
     * @dev Returns the last root
    function getLastRoot() public view returns (uint) {
        return roots[D.currentRootIndex];
    }
    */

    // events
    event LogBetIn(uint indexed index,uint indexed newHash);
    //event LogBetHash(uint indexed index,uint indexed newHash,uint indexed newRand);
    event LogCommit(uint indexed index,uint indexed commitIndex,uint indexed commitHash);
    event LogUpdate(uint indexed index,uint indexed newRand,uint indexed newRoot);
    event LogCancel(uint indexed index);
    event LogWin(uint indexed nullifierHash, uint indexed reward);
    event LogClose(address indexed owner);
    event LogResetCommit(address indexed owner);
    event LogWithdraw(address indexed owner);
    event LogReopen(address indexed owner);
    event LogChangeOwner(address indexed owner, address indexed newOwner);
    event LogChangeGenerator(address indexed owner, address indexed newGenerator);
}
