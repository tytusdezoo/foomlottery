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

    
    uint256 constant IC0x = 18975983415955038216534607848343083393518196633167168381524310557535706978436;
    uint256 constant IC0y = 13322914276087145874066078887651607553612569014273059657470451598863858663559;
    
    uint256 constant IC1x = 8043833675765709306902577209688274927146707285523268831572128075855908801189;
    uint256 constant IC1y = 16325877456581503654693707886085331446396802634522727595316984882810207827275;
    
    uint256 constant IC2x = 13833788957599068919973585875427345232317749268667663185866577273149179039707;
    uint256 constant IC2y = 19912128834083086211320406984161541620055267817494333038580951515980014461848;
    
    uint256 constant IC3x = 6553862551897069052134023558985688112456190613837044895537762097740858699414;
    uint256 constant IC3y = 16523768458018086321290498903907424051697981695526021746187188188761230903281;
    
    uint256 constant IC4x = 13954939696999126146130491038043511696538562824517745169270127826629039112605;
    uint256 constant IC4y = 17779402257242516332711661245664909727715531492549308001166745484569103353250;
    
    uint256 constant IC5x = 11808721118968897465748895117695412883441036271834514150058571837124283040908;
    uint256 constant IC5y = 21203112923291164263632409861051348752164275548598248442466576552958181276258;
    
    uint256 constant IC6x = 8345680854871281821636478479902208688458425532643624043264040106413551255856;
    uint256 constant IC6y = 3572081813262563772962963170296161776628004087327027818216716340137899838098;
    
    uint256 constant IC7x = 13533660224759077882588325650003592468522765791799600901571965543517722770801;
    uint256 constant IC7y = 5765606684040157899802190639055107342809843351921212326197424566050289802147;
    
    uint256 constant IC8x = 10607046454373831182572905313373931863083416078008076394417969829119023228158;
    uint256 constant IC8y = 20284197939698450466185878083537812486814898857150126921332952276130010150589;
    
    uint256 constant IC9x = 18415532209175632942610941907011269218441986511541568153563504943575323684913;
    uint256 constant IC9y = 12605878471725916296615440418581401997777577761626300174160569796547876989696;
    
    uint256 constant IC10x = 10637963069020832623327418541490947417490223486854614099504664522959967180804;
    uint256 constant IC10y = 1611956113438068761496175258951427204111060141845189517367954365947135298877;
    
    uint256 constant IC11x = 3050336865658575315477763982681845936680881774060070367739867722993706734928;
    uint256 constant IC11y = 1843042607320133479128753806333675264299057192021164080329551181448605590885;
    
    uint256 constant IC12x = 95117982039238108217403318995172560020548561992197470191107599836579049294;
    uint256 constant IC12y = 10991141329041403725288594536190160251060942715527028071261793922658601098750;
    
    uint256 constant IC13x = 19445510832564428556219450378156116652486396738800359610623858563432914113545;
    uint256 constant IC13y = 18544765587464628885942368431571105626469838169593528843727090230489010104954;
    
    uint256 constant IC14x = 10183078561336987047394145054643820295116446121632038324251895050998877262452;
    uint256 constant IC14y = 17268227642878772772617640526277218508439449274894095045486580348250990731475;
    
    uint256 constant IC15x = 10610578283242201216089019239705259174322181264429305587341257048374043869446;
    uint256 constant IC15y = 18790147543961678460143761451846575950182430425558461070051312438517013050413;
    
    uint256 constant IC16x = 17229958875589967663341674061093638439947987560962600783710360475652538993635;
    uint256 constant IC16y = 17745072951607436713401503072071251836346245429376962924223214461472430019164;
    
    uint256 constant IC17x = 12544187943906932725667850615736192908675940251131883417843720371459604678070;
    uint256 constant IC17y = 6454861060608031447201887580879436220287109413215965829116991681077180096354;
    
    uint256 constant IC18x = 10239579120247549877311895594324046603466904991581904505565429090714561940555;
    uint256 constant IC18y = 17740359027327293200797939103518048237137864593854309318044364328393936793012;
    
    uint256 constant IC19x = 21634351742574553458557255194496100350623051269474748873948911226767740224599;
    uint256 constant IC19y = 457867959505637300686173923379222523744896748707637548336174006485953731335;
    
    uint256 constant IC20x = 15984715185882854196682175894346652602304897565666083289781075807071605715252;
    uint256 constant IC20y = 8600815348368051979417994188090266002423040867445881605303367043616290278376;
    
    uint256 constant IC21x = 21500205222061203956417887375450036415502040269144812022514762213072092885474;
    uint256 constant IC21y = 4208606336317633046827467717758387099452715730775474014890234216972371919146;
    
    uint256 constant IC22x = 3056145729279951226661217880926421645444388319253789404207061476175297312347;
    uint256 constant IC22y = 7635536538501169190695833580961782468332163494900298184926055999856060042250;
    
    uint256 constant IC23x = 4133694108284189815216720112262272435121711481317674496675014320660729289242;
    uint256 constant IC23y = 19397039512317413151819820053374568558996243954307151345461252458972277404107;
    
    uint256 constant IC24x = 20128343334542050118472899189888632654491899379585344350703958803427226952558;
    uint256 constant IC24y = 11468086055745085518638982422509813371429399896862768805845469710740517738652;
    
    uint256 constant IC25x = 5281444309713073791935233171600145561048668396862954462703910654077781814551;
    uint256 constant IC25y = 5422980068461049236254467145720802160362259798840996420793186428904360772518;
    
    uint256 constant IC26x = 20582759657764035860193685612089338834999615946631117171425071372625785270652;
    uint256 constant IC26y = 9854069920084205818199693891921696638287305478041701561461835813439097297589;
    
 
    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pPairing = 128;

    uint16 constant pLastMem = 896;

    function verifyProof(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[26] calldata _pubSignals) public view returns (bool) {
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
            

            // Validate all evaluations
            let isValid := checkPairing(_pA, _pB, _pC, _pubSignals, pMem)

            mstore(0, isValid)
             return(0, 0x20)
         }
     }
 }
