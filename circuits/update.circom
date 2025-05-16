pragma circom 2.2.0;

include "./lib/mimcsponge.circom"; // NEW
include "./merkletree.circom";

// updates merkel tree with new hashes
template Update(numhashes,levels) {
    signal input oldRoot;
    signal input newRoot;
    signal input index; // indexOf(numhash[0])-1
    signal input newRand;
    signal input newhashes[numhashes]; // starts with previous hash

    signal input oldLeaf;
    signal input pathElements[levels];

    component bits[numhashes+2];
    component mimc[numhashes];
    component path[numhashes+1];
    component is0[numhashes+1];
    signal roots[numhashes+1];
    bits[0] = Num2Bits(levels);
    bits[0].in <== index;
    for(var i = 0; i < numhashes+1; i++) {
        bits[i+1] = Num2Bits(levels+1);
        bits[i+1].in <== index + i + 1;

        if(i>0){
            mimc[i-1] = MiMCSponge(3, 220, 1);
            mimc[i-1].ins[0] <== newhashes[i-1];
            mimc[i-1].ins[1] <== newRand;
            mimc[i-1].ins[2] <== index + i;
            mimc[i-1].k <== 0;
        }

        path[i] = MerkleTreeInsert(levels);
        path[i].leaf <== i == 0 ? oldLeaf : mimc[i-1].outs[0];
        for (var j = 0; j < levels; j++) {
            path[i].now[j] <== bits[i].out[j];
            path[i].next[j] <== bits[i+1].out[j];
            path[i].pathElements[j] <== i == 0 ? pathElements[j] : path[i-1].newElements[j];
        }
        is0[i] = IsZero();
        is0[i].in <== i == 0 ? 1 : newhashes[i-1];
        if( i == 0 ){
            oldRoot === path[0].root;
            roots[0] <== path[0].root;
        }
        else{
            roots[i] <== (roots[i-1] -  path[i].root) * is0[i].out + path[i].root;
        }
    }
    newRoot === roots[numhashes];
}
