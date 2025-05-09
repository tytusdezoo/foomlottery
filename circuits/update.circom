pragma circom 2.2.0;

include "./lib/bitify.circom";
include "./lib/mimcsponge.circom"; // NEW
include "./merkletree.circom";

// updates merkel tree with new hashes
template Update(numhashes,levels) {
    signal input oldRoot;
    signal input newRoot;
    signal input index;
    signal input newhashes[numhashes]; // starts with previous hash
    signal input pathElements[levels];

    component inserts[numhashes];
    component is0[numhashes];
    var newroot = 0;
    var paths[numhashes][levels];
    for(var i = 0; i < numhashes; i++) {
        inserts[i] = component MerkleTreeChecker(levels);
        inserts[i].leaf <== newhashes[i];
        inserts[i].index <== ind + i;
        for (var j = 0; j < levels; j++) {
            insert[i].pathElements[j] <== i == 0 ? pathElements[j] : paths[i-1][j];
        }
        for (var j = 0; j < levels; j++) {
            paths[i][j] <== insert[i].newElements[j];
        }
        if( i == 0 ){
            oldRoot === inserts[i].root;
        }
        is0[i] = component IsZero();
        is0[i].in[0] <== newhashes[i];
        newroot += (1-is0[i].out) * (inserts[i].root - newroot);
    }
    newRoot === newroot;
}

component main {public [oldRoot, newRoot, index, newhashes]} = Withdraw(8,32);
