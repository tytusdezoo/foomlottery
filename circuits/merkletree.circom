pragma circom 2.2.0;

include "./lib/bitify.circom";
include "./lib/mimcsponge.circom";

// Computes MiMC([left, right])
template HashLeftRight() {
    signal input left;
    signal input right;
    signal output hash;

    component hasher = MiMCSponge(2, 220, 1);
    hasher.ins[0] <== left;
    hasher.ins[1] <== right;
    hasher.k <== 0;
    hash <== hasher.outs[0];
}

// if s == 0 returns [in[0], in[1]]
// if s == 1 returns [in[1], in[0]]
template DualMux() {
    signal input in[2];
    signal input s;
    signal output out[2];

    s * (1 - s) === 0;
    out[0] <== (in[1] - in[0])*s + in[0];
    out[1] <== (in[0] - in[1])*s + in[1];
}

template MerkleTreeInsert(levels) {
    signal input leaf;
    signal input now[levels];
    signal input next[levels];
    signal input pathElements[levels];
    signal output root;
    signal output newElements[levels];

    var zeros[32]=[
        0x24d599883f039a5cb553f9ec0e5998d58d8816e823bd556164f72aef0ef7d9c0 ,// 0 mimcsponge([keccak(foom)<<4,0,0])
        0x2f1ff042a008b28a64620fc1680b24845d81a7b15e13e61c96bdd1f14d766087 ,// 1
        0x289805921b8f5a18ee9a74f7d5ec3b0e9ca0adc0e83fdad1ef2b44a36feb4915 ,// 2
        0x076e6e010aa2924a88a939fcb0b9fde77cc3daaf47315c65a23ae4c6cbf4dd5b ,// 3
        0x16a8eba566fdb9cdc992c0b3a49038e0e89293db4c835dbcb51121a7a596b3a8 ,// 4
        0x0747a40228ab01116a490f9dc4bb31d093ebc2b286d5baf25a35e2f259ab6360 ,// 5
        0x19b8ae3573dfdfec1ae426839327ad792d75b20ce2122841eb5c05b25f943ee9 ,// 6
        0x18a49708472d340ad5cdd621930879ce2e1d168fd658a5591aac89bc8967e371 ,// 7
        0x0e5c230fa94b937789a1980f91b9de6233a7d0315f037c7d4917cba089e0042a ,// 8
        0x17121b5b4dd1193798d1835b31f4dc7113c7f37fb000585f29e2fa974405fad1 ,// 9
        0x2ebd0b9a7b05be98e7c1226b5cd6efb598f71351b471c36b2d94071c6cf19bae ,// 10
        0x1c1e3214ae542a0c6be338e46d372836df36fe571e94cdbfcb8ef5562be919ba ,// 11
        0x25ef42051f7b36cbba71e74faef3b6b0dce8837a25b97587a5b07abb881e945f ,// 12
        0x1b53fd6aab7176d6170651a76e1211a3439686a62e61676eaebf5c1716a2317c ,// 13
        0x27410bde6a9682214ea3e3d3904e06205188f74e36bcc0083be1d017a2eef1ab ,// 14
        0x2088e5f0196b4975e346add21bb3b0c6f9c764cec97142e3a892db275bdd57b9 ,// 15
        0x255da7d5316310ad81de31bfd5b8272b30ce70c742685ac9696446f618399317 ,// 16
        0x069bf458124ec171de8b924a604e0820b7258ff05d430f3ab4c2af139dd17928 ,// 17
        0x2c8035745ce1954026ee8381bc2658c6be243abe27a9910ac22f254d93a24d28 ,// 18
        0x0a553c4e81ac3c5cd31ba31505e0913697a0c1a26f1aefc6e2712942f93189f9 ,// 19
        0x155bfb4e8982a3d8e5e504b622308cefc732ab93d679861250a90f22038105c4 ,// 20
        0x0f11f3d423bbac6bd70a6c5c3271864e88fe1cecb21597fc9ffb881036326a3e ,// 21
        0x10d0520189355c557fb03969b3a412c4f777f8c1efbbc6a46128a0f39a747f78 ,// 22
        0x226d9816e90d488d9d2782f981845daf0aa8668ca6c7f1f16e2242a280a7ebe6 ,// 23
        0x1dd4b847fd5bdd5d53a661d8268eb5dd6629669922e8a0dcbbeedc8d6a966aaf ,// 24
        0x08032412df6a6f95586be9a21a0f86ef919191a535d470511cb6103b5f7abe0e ,// 25
        0x2b72fd1bf1208c26b276a8ce1e202fb54504d9370c0200e98d8364f437e0e480 ,// 26
        0x0504518c4257caf65f53bb8f04a351091489919cfaf412033bfbd7ec56509a41 ,// 27
        0x2db93a8b5d4460b63f7665d67d39cac5175dfe465e3e2aa5a2c57687be16eb02 ,// 28
        0x009c93f2f4bc22f55bb7bbc632fcbeffff98adeeccad0e88719d42df48d17dac ,// 29
        0x00ba98fad7917110415951e7f2afec72ce24590c8fa911353590842e6de07f2e ,// 30
        0x1093c09ab5330cf80a78d3ca9e4c48b685109cce47d4de0da8f9c2e0040b913f];// 31
      //0x25439a05239667bccd12fc3bd280a29a02728ed44410446cbd51a27cda333b00 ROOT
 
    component selector[levels];
    component hashers[levels];

    for (var i = 0; i < levels; i++) {
        selector[i] = DualMux();
        selector[i].in[0] <== i == 0 ? leaf : hashers[i - 1].hash;
        selector[i].in[1] <== pathElements[i];
        selector[i].s <== now[i];

        hashers[i] = HashLeftRight();
        hashers[i].left <== selector[i].out[0];
        hashers[i].right <== selector[i].out[1];

        newElements[i] <== ((i == 0 ? leaf : selector[i].out[0]) - zeros[i]) * next[i] + zeros[i];
    }

    root <== hashers[levels - 1].hash;
}
