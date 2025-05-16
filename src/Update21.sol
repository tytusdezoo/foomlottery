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

    
    uint256 constant IC0x = 14925812531294108040416856029731722230221405074289173968977702337336613599114;
    uint256 constant IC0y = 13277198682222483164761844693234737469188436616062619878329435358569168593589;
    
    uint256 constant IC1x = 1986490688537024273477136543663106474755583915889877023700279376957890976521;
    uint256 constant IC1y = 15747330287047789877734504766856598183380540075654605167858148437711504103113;
    
    uint256 constant IC2x = 9038891989204999060833934119839503410657711956571860310534846262641787539395;
    uint256 constant IC2y = 14608319269283544889252884226096158673026982151622199108730248228658442429434;
    
    uint256 constant IC3x = 19661933328024011273109820919695782457342651090965623962300781771851180250489;
    uint256 constant IC3y = 21176840262347576362471967058044502314358668914556288542612554307414517236067;
    
    uint256 constant IC4x = 13176242420216123870280188385701617783369831304221586877170965973556123492794;
    uint256 constant IC4y = 8603840946046531810163035021585533418108168688656160000484968948211541615897;
    
    uint256 constant IC5x = 15133965245959109535474720708763717343296383538406720247199333870776037610367;
    uint256 constant IC5y = 9678150701324835782049730963573267610026204959629490380794634498033065131285;
    
    uint256 constant IC6x = 16729267413152360888549878649905749878694844703471369211563709390858487779208;
    uint256 constant IC6y = 14274319199862336765199952023155888206715816214355031058611420354051972631802;
    
    uint256 constant IC7x = 12651960190685717886406588296978183963772844308138637742974120133885964686874;
    uint256 constant IC7y = 1963127235073621498063095890558099960373777656259670337527340150868602604275;
    
    uint256 constant IC8x = 6869239581433815724272171548831270776909164307999315326341698320109449012635;
    uint256 constant IC8y = 950001258217601201802196698551134206639527868574512536550384741399720743514;
    
    uint256 constant IC9x = 21528206637089487549111187549245863680316667671488092243877260281656767700022;
    uint256 constant IC9y = 7865006310501033426713699930172784972030501415221311871861372644756387124329;
    
    uint256 constant IC10x = 9975245478731316062537199504246409382802051415002262375413130275019266437343;
    uint256 constant IC10y = 4995646828305191661902745082564525395210281241721754500812432207407884642735;
    
    uint256 constant IC11x = 15923500306167889057629341385197623010202213173708628566593711429135183307061;
    uint256 constant IC11y = 18161315843638307985476109362694378741854617456049506360490697152741218966019;
    
    uint256 constant IC12x = 21356975693577726511366446708114660933581810102680030652135242314689673582378;
    uint256 constant IC12y = 807328939318728375782011955669513330347592298649041778229933864142254839637;
    
    uint256 constant IC13x = 19735558906412824568463383790409050096666532398468501397776770505485668583887;
    uint256 constant IC13y = 17205031412551164343495333544653816020358512527425690725023030265642160380108;
    
    uint256 constant IC14x = 12587368029286856231679841551563877123244183892122192256925520719295812105266;
    uint256 constant IC14y = 8984932265829949194239984125772331134181342984226624611146420711638585714403;
    
    uint256 constant IC15x = 7345938082672882970916999978049893229418019927004817502817617306876288336395;
    uint256 constant IC15y = 11972039628054724275288631960565229397880257091242602691274748168901692241464;
    
    uint256 constant IC16x = 1536994724111914645165604843297103623533109127466829678383692755187163765171;
    uint256 constant IC16y = 12112385227874527502442545235318145588038972434401174327957471556434243446819;
    
    uint256 constant IC17x = 16471098794668979010774238494043004444488257043273677410157161349685028304503;
    uint256 constant IC17y = 14369070659710846983397400566723430330957332313763812109868639412214385366108;
    
    uint256 constant IC18x = 19860691268538267857728320828113376938793643558848983535757503422729338735532;
    uint256 constant IC18y = 9419659060399583300434211624018265197819474829412732656795817523017093073683;
    
    uint256 constant IC19x = 5861768265462972821554490210432929321470907257963271696968410366430292256158;
    uint256 constant IC19y = 693209066467497150928944416755871017548765122121364534275174333258421345563;
    
    uint256 constant IC20x = 723646367615653605732659356903846347538840223646754267989429978974387603277;
    uint256 constant IC20y = 15950294941583251831948340801727851094116936540435387947196157883625055967267;
    
    uint256 constant IC21x = 12089446302208259303596926813536388583476806568210493044197929762393014004147;
    uint256 constant IC21y = 9362004419989839380549472019117903655001955669654782883869981901035913319268;
    
    uint256 constant IC22x = 19685233369809526809166974267289679613831764000916432891985473506090741996536;
    uint256 constant IC22y = 1871933840071516707518733349436242916864846512073594792060025635239492181375;
    
    uint256 constant IC23x = 18185538714685864125497548235458473141644427902273548811004051773173597289004;
    uint256 constant IC23y = 9483432046179423993904994157005568909786332629883889851016091187070324329225;
    
    uint256 constant IC24x = 6859110040882178662569231369968738955067669174072168847639478726139827322871;
    uint256 constant IC24y = 8002373989413341210122861596482746012725379203410106558287613496144327415270;
    
    uint256 constant IC25x = 17004330926016091443711910006011808103222050082058635948085010606131736512970;
    uint256 constant IC25y = 19648010187555439501515361097551894152560571469155542039310546216501855205068;
    
 
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
