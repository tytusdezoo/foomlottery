pragma solidity ^0.7.0;

import "./MerkleTreeWithHistory.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

interface IVerifier {
    function verifyProof(
        uint256[2] calldata _pA,
        uint256[2][2] calldata _pB,
        uint256[2] calldata _pC,
        uint256[9] calldata _pubSignals
    ) external view returns (bool);
}
interface ICancel {
    function verifyProof(
        uint256[2] calldata _pA,
        uint256[2][2] calldata _pB,
        uint256[2] calldata _pC,
        uint256[6] calldata _pubSignals
    ) external view returns (bool);
}
interface IHasher {
  function MiMCSponge(uint256 in_xL, uint256 in_xR) external pure returns (uint256 xL, uint256 xR);
}

/**
 * @title FOOM Lottery
 */
contract FoomLottery is MerkleTreeWithHistory, ReentrancyGuard {
    using SafeERC20 for IERC20;
    IERC20 public token; // FOOM token

    // metadata
    string public constant name = "Foom Lottery";

    uint public constant merkleTreeLevels = 31 ; // number of Merkle Tree levels
    uint public constant merkleTreeReportLevel = 8 ; // report completed Merkle Tree level
    uint public constant periodBlocks = 16384 ; // number of blocks in a period
    uint public constant betMin = 0.001 ether; // minimum bet size per block, 
    uint public constant betPower1 = 10; // power of the first bet = 1024 ... TODO: consider increasing to 20
    uint public constant betPower2 = 16; // power of the second bet = 65536
    uint public constant betPower3 = 22; // power of the third bet = 4194304 (not enough FOOM now)
    uint public constant betsMax = 128; // maximum number of bets in queue
    uint public constant dividendFeePerCent = 4; // 4% of dividends go to the shareholders (wall)
    uint public constant generatorFeePerCent = 1; // 1% of dividends go to the generator
    uint public constant maxBalance = 2**108; // maximum balance of a user and maximum size of bets in period
    //TODO: define minimum play amount

    // contract state
    address public owner;
    address public generator;
    uint public periodStartBlock;

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
    mapping(uint256 => Period) public periods;
    uint public currentBalance = 1; // sum of funds in wallets
    uint public currentBets = 1; // total bet volume in current period
    uint public currentShares = 1; // sum of funds eligible for dividend in current period
    uint public dividendPeriod = 1; // current dividend period

    // betting parameters
    struct BetsRC {
        uint256 R; // total bet volume in period
        uint256 C; // total eligible funds in period
    }
    //BetsRC public bets[betsMax]; // bets in queue
    // it removes index range check on every interaction
    mapping(uint256 => BetsRC) public bets;
    uint public betsSum = 0; // sum of bets in queue
    uint public betsWaiting = 0; // sum of bets waiting for new generator commit
    uint public betsIndex = 0; // index of the next slot in queue
    mapping (uint => uint) public nullifier; // nullifier hash for each bet

    //mapping (uint => uint) public betsMap; // TODO: all previous bets , for testing only !

    // generator data
    uint public commitHash = 0;
    uint public commitBlock = 0;
    uint public commitIndex = 0;

    // constructor
    IVerifier public immutable verifier;
    ICancel public immutable cancel;
    IHasher public immutable hasher;
    constructor(
        IVerifier _verifier,
        ICancel _cancel,
        IHasher _hasher,
        IERC20 _token
          ) MerkleTreeWithHistory(merkleTreeLevels, _hasher) {
            verifier = _verifier;
            cancel = _cancel;
            hasher = _hasher;
            token = _token;
            owner = msg.sender;
            generator = msg.sender;
            periodStartBlock = block.number;
            wallets[owner] = Wallet(uint112(1),uint112(1),uint16(dividendPeriod),uint16(0));
            periods.push(Period(0,0)); // not used
            periods.push(Period(1,1)); // not used
    }

/* lottery functions */

    /**
     * @dev Calculate mask for lottery
     */
    function _getMask(uint _amount) pure returns (uint) {
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
    function play(uint _secrethash,uint _amount) external {
        require(uint256(_secrethash) < FIELD_SIZE, "_left should be inside the field");
        require(msg.value == 0, "ETH value is supposed to be 0 for ERC20 instance");
        require(betsIndex + nextIndex < 2**32, "No more bets allowed"); // TODO: move to commit() ; nextIndex is from MerkleTreeWithHistory
        token.safeTransferFrom(msg.sender, address(this), _amount);
        require(_secrethash != 0, "Invalid secret hash");
        require(betsIndex >= betsMax, "No more bets allowed");
        if(commitBlock == 0) {
            betsSum += _amount;
        }
        else {
            betsWaiting += _amount;
        }
        uint mask = _getMask(_amount);
        uint R = _secrethash;
        uint C = 0;
        (R, C) = _hasher.MiMCSponge(R, C, 0);
        R = addmod(R, mask, FIELD_SIZE);
        (R, C) = _hasher.MiMCSponge(R, C, 0);
        bets[betsIndex].R = R;
        bets[betsIndex].C = C;
        //uint power = _getPower(_amount);
        //// store the bets in the contract
        //uint bethash = power+(_secrethash<<8); // TODO: convert to zksnark freindly update, add minBet if allowed to change
        //bets[betsIndex] = bethash;
        LogBetIn(_secrethash,nextIndex+betsIndex,mask,R,C); // mask,R,C not needed
        betsIndex++;
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
        uint _luck, // 0x1,0x2,0x4 for each lottery reward
        uint _invest) payable external {
        require(msg.value == _refund, "Incorrect refund amount received by the contract");
        require(nullifier[_nullifierHash] == 0, "Incorrect nullifier");
        require(isKnownRoot(_root), "Cannot find your merkle root"); // Make sure to use a recent one
        require(
            verifier.verifyProof(
                _pA,
                _pB,
                _pC,
                [
                    uint256(_root),
                    uint256(_nullifierHash),
                    uint256(_luck&1?1:0),
                    uint256(_luck&2?1:0),
                    uint256(_luck&4?1:0),
                    uint256(uint160(_recipient)),
                    uint256(uint160(_relayer)),
                    _fee,
                    _refund
                ]
            ),
            "Invalid withdraw proof"
        );
        nullifier[_nullifierHash] = 1;
        uint _reward == betMin * uint256(_luck&1?1:0) * 2**betPower1 +
                        betMin * uint256(_luck&2?1:0) * 2**betPower2 +
                        betMin * uint256(_luck&4?1:0) * 2**betPower3 ;
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
        uint balance = token.balanceOf(address(this));
        if(balance < _reward) {
            _invest = _reward - balance;
            currentBalance += _invest;
            wallets[_recipient].balance += uint112(_invest);
            _reward -= _invest;
        }
        require(_reward < _fee, "Insufficient reward");
        token.safeTransfer(_recipient, _reward - _fee);
        if (_fee > 0) {
            token.safeTransfer(_relayer, _fee);
        }
        if (_refund > 0) {
          _recipient.call{ value: _refund }("");
        }
    }

   /**
     * @dev cancel bet, no privacy !
     */
    function cancelbet(
        uint[2] calldata _pA,
        uint[2][2] calldata _pB,
        uint[2] calldata _pC,
        uint _betIndex,
        address payable _recipient,
        address payable _relayer,
        uint _fee,
        uint _refund) payable external {
        require(msg.value == _refund, "Incorrect refund amount received by the contract");
        require(nextIndex<=betIndex && betIndex<nextIndex+betsIndex, "Bet probably processed");
        uint betId=betIndex-nextIndex;
        require(bidId<betsMax, "Cannot find your bet"); // probably, bet already processed
        require(
            cancel.verifyProof(
                _pA,
                _pB,
                _pC,
                [
                    uint(bets[betId].R),
                    uint(bets[betId].C),
                    uint(uint160(_recipient)),
                    uint(uint160(_relayer)),
                    _fee,
                    _refund
                ]
            ),
            "Invalid withdraw proof"
        );
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
        /* process withdrawal */
        uint balance = token.balanceOf(address(this));
        if(balance < _reward) {
            collectDividend(_recipient);
            uint _invest = _reward - balance;
            currentBalance += _invest;
            wallets[_recipient].balance += uint112(_invest);
            _reward -= _invest;
        }
        require(_reward < _fee, "Insufficient reward");
        token.safeTransfer(_recipient, _reward - _fee);
        if (_fee > 0) {
            token.safeTransfer(_relayer, _fee);
        }
        if (_refund > 0) {
          _recipient.call{ value: _refund }("");
        }
    }


/* random number generator functions */

    /**
     * @dev commit the generator secret
     */
    function commit(uint _commitHash) external onlyGenerator {
        require(_commitHash != 0, "Invalid commit hash");
        require(commitHash == 0, "Commit hash already set");
        require(commitBlock == 0, "Commit block already set");
        commitHash = _commitHash;
        commitBlock = block.number;
        commitIndex = betsIndex;
    }

    /**
     * @dev reveal the generator secret
     */
    function reveal(uint _revealSecret) external onlyGenerator {
        require(uint(keccak256(_revealSecret)) == commitHash, "Invalid reveal secret");
        require(commitBlock != 0, "Commit not set");
        uint commitBlockHash = block.blockhash(commitBlock);
        require(commitBlockHash != 0, "Commit block hash not found");
        uint newhash = uint240(keccak256(_revealSecret,commitBlockHash));
        uint insertedIndex;
        for(uint i = 0; i < commitIndex; i++) {
            uint R = bets[i].R;
            uint C = bets[i].C;
            R = addmod(R, newhash, FIELD_SIZE);
            (R, C) = _hasher.MiMCSponge(R, C, 0);
            uint currentLevelHash = R;
            if(i<commitIndex-1) {
                insertedIndex = _insertleft(currentLevelHash);
            }
            else {
                insertedIndex = _insert(currentLevelHash);
            }
            LogBetHash(insertedIndex,newhash,currentLevelHash); // currentLevelHash for speedup
            newhash++;
            //betsMap[bets[i]] = newhash; // TODO: for testing only
        }
        for(uint j = 0; i < bestIndex; i++, j++) { // queue unprocessed bets
            bets[j].R=bets[i].R;
            bets[j].C=bets[i].C;
        }
        // TODO: pay fee to generator
        betsSum = betsWaiting;
        betsWaiting = 0;
        betsIndex = j;
        commitHash = 0;
        commitBlock = 0;
        // commitIndex = 0; // not needed
    }

    /**
     * @dev insert a leaf into the merkletree without updating the root
     */
    function _insertleft(bytes32 _leaf) internal returns (uint index) { // from MerkleTreeWithHistory
        uint _nextIndex = nextIndex;
        uint currentIndex = _nextIndex;
        bytes32 currentLevelHash = _leaf;
        bytes32 left;
        bytes32 right;

        //TODO: log hiher levels

        for (uint i = 0; i < merkleTreeLevels; i++) {
            if (currentIndex % 2 == 0) {
                filledSubtrees[i] = currentLevelHash;
                nextIndex = _nextIndex + 1;
                if(i=>merkleTreeReportLevel){
                    LogTreeHash(i,nextIndex,currentLevelHash);
                }
                return _nextIndex;
            } else {
                left = filledSubtrees[i];
                right = currentLevelHash;
            }
            currentLevelHash = hashLeftRight(hasher, left, right);
            currentIndex /= 2;
        }
        nextIndex = _nextIndex + 1;
        return _nextIndex;
    }

/* investment functions */

    /**
     * @dev Update dividend period
     */
    function updateDividendPeriod() public {
        if(block.number >= periodStartBlock + periodBlocks || currentBets > maxBalance) {
            periods.push(Period(currentBets,currentShares));
            currentShares = currentBalance;
            currentBets = 0;
            periodStartBlock = block.number;
            dividendPeriod++;
        }
    }

    /**
     * @dev Commit remaining dividends before balance changes
     */
    function collectDividend(address _who) public {
        updateDividendPeriod();
        uint last = wallets[_who].lastDividendPeriod;
        if(last==0){
            wallets[_who].lastDividendPeriod=uint16(dividendPeriod);
            return;
        }
        if(last==dividendPeriod) {
            return;
        }
        uint shares = uint256(wallets[_who].shares) * 0xffffffff;
        uint betshares = shares * periods[last].bets / periods[last].shares;
        shares = uint256(wallets[_who].balance) * 0xffffffff;
        for(last++;last<dividendPeriod;last++) {
            betshares += shares * periods[last].bets / periods[last].shares;
        }
        uint108 dividend = betshares * dividendFeePerCent / 100 / 0xffffffff; // uint108 to prevent theoretical balance overflow
        currentBalance += dividend;
        currentShares += dividend;
        wallets[_who].balance += dividend;
        wallets[_who].shares = wallets[_who].balance;
        wallets[_who].lastDividendPeriod = uint16(dividendPeriod);
    }

    /**
     * @dev Pay out balance from wallet
     * @param _amount The amount to pay out.
     */
    function payOut(uint _amount) public {
        collectDividend(msg.sender);
        require(_amount <= wallets[msg.sender].balance, "Invalid amount");
        require(dividendPeriod <= wallets[msg.sender].nextWithdrawPeriod, "Wait till the next dividend period");
        if(_amount==0) {
            _amount = wallets[msg.sender].balance;
        }
        uint balance = token.balanceOf(address(this));
        if(_amount > balance) {
            _amount = balance;
            wallets[msg.sender].nextWithdrawPeriod = uint16(dividendPeriod + 1); // wait 1 period for more funds
        }
        wallets[msg.sender].balance -= uint112(_amount);
        currentBalance -= _amount;
        if(wallets[msg.sender].balance<wallets[msg.sender].shares) {
            currentShares -= wallets[msg.sender].shares - wallets[msg.sender].balance;
            wallets[msg.sender].shares = wallets[msg.sender].balance;
        }
        token.safeTransfer(msg.sender, _amount);
    }

/* administrative functions */

    /**
     * @dev deposit security deposit to reset commit
     */
    function resetcommit() payable external onlyOwner {
        require(commitHash!=0 && block.blockhash(commitBlock)==0, "No failed commit");
        token.safeTransferFrom(msg.sender, address(this), betsSum);
        commitHash = 0;
        commitBlock = 0;
        betsSum += betsWaiting;
        betsWaiting = 0;
        LogResetCommit(msg.sender);
    }

    /**
     * @dev close the lottery
     */
    function close() external onlyOwner {
        require(betsIndex==0, "Open bets");
        commitHash = 1;
        commitBlock = block.number;
        betsIndex = betsMax;
        LogClose(msg.sender);
    }

    /**
     * @dev reopen the lottery again
     */
    function reopen() external onlyOwner {
        require(commitHash==1, "Lottery open");
        commitHash = 0;
        commitBlock = 0;
        betsIndex = 0;
        LogReopen(msg.sender);
    }

    /**
     * @dev withdraw the remaining balance
     */
    function adminwithdraw() external onlyOwner {
        require(commitHash==1, "Lottery open");
        require(block.number > commitBlock + 4*60*24*365*2, "Not enough blocks passed"); // wait 2 years (in Ethereum)
        msg.sender.transfer(this.balance);
        token.safeTransfer(msg.sender, token.balanceOf(address(this)));
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
    function walletSharesOf(address _owner) constant external returns (uint) {
        return uint(wallets[_owner].shares);
    }
    
    /**
     * @dev Show last balance eligible for dividend.
     * @param _owner The address of the account.
     */
    function walletBalanceOf(address _owner) constant external returns (uint) {
        return uint(wallets[_owner].balance);
    }
    
    /**
     * @dev Show last dividend period processed.
     * @param _owner The address of the account.
     */
    function walletPeriodOf(address _owner) constant external returns (uint) {
        return uint(wallets[_owner].lastDividendPeriod);
    }
    
    /**
     * @dev Show block number when withdraw can continue.
     * @param _owner The address of the account.
     */
    function walletBlockOf(address _owner) constant external returns (uint) {
        return uint(wallets[_owner].nextWithdrawBlock);
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
    
}
