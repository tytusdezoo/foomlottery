pragma circom 2.2.0;

include "./lib/mimcsponge.circom"; // NEW
include "./merkletree.circom";
include "./update.circom";

component main {public [oldRoot, newRoot, index, newRand, newhashes]} = Update(11,32);
