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

contract Update44G16Verifier {
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

    
    uint256 constant IC0x = 10818376814960468733936971658254646576813207961836231978629211717663911848078;
    uint256 constant IC0y = 14938619547536952898683419826337995609099683090657969474543950751593642128295;
    
    uint256 constant IC1x = 21094004504092561633597718767965358974781685323106087414022214379374973893167;
    uint256 constant IC1y = 8029156103779459626424946563678916531654739429926410926168662109432538105617;
    
    uint256 constant IC2x = 13893355904171886109488996545329067413951308043293629236103582843449306728555;
    uint256 constant IC2y = 21103417585402600439681098576332073271141461931239548847544421797399440182328;
    
    uint256 constant IC3x = 14727842892129198291083460025467509780469013424798036863222371976750338516356;
    uint256 constant IC3y = 1042146022496248309562586966165598569736035120924184153447257564240208476440;
    
    uint256 constant IC4x = 14223498530450258435317238908862350935316894106827210222118780375340431667749;
    uint256 constant IC4y = 12454740289169209896930489833671767304658126316793634750587427827829925647579;
    
    uint256 constant IC5x = 3197512969966234455710951582445935972087151269930404046931628128222985136557;
    uint256 constant IC5y = 12273269660772321962509357120652700587029005645774755034661453051947100727000;
    
    uint256 constant IC6x = 14526635572731019431297116325850716438593978478785804919748217009426147673866;
    uint256 constant IC6y = 4567596553639640424928690162544523711854907361964886553640810131730506583326;
    
    uint256 constant IC7x = 5996368594415016067035978553570001473694338379520588782213959637625550380600;
    uint256 constant IC7y = 20396942155359641829012775969146379380674748202535622209647440110145573832314;
    
    uint256 constant IC8x = 15783555950831746788943307272256943129383176123803067168814011171737974983639;
    uint256 constant IC8y = 3485759190445254284539258044829528791104068765902817430360196973871116131994;
    
    uint256 constant IC9x = 9093447222825113487903603456709915821431677535581819148129678401466572689699;
    uint256 constant IC9y = 14579475944070605374142167877405371253887501190746830790024335481330396218468;
    
    uint256 constant IC10x = 18440447559898839832423801201819755170556207014693870229329518576511454357203;
    uint256 constant IC10y = 5742796046889049870605142036210890302031021719096348080735686030294340662626;
    
    uint256 constant IC11x = 1731751721193915848153988062509318599102178614661264956113593808051307203328;
    uint256 constant IC11y = 1308936517251281996779991140203147307887699996298905318854192537546876978898;
    
    uint256 constant IC12x = 7136351959074722028334788549559343256006541526109112156943022980370636435821;
    uint256 constant IC12y = 4681476672179738630029997531984572115928382927528629371017868490088843739114;
    
    uint256 constant IC13x = 5925404249403077736083833713350557531465981319594188371392116883808472569241;
    uint256 constant IC13y = 5977647322096626058436977704976774874594023101939329852939114654687016981810;
    
    uint256 constant IC14x = 14942005442116071966128817772711713708905499671001414232737283235843260493559;
    uint256 constant IC14y = 5377573577913635768413123715795497779875672992763642013729483009158074888657;
    
    uint256 constant IC15x = 11688777222958442340384647637870120539308546972152181364253336440714939512618;
    uint256 constant IC15y = 20035525701589607017315468704764746029251361553754571095597627083941045530433;
    
    uint256 constant IC16x = 917621828173454462984414029874456109197890077571986475837571872252369588600;
    uint256 constant IC16y = 17137045135770348460517912900057223866303044407887595794588660944962234027436;
    
    uint256 constant IC17x = 15045368475896211070613785139044414272730051839147758026511179288044707501418;
    uint256 constant IC17y = 2933112280311706961418225081190159543392067476904530599933071979404114420963;
    
    uint256 constant IC18x = 14448262533387898509235751443608993571727447365748980448895494538493279963064;
    uint256 constant IC18y = 15209858661146823333028106291210697969600457183271580010672115610058649830432;
    
    uint256 constant IC19x = 258776672367498306543897620254208830322969083702696135401846789411079590907;
    uint256 constant IC19y = 1667604510873203815726223840617525595892655595557113723997559936691851929991;
    
    uint256 constant IC20x = 1220801434370492973908395612392138776666529567207080847942108732017929214466;
    uint256 constant IC20y = 9892222989113162840310176433784092740552557825709746505887411948729948469210;
    
    uint256 constant IC21x = 17829232200555983160322276181743406539401573768658301361349005577440705004015;
    uint256 constant IC21y = 1013672671883722758339264064349856890461325108736942942697812171866671340718;
    
    uint256 constant IC22x = 2537349253088465449796811541309099571230830662603152705095571313279009407134;
    uint256 constant IC22y = 12229383463674493546678957195930114569818407879411280023708334234283032489110;
    
    uint256 constant IC23x = 9971496378534959845415160587958762657612368175609136655383840961682181052005;
    uint256 constant IC23y = 8907594423216982092218635483162518046595252984325516598840093854092761094;
    
    uint256 constant IC24x = 1119094757428646597621367311857524425939421604467196686697076318441299797716;
    uint256 constant IC24y = 2107581143254841942621927869752399232638613110803440474483036053692747832074;
    
    uint256 constant IC25x = 8131067357853364980635118619365824940523000745639740951093084808771397134564;
    uint256 constant IC25y = 17792457228742584927141584883439272973723777229077452425103431431689161814915;
    
    uint256 constant IC26x = 13720036908394353988965186928313076747134686962225594638951564479578276908705;
    uint256 constant IC26y = 17254652215906264901682937049514254088877966166798526225342782516720302290956;
    
    uint256 constant IC27x = 16482857233189491490699403663422169285877268934354003342331779231757294715962;
    uint256 constant IC27y = 11632111648854123533716213368444260599606912255629544162336985637279985034964;
    
    uint256 constant IC28x = 6752537137854415590161132271685013718187472037631597452478214535909744661589;
    uint256 constant IC28y = 7844189437423974787592849581754761874884630406037273679320095073981554025209;
    
    uint256 constant IC29x = 20466946341766357551396208699046579086174883112170845130500369770118180843705;
    uint256 constant IC29y = 13236907552730663538109704963743669771247052536823381219612609580142580604819;
    
    uint256 constant IC30x = 185913731885559166242032188282895126554133413548683219902819609231360108114;
    uint256 constant IC30y = 8203724278761640531691548505582141803588507756920559181088509836987296055322;
    
    uint256 constant IC31x = 18945801980941648194481201889246737887214560767971912135044231843149325077790;
    uint256 constant IC31y = 9808497359499900378422678203271360297881738075764166806986274864942184071438;
    
    uint256 constant IC32x = 11155135687617436532256573490703627927578099497376464383555475239265916845979;
    uint256 constant IC32y = 12492607696172678747955665091210035521182511742625843761692090264467840130100;
    
    uint256 constant IC33x = 16042467101131964817023531044795454881882223245587482714357989393377073602296;
    uint256 constant IC33y = 5319038393968096261688781945232574265872442931150500696649703586067363182213;
    
    uint256 constant IC34x = 1331407291804889719485388394613890790413010496036015608118144736559072843495;
    uint256 constant IC34y = 14570327361041849655247170618226376980415136738504600307739418366700290611644;
    
    uint256 constant IC35x = 2482497821068864038226754703636160872900450932741080853090869055157514092346;
    uint256 constant IC35y = 15221399140066776205694036850838192087243621186789867948478118761273474323636;
    
    uint256 constant IC36x = 14245800903263177231299203675259253572239262503391286504883546294812475491204;
    uint256 constant IC36y = 1533779150477282056328056009401496692278727491961848369615830225913072190332;
    
    uint256 constant IC37x = 1889763494162372615756755667256478984866146980786477018979169274662415484824;
    uint256 constant IC37y = 13683017338565859066224371060370823852049163328533701112344550069031178090444;
    
    uint256 constant IC38x = 10040222719494491202488151904465752716621154664703179945323265049481910723159;
    uint256 constant IC38y = 11984849553870566248660075712191454117080969518923779465384051437628451578970;
    
    uint256 constant IC39x = 20355226878846715891364659935474049864076810345057652358563330189730873013128;
    uint256 constant IC39y = 20636112948630275271814865249710356247524798020994427717303453778680758912175;
    
    uint256 constant IC40x = 17756476493039886332319535185266180582447066881448756209686396057674742031566;
    uint256 constant IC40y = 13274072041483288327417784381201340491238447204478425143091987355396178152189;
    
    uint256 constant IC41x = 21569874181802934643252115222044323359568668547655772186625768821819066280700;
    uint256 constant IC41y = 21676407775305508930943904137447632863509413685927133827953765565016047133840;
    
    uint256 constant IC42x = 18150318220741838111960466303541969816250985571200394084260410314460154463914;
    uint256 constant IC42y = 14202114124453646619468233748500269286351894697197510387121512409893972995720;
    
    uint256 constant IC43x = 15110616078653820189843875874451254005388978026777032538683947309285317460887;
    uint256 constant IC43y = 3123508363223874983497497451470739806847430934274308867862041421532675568120;
    
    uint256 constant IC44x = 9400458550138867847718286602464342299430975704654166892342397418407357334497;
    uint256 constant IC44y = 12393020820668547141982261924621192813593953786285644329577484228403646177359;
    
    uint256 constant IC45x = 15063627885029133117595643578463276688613427003937507188479314734067654224865;
    uint256 constant IC45y = 6150335334200146366812418660670012739239420249640118030370079492293729691207;
    
    uint256 constant IC46x = 11097009948533288780421472814025753311760054771424987745180469559329297228964;
    uint256 constant IC46y = 4185296865272732588882768214541286622553765055677077369928518631666749091571;
    
    uint256 constant IC47x = 17992870769719808098960306504767867055575893300418214660188171219497785178225;
    uint256 constant IC47y = 21106886411467932058469859312675006796443170735840997930801238529750245455302;
    
    uint256 constant IC48x = 5384096450501625871210765669227150561189139582070254359548821012513657608151;
    uint256 constant IC48y = 10174361900540390022780490260040329526177771111033562058465675479685895906217;
    
 
    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pPairing = 128;

    uint16 constant pLastMem = 896;

    function verifyProof(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[48] calldata _pubSignals) public view returns (bool) {
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
                
                g1_mulAccC(_pVk, IC28x, IC28y, calldataload(add(pubSignals, 864)))
                
                g1_mulAccC(_pVk, IC29x, IC29y, calldataload(add(pubSignals, 896)))
                
                g1_mulAccC(_pVk, IC30x, IC30y, calldataload(add(pubSignals, 928)))
                
                g1_mulAccC(_pVk, IC31x, IC31y, calldataload(add(pubSignals, 960)))
                
                g1_mulAccC(_pVk, IC32x, IC32y, calldataload(add(pubSignals, 992)))
                
                g1_mulAccC(_pVk, IC33x, IC33y, calldataload(add(pubSignals, 1024)))
                
                g1_mulAccC(_pVk, IC34x, IC34y, calldataload(add(pubSignals, 1056)))
                
                g1_mulAccC(_pVk, IC35x, IC35y, calldataload(add(pubSignals, 1088)))
                
                g1_mulAccC(_pVk, IC36x, IC36y, calldataload(add(pubSignals, 1120)))
                
                g1_mulAccC(_pVk, IC37x, IC37y, calldataload(add(pubSignals, 1152)))
                
                g1_mulAccC(_pVk, IC38x, IC38y, calldataload(add(pubSignals, 1184)))
                
                g1_mulAccC(_pVk, IC39x, IC39y, calldataload(add(pubSignals, 1216)))
                
                g1_mulAccC(_pVk, IC40x, IC40y, calldataload(add(pubSignals, 1248)))
                
                g1_mulAccC(_pVk, IC41x, IC41y, calldataload(add(pubSignals, 1280)))
                
                g1_mulAccC(_pVk, IC42x, IC42y, calldataload(add(pubSignals, 1312)))
                
                g1_mulAccC(_pVk, IC43x, IC43y, calldataload(add(pubSignals, 1344)))
                
                g1_mulAccC(_pVk, IC44x, IC44y, calldataload(add(pubSignals, 1376)))
                
                g1_mulAccC(_pVk, IC45x, IC45y, calldataload(add(pubSignals, 1408)))
                
                g1_mulAccC(_pVk, IC46x, IC46y, calldataload(add(pubSignals, 1440)))
                
                g1_mulAccC(_pVk, IC47x, IC47y, calldataload(add(pubSignals, 1472)))
                
                g1_mulAccC(_pVk, IC48x, IC48y, calldataload(add(pubSignals, 1504)))
                

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
            
            checkField(calldataload(add(_pubSignals, 864)))
            
            checkField(calldataload(add(_pubSignals, 896)))
            
            checkField(calldataload(add(_pubSignals, 928)))
            
            checkField(calldataload(add(_pubSignals, 960)))
            
            checkField(calldataload(add(_pubSignals, 992)))
            
            checkField(calldataload(add(_pubSignals, 1024)))
            
            checkField(calldataload(add(_pubSignals, 1056)))
            
            checkField(calldataload(add(_pubSignals, 1088)))
            
            checkField(calldataload(add(_pubSignals, 1120)))
            
            checkField(calldataload(add(_pubSignals, 1152)))
            
            checkField(calldataload(add(_pubSignals, 1184)))
            
            checkField(calldataload(add(_pubSignals, 1216)))
            
            checkField(calldataload(add(_pubSignals, 1248)))
            
            checkField(calldataload(add(_pubSignals, 1280)))
            
            checkField(calldataload(add(_pubSignals, 1312)))
            
            checkField(calldataload(add(_pubSignals, 1344)))
            
            checkField(calldataload(add(_pubSignals, 1376)))
            
            checkField(calldataload(add(_pubSignals, 1408)))
            
            checkField(calldataload(add(_pubSignals, 1440)))
            
            checkField(calldataload(add(_pubSignals, 1472)))
            
            checkField(calldataload(add(_pubSignals, 1504)))
            

            // Validate all evaluations
            let isValid := checkPairing(_pA, _pB, _pC, _pubSignals, pMem)

            mstore(0, isValid)
             return(0, 0x20)
         }
     }
 }
