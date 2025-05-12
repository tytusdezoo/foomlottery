pragma circom 2.2.0;

include "./lib/mimcsponge.circom"; // NEW
include "./merkletree.circom";

// updates merkel tree with new hashes
template Update(numhashes,levels) {
    signal input oldRoot;
    signal input newRoot;
    signal input index;
    signal input oldRand;
    signal input newRand;
    signal input newhashes[numhashes]; // starts with previous hash

    signal input pathElements[levels];

    // must compute here rand addition, too expensive in contract

    component mimc[numhashes];
    component inserts[numhashes];
    component is0[numhashes];
    //signal paths[numhashes][levels];
    signal roots[numhashes];
    for(var i = 0; i < numhashes; i++) {
        mimc[i] = MiMCSponge(2, 220, 1);
        mimc[i].ins[0] <== newhashes[i];
        mimc[i].ins[1] <== i == 0 ? oldRand + index : newRand + index + i;
        mimc[i].k <== 0;

        inserts[i] = MerkleTreeInsert(levels);
        inserts[i].leaf <== mimc[i].outs[0];
        inserts[i].index <== index + i;
        for (var j = 0; j < levels; j++) {
            inserts[i].pathElements[j] <== i == 0 ? pathElements[j] : inserts[i-1].newElements[j];
        }
        is0[i] = IsZero();
        is0[i].in <== newhashes[i];
        if( i == 0 ){
            oldRoot === inserts[i].root;
            roots[0] <== inserts[i].root;
        }
        else{
            roots[i] <== (roots[i-1] -  inserts[i].root) * is0[i].out + inserts[i].root;
        }
    }
    newRoot === roots[numhashes-1];
}

component main {public [oldRoot, newRoot, index, oldRand, newRand, newhashes]} = Update(8,32);
