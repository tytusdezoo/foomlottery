pragma circom 2.2.0;

include "./lib/bitify.circom";
include "./lib/pedersen.circom";
include "./lib/mimcsponge.circom";
include "./merkletree.circom";

template CommitmentHasher() {
    signal input secret;
    signal input nullifier;
    signal output secretHash;
    signal output nullifierHash;

    component secretHasher = Pedersen(248);
    component secretBits = Num2Bits(248);
    component nullifierHasher = Pedersen(248);
    component nullifierBits = Num2Bits(256);
    secretBits.in <== secret;
    nullifierBits.in <== nullifier;
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
    signal input rewardbits;
    signal input recipient; // not taking part in any computations
    signal input relayer;  // not taking part in any computations
    signal input fee;      // not taking part in any computations
    signal input refund;   // not taking part in any computations
    
    signal input secret;
    signal input power;
    signal input rand;
    signal input pathIndex;
    signal input pathElements[levels];

    // create secret random number
    component mimc1 = MiMCSponge(3, 220, 1);
    mimc1.ins[0] <== secret;
    mimc1.ins[1] <== rand;
    mimc1.ins[2] <== pathIndex;
    mimc1.k <== 0;

    component hasher = CommitmentHasher();
    hasher.secret <== secret;
    hasher.nullifier <== mimc1.outs[0];
    hasher.nullifierHash === nullifierHash;

    component hasherBits = Num2Bits(256);
    hasherBits.in <== hasher.secretHash;
    hasherBits.out[0] === 0;
    hasherBits.out[1] === 0;
    hasherBits.out[2] === 0;
    hasherBits.out[3] === 0;
    hasherBits.out[4] === 0;

    // compute mask
    component eq[power3+1];
    signal mask;
    mask <-- (power<=power1)?(((2 **(power1+power2+power3+1 )-1 )<<(power              ))                         )&(2 **(power1+power2+power3+1 )-1 ) :
            ((power<=power2)?(((2 **(       power2+power3+1 )-1 )<<(power+power1       ))|(2 **(power1       )-1 ))&(2 **(power1+power2+power3+1 )-1 ) :
                             (((2 **(              power3+1 )-1 )<<(power+power1+power2))|(2 **(power1+power2)-1 ))&(2 **(power1+power2+power3+1 )-1 ));
    var sum = 0;
    var maskcheck = 0;
    for(var i = 0; i <= power3; i++) {
        var imask=
             (    i<=power1)?(((2 **(power1+power2+power3+1 )-1 )<<(    i              ))                         )&(2 **(power1+power2+power3+1 )-1 ) :
            ((    i<=power2)?(((2 **(       power2+power3+1 )-1 )<<(    i+power1       ))|(2 **(power1       )-1 ))&(2 **(power1+power2+power3+1 )-1 ) :
                             (((2 **(              power3+1 )-1 )<<(    i+power1+power2))|(2 **(power1+power2)-1 ))&(2 **(power1+power2+power3+1 )-1 ));
        eq[i] = IsEqual();
        eq[i].in[0] <== i;
        eq[i].in[1] <== power;
        sum += eq[i].out;
        maskcheck += eq[i].out * imask;
    }
    sum === 1;
    mask === maskcheck;

    // evaluate lottery
    signal test[power1+power2+power3];
    component lottoBits = Num2Bits(256);
    component maskBits = Num2Bits(power1+power2+power3+1);
    component rewardBits = Num2Bits(3);
    lottoBits.in <== mimc1.outs[0];
    maskBits.in <== mask;
    rewardBits.in <== rewardbits;
    var j = 0;
    for ( j=j ; j < power1; j++) {
        test[j] <== lottoBits.out[j] * maskBits.out[j];
        test[j] * rewardBits.out[0] === 0;
    }
    for ( j=j ; j < power1+power2; j++) {
        test[j] <== lottoBits.out[j] * maskBits.out[j];
        test[j] * rewardBits.out[1] === 0;
    }
    for ( j=j ; j < power1+power2+power3; j++) {
        test[j] <== lottoBits.out[j] * maskBits.out[j];
        test[j] * rewardBits.out[2] === 0;
    }

    component mimc2 = MiMCSponge(3, 220, 1);
    mimc2.ins[0] <== hasher.secretHash + power + 1;
    mimc2.ins[1] <== rand;
    mimc2.ins[2] <== pathIndex;
    mimc2.k <== 0;

    component bits[2];
    bits[0] = Num2Bits(levels);
    bits[0].in <== pathIndex;
    bits[1] = Num2Bits(levels+1);
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

component main {public [root, nullifierHash, rewardbits, recipient, relayer, fee, refund]} = Withdraw(32,10,16,22);
