pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

interface IWithdraw {
  function verifyProof( uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[9] calldata _pubSignals) external view returns (bool);
}
interface ICancel {
  function verifyProof( uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[6] calldata _pubSignals) external view returns (bool);
}
interface IHasher {
  function MiMCSponge(uint256 in_xL, uint256 in_xR, uint256 k) external pure returns (uint256 xL, uint256 xR);
}

/**
 * @title FOOM Lottery
 */
contract FoomLottery {
    using SafeERC20 for IERC20;
    IERC20 public immutable token; // FOOM token
    IWithdraw public immutable withdraw;
    ICancel public immutable cancel;
    IHasher public immutable hasher;

    // keep together
    struct Data {
        uint64 periodStartBlock;
        uint64 commitBlock;
        uint32 nextIndex;
        uint32 dividendPeriod; // current dividend period
        uint32 commitCount;
        uint8 betsIndex; // index of the next slot in queue
        uint8 commitIndex;
        uint8 currentRootIndex;
        uint8 status;
    }
    Data public D;

    // metadata
    string public constant name = "Foom Lottery";

    uint public constant FIELD_SIZE = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    uint public constant merkleTreeLevels = 32 ; // number of Merkle Tree levels
    uint public constant merkleTreeReportLevel = 8 ; // report completed Merkle Tree level
    uint public constant periodBlocks = 16384 ; // number of blocks in a period
    uint public constant betMin = 1; // TODO: compute correct value
    uint public constant betPower1 = 10; // power of the first bet = 1024
    uint public constant betPower2 = 16; // power of the second bet = 65536
    uint public constant betPower3 = 22; // power of the third bet = 4194304
    uint public constant betsMax = 128; // maximum number of bets in queue, max 8bit
    uint public constant dividendFeePerCent = 4; // 4% of dividends go to the shareholders (wall)
    uint public constant generatorFeePerCent = 1; // 1% of dividends go to the generator
    uint public constant maxBalance = 2**108; // maximum balance of a user and maximum size of bets in period
    uint public constant ROOT_HISTORY_SIZE = 64;
    uint private constant _NOT_ENTERED = 1;
    uint private constant _ENTERED = 2;

    // contract state
    address public owner;
    address public generator;
    //uint64 public periodStartBlock;

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
    //Period[] public periods;
    // it removes index range check on every interaction
    mapping(uint => Period) public periods;
    uint128 public currentBalance = 1; // sum of funds in wallets
    uint128 public currentBets = 1; // total bet volume in current period
    uint128 public currentShares = 1; // sum of funds eligible for dividend in current period
    //uint32 public dividendPeriod = 1; // current dividend period

    // betting parameters
    struct BetsRC {
        uint R; // total bet volume in period
        uint C; // total eligible funds in period
    }
    //BetsRC public bets[betsMax]; // bets in queue
    // it removes index range check on every interaction
    mapping(uint => BetsRC) public bets;
    uint128 public betsSum = 0; // sum of bets in queue
    uint128 public betsWaiting = 0; // sum of bets waiting for new generator commit
    //uint8 public betsIndex = 0; // index of the next slot in queue
    mapping (uint => uint) public nullifier; // nullifier hash for each bet

    // generator data
    //uint64 public commitBlock = 0;
    //uint8 public commitIndex = 0;
    uint public commitHash = 0;
    uint public commitBlockHash = 0;

    // mertkeltree
    mapping(uint => bytes32) public constant zeros;
    mapping(uint => bytes32) public filledSubtrees;
    mapping(uint => bytes32) public roots;
    //uint8 public currentRootIndex = 0;
    //uint32 public nextIndex = 0;

    // constructor
    constructor(IWithdraw _Withdraw,ICancel _Cancel,IHasher _Hasher,IERC20 _Token,uint _BetMin) {
        require(merkleTreeLevels<=32,"Tree too large");
        withdraw = _Withdraw;
        cancel = _Cancel;
        hasher = _Hasher;
        token = _Token;
        betMin = _BetMin;
        owner = msg.sender;
        generator = msg.sender;
        D.periodStartBlock = block.number;
        D.dividendPeriod = 1;
        D.status = _NOT_ENTERED;
        wallets[owner] = Wallet(uint112(1),uint112(1),uint16(D.dividendPeriod),uint16(0));
        periods.push(Period(0,0));
        periods.push(Period(1,1));
        zeros[ 0]= bytes32(0x2fe54c60d3acabf3343a35b6eba15db4821b340f76e741e2249685ed4899af6c);
        zeros[ 1]= bytes32(0x256a6135777eee2fd26f54b8b7037a25439d5235caee224154186d2b8a52e31d);
        zeros[ 2]= bytes32(0x1151949895e82ab19924de92c40a3d6f7bcb60d92b00504b8199613683f0c200);
        zeros[ 3]= bytes32(0x20121ee811489ff8d61f09fb89e313f14959a0f28bb428a20dba6b0b068b3bdb);
        zeros[ 4]= bytes32(0x0a89ca6ffa14cc462cfedb842c30ed221a50a3d6bf022a6a57dc82ab24c157c9);
        zeros[ 5]= bytes32(0x24ca05c2b5cd42e890d6be94c68d0689f4f21c9cec9c0f13fe41d566dfb54959);
        zeros[ 6]= bytes32(0x1ccb97c932565a92c60156bdba2d08f3bf1377464e025cee765679e604a7315c);
        zeros[ 7]= bytes32(0x19156fbd7d1a8bf5cba8909367de1b624534ebab4f0f79e003bccdd1b182bdb4);
        zeros[ 8]= bytes32(0x261af8c1f0912e465744641409f622d466c3920ac6e5ff37e36604cb11dfff80);
        zeros[ 9]= bytes32(0x0058459724ff6ca5a1652fcbc3e82b93895cf08e975b19beab3f54c217d1c007);
        zeros[10]= bytes32(0x1f04ef20dee48d39984d8eabe768a70eafa6310ad20849d4573c3c40c2ad1e30);
        zeros[11]= bytes32(0x1bea3dec5dab51567ce7e200a30f7ba6d4276aeaa53e2686f962a46c66d511e5);
        zeros[12]= bytes32(0x0ee0f941e2da4b9e31c3ca97a40d8fa9ce68d97c084177071b3cb46cd3372f0f);
        zeros[13]= bytes32(0x1ca9503e8935884501bbaf20be14eb4c46b89772c97b96e3b2ebf3a36a948bbd);
        zeros[14]= bytes32(0x133a80e30697cd55d8f7d4b0965b7be24057ba5dc3da898ee2187232446cb108);
        zeros[15]= bytes32(0x13e6d8fc88839ed76e182c2a779af5b2c0da9dd18c90427a644f7e148a6253b6);
        zeros[16]= bytes32(0x1eb16b057a477f4bc8f572ea6bee39561098f78f15bfb3699dcbb7bd8db61854);
        zeros[17]= bytes32(0x0da2cb16a1ceaabf1c16b838f7a9e3f2a3a3088d9e0a6debaa748114620696ea);
        zeros[18]= bytes32(0x24a3b3d822420b14b5d8cb6c28a574f01e98ea9e940551d2ebd75cee12649f9d);
        zeros[19]= bytes32(0x198622acbd783d1b0d9064105b1fc8e4d8889de95c4c519b3f635809fe6afc05);
        zeros[20]= bytes32(0x29d7ed391256ccc3ea596c86e933b89ff339d25ea8ddced975ae2fe30b5296d4);
        zeros[21]= bytes32(0x19be59f2f0413ce78c0c3703a3a5451b1d7f39629fa33abd11548a76065b2967);
        zeros[22]= bytes32(0x1ff3f61797e538b70e619310d33f2a063e7eb59104e112e95738da1254dc3453);
        zeros[23]= bytes32(0x10c16ae9959cf8358980d9dd9616e48228737310a10e2b6b731c1a548f036c48);
        zeros[24]= bytes32(0x0ba433a63174a90ac20992e75e3095496812b652685b5e1a2eae0b1bf4e8fcd1);
        zeros[25]= bytes32(0x019ddb9df2bc98d987d0dfeca9d2b643deafab8f7036562e627c3667266a044c);
        zeros[26]= bytes32(0x2d3c88b23175c5a5565db928414c66d1912b11acf974b2e644caaac04739ce99);
        zeros[27]= bytes32(0x2eab55f6ae4e66e32c5189eed5c470840863445760f5ed7e7b69b2a62600f354);
        zeros[28]= bytes32(0x002df37a2642621802383cf952bf4dd1f32e05433beeb1fd41031fb7eace979d);
        zeros[29]= bytes32(0x104aeb41435db66c3e62feccc1d6f5d98d0a0ed75d1374db457cf462e3a1f427);
        zeros[30]= bytes32(0x1f3c6fd858e9a7d4b0d1f38e256a09d81d5a5e3c963987e2d4b814cfab7c6ebb);
        zeros[31]= bytes32(0x2c7a07d20dff79d01fecedc1134284a8d08436606c93693b67e333f671bf69cc);
        for (uint i = 0; i < merkleTreeLevels; i++) {
            filledSubtrees[i] = zeros[i];
        }
        roots[0] = zeros[merkleTreeLevels - 1];
    }

/* lottery functions */

    /**
     * @dev Calculate mask for lottery
     */
    function getMask(uint _amount) pure returns (uint) {
        uint mask = 0;
        for(uint i = 0; i <= betPower2; i++) {
            require(_amount >= betMin * (2 + 2**i), "Invalid bet amount");
            if(_amount == betMin * (2 + 2**i)) {
                if(i<=betPower1){
                    mask=(2**(betPower1+betPower2+1)-1)<<i;
                }
                else{
                    mask=((2**betPower2-1)<<(i+betPower1))|(2**betPower1-1);
                }
                mask=mask&(2**(betPower1+betPower2+1)-1);
                break;
            }
        }
        require(mask != 0, "Invalid bet amount");
        return (mask);
    }

    /**
     * @dev Play in lottery
     */
    function play(uint _secrethash,uint _amount) payable external nonReentrant {
        require(0<_secrethash &&_secrethash < FIELD_SIZE, "_secrethash should be inside the field");
        require(D.betsIndex < betsMax && D.betsIndex + D.nextIndex < 2 ** merkleTreeLevels - 1, "No more bets allowed");
        _amount=_deposit(_amount);
        if(D.commitBlock == 0) {
            betsSum += _amount;
        }
        else {
            rememberHash();
            betsWaiting += _amount;
        }
        uint mask = getMask(_amount);
        uint R = _secrethash;
        uint C = 0;
        (R, C) = hasher.MiMCSponge(R, C, 0);
        R = addmod(R, mask, FIELD_SIZE);
        (R, C) = hasher.MiMCSponge(R, C, 0);
        bets[D.betsIndex].R = R;
        bets[D.betsIndex].C = C;
        LogBetIn(_secrethash,D.nextIndex+D.betsIndex,mask,R,C); // mask,R,C not needed
        D.betsIndex++;
    }

    /**
     * @dev collect the reward
     */
    function collect(
        uint[2] calldata _pA,
        uint[2][2] calldata _pB,
        uint[2] calldata _pC,
        bytes32 _root,
        bytes32 _nullifierHash,
        address payable _recipient,
        address payable _relayer,
        uint _fee,
        uint _refund,
	uint _rew1,
	uint _rew2,
	uint _rew3,
        uint _invest) payable external nonReentrant {
        require(msg.value == _refund, "Incorrect refund amount received by the contract");
        require(nullifier[_nullifierHash] == 0, "Incorrect nullifier");
        require(isKnownRoot(_root), "Cannot find your merkle root"); // Make sure to use a recent one
        require(withdraw.verifyProof( _pA, _pB, _pC, [ uint(_root), uint(_nullifierHash), uint(_rew1), uint(_rew2), uint(_rew3), uint(uint160(_recipient)), uint(uint160(_relayer)), _fee, _refund ]), "Invalid withdraw proof");
        nullifier[_nullifierHash] = 1;
        uint _reward == betMin * _rew1 * 2**betPower1 +
                        betMin * _rew2 * 2**betPower2 +
                        betMin * _rew3 * 2**betPower3 ;
        LogWin(uint _nullifierHash, uint _reward);
        currentBets += _reward;
        collectDividend(generator);
        uint generatorReward = _reward * generatorFeePerCent / 100;
        currentBalance += generatorReward;
        wallets[generator].balance += uint112(generatorReward);
        collectDividend(_recipient);
        _reward = _reward * (100 - dividendFeePerCent - generatorFeePerCent) / 100;
        if(_invest>0 && wallets[_recipient].balance < maxBalance) {
            if(_invest > _reward) {
                _invest = _reward;
            }
            currentBalance += _invest;
            wallets[_recipient].balance += uint112(_invest);
            _reward -= _invest;
        }
        /* process withdrawal */
        if(betMin * 2**betPower2 < _reward) { // limit max withdrawal
            _invest = _reward - (betMin * 2**betPower2);
            currentBalance += _invest;
            wallets[_recipient].balance += uint112(_invest);
            wallets[_recipient].nextWithdrawPeriod = uint16(D.dividendPeriod + 1); // wait 1 period for more funds
            _reward -= _invest;
        }
        uint balance = _balance():
        if(balance < _reward) {
            _invest = _reward - balance;
            currentBalance += _invest;
            wallets[_recipient].balance += uint112(_invest);
            _reward -= _invest;
        }
        require(_reward < _fee, "Insufficient reward");
        _withdraw(_recipient,_reward - _fee);
        if (_fee > 0) {
            _withdraw(_relayer,_fee);
        }
        if (_refund > 0) {
          _recipient.call{ value: _refund }("");
        }
        rememberHash();
    }

   /**
     * @dev cancel bet, no privacy !
     */
    function cancelbet(
        uint _betIndex,
        uint[2] calldata _pA,
        uint[2][2] calldata _pB,
        uint[2] calldata _pC,
        address payable _recipient,
        address payable _relayer,
        uint _fee,
        uint _refund) payable external nonReentrant {
        require(msg.value == _refund, "Incorrect refund amount received by the contract");
        require(D.nextIndex<=betIndex && betIndex<D.nextIndex+D.betsIndex, "Bet probably processed");
        uint betId=betIndex-D.nextIndex;
        require(bidId<betsMax, "Cannot find your bet"); // probably, bet already processed
        require(cancel.verifyProof( _pA, _pB, _pC, [ uint(bets[betId].R), uint(bets[betId].C), uint(uint160(_recipient)), uint(uint160(_relayer)), _fee, _refund ]), "Invalid withdraw proof");
        bets[betId]=BetsRC(0,0);
        uint _reward == 2 * betMin; // fee: betMin
        uint i=0;
        for( ; i<=betPower1 ; i++){
            if(!(_mask & (2**i))){
                _reward = betMin * (1 + 2**(i+1)); // fee: betMin
            }
        }
        for( ; i<=betPower2 ; i++){
            if(!(_mask & (2**(i+betPower1)))){
                _reward = betMin * (1 + 2**(i+1)); // fee: betMin
            }
        }
        LogCancel(betIndex);
        collectDividend(_recipient);
        /* process withdrawal */
        uint balance = _balance();
        if(balance < _reward) {
            uint _invest = _reward - balance;
            currentBalance += _invest;
            wallets[_recipient].balance += uint112(_invest);
            _reward -= _invest;
        }
        require(_reward < _fee, "Insufficient reward");
        _withdraw(_recipient,_reward - _fee);
        if (_fee > 0) {
            _withdraw(_relayer,_fee);
        }
        if (_refund > 0) {
          _recipient.call{ value: _refund }("");
        }
        rememberHash();
    }


/* random number generator functions */

    /**
     * @dev commit the generator secret
     */
    function commit(uint _commitHash) external onlyGenerator {
        require(commitHash != 0, "Invalid commit hash");
        require(commitHash == 0, "Commit hash already set");
        require(D.commitBlock == 0, "Commit block already set");
        commitHash = _commitHash;
        D.commitBlock = block.number;
        D.commitIndex = D.betsIndex;
        D.commitCount ++;
        commitBlockHash = 0;
    }

    /**
     * @dev remember commitBlockHash
     */
    function rememberHash() public {
        if(D.commitBlock != 0 && commitBlockHash == 0){
          commitBlockHash = block.blockhash(D.commitBlock);}
    }

    /**
     * @dev reveal the generator secret
     */
    function reveal(uint _revealSecret) external onlyGenerator returns (uint, uint) {
        require(uint(keccak256(_revealSecret)) == commitHash, "Invalid reveal secret");
        require(D.commitBlock != 0, "Commit not set");
        rememberHash();
        require(commitBlockHash != 0, "Commit block hash not found");
        uint newhash = uint128(keccak256(_revealSecret,commitBlockHash));
        uint insertedIndex=D.nextIndex;
        uint rand;
        uint j;
        for(uint i = 0; i < D.commitIndex; i++) {
            uint R = bets[i].R;
            uint C = bets[i].C;
            rand=newhash+insertedIndex;
            R = addmod(R, rand, FIELD_SIZE);
            (R, C) = hasher.MiMCSponge(R, C, 0);
            uint currentLevelHash = R;
            if(i<D.commitIndex-1) {
                insertedIndex = _insertleft(currentLevelHash);
            }
            else {
                insertedIndex = _insert(currentLevelHash);
            }
            LogBetHash(insertedIndex,rand,currentLevelHash); // currentLevelHash for speedup
        }
        for(j = 0; i < bestIndex; i++, j++) { // queue unprocessed bets
            bets[j].R=bets[i].R;
            bets[j].C=bets[i].C;
        }
        betsSum = betsWaiting;
        betsWaiting = 0;
        D.betsIndex = j;
        commitHash = 0;
        D.commitBlock = 0;
        return(rand,currentLevelHash); // only last leaf is returned :-(
    }

/* investment functions */

    /**
     * @dev Update dividend period
     */
    function updateDividendPeriod() public {
        if(block.number >= D.periodStartBlock + periodBlocks || currentBets > maxBalance) {
            periods.push(Period(currentBets,currentShares));
            currentShares = currentBalance;
            currentBets = 0;
            D.periodStartBlock = block.number;
            D.dividendPeriod++;
        }
    }

    /**
     * @dev Commit remaining dividends before balance changes
     */
    function collectDividend(address _who) public nonReentrant {
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
        uint108 dividend = betshares * dividendFeePerCent / 100 / 0xffffffff; // uint108 to prevent theoretical balance overflow
        currentBalance += dividend;
        currentShares += dividend;
        wallets[_who].balance += dividend;
        wallets[_who].shares = wallets[_who].balance;
        wallets[_who].lastDividendPeriod = uint16(D.dividendPeriod);
    }

    /**
     * @dev Pay out balance from wallet
     * @param _amount The amount to pay out.
     */

    function payOut() public nonReentrant {
        collectDividend(msg.sender);
        require(D.dividendPeriod <= wallets[msg.sender].nextWithdrawPeriod, "Wait till the next dividend period");
        uint _amount = wallets[msg.sender].balance;
        if(betMin * 2**betPower2 < _amount) { // limit max withdrawal
            _amount = betMin * 2**betPower2;
            wallets[msg.sender].nextWithdrawPeriod = uint16(D.dividendPeriod + 1);
        }
        uint balance = _balance();
        if(_amount > balance) {
            _amount = balance;
            wallets[msg.sender].nextWithdrawPeriod = uint16(D.dividendPeriod + 1); // wait 1 period for more funds
        }
        wallets[msg.sender].balance -= uint112(_amount);
        currentBalance -= _amount;
        if(wallets[msg.sender].balance<wallets[msg.sender].shares) {
            currentShares -= wallets[msg.sender].shares - wallets[msg.sender].balance;
            wallets[msg.sender].shares = wallets[msg.sender].balance;
        }
        _withdraw(msg.sender,_amount);
    }

/* administrative functions */

    function _balance() internal returns (uint) {
        return(token.balanceOf(address(this)));
    }

    function _deposit(uint _amount) internal returns (uint) {
        token.safeTransferFrom(msg.sender, address(this), _amount);
        return(_amount);
    }

    function _withdraw(address _who,uint _amount) internal {
        token.safeTransferFrom(address(this), _who, _amount);
    }

    function exec(address _who,bytes _data) payable external onlyOwner {
        require(_who.call.value(msg.value)(_data));
    }

    /**
     * @dev deposit security deposit to reset commit
     */
    function resetcommit() payable external onlyOwner {
        require(commitHash!=0 && block.blockhash(D.commitBlock)==0, "No failed commit");
        if(token==0){
          require(msg.value >= betsSum, "transfer too low");
        }
        else{
          token.safeTransferFrom(msg.sender, address(this), betsSum);
        }
        commitHash = 0;
        D.commitBlock = 0;
        betsSum += betsWaiting;
        betsWaiting = 0;
        LogResetCommit(msg.sender);
    }

    /**
     * @dev close the lottery
     */
    function close() external onlyOwner {
        require(D.betsIndex==0, "Open bets");
        commitHash = 1;
        D.commitBlock = block.number;
        D.betsIndex = betsMax;
        LogClose(msg.sender);
    }

    /**
     * @dev reopen the lottery again
     */
    function reopen() external onlyOwner {
        require(commitHash==1, "Lottery open");
        commitHash = 0;
        D.commitBlock = 0;
        D.betsIndex = 0;
        LogReopen(msg.sender);
    }

    /**
     * @dev withdraw the remaining balance
     */
    function adminwithdraw() external onlyOwner {
        require(commitHash==1, "Lottery open");
        require(block.number > D.commitBlock + 4*60*24*365*2, "Not enough blocks passed"); // wait 2 years (in Ethereum)
        if(this.balance){
            msg.sender.transfer(this.balance);
        }
        if(token!=0){
            token.safeTransfer(msg.sender, token.balanceOf(address(this)));
        }
        LogWithdraw(msg.sender);
    }

    /**
     * @dev do not allow to send ether to the contract
     */
    function () payable external {
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
        require(D.status != _ENTERED, "ReentrancyGuard: reentrant call");
        D.status = _ENTERED;
        _;
        D.status = _NOT_ENTERED;
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
        LogChangeOwner(msg.sender, _who);
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
        LogChangeGenerator(msg.sender, _who);
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
     * @dev Returns data for generator
     */
    function getStatus() public view returns (uint , uint , uint ,uint ) {
        return (uint betsIndex, uint commitCount, uint commitBlock,uint commitHash);
    }

    /**
     * @dev Returns the last root
     */
    function getLastRoot() public view returns (bytes32) {
        return roots[D.currentRootIndex];
    }

    // events
    event LogBetIn(uint indexed secrethash,uint indexed index,uint R,uint C,uint mask);
    event LogBetHash(uint indexed index,uint newhash,uint currentLevelHash);
    event LogCancel(uint indexed index);
    event LogWin(uint indexed nullifierHash, uint reward);
    event LogTreeHash(uint indexed level,uint indexed index,uint levelHash);
    event LogClose(address indexed owner);
    event LogResetCommit(address indexed owner);
    event LogWithdraw(address indexed owner);
    event LogReopen(address indexed owner);
    event LogChangeOwner(address indexed owner, address indexed newOwner);
    event LogChangeGenerator(address indexed owner, address indexed newGenerator);
    
    /**
     * @dev Hash 2 tree leaves, returns MiMC(_left, _right)
     */
    function hashLeftRight(bytes32 _left, bytes32 _right) public pure returns (bytes32) {
        //require(uint(_left) < FIELD_SIZE, "_left should be inside the field");
        //require(uint(_right) < FIELD_SIZE, "_right should be inside the field");
        uint R = uint(_left);
        uint C = 0;
        (R, C) = hasher.MiMCSponge(R, C, 0);
        R = addmod(R, uint(_right), FIELD_SIZE);
        (R, C) = hasher.MiMCSponge(R, C, 0);
        return bytes32(R);
    }

    function _insert(bytes32 _leaf) internal returns (uint index) {
        uint currentIndex = D.nextIndex++;
        bytes32 currentLevelHash = _leaf;
        bytes32 left;
        bytes32 right;

        for (uint i = 0; i < merkleTreeLevels; i++) {
            if (currentIndex % 2 == 0) {
                left = currentLevelHash;
                right = zeros[i];
                filledSubtrees[i] = currentLevelHash;
                if(i=>merkleTreeReportLevel){
                    LogTreeHash(i,D.nextIndex-1,currentLevelHash);
                }
            } else {
                left = filledSubtrees[i];
                right = currentLevelHash;
            }
            currentLevelHash = hashLeftRight(left, right);
            currentIndex /= 2;
        }

        uint newRootIndex = (D.currentRootIndex + 1) % ROOT_HISTORY_SIZE;
        D.currentRootIndex = newRootIndex;
        roots[newRootIndex] = currentLevelHash;
        return D.nextIndex-1;
    }

    /**
     * @dev insert a leaf into the merkletree without updating the root
     */
    function _insertleft(bytes32 _leaf) internal returns (uint index) { // from MerkleTreeWithHistory
        uint currentIndex = D.nextIndex++;
        bytes32 currentLevelHash = _leaf;
        bytes32 left;
        bytes32 right;
        for (uint i = 0; i < merkleTreeLevels; i++) {
            if (currentIndex % 2 == 0) {
                filledSubtrees[i] = currentLevelHash;
                if(i=>merkleTreeReportLevel){
                    LogTreeHash(i,D.nextIndex-1,currentLevelHash);
                }
                return D.nextIndex-1;
            } else {
                left = filledSubtrees[i];
                right = currentLevelHash;
            }
            currentLevelHash = hashLeftRight(left, right);
            currentIndex /= 2;
        }
        return D.nextIndex-1;
    }

    /**
     * @dev Whether the root is present in the root history
     */
    function isKnownRoot(bytes32 _root) public view returns (bool) {
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
                i = ROOT_HISTORY_SIZE;
            }
            i--;
        } while (i != _currentRootIndex);
        return false;
    }
}
