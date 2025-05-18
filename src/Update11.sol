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

contract Update11G16Verifier {
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

    
    uint256 constant IC0x = 7595309034313154675251677072850919370740853530954089161391210880521666509845;
    uint256 constant IC0y = 6976654317590199339712521547150293347529045604086276574717210213257476605049;
    
    uint256 constant IC1x = 19854337837010409700723190708747856080124399766495049363815678496035679226009;
    uint256 constant IC1y = 16840880674801624069189781637437797919564554334447852423733357991961980354749;
    
    uint256 constant IC2x = 17681307038487373528392473973356338004987847026868378301052038868260061330402;
    uint256 constant IC2y = 20635392722802334672483358213689363962302217412683118804496676878900007015040;
    
    uint256 constant IC3x = 1717777950039250875658733152755543028761829947697119313166852647221539728270;
    uint256 constant IC3y = 8181487335573965305779968869346746141419319488242639675067587347816331817315;
    
    uint256 constant IC4x = 9084277476379077815820541012120324998766771758100810041433588612801083687578;
    uint256 constant IC4y = 895158765057941211513812100859876376108318658052630757148699316418340370216;
    
    uint256 constant IC5x = 12452398191426146811054054590573186291803464641667356922687938679905642208036;
    uint256 constant IC5y = 13799403390826296719724262780332859925828378159278607881669697342250800510553;
    
    uint256 constant IC6x = 997468849238449110329442013101818994639206101387207685100825342152875380912;
    uint256 constant IC6y = 16268675650035248028960080292595741739907589850822887601993612864953990768046;
    
    uint256 constant IC7x = 12386337834036647814798770436183801883765850117529256850756874706233201306196;
    uint256 constant IC7y = 10470116015693579889758071861560425153773857997389210112977369104707127917378;
    
    uint256 constant IC8x = 9059825137842748365940714435119284765563635740843671483391006486619134161066;
    uint256 constant IC8y = 3153803214045557101222862702672470008640015131165930471535426271105243750682;
    
    uint256 constant IC9x = 15263549467867682608431026908512374989843651497521493236020148991120807277923;
    uint256 constant IC9y = 10777168715269638843180380069130206146863978974210203071807688239148843046386;
    
    uint256 constant IC10x = 7180805022706072672728479169365223139434198425140349490451374558793819511010;
    uint256 constant IC10y = 10368463685749240962999840443458118407851622549634962178724114702035859078434;
    
    uint256 constant IC11x = 14296984059202427619503507550451130971026557180086949347420532138680499145783;
    uint256 constant IC11y = 6323565801163841572426068536009174785697781136287826204892699628246050342677;
    
    uint256 constant IC12x = 13901160507475276365875526312027243431622593080840468986121159940740253924203;
    uint256 constant IC12y = 8561284596323973866284035083190137663418932738100805534699284220636941049804;
    
    uint256 constant IC13x = 19757555550216362414310280769296828916207970639189021659796231691395439195958;
    uint256 constant IC13y = 14846275623831425602626299147285388765672609693251318687343742068494539485333;
    
    uint256 constant IC14x = 10485756124534755297902983449769290787231574916159862406137346552862288015734;
    uint256 constant IC14y = 3700171034456287310471899619002892901847331004014463255965281666816035824016;
    
    uint256 constant IC15x = 11285854294954828260311778336841367547738575820240586779256805165153363197059;
    uint256 constant IC15y = 20209393097921866174690557610676018169002964147342380734971315257995057030575;
    
 
    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pPairing = 128;

    uint16 constant pLastMem = 896;

    function verifyProof(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[15] calldata _pubSignals) public view returns (bool) {
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
            

            // Validate all evaluations
            let isValid := checkPairing(_pA, _pB, _pC, _pubSignals, pMem)

            mstore(0, isValid)
             return(0, 0x20)
         }
     }
 }
