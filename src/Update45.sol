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

contract Update45G16Verifier {
    // Scalar field size
    uint256 constant r    = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    // Base field size
    uint256 constant q   = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    // Verification Key data
    uint256 constant alphax  = 20491192805390485299153009773594534940189261866228447918068658471970481763042;
    uint256 constant alphay  = 9383485363053290200918347156157836566562967994039712273449902621266178545958;
    uint256 constant betax1  = 4252822878758300859123897981450591353533073413197771768651442665752259397132;
    uint256 constant betax2  = 6375614351688725206403948262868962793625744043794305715222011528459656738731;
    uint256 constant betay1  = 21847035105528745403288232691147584728191162732299865338377159692350059136679;
    uint256 constant betay2  = 10505242626370262277552901082094356697409835680220590971873171140371331206856;
    uint256 constant gammax1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant gammax2 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 constant gammay1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant gammay2 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;
    uint256 constant deltax1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant deltax2 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 constant deltay1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant deltay2 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;

    
    uint256 constant IC0x = 13226594185814432197979068672770943512991412925896681008383692094750665838361;
    uint256 constant IC0y = 18942784735057214165506133289273168405169970666045045906333021771771846130298;
    
    uint256 constant IC1x = 745105782909595204140925888419225572010502644407691738407200313614223291397;
    uint256 constant IC1y = 19661975016376891817371217861122932808175881955555498341832604010544254143666;
    
    uint256 constant IC2x = 5375104900202190524503969514700865148137135683347828150758927776424154675103;
    uint256 constant IC2y = 6678236830635395290604960451690861134766914385137140382574770119418834450353;
    
    uint256 constant IC3x = 18277770648150854873986034749200366116634675565508408805934722194165844535510;
    uint256 constant IC3y = 4324642713344028658866930477201861980682250868608833592289118344236481232484;
    
    uint256 constant IC4x = 21591062063961851900935404741977936287985771528611137218215081564090940939743;
    uint256 constant IC4y = 11256842866454933496586513776713915129365350435693121437526022914085119470207;
    
    uint256 constant IC5x = 6359369956874432362629724190255671974996707230431872321318977494543756539012;
    uint256 constant IC5y = 677895866730185430363246567024615618424946775981231175599606366486973244371;
    
    uint256 constant IC6x = 15231814474956413761255008405714768942481749830445997964804392801027812329775;
    uint256 constant IC6y = 8052127431781708655088066261963366155224367668349379709814153762531459993909;
    
    uint256 constant IC7x = 19982220858301305751483671233136102729097859685865448555287056029256215982880;
    uint256 constant IC7y = 20015064495367494098016655285284739492067515872396454853859469270798682744685;
    
    uint256 constant IC8x = 15059779266799982654777085245348907085560888034859443195614945671083037134795;
    uint256 constant IC8y = 1787087764378369493142721883429599131237314684290999331314542610983083261131;
    
    uint256 constant IC9x = 13083074129599549109267567142317803688484623770814388281711483356185667556018;
    uint256 constant IC9y = 2803345894594293734249634601832546382205136588923846932507001947260158621860;
    
    uint256 constant IC10x = 14334175049169572170918752101213587115416277029840898506808660042111027334568;
    uint256 constant IC10y = 21695004667675158101329088353488052447165449680917105424202045690626301708632;
    
    uint256 constant IC11x = 8108813042978968854890090392929679173616807966294458110265822519897709823462;
    uint256 constant IC11y = 17280508408392443737511231603030469144915530389285619812138347502746675436946;
    
    uint256 constant IC12x = 4621772009044251615810728681967762406372715787622718486718400402716973196400;
    uint256 constant IC12y = 7325146186051909326502404453839461363142632343782201328478906066466692816161;
    
    uint256 constant IC13x = 8519237599617501864177326168812113035205353341201915464267169721017411495754;
    uint256 constant IC13y = 7440819023420780321318520210589245957743881739839709459364307827506796266035;
    
    uint256 constant IC14x = 19187382602863804179939643161282107952256975343141459308464557190145107354231;
    uint256 constant IC14y = 9424025059813665318426832493215954451517734325455878895253298911026030677342;
    
    uint256 constant IC15x = 11180153440463031548951876215161718321973607051498724174248969248637794816304;
    uint256 constant IC15y = 14612611085365312244194974548189045496195545871683386695049633128271081812125;
    
    uint256 constant IC16x = 14783214900112456294005645519087844029843005231725007330374737388487148342238;
    uint256 constant IC16y = 9481478468259679850932255794406851334309911795732244618436462302230763335228;
    
    uint256 constant IC17x = 20232828861861728594584806426346253254497582950329348699198068969550309764172;
    uint256 constant IC17y = 1138601662431411535178781172068631518063749686182182285661506171924690577744;
    
    uint256 constant IC18x = 18295121598072600271421554427721304479183841748065504143650206227629756695556;
    uint256 constant IC18y = 4749679402337534662568322599633574117936577640554351295356001240471142386413;
    
    uint256 constant IC19x = 2405622451916176037428641223174958729187027940916805625643510311463828238971;
    uint256 constant IC19y = 8594520505959043999885091809822254871680333384951041925156257460232684560259;
    
    uint256 constant IC20x = 15997400562069884032768251296535082620643663026283352733115314383556780293985;
    uint256 constant IC20y = 7140821575251827300966570332795763052451155794525413786282051263969763883241;
    
    uint256 constant IC21x = 18559792723748458537488817420656796773877931123355242079967415551089711140943;
    uint256 constant IC21y = 9964401764429623878620608373004352641524072409378303947625993360380574460935;
    
    uint256 constant IC22x = 21263064039958136177956349838215068453343163303807458060614996912243217502349;
    uint256 constant IC22y = 15768661671790186052445142391629525845729134629883943906882408564963204875779;
    
    uint256 constant IC23x = 19581713164100668710162778013933654633034816664879414982505220783060964425131;
    uint256 constant IC23y = 3293541488135525013211005032702003857948639618591517188905131684109520888544;
    
    uint256 constant IC24x = 19235222738988969347618075933292659063595988998069119911915744188003212662256;
    uint256 constant IC24y = 20983189407626533565079023295250001305763238963477356896401388723785896185722;
    
    uint256 constant IC25x = 15927225477690126086821820512271250380309637180583405806366131331892835464013;
    uint256 constant IC25y = 16027774566406053957850948220155582909022390539089029373339166936741647696237;
    
    uint256 constant IC26x = 6203930736949023785568853161833191357538835761678657067570643254772900682146;
    uint256 constant IC26y = 3518125169074531272254516962069374847496276651277163136260600297988864026481;
    
    uint256 constant IC27x = 11838429003185491962557048006861958448926579337050159961981570941140914582562;
    uint256 constant IC27y = 4226605528304543449316495698929157546060282407563234894913421796264841328011;
    
    uint256 constant IC28x = 5807710379099639675879295854507426464706492321936539726653397722063717041923;
    uint256 constant IC28y = 12378975277456324489852699283018411356996084110213072474069368882094227447123;
    
    uint256 constant IC29x = 6470816506909585841526250910129978185799162620708650118092906503648282734746;
    uint256 constant IC29y = 5610869225827311932821165019124769410311351047338787643541597821672723887752;
    
    uint256 constant IC30x = 477539154669525037336445518911357465552237779052013837162507201053240758520;
    uint256 constant IC30y = 12927919066275240125479661370366830546481663945259559151337689796700284932431;
    
    uint256 constant IC31x = 14353080498356922780062926816339449573948495042439251173276970560641045217459;
    uint256 constant IC31y = 603906648105440587117761269631752524645588851562946930533542469072958296841;
    
    uint256 constant IC32x = 9407306306302476242042221054864949248913792624696834795753440695138927102986;
    uint256 constant IC32y = 3244330743655493026444440358254054306946659689752331213593003279765849881358;
    
    uint256 constant IC33x = 14038252791148213926715460613807247188914237361107480656311674324948817070751;
    uint256 constant IC33y = 17909489585722993096772674386358791667825205730711324183599963377351118994568;
    
    uint256 constant IC34x = 614465294363773968270271174125942404122062575827911857620221265761903821689;
    uint256 constant IC34y = 16122748799092375961777258161879810212062127678736299506698926571180488766646;
    
    uint256 constant IC35x = 14800589758175457014229019791959431747156592928092648411252786546477409880778;
    uint256 constant IC35y = 19280010669469561145939263237408466083074675083426410856430072794146511429608;
    
    uint256 constant IC36x = 16462643027631941123973332855829715354382722478342612678876055053686881161721;
    uint256 constant IC36y = 20611138045991153786078423183968136965547459945610065725744411443269080138571;
    
    uint256 constant IC37x = 14794813309046216659148747537218564597743970691507492934075425796630538798755;
    uint256 constant IC37y = 16087209495056423599305578794374831949194854568505971056908325156416914638500;
    
    uint256 constant IC38x = 8855873826931452872728877999005039917792369704898148242172460624859394527780;
    uint256 constant IC38y = 9377378692716039085422934207465646993438197601611162984355159751373372814459;
    
    uint256 constant IC39x = 16964526877495437394704621622058976082067687362825757591158302776217568944136;
    uint256 constant IC39y = 21773561953133366141531369683684934182665994257123596053520447031418408669887;
    
    uint256 constant IC40x = 11517451652672348595334814268299672647483559454380350941950660289157015846277;
    uint256 constant IC40y = 9308328880953724673496868318072547880126369154589750558228329191959258242158;
    
    uint256 constant IC41x = 1625260628487320141484935273613978010008404967311297047218204224047031609331;
    uint256 constant IC41y = 15809490003710483426411252356683331883619772739004491678368507156809238084230;
    
    uint256 constant IC42x = 492535780320525504305498059041256351181363326326629524608538390512508216048;
    uint256 constant IC42y = 5956758612436300481820774791078313498018538345620927965699003809508884523041;
    
    uint256 constant IC43x = 9506462120596192905862437330911271746221478241845431030876224910719113786978;
    uint256 constant IC43y = 7932952864165535164344556060177045120240905883232969313138686128448294638372;
    
    uint256 constant IC44x = 12117602973126312477508505506435221508376648131281011679923476247524156024129;
    uint256 constant IC44y = 9036334638746738019410909201302077925766514212767401112147164878538110487020;
    
    uint256 constant IC45x = 4656965272641104596822379380254009823895396245233137995010867218382204160515;
    uint256 constant IC45y = 14927752944863522472640124563479623345093842708025936289745012592078209019326;
    
    uint256 constant IC46x = 10913333270863376884565053826019527456425522754872615301703290697656712891327;
    uint256 constant IC46y = 9866802111633282337836130053831207549758904451269239080985335738967015931560;
    
    uint256 constant IC47x = 19412808954989786847476769577769415624837290348886847726709811195073742393115;
    uint256 constant IC47y = 18078333322476690848874318275405190134536784663774934220410224590785078306178;
    
    uint256 constant IC48x = 10969991540344130262078741677531963529442644985265138689204686412035262839342;
    uint256 constant IC48y = 456881793447658502672043053200375466971558123000610084880328489220061740059;
    
    uint256 constant IC49x = 10005263157686764150362792387537008051010150385513615696598489953414089799248;
    uint256 constant IC49y = 8042015170808641291951131551486425812999172176516668351379310200679729332494;
    
 
    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pPairing = 128;

    uint16 constant pLastMem = 896;

    function verifyProof(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[49] calldata _pubSignals) public view returns (bool) {
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
                
                g1_mulAccC(_pVk, IC49x, IC49y, calldataload(add(pubSignals, 1536)))
                

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
            
            checkField(calldataload(add(_pubSignals, 1536)))
            

            // Validate all evaluations
            let isValid := checkPairing(_pA, _pB, _pC, _pubSignals, pMem)

            mstore(0, isValid)
             return(0, 0x20)
         }
     }
 }
