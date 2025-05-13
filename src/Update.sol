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

contract UpdateG16Verifier {
    // Scalar field size
    uint256 constant r    = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    // Base field size
    uint256 constant q   = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    // Verification Key data
    uint256 constant alphax  = 6859943267726103022456218751742496434801598539734702492857713593831870541183;
    uint256 constant alphay  = 2437570400317167727432567733857261645200050451297161534515093126079433274402;
    uint256 constant betax1  = 11671931071845645930016499310281410168299101411971340104956017465783373351812;
    uint256 constant betax2  = 17221176884730639789839717415476675549364582489495784854476713054107666068499;
    uint256 constant betay1  = 772925938534248297626458290053347858868660458239242363627629771871669297453;
    uint256 constant betay2  = 7163858409291571903879572784330178529228882991408477512962335244211350167148;
    uint256 constant gammax1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant gammax2 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 constant gammay1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant gammay2 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;
    uint256 constant deltax1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant deltax2 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 constant deltay1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant deltay2 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;

    
    uint256 constant IC0x = 10106687807421507978455789804392982078113107712978098854797729211289487715531;
    uint256 constant IC0y = 19327513821379190289802592928233471368998286040180500634825703222291320464758;
    
    uint256 constant IC1x = 3075829542273186992111789692174041164060646975166465430755510746897157630688;
    uint256 constant IC1y = 18264126894349825065574458496307172540280095847268608134306584330414992958944;
    
    uint256 constant IC2x = 21802614256759765549996777257555155585376129496651178621098133634879954320497;
    uint256 constant IC2y = 3201346990685544952894059860336777176739262136481469075197738157229018640237;
    
    uint256 constant IC3x = 12618701914365404523285663879356984090064492302127671340553668153108888914245;
    uint256 constant IC3y = 865474685574809596800592351819923313167945296437063170692034758061145695456;
    
    uint256 constant IC4x = 17225934982424379234513406836498026243416588240821828905685142374541953287890;
    uint256 constant IC4y = 10164177243785609371662058058295107035148111282675714650581431737133112158925;
    
    uint256 constant IC5x = 8721036832224302994491560605513249886727782630791639873381014589065474720685;
    uint256 constant IC5y = 14823338800700676387269060964395039445508710861758959222788517278649421564395;
    
    uint256 constant IC6x = 19924280499363845189846842485594262026455720896220922827696637667568945706755;
    uint256 constant IC6y = 15299523166685119269189507352194702180706291496103959966642956706524515889692;
    
    uint256 constant IC7x = 20167214421391846646410270960635355463625344306911648238078256444929159872396;
    uint256 constant IC7y = 4513958887568952259976855442241386669642353568262076816570352364926498684889;
    
    uint256 constant IC8x = 14789203639820002547159158060598611495796575246559260736426820207690176479785;
    uint256 constant IC8y = 14554988422210756226724616755001058427720331524839509786956170171896054718772;
    
    uint256 constant IC9x = 11989022821014166972084998414719955647634772624092486277609568648540150669639;
    uint256 constant IC9y = 8318131951159906869570354913699429074035265032288130808866430975496344636950;
    
    uint256 constant IC10x = 1655618051408008594522402982886210959301911039518652953496033822348331286039;
    uint256 constant IC10y = 12171185138419845008940430928585897276135098063586393906231292452215329085578;
    
    uint256 constant IC11x = 13905515178468128217043352135763819729939323902338306123817856228588975056069;
    uint256 constant IC11y = 12474834527021909818581977713194694570229009848650529457330260694517183050004;
    
    uint256 constant IC12x = 11195120414827009800707576097133587935459213482700945831491744339307921305879;
    uint256 constant IC12y = 11312744030070215287220427885387101452293239838290966302486101202141097670627;
    
    uint256 constant IC13x = 9492698522188864558237097052312208231695858455496508870940011002535083834173;
    uint256 constant IC13y = 10646500635893717356333080786685146637900283499535670518472164780066842339723;
    
    uint256 constant IC14x = 5651433736450870994606381418767448459346958034581912688345901387884799828224;
    uint256 constant IC14y = 19691387616587926815585522546948214188664259972046485109126340991230549734599;
    
    uint256 constant IC15x = 12254922751006702950227862307903372849623538453870527205436725396421794158157;
    uint256 constant IC15y = 10773142647643669800350945306383991623519021881555235948288074759797153606270;
    
    uint256 constant IC16x = 9332442495379685126983342222964919237213172402260069933671152275096959718814;
    uint256 constant IC16y = 4307123656337878398796576415563363322228189450986392861141112583153177007562;
    
    uint256 constant IC17x = 813245618435114441348725268688523256799302078568910732586113250883196757740;
    uint256 constant IC17y = 20564422757898166535499281855376954231268849120664081899317674113750796341650;
    
    uint256 constant IC18x = 16966866743506815347261335140802973417816829668039149956326202486358522038677;
    uint256 constant IC18y = 19964491332709194014668796636063327939719814502100509778853768858304115145354;
    
    uint256 constant IC19x = 18957211614886259000708766527963769039430061738759905606872082423173632641039;
    uint256 constant IC19y = 13131584602561712277930139911820574347895553052764418331260245120089814721021;
    
    uint256 constant IC20x = 867935535823254238745531483145051516092944489093640272398731841265666485906;
    uint256 constant IC20y = 18854794646963131652772636019468734331484674087516453444377979638405887476430;
    
    uint256 constant IC21x = 16763715833852852213229931209878088637745584134227639533442623106986884150757;
    uint256 constant IC21y = 21078324755488403036552243110377672056087874387669484067218319182545965739614;
    
    uint256 constant IC22x = 8911908213640184963631591833507375107706247318992783942700350326382849366263;
    uint256 constant IC22y = 1871217859481315452245386019925091945484100197088712447518619821661758670797;
    
    uint256 constant IC23x = 6623053682798726398624470784833530901690273509557679754262587134998913170836;
    uint256 constant IC23y = 24131442569915638550171933367579213949415859485274278018058472455608882459;
    
    uint256 constant IC24x = 7878617049157975815469279705783365317542982674740155680261764342579732590798;
    uint256 constant IC24y = 5630549748402387663336551749397817595117196453930399080461153652732635265810;
    
    uint256 constant IC25x = 16485101627905479288088880166865626128379159149243856439855268801381335442345;
    uint256 constant IC25y = 20022389548251411894944568142866335767655307804634329223394719860058849972297;
    
    uint256 constant IC26x = 13128877073436575676011740131825868144366804543882500187234122548717271903075;
    uint256 constant IC26y = 5319971910732579947017421550449048686047603164876326783241238988879539082595;
    
    uint256 constant IC27x = 4549063773106502836363173405357455910686782174602736860706713014516993612441;
    uint256 constant IC27y = 19366771494822392169113914033216751857626979337958963373061612858118624525891;
    
 
    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pPairing = 128;

    uint16 constant pLastMem = 896;

    function verifyProof(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[27] calldata _pubSignals) public view returns (bool) {
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
                
                g1_mulAccC(_pVk, IC26x, IC26y, calldataload(add(pubSignals, 800)))
                
                g1_mulAccC(_pVk, IC27x, IC27y, calldataload(add(pubSignals, 832)))
                

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
            
            checkField(calldataload(add(_pubSignals, 800)))
            
            checkField(calldataload(add(_pubSignals, 832)))
            

            // Validate all evaluations
            let isValid := checkPairing(_pA, _pB, _pC, _pubSignals, pMem)

            mstore(0, isValid)
             return(0, 0x20)
         }
     }
 }
