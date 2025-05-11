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
    signal input index;
    signal input pathElements[levels];
    signal output root;
    signal output newElements[levels];

    var zeros[32]=[
        0x202a8f96045740e4004986fd2b650cf51b0cc148fb60f01312e628237deef281,
        0x0b2e758743ccfa3862e08c5dd379fd69488aa75ad6af13accc53ba97fcbcb528,
        0x057c4de8d5a8528665a63b905f0101ff7613414908e90d50d2f0c653dbb715de,
        0x0e1b6cdd46ad9ffd5e994c864581fdf4de1d591f0b036a7f187ecc98ac7c3cb3,
        0x0bbeaea623e15c126bc2a79b7721293d8c5819c0c93fc6f4b46d96c8d30310ca,
        0x2cee490e0f6709557a04c4a64a1b2f07de1334e74cabd9eea3f37f8c1e17e522,
        0x11cb3f75ae3bf84cf9a02a6c1d8feec18c6e81e34c2cf970985b827a56f5f925,
        0x2a5e106d6c503d83ac7fcd2680b040813f09d95f5c514873b27bdd564eeea9f9,
        0x017e8145556b5a426ee6112399ea51d95122a72a988f9e753e9117aa3d973d1b,
        0x11f5c0dbcc3d321f68cb3cb6c16795c1e08d18fbcc7567d204af1af66ca563eb,
        0x25d3fdb57ca9a4db85f2347ddf635f99730cd68705a54e27fc9a1d9b25d01d11,
        0x23dc1234876e354166436513d626df9b3810799dfe523d8717a4c33a137a42c9,
        0x227e0f15e1ff7d57d9d0e5243675d169d193489d0800c9945959174ba5658154,
        0x0dffe4520de3d082f56bb106e2924b456f825e922761d749eb1a29afb1f784f9,
        0x1ffa90c56f39c538f241eba71782e4a69aab0fb43cb968505d35a0f14529a05d,
        0x2201599ef7782d4d035487ab1467a6f0ce0abe69e5e755710ea10e6f4fe51bfd,
        0x2f426caa63faba590dbb1c463ef494585f254e373fa6a23567cc9291135ef1a4,
        0x0b0dcf14ca5e6f9a0660818681d21b6df5bd9075e1945df85d957e061eff565d,
        0x2ae4465fbe8fd25a39f1e0e289098d1a3b26cd274b0ef4c911974b5f1b5bbe57,
        0x2111ccd495b2338952afea3a1cf0c7e816333240678b1ebc545007179111e956,
        0x0316a21cfe5ebf127b1efae4ecfbc476c47db546b13c915efebbf917dbad2a63,
        0x2fdca0843043698e90deb1b0c52181d8188763ebbd88aa6659df9ffb23aa3bc4,
        0x04c99043b2be17c6af3e10796d0bf75b08d03f413d4af528b198f200dc832939,
        0x2ebce6763c7028261ed65d432ceec1a7493969c80bbf426ca9167d80a1c8d963,
        0x23e42a65648de39e532e24e9050c5355fddb331700a155782c4f3a85b1766b6d,
        0x2f9db21a4c7ab179efa1cac9fc389084ecc410ed2e7d5426ca5dde18777f5df6,
        0x25d215bce3087b0d8c6ef120d696ce075b22402dd800fcd53f43c382fe5db539,
        0x29e89141890d3ed3eaf93345eaf7e73ae777091a61e659ec73ca39e5cfc87163,
        0x2f3c98cd95ccff391976b8954f9b94b0a1ba61497d64eb9575c9f4d9602431ba,
        0x0e4a4b68ebb99a1cd97ae3bcd3bc3ed63e9a320069e1799ba6cc5b972677ff73,
        0x2c1f841238f664dd797957778269fa53c8ecdfd1af0c339219b862bb9770064e,
        0x2150e5c55045c73f99cacd199d6086e84381f17b861cb0fb73fcc8803c180a59];
    // Root: 0x0e70c0ce4936fef410bff8991ee5051bfce7d594013b64aba97369ce4f2e2454
 
    component index0Bits = Num2Bits(levels);
    index0Bits.in <== index;
    component index1Bits = Num2Bits(levels+1);
    index1Bits.in <== index+1;
    component selector[levels];
    component hashers[levels];

    for (var i = 0; i < levels; i++) {
        selector[i] = DualMux();
        selector[i].in[0] <== i == 0 ? leaf : hashers[i - 1].hash;
        selector[i].in[1] <== pathElements[i];
        selector[i].s <== index0Bits.out[i];

        hashers[i] = HashLeftRight();
        hashers[i].left <== selector[i].out[0];
        hashers[i].right <== selector[i].out[1];

        newElements[i] <== selector[i].in[0] * index1Bits.out[i] + zeros[i] * (1-index1Bits.out[i]);
    }

    root <== hashers[levels - 1].hash;
}
