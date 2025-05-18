// SPDX-License-Identifier: GPL-3.0
/*
    Copyright 2021 0KIMS association.

    This file is generated with [snarkJS](https://github.com/iden3/snarkjs).

    snarkJS is a free software: you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    snarkJS is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
    or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
    License for more details.

    You should have received a copy of the GNU General Public License
    along with snarkJS. If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity >=0.7.0 <0.9.0;

contract Update21G16Verifier {
    // Scalar field size
    uint256 constant r    = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    // Base field size
    uint256 constant q   = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    // Verification Key data
    uint256 constant alphax  = 2838016017525993883163010382521498941721758473052108532585727710701360203208;
    uint256 constant alphay  = 2346961761741541737200884140995866091443071889616956183082745198307205897929;
    uint256 constant betax1  = 9532671793448323673973867030159421513372291508899986602383143800190967227025;
    uint256 constant betax2  = 12195696501946267449773660014685323754093080381999245734043068773778624885111;
    uint256 constant betay1  = 8125331622783751154761977266182848277785052347188382360871922521310672955338;
    uint256 constant betay2  = 7167542840595813515304972215445980544860021183383853823313468346475156396727;
    uint256 constant gammax1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant gammax2 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 constant gammay1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant gammay2 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;
    uint256 constant deltax1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant deltax2 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 constant deltay1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant deltay2 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;

    
    uint256 constant IC0x = 11379266600937343595136068045193940614899576762447677394244599428541736769923;
    uint256 constant IC0y = 4365081620985419416926425245561255278858245376629706739357238398681895728079;
    
    uint256 constant IC1x = 5470512443756657192146720168001198300149919295728761928128576935207131557540;
    uint256 constant IC1y = 13070112318219185333534711974389036339794687832915334715160036341923283644112;
    
    uint256 constant IC2x = 429215742197667837850379340187576823761623162256891510986314897899104810763;
    uint256 constant IC2y = 20657581641698266624554699118609162930391754980638457005394945784389836027890;
    
    uint256 constant IC3x = 4178033782676477672382482122953013277882352761835112906043943071929035341702;
    uint256 constant IC3y = 11207632921278703663227607062658945004980912864540203499105408763294932358337;
    
    uint256 constant IC4x = 258868395598233605908390893231611029531429345167595330420031039261077009705;
    uint256 constant IC4y = 14618939084361604052791753602868652650266425693001831954283506588851834504564;
    
    uint256 constant IC5x = 3171043781693335781164563604849418954344662367573049112960208538493799973829;
    uint256 constant IC5y = 5065068680533036884416792556158426526192745195992585550196882431397914754676;
    
    uint256 constant IC6x = 21393965608671103959929413876166538211109403379622901428260387998672939743012;
    uint256 constant IC6y = 17007102553135806491530309316623369996384402943879320198276894913017757668570;
    
    uint256 constant IC7x = 13240607397224257536055739915199231709930803651460853022925799797223485783062;
    uint256 constant IC7y = 10776736143982308777392542594874119989738472222529448921598582606238901369097;
    
    uint256 constant IC8x = 2802012277581075145096199907871763360646127851363808728180266541326596854128;
    uint256 constant IC8y = 10880080697660561025584526246407795418943346610849482909986819271865397201297;
    
    uint256 constant IC9x = 7699937865402510969882177572834702442329226582866496571009129889253072619661;
    uint256 constant IC9y = 19117466232365655071736288801548587681460327273298091016176529851762559339720;
    
    uint256 constant IC10x = 19737419904865963388254468535074761608555667248270537003028084728972894880560;
    uint256 constant IC10y = 544167737561555576962681986580210977443272493821891378030019757889007204857;
    
    uint256 constant IC11x = 10879005328258186745368445251566208790093111861724056408108671483350335372653;
    uint256 constant IC11y = 12032837490333318630797194690835710660069674007402300990991884934450246839150;
    
    uint256 constant IC12x = 5645480496243937299645612887725013482269883048798269233765755004229768211071;
    uint256 constant IC12y = 19170781186681293811610562944269231235529625685010821959897090404479874008575;
    
    uint256 constant IC13x = 3768012800194895466849041948842847851268557628157962268662566239074329850760;
    uint256 constant IC13y = 13088044186523424835605623068228785974831818235423387385442473936372558135166;
    
    uint256 constant IC14x = 13293668477815845882809117346300571677712125152174775184887230786495231205807;
    uint256 constant IC14y = 7256525182907767967025702365510226141560121798398908918398591476522975767375;
    
    uint256 constant IC15x = 21208484944969216240150532509457021715756754421935094567198284777008477282252;
    uint256 constant IC15y = 21188702103405434497240352975869925845447876017203372403034703202874145438655;
    
    uint256 constant IC16x = 20574115836745314059893030777546466687005023464794143053167050211564665000492;
    uint256 constant IC16y = 10306802266763978855535412020296902574050972551727833279531647198885680634527;
    
    uint256 constant IC17x = 16330880705040396027392990381088430234562778711605008939124590619066169323511;
    uint256 constant IC17y = 3363496294729063312185881317889239177362556947378980291652282276047655746425;
    
    uint256 constant IC18x = 7221441816038969721870979524046335207174544162494565350954003424259976228019;
    uint256 constant IC18y = 5147071770818305353948377738546899806002164004297532603290643655628007320078;
    
    uint256 constant IC19x = 16189688044282603621042294228643092589834683696331102755142290273275645466393;
    uint256 constant IC19y = 12035159135980249768809412607467166234876305186025132734572755050330467638764;
    
    uint256 constant IC20x = 5489562913113957393295302794079125659775797724327032930647502626512102653624;
    uint256 constant IC20y = 15120708786930439959725004133734044262043453045403662478967459509960886950100;
    
    uint256 constant IC21x = 10506073719215186508582228674368984517584602827554923315509133427563186435807;
    uint256 constant IC21y = 14680698648303177440263125988235187795386389915053272797874845130036102834269;
    
    uint256 constant IC22x = 11982740021244587349540287825317808871861199609052657860480166588218045172894;
    uint256 constant IC22y = 13409352976369749348068956330192829776179621185042466897494306989922180191;
    
    uint256 constant IC23x = 10417830314756653616317562251795130424277701905307850066256147039390992801836;
    uint256 constant IC23y = 14854557887982188935993900334399547400194635373532819921153310275263831349312;
    
    uint256 constant IC24x = 1842189129451305944295821573358572685603215948995437294764123658337084309312;
    uint256 constant IC24y = 16926695929101417450636052264463723480027652724892353460459050215194094012143;
    
    uint256 constant IC25x = 9740204152576857607734719165215663308303130049061586760205738750992327881993;
    uint256 constant IC25y = 21133637339143418411806073466556702027783259983932290624465419772981406770480;
    
 
    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pPairing = 128;

    uint16 constant pLastMem = 896;

    function verifyProof(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[25] calldata _pubSignals) public view returns (bool) {
        assembly {
            function checkField(v) {
                if iszero(lt(v, r)) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }
            
            // G1 function to multiply a G1 value(x,y) to value in an address
            function g1_mulAccC(pR, x, y, s) {
                let success
                let mIn := mload(0x40)
                mstore(mIn, x)
                mstore(add(mIn, 32), y)
                mstore(add(mIn, 64), s)

                success := staticcall(sub(gas(), 2000), 7, mIn, 96, mIn, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }

                mstore(add(mIn, 64), mload(pR))
                mstore(add(mIn, 96), mload(add(pR, 32)))

                success := staticcall(sub(gas(), 2000), 6, mIn, 128, pR, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }

            function checkPairing(pA, pB, pC, pubSignals, pMem) -> isOk {
                let _pPairing := add(pMem, pPairing)
                let _pVk := add(pMem, pVk)

                mstore(_pVk, IC0x)
                mstore(add(_pVk, 32), IC0y)

                // Compute the linear combination vk_x
                
                g1_mulAccC(_pVk, IC1x, IC1y, calldataload(add(pubSignals, 0)))
                
                g1_mulAccC(_pVk, IC2x, IC2y, calldataload(add(pubSignals, 32)))
                
                g1_mulAccC(_pVk, IC3x, IC3y, calldataload(add(pubSignals, 64)))
                
                g1_mulAccC(_pVk, IC4x, IC4y, calldataload(add(pubSignals, 96)))
                
                g1_mulAccC(_pVk, IC5x, IC5y, calldataload(add(pubSignals, 128)))
                
                g1_mulAccC(_pVk, IC6x, IC6y, calldataload(add(pubSignals, 160)))
                
                g1_mulAccC(_pVk, IC7x, IC7y, calldataload(add(pubSignals, 192)))
                
                g1_mulAccC(_pVk, IC8x, IC8y, calldataload(add(pubSignals, 224)))
                
                g1_mulAccC(_pVk, IC9x, IC9y, calldataload(add(pubSignals, 256)))
                
                g1_mulAccC(_pVk, IC10x, IC10y, calldataload(add(pubSignals, 288)))
                
                g1_mulAccC(_pVk, IC11x, IC11y, calldataload(add(pubSignals, 320)))
                
                g1_mulAccC(_pVk, IC12x, IC12y, calldataload(add(pubSignals, 352)))
                
                g1_mulAccC(_pVk, IC13x, IC13y, calldataload(add(pubSignals, 384)))
                
                g1_mulAccC(_pVk, IC14x, IC14y, calldataload(add(pubSignals, 416)))
                
                g1_mulAccC(_pVk, IC15x, IC15y, calldataload(add(pubSignals, 448)))
                
                g1_mulAccC(_pVk, IC16x, IC16y, calldataload(add(pubSignals, 480)))
                
                g1_mulAccC(_pVk, IC17x, IC17y, calldataload(add(pubSignals, 512)))
                
                g1_mulAccC(_pVk, IC18x, IC18y, calldataload(add(pubSignals, 544)))
                
                g1_mulAccC(_pVk, IC19x, IC19y, calldataload(add(pubSignals, 576)))
                
                g1_mulAccC(_pVk, IC20x, IC20y, calldataload(add(pubSignals, 608)))
                
                g1_mulAccC(_pVk, IC21x, IC21y, calldataload(add(pubSignals, 640)))
                
                g1_mulAccC(_pVk, IC22x, IC22y, calldataload(add(pubSignals, 672)))
                
                g1_mulAccC(_pVk, IC23x, IC23y, calldataload(add(pubSignals, 704)))
                
                g1_mulAccC(_pVk, IC24x, IC24y, calldataload(add(pubSignals, 736)))
                
                g1_mulAccC(_pVk, IC25x, IC25y, calldataload(add(pubSignals, 768)))
                

                // -A
                mstore(_pPairing, calldataload(pA))
                mstore(add(_pPairing, 32), mod(sub(q, calldataload(add(pA, 32))), q))

                // B
                mstore(add(_pPairing, 64), calldataload(pB))
                mstore(add(_pPairing, 96), calldataload(add(pB, 32)))
                mstore(add(_pPairing, 128), calldataload(add(pB, 64)))
                mstore(add(_pPairing, 160), calldataload(add(pB, 96)))

                // alpha1
                mstore(add(_pPairing, 192), alphax)
                mstore(add(_pPairing, 224), alphay)

                // beta2
                mstore(add(_pPairing, 256), betax1)
                mstore(add(_pPairing, 288), betax2)
                mstore(add(_pPairing, 320), betay1)
                mstore(add(_pPairing, 352), betay2)

                // vk_x
                mstore(add(_pPairing, 384), mload(add(pMem, pVk)))
                mstore(add(_pPairing, 416), mload(add(pMem, add(pVk, 32))))


                // gamma2
                mstore(add(_pPairing, 448), gammax1)
                mstore(add(_pPairing, 480), gammax2)
                mstore(add(_pPairing, 512), gammay1)
                mstore(add(_pPairing, 544), gammay2)

                // C
                mstore(add(_pPairing, 576), calldataload(pC))
                mstore(add(_pPairing, 608), calldataload(add(pC, 32)))

                // delta2
                mstore(add(_pPairing, 640), deltax1)
                mstore(add(_pPairing, 672), deltax2)
                mstore(add(_pPairing, 704), deltay1)
                mstore(add(_pPairing, 736), deltay2)


                let success := staticcall(sub(gas(), 2000), 8, _pPairing, 768, _pPairing, 0x20)

                isOk := and(success, mload(_pPairing))
            }

            let pMem := mload(0x40)
            mstore(0x40, add(pMem, pLastMem))

            // Validate that all evaluations ∈ F
            
            checkField(calldataload(add(_pubSignals, 0)))
            
            checkField(calldataload(add(_pubSignals, 32)))
            
            checkField(calldataload(add(_pubSignals, 64)))
            
            checkField(calldataload(add(_pubSignals, 96)))
            
            checkField(calldataload(add(_pubSignals, 128)))
            
            checkField(calldataload(add(_pubSignals, 160)))
            
            checkField(calldataload(add(_pubSignals, 192)))
            
            checkField(calldataload(add(_pubSignals, 224)))
            
            checkField(calldataload(add(_pubSignals, 256)))
            
            checkField(calldataload(add(_pubSignals, 288)))
            
            checkField(calldataload(add(_pubSignals, 320)))
            
            checkField(calldataload(add(_pubSignals, 352)))
            
            checkField(calldataload(add(_pubSignals, 384)))
            
            checkField(calldataload(add(_pubSignals, 416)))
            
            checkField(calldataload(add(_pubSignals, 448)))
            
            checkField(calldataload(add(_pubSignals, 480)))
            
            checkField(calldataload(add(_pubSignals, 512)))
            
            checkField(calldataload(add(_pubSignals, 544)))
            
            checkField(calldataload(add(_pubSignals, 576)))
            
            checkField(calldataload(add(_pubSignals, 608)))
            
            checkField(calldataload(add(_pubSignals, 640)))
            
            checkField(calldataload(add(_pubSignals, 672)))
            
            checkField(calldataload(add(_pubSignals, 704)))
            
            checkField(calldataload(add(_pubSignals, 736)))
            
            checkField(calldataload(add(_pubSignals, 768)))
            

            // Validate all evaluations
            let isValid := checkPairing(_pA, _pB, _pC, _pubSignals, pMem)

            mstore(0, isValid)
             return(0, 0x20)
         }
     }
 }
