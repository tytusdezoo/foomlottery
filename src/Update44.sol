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

    
    uint256 constant IC0x = 19693546110240235416830396366858301739437484300852284109597742205489862139691;
    uint256 constant IC0y = 801478251393002861773917262311518330044383916035510455351125268278929164877;
    
    uint256 constant IC1x = 19857648218082278780518139102803069066684486122635581887587030514765980443898;
    uint256 constant IC1y = 1603595371033434137158559717141929755237418981995627342041714953032295685070;
    
    uint256 constant IC2x = 17316253173310575908783223264093034447880422936285666726212054829511286927338;
    uint256 constant IC2y = 14865132492904352652396318899158222861346527977051950068682163535083010687822;
    
    uint256 constant IC3x = 1139027598448386276711660531971858232763608653959930118747486823831500623295;
    uint256 constant IC3y = 6175874174108322266218121069957771358754476356252672308541792848141867341889;
    
    uint256 constant IC4x = 4449613051755564045688526597569490777421092467408695825605094897944188752465;
    uint256 constant IC4y = 19720640628124571615714740454534925962150436962360225948144492867015957938904;
    
    uint256 constant IC5x = 20941546314379472449969122900851989530617631342028025323195077438266020756691;
    uint256 constant IC5y = 9613153270047330459657391737484696808989411113511367836260621762790849273795;
    
    uint256 constant IC6x = 12948678137491031812383271761055231991801843993809775637584238919853490241129;
    uint256 constant IC6y = 16839726365978635890567628802704529829591538170495310205808180047470181532178;
    
    uint256 constant IC7x = 4359913748366342807017932667433163991985170483803785808185447229625753935228;
    uint256 constant IC7y = 18807097686007237049355641382304902163049288082146599517340033261013004304134;
    
    uint256 constant IC8x = 12063061471300709960211618573931424581792693510595336508435231459897873934621;
    uint256 constant IC8y = 16513622493927603792317660693067980439818725274011747006369354259944006272525;
    
    uint256 constant IC9x = 6491261869951794232818357608818652664578790880168637395666641258188788673586;
    uint256 constant IC9y = 454367241634339903329036726781293325549993060139192640581345207138679288279;
    
    uint256 constant IC10x = 5844741703813684207188403585896652701504356331737762910525326490486741152884;
    uint256 constant IC10y = 3561125378201455917466885643707430401101107606997880246285431814750620032250;
    
    uint256 constant IC11x = 16273741274777297383371832526690433207567441704578859042433119443049534466179;
    uint256 constant IC11y = 14058084626966518855999889521645218751001369797621244779383606240152043402538;
    
    uint256 constant IC12x = 7735673958387899082122751921263724851448822824583816356298671607700778754268;
    uint256 constant IC12y = 918665132506179332822422643754389732072710908505292524852490140974138111435;
    
    uint256 constant IC13x = 14851067518117748887278013184557512216262754693886548267862875294047840723899;
    uint256 constant IC13y = 13828656720445892611664518804282718421421903897492747723922774261188944615173;
    
    uint256 constant IC14x = 5360767676950132055751671894288568277895775273222564585214793568984505248876;
    uint256 constant IC14y = 4469930065887863878598406490879012352133118935795078289173161686297757646508;
    
    uint256 constant IC15x = 12119406777238940421266647563814365994279763260595351809323398033914658513041;
    uint256 constant IC15y = 10086836454939292977393586580021587108075357251622161953983785929543670041466;
    
    uint256 constant IC16x = 20637722510778428701721257680957815253590158031164639692812438870820676485384;
    uint256 constant IC16y = 16542797474421816011624651468381617415377133476775350826950850436381162183951;
    
    uint256 constant IC17x = 21363794971128954210743843403396732901521501025144657614520220677242805996105;
    uint256 constant IC17y = 8448844331975544225081928780711005548216982899931687313343684752407487344370;
    
    uint256 constant IC18x = 17717841984623533369230504620509911480924384529446552061677929545630172971066;
    uint256 constant IC18y = 2648773986952600453687150213063746124165466945781632808100801738181477884100;
    
    uint256 constant IC19x = 2328670659875913322789669484649209706223219766214496546862946193824920443575;
    uint256 constant IC19y = 14194668210154450425338147594393362432163990317828673283011910982874193083163;
    
    uint256 constant IC20x = 19752679241251577597486377354809376893272163521987002307159646811066192114181;
    uint256 constant IC20y = 18906174476974722799682500226603075555267308754849618441130883165632361764627;
    
    uint256 constant IC21x = 18871549532734446295664090213310262801410444375832549768629236994330056775916;
    uint256 constant IC21y = 13915795703573870814945944631866166333818275840381941957568911770403882599985;
    
    uint256 constant IC22x = 12435717047073369605131067560689447627337373849044338705119923624270559336221;
    uint256 constant IC22y = 4245446704913441289059531230626819809095924718936799786165078451529419463561;
    
    uint256 constant IC23x = 8549311999240844288799212636215685717319683172375686551392020370655878998527;
    uint256 constant IC23y = 10889892234540915055674474461941533875219015469568231347097961914280121544262;
    
    uint256 constant IC24x = 17537141432578093621989270474699669544195324412416293458414042237314733689947;
    uint256 constant IC24y = 20962608206907778487943935445848817178213477092145697996882414298596453425872;
    
    uint256 constant IC25x = 3523276322291982588702823541775523956736667563213866722280573220729235826389;
    uint256 constant IC25y = 1598018068773953678844962233791939222741353090077421962410026423348041495376;
    
    uint256 constant IC26x = 1620622193346522942972226676517488939999876502484903323099898881111904175321;
    uint256 constant IC26y = 17425690526862994587430003835873394453524795066669052936347461867642592042191;
    
    uint256 constant IC27x = 14385098578677566393395246858515986402991164625128477047089848356774648537098;
    uint256 constant IC27y = 15923498718293786408387922636932194614157054380188379609802649593042127641083;
    
    uint256 constant IC28x = 6723067440933349002650103370700571348308899048477942506772482728925027783717;
    uint256 constant IC28y = 3829147297531185425537396633915349711056056896231686849618517192816863176842;
    
    uint256 constant IC29x = 18083854881635194940029249545070580600817110772702409189064800138498764699670;
    uint256 constant IC29y = 14077294980577509674765682776931353909233964414280614796802171443601441862314;
    
    uint256 constant IC30x = 2531382473534479538452509306795465056626800393756070400989851505746588314063;
    uint256 constant IC30y = 21437255089284373525035157250036748584914553131344529331670983856698552993142;
    
    uint256 constant IC31x = 16688781520379988417886066359663370676837662984530941471676806078141173653690;
    uint256 constant IC31y = 16881846683923930255238566958993452715072718227643252641732082579477888854011;
    
    uint256 constant IC32x = 746918927460340980823372461827126831445273530836855689932457524887880027930;
    uint256 constant IC32y = 20848461026569674374855557276777223955812653559785412085408725389734887383413;
    
    uint256 constant IC33x = 4910227753998844879808703093914611568151591120124842223382261390507915567960;
    uint256 constant IC33y = 21746571080924656572023162578095142002919330130606047504517675090842149402406;
    
    uint256 constant IC34x = 21529891245389875824845332866202900418623138839654288830630032049682007653091;
    uint256 constant IC34y = 21605032418095023721951102733823358655361301403992193636232378660305251080965;
    
    uint256 constant IC35x = 9705139927462479526193913103104652789963947612402746493103398561592467633112;
    uint256 constant IC35y = 12595667894537179440410522869770270392747881593648530312032865287477174894857;
    
    uint256 constant IC36x = 11666661284231475931506247503224757173342962303723779209230202331747925194206;
    uint256 constant IC36y = 12812159730283973388846452415023664854958796560050351357722668349392505866835;
    
    uint256 constant IC37x = 1761049360465071522972067042080553985893160362810955918477982481311325821614;
    uint256 constant IC37y = 14089754887068329538422445528764471117870931901751597001762590950555504574511;
    
    uint256 constant IC38x = 1701775753123157412027373061663329389624718329968437873693388728172147788510;
    uint256 constant IC38y = 15482091399843247293509746402046261702624820635048594015237508520993730340524;
    
    uint256 constant IC39x = 19662468050805556797925588275206622503074943903559268714092893327029206993169;
    uint256 constant IC39y = 9782740178784964410740051240735881949082598553610630546649690244046336241507;
    
    uint256 constant IC40x = 6860050410781593483358158056889562617054172978447503565977611254435089108779;
    uint256 constant IC40y = 1446950124288837265677689566281530857730423792655257854092130542891031080622;
    
    uint256 constant IC41x = 15897600820720608036409346847858666079153041378917659589057664531409281416091;
    uint256 constant IC41y = 5824447632900129342691609688372125941656971803347539014127944768958948432493;
    
    uint256 constant IC42x = 2954063216039554913262294777521160945918788637986918747492036247592920614923;
    uint256 constant IC42y = 9357657783800659289551695833668741453870370722618365927938234414983907105130;
    
    uint256 constant IC43x = 107093550318201454181391510628288362116808566071337592791529935939597136098;
    uint256 constant IC43y = 9258949751454856089041439548749189083494582347411938501797668260143598335307;
    
    uint256 constant IC44x = 21063345541482437224667572575105056382246816624043301252090672885490413673207;
    uint256 constant IC44y = 13429926212913858695375350965537310837846524028695525721917373546900132622509;
    
    uint256 constant IC45x = 17464277013429366990042653153631367768859261367011006989828046807527442892341;
    uint256 constant IC45y = 5305628908913601103498541406421935128704244029073176633348180015952269299807;
    
    uint256 constant IC46x = 3550622544167656564901417010336013308928920607992510985397535943153889068878;
    uint256 constant IC46y = 4715698854516971093268541331425109735018457614728715968143609907172512696848;
    
    uint256 constant IC47x = 16663648888655213637349096378131999207144887768579299563072544797919233204094;
    uint256 constant IC47y = 17872659083180292750172110798131912265778319789683269323848671156185224511809;
    
    uint256 constant IC48x = 6950759386420633826424413637396849605038709337616865993075793136393200412497;
    uint256 constant IC48y = 12063889769678214421897837947352421331661300648727946782707139823743790405346;
    
 
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
