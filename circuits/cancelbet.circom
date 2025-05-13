pragma circom 2.2.0;

include "./lib/bitify.circom";
include "./lib/pedersen.circom";
include "./lib/mimcsponge.circom";

template SecretHasher() {
    signal input secret;
    signal output commitment;

    component secretHasher = Pedersen(248);
    component secretBits = Num2Bits(248);
    secretBits.in <== secret;
    for (var i = 0; i < 248; i++) {
        secretHasher.in[i] <== secretBits.out[i];
    }
    commitment <== secretHasher.out[0];
}

// Verifies that commitment that corresponds to given secret and nullifier is included in the merkle tree of deposits
template CancelBet() {
    signal input inHash;
    signal input recipient; // not taking part in any computations
    signal input relayer;  // not taking part in any computations
    signal input fee;      // not taking part in any computations
    signal input refund;   // not taking part in any computations
    
    signal input secret;

    component hasher = SecretHasher();
    hasher.secret <== secret;
    hasher.commitment === inHash;

    signal recipientSquare;
    signal feeSquare;
    signal relayerSquare;
    signal refundSquare;
    recipientSquare <== recipient * recipient;
    feeSquare <== fee * fee;
    relayerSquare <== relayer * relayer;
    refundSquare <== refund * refund;
}

component main {public [inHash, recipient, relayer, fee, refund]} = CancelBet();
