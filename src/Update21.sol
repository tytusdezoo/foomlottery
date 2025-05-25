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
    uint256 constant alphax  = 16428432848801857252194528405604668803277877773566238944394625302971855135431;
    uint256 constant alphay  = 16846502678714586896801519656441059708016666274385668027902869494772365009666;
    uint256 constant betax1  = 3182164110458002340215786955198810119980427837186618912744689678939861918171;
    uint256 constant betax2  = 16348171800823588416173124589066524623406261996681292662100840445103873053252;
    uint256 constant betay1  = 4920802715848186258981584729175884379674325733638798907835771393452862684714;
    uint256 constant betay2  = 19687132236965066906216944365591810874384658708175106803089633851114028275753;
    uint256 constant gammax1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant gammax2 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 constant gammay1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant gammay2 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;
    uint256 constant deltax1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant deltax2 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 constant deltay1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant deltay2 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;

    
    uint256 constant IC0x = 13852630364928213287445884746097896328306104257236845891287198166392436968151;
    uint256 constant IC0y = 3101998179997283462982086256873933871055012716146887093438277363179839433854;
    
    uint256 constant IC1x = 629154946469136491973169819218237036919331702392766150363432502086673957311;
    uint256 constant IC1y = 11637513339371422214850238106795028616819231737358733078585201290352241763528;
    
    uint256 constant IC2x = 13839374033457759318672422669017903836368139446358669457340111412380246579211;
    uint256 constant IC2y = 2869672483792356532520631542227727752772670914350050227955721161877187387206;
    
    uint256 constant IC3x = 16029413623317613816421330219622874619516021933071366579854411265281268267906;
    uint256 constant IC3y = 14337576333275845445419359152267815539335330177479413888686583627025257169584;
    
    uint256 constant IC4x = 15205246864949518348411760376402696719472136571491778678415268407895852844834;
    uint256 constant IC4y = 8572595025255797239508844874250917725601691120139757634023984076767233899001;
    
    uint256 constant IC5x = 10009409535639554396696856791982402965810230229998730609973549416194049796756;
    uint256 constant IC5y = 2661491887481579998151909706964931398709030384029434831058043708774292956613;
    
    uint256 constant IC6x = 8102849026966260848446633866838457743088062629897883310430358383118398416886;
    uint256 constant IC6y = 3896307260534366018963780457889600557400972973850958111410540322262689693898;
    
    uint256 constant IC7x = 18791836530014980312872473786005020271244823517705404570389512522143972731897;
    uint256 constant IC7y = 11316190482967478926368619716232410754595294054546574150639115148784168933238;
    
    uint256 constant IC8x = 1080806641834953406649616455982843738396677779859297796535473683051174118224;
    uint256 constant IC8y = 11602250699820923558107868405482990089024674690004173126050399510461032768163;
    
    uint256 constant IC9x = 16334057410437679293363878471460884920990945220954152381629238194676918756964;
    uint256 constant IC9y = 8734788551694584264268051106330401978008888720079556244839049052338828123390;
    
    uint256 constant IC10x = 8197016098543584229866727754409314350425679377651691714799269251103601797465;
    uint256 constant IC10y = 5981423897043551629256767224296782273291997371005779487785759726697670259681;
    
    uint256 constant IC11x = 20048447050790147360578649060958519995697694594061737018709192061110840226513;
    uint256 constant IC11y = 16139202794044925499695002027281682846072696328962227286859004671925630982705;
    
    uint256 constant IC12x = 18206477236951018557626500411056646622773943923483423150868176076081688937822;
    uint256 constant IC12y = 14403882726040749021434532112883528262377408731097847869778938071982718239119;
    
    uint256 constant IC13x = 3495527956089464987631795593483289275191787700576167132078785861079190564676;
    uint256 constant IC13y = 15513885789067686681807338835954224362730386242920546323839920711294554352177;
    
    uint256 constant IC14x = 10385128487025198087886703916103831887399321830568779608209684005606254767806;
    uint256 constant IC14y = 14302127058951345897913314890077883119763340554595118482613569040434239965694;
    
    uint256 constant IC15x = 1095471700698153941644656247881346821152546369461575953899985993048394598536;
    uint256 constant IC15y = 12757817884644152273835681610232457659760965944567078844690748714112985417805;
    
    uint256 constant IC16x = 12164155472142668837199827564722933118904813685648800418830491488561146903277;
    uint256 constant IC16y = 19353175553933508342643676124236911369481967438245606317610769316273594809114;
    
    uint256 constant IC17x = 14941863887577133884647343138846753848608120434174847510479182115604507964712;
    uint256 constant IC17y = 19303937585747103234762744201322470852701701955806452621864526339493763650157;
    
    uint256 constant IC18x = 437249569721430993627037740468070613661392514261693526787972867294978683189;
    uint256 constant IC18y = 11069672539436349837548054793797733655294307971765447094245216535016537494842;
    
    uint256 constant IC19x = 3997126988743373855604349750639753930143538506761213443355608998757999368579;
    uint256 constant IC19y = 13023676559302218766037016988998346448397441110335332688019213520478988291787;
    
    uint256 constant IC20x = 20716373159141137216269909846520935079720349070842870215132562704638225340969;
    uint256 constant IC20y = 21424735879408766705797216912789428314464891396619853422215142541836924232629;
    
    uint256 constant IC21x = 14310843479688212543608032716294324986550486168600964112761136719675483017934;
    uint256 constant IC21y = 17198788858062805187897808420123959688421393794502339330483656176663725728459;
    
    uint256 constant IC22x = 2135477531008824840130964025705706020877948219980295474530582165623992915199;
    uint256 constant IC22y = 18342583216739869406500695556872281288328160013993739163615014616400604029129;
    
    uint256 constant IC23x = 6102052161679815889608243875502540432778167953307207057010884153352463787288;
    uint256 constant IC23y = 14642540967655646617800361599135453211727539048459313142112108538018715041114;
    
    uint256 constant IC24x = 15434438437101641817086250893309708136715854296476142794066089664727201169264;
    uint256 constant IC24y = 863315653650264037946230188293128242170292217586618980771155896036981425946;
    
    uint256 constant IC25x = 15970581368300988144739622734460571640582714406880744666852947762222987893516;
    uint256 constant IC25y = 825485129142030388372268040026179657687255772435646260499751437718144258583;
    
 
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
