pragma circom 2.2.0;

include "./lib/mimcsponge.circom"; // NEW
include "./merkletree.circom";

// updates merkel tree with new hashes
template Update(numhashes,levels) {
    signal input oldRoot;
    signal input newRoot;
    signal input index;
    signal input newRand;
    signal input newhashes[numhashes]; // starts with previous hash

    signal input oldRand;
    signal input pathElements[levels];

    component bits[numhashes+1];
    component mimc[numhashes];
    component path[numhashes];
    component is0[numhashes];
    signal roots[numhashes];
    bits[0] = Num2Bits(levels);
    bits[0].in <== index;
    for(var i = 0; i < numhashes; i++) {
        bits[i+1] = Num2Bits(levels+1);
        bits[i+1].in <== index + i + 1;

        mimc[i] = MiMCSponge(3, 220, 1);
        mimc[i].ins[0] <== newhashes[i];
        mimc[i].ins[1] <== i == 0 ? oldRand : newRand;
        mimc[i].ins[2] <== index + i;
        mimc[i].k <== 0;

        path[i] = MerkleTreeInsert(levels);
        path[i].leaf <== mimc[i].outs[0];
        //inserts[i].index <== index + i;
        for (var j = 0; j < levels; j++) {
            path[i].now[j] <== bits[i].out[j];
            path[i].next[j] <== bits[i+1].out[j];
            path[i].pathElements[j] <== i == 0 ? pathElements[j] : path[i-1].newElements[j];
        }
        is0[i] = IsZero();
        is0[i].in <== newhashes[i];
        if( i == 0 ){
            oldRoot === path[0].root;
            roots[0] <== path[0].root;
        }
        else{
            roots[i] <== (roots[i-1] -  path[i].root) * is0[i].out + path[i].root;
        }
    }
    newRoot === roots[numhashes-1];
}

component main {public [oldRoot, newRoot, index, newRand, newhashes]} = Update(22,32);
