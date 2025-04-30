pragma circom 2.2.0;

include "./lib/bitify.circom";
include "./lib/pedersen.circom";
include "./lib/mimcsponge.circom";

// computes Pedersen(nullifier + secret)
template PreCommitmentHasher() {
    signal input nullifier;
    signal input secret;
    signal output commitment;

    component commitmentHasher = Pedersen(496);
    component nullifierBits = Num2Bits(248);
    component secretBits = Num2Bits(248);
    nullifierBits.in <== nullifier;
    secretBits.in <== secret;
    for (var i = 0; i < 248; i++) {
        commitmentHasher.in[i] <== nullifierBits.out[i];
        commitmentHasher.in[i + 248] <== secretBits.out[i];
    }
    commitment <== commitmentHasher.out[0];
}

// Verifies that commitment that corresponds to given secret and nullifier is included in the merkle tree of deposits
template CancelBet() {
    signal input inR;
    signal input inC;
    signal input recipient; // not taking part in any computations
    signal input relayer;  // not taking part in any computations
    signal input fee;      // not taking part in any computations
    signal input refund;   // not taking part in any computations
    
    signal input nullifier; // TODO: could be removed
    signal input secret;
    signal input mask;

    component hasher = PreCommitmentHasher();
    hasher.nullifier <== nullifier;
    hasher.secret <== secret;

    component S0 = MiMCFeistel(220);
    S0.k <== 0;
    S0.xL_in <== hasher.commitment;
    S0.xR_in <== 0;

    component S1 = MiMCFeistel(220);
    S1.k <== 0;
    S1.xL_in <== S0.xL_out + mask;
    S1.xR_in <== S0.xR_out;

    S1.xL_out === inR;
    S1.xR_out === inC;

    signal recipientSquare;
    signal feeSquare;
    signal relayerSquare;
    signal refundSquare;
    recipientSquare <== recipient * recipient;
    feeSquare <== fee * fee;
    relayerSquare <== relayer * relayer;
    refundSquare <== refund * refund;
}

component main {public [inR, inC, recipient, relayer, fee, refund]} = CancelBet();
