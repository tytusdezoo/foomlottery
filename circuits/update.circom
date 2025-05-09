pragma circom 2.2.0;

include "./lib/bitify.circom";
include "./lib/pedersen.circom";
include "./lib/mimcsponge.circom"; // NEW
include "./merkletree.circom";

// updates merkel tree with new hashes
template Withdraw(numhashes,levels) {
    signal input oldRoot;
    signal input newRoot;
    signal input index;
    signal input rand;
    signal input lasthash;
    signal input newhashes[numhashes];
    
    signal input pathElements[levels];
    signal input pathIndices[levels];


    component trees[numhashes+1];

    trees[0] = MerkleTreeChecker(levels);
    trees[0].leaf <== lasthash;
    trees[0].root <== oldRoot;
    for (var i = 0; i < levels; i++) {
        trees[0].pathElements[i] <== pathElements[i];
        trees[0].pathIndices[i] <== pathIndices[i];
    }

    component inserts[numhashes];
    component is0[numhashes];
    for(var i = 0; i <= numhashes; i++) {
        is0[i] = IsZero();
        is0[i].in[0] <== newhashes[i];
        


    component hasher = CommitmentHasher();
    hasher.secret <== secret;
    hasher.rand <== rand; // NEW
    hasher.nullifierHash === nullifierHash;

    // test legal hash
    component hasherBits = Num2Bits(256);
    hasherBits.in <== hasher.commitment;
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
    mimc1.ins[1] <== rand;
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
    mimc2.ins[0] <== hasher.commitment + power + 1;
    mimc2.ins[1] <== rand;
    mimc2.k <== 0;

    // NEW BLOCK END

    component tree = MerkleTreeChecker(levels);
    tree.leaf <== mimc2.outs[0];
    tree.root <== root;
    for (var i = 0; i < levels; i++) {
        tree.pathElements[i] <== pathElements[i];
        tree.pathIndices[i] <== pathIndices[i];
    }

}

component main {public [oldRoot, newRoot, index,rand, lasthash, newhashes]} = Withdraw(8,32);
