pragma circom 2.2.0;

include "./lib/bitify.circom";
include "./lib/pedersen.circom";
include "./lib/mimcsponge.circom"; // NEW
include "./merkletree.circom";

template CommitmentHasher() {
    signal input secret;
    signal input rand_index; // NEW
    signal output secretHash;
    signal output nullifierHash;

    component secretHasher = Pedersen(248);
    component secretBits = Num2Bits(248);
    component nullifierHasher = Pedersen(248);
    component nullifierBits = Num2Bits(256);
    secretBits.in <== secret;
    nullifierBits.in <== secret + rand_index;
    for (var i = 0; i < 248; i++) {
        secretHasher.in[i] <== secretBits.out[i];
        nullifierHasher.in[i] <== nullifierBits.out[248 -1 -i];
    }

    secretHash <== secretHasher.out[0];
    nullifierHash <== nullifierHasher.out[0];
}

// Verifies that secretHash that corresponds to given secret and nullifier is included in the merkle tree of deposits
template Withdraw(levels,power1,power2,power3) {
    signal input root;
    signal input nullifierHash;
    signal input reward1; // NEW
    signal input reward2; // NEW
    signal input reward3; // NEW
    signal input recipient; // not taking part in any computations
    signal input relayer;  // not taking part in any computations
    signal input fee;      // not taking part in any computations
    signal input refund;   // not taking part in any computations
    
    signal input secret;
    signal input power; // NEW
    signal input rand; // NEW
    signal input pathIndex;
    signal input pathElements[levels];
    //signal input pathIndices[levels];

    component hasher = CommitmentHasher();
    hasher.secret <== secret;
    hasher.rand_index <== rand + pathIndex; // NEW
    hasher.nullifierHash === nullifierHash;

    // test legal hash
    component hasherBits = Num2Bits(256);
    hasherBits.in <== hasher.secretHash;
    hasherBits.out[0] === 0;
    hasherBits.out[1] === 0;
    hasherBits.out[2] === 0;
    hasherBits.out[3] === 0;
    hasherBits.out[4] === 0;

    // test reward values (probably not needed, tested in contract)
    reward1*(reward1-1) === 0;
    reward2*(reward2-1) === 0;
    reward3*(reward3-1) === 0;

    // compute mask
    component eq[power2+1];
    signal isequal[power2+1];
    signal mask;
    mask <-- (power<=power1)?((2**(power1+power2+1)-1)<<power)&(2**(power1+power2+1)-1):(((2**power2-1)<<(power+power1))|(2**power1-1))&(2**(power1+power2+1)-1);
    var sum = 0;
    for(var i = 0; i <= power2; i++) {
        eq[i] = IsEqual();
        eq[i].in[0] <== i;
        eq[i].in[1] <== power;
        isequal[i] <== eq[i].out * mask;
        sum += eq[i].out;
        if(i<=power1){
            var val=((2**(power1+power2+1)-1)<<i)&(2**(power1+power2+1)-1);
            isequal[i] === eq[i].out * val;
        }
        else{
            var val=(((2**power2-1)<<(i+power1))|(2**power1-1))&(2**(power1+power2+1)-1);
            isequal[i] === eq[i].out * val;
        }
    }
    sum === 1;

    // create secret random number
    component mimc1 = MiMCSponge(2, 220, 1);
    mimc1.ins[0] <== secret;
    mimc1.ins[1] <== rand + pathIndex;
    mimc1.k <== 0;
    signal lotto;
    lotto <== mimc1.outs[0];

    // evaluate lottery
    signal test[power1+power2];
    component lottoBits = Num2Bits(256);
    component maskBits = Num2Bits(power1+power2+1);
    lottoBits.in <== lotto;
    maskBits.in <== mask;
    var j = 0;
    for ( j=j ; j < power1; j++) {
        test[j] <== lottoBits.out[j] * maskBits.out[j];
        test[j] * reward1 === 0;
    }
    for ( j=j ; j < power1+power2; j++) {
        test[j] <== lottoBits.out[j] * maskBits.out[j];
        test[j] * reward2 === 0;
    }
    for ( j=j ; j < power1+power2+power3; j++) { // no more mask
        lottoBits.out[j]*reward3 === 0;
    }

    // NEW calculate new leaf hash
    component mimc2 = MiMCSponge(2, 220, 1);
    mimc2.ins[0] <== hasher.secretHash + power + 1;
    mimc2.ins[1] <== rand + pathIndex;
    mimc2.k <== 0;

    // NEW BLOCK END

    component bits[2];
    bits[0] = Num2Bits(levels);
    bits[0].in <== pathIndex;
    bits[1] = Num2Bits(levels);
    bits[1].in <== pathIndex + 1;
    component path = MerkleTreeInsert(levels);
    path.leaf <== mimc2.outs[0];
    //tree.index <== pathIndex;
    for (var i = 0; i < levels; i++) {
        path.now[i] <== bits[0].out[i];
        path.next[i] <== bits[1].out[i];
        path.pathElements[i] <== pathElements[i];
    }
    root === path.root;

    signal recipientSquare;
    signal feeSquare;
    signal relayerSquare;
    signal refundSquare;
    recipientSquare <== recipient * recipient;
    feeSquare <== fee * fee;
    relayerSquare <== relayer * relayer;
    refundSquare <== refund * refund;
}

component main {public [root, nullifierHash, reward1, reward2, reward3, recipient, relayer, fee, refund]} = Withdraw(32,10,16,22);
