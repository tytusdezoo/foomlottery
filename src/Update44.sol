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

    
    uint256 constant IC0x = 20473182810432034573290783844177284498826892260870679211769065212147463135854;
    uint256 constant IC0y = 6334632568405210316957590030469315374802098595884102681297688913472681861788;
    
    uint256 constant IC1x = 2281584068328918763469764459201954056617378322586921691070517671567866265304;
    uint256 constant IC1y = 8616791279054498216910217692254285335958192843404285872470632220147606804638;
    
    uint256 constant IC2x = 15945364600828582816204615958708722673100203684173254125651954236389325852411;
    uint256 constant IC2y = 18392485430668946668287974495541530599578112009270177103550225735221271923561;
    
    uint256 constant IC3x = 11435964501939250414808893111180678695280225648317691603255647096502696039762;
    uint256 constant IC3y = 19061637569019871937866527327087254197288186713331202457994039903267406198800;
    
    uint256 constant IC4x = 15885913819391022249234286620401084342672930282218703675989622866234504247939;
    uint256 constant IC4y = 13347932492353431771194808524613321804747994769239506051280754191483028909064;
    
    uint256 constant IC5x = 14544807546534252265825273318932548467188677533246195887693892929104244470366;
    uint256 constant IC5y = 14208376225763603222469005892256315298781932858207864589015998199026480307814;
    
    uint256 constant IC6x = 10121854955922887476785947852385246826463439495634224610712798336278047130040;
    uint256 constant IC6y = 12603068699703123846136140543479605044388956826981542634706910729951343322968;
    
    uint256 constant IC7x = 16237393055531731408119154868454397345777183302518372310299628404685681681596;
    uint256 constant IC7y = 18408187913514912076789385835806952539571683732699025556719208305224978766268;
    
    uint256 constant IC8x = 2498679426619107073699409224137255976012123096328865922374997540445259840922;
    uint256 constant IC8y = 9950147678717776016934772312160700315817490763742397295003048455189292328228;
    
    uint256 constant IC9x = 5439842766931035675836234306115954017366306494637317808768566811847968451893;
    uint256 constant IC9y = 10973859552952204305707751316407971233663225145022446465565580317206083315127;
    
    uint256 constant IC10x = 11996710779561131325597202978245962697455830197836709097238870586263292962605;
    uint256 constant IC10y = 18781783881320547585034720861583613325618333789938467137520769496414049421839;
    
    uint256 constant IC11x = 18606807483159672044965315436176499524473906918919788432282268086389453505845;
    uint256 constant IC11y = 17762316539366125103295726106646706175961768352070736784447242025964387740421;
    
    uint256 constant IC12x = 19178831269607871399065150942287416354409823297167177629563706254869012305388;
    uint256 constant IC12y = 268310514820218496591330868908156582814698067007892634395776818170091381054;
    
    uint256 constant IC13x = 7199195344890982270509901830592995217273862347742492765988473103941223738375;
    uint256 constant IC13y = 11628349049463014811750729627999651023464734246995338550999870108261337613348;
    
    uint256 constant IC14x = 5746852295162260655687079422396845835845720617133253882065242417323778470720;
    uint256 constant IC14y = 8428527241759207166595438315342399773610436869876049872738708871655354125446;
    
    uint256 constant IC15x = 6542594034905544222287254305369533679606181256500949575383671346490178891698;
    uint256 constant IC15y = 8852226057718967992643957666082926782482986587807993832870319771035890452433;
    
    uint256 constant IC16x = 20057412093113379449043261585213173322121048737618049659971431309459399814696;
    uint256 constant IC16y = 3846746527141776835330513525132131938491508974843539906470831871448625438569;
    
    uint256 constant IC17x = 18148080625949815715394940590756415318863553710549901529781779140942613451505;
    uint256 constant IC17y = 1058350043945200546582160221012345500656147078101326013198251089365367535335;
    
    uint256 constant IC18x = 12583084694998437474695680078189057646067419046805832195333677427272771285999;
    uint256 constant IC18y = 8543739209798280831690580911069788216427328675790354243920110448458985032366;
    
    uint256 constant IC19x = 16382249348402445260363629061721672069374006630446995381021530991051429668217;
    uint256 constant IC19y = 3555381483650266327224812727409670152942970782252765470835074510105813774545;
    
    uint256 constant IC20x = 15741176017285016858260578507172005191133592313775812220550140730492975329730;
    uint256 constant IC20y = 3082868731805819143780957386821852334031844313115338705177922365688107513849;
    
    uint256 constant IC21x = 7810379239906296828893308299133454575091944273065344487861200609538144056736;
    uint256 constant IC21y = 4879849090245823112991089023472194566980036051544114907807117334626005370059;
    
    uint256 constant IC22x = 9170750930593150749380459252229078420093192694869654404184873247722937817798;
    uint256 constant IC22y = 16796588774527890175598989750075387126054533557234049628469162171691238421924;
    
    uint256 constant IC23x = 17994703944987240585212705329601442856263284269315426476654193247119407428914;
    uint256 constant IC23y = 6029054818417911448785943370135726457539945132958124984946620095190206591854;
    
    uint256 constant IC24x = 19102708262965433831351997599672463967253875946855006984304754590037101791977;
    uint256 constant IC24y = 12773101789868566984986386313979960908136767238869153290431233116523186997731;
    
    uint256 constant IC25x = 11106895034401590667114786651574636307159385185890902562439360521528264010862;
    uint256 constant IC25y = 6609555650837360085849483417359520263284568283120135623973582885504169351263;
    
    uint256 constant IC26x = 7958647926908770587581632834606219172931604327077507069843152804348764591022;
    uint256 constant IC26y = 20898930870664240005342683084505766312987908692752998108604543084922329809707;
    
    uint256 constant IC27x = 5922152916347960279838857465022980605214115469859160595827146138863392809864;
    uint256 constant IC27y = 12744375219047314213722111147725180492831508335704392065875310365521675031150;
    
    uint256 constant IC28x = 10204711738854130447856949221100792667802230904497449819428243993273319313561;
    uint256 constant IC28y = 12048311641935457818084414496128956396401939279559939718828785493468878965511;
    
    uint256 constant IC29x = 5490796095531626149029435406057887374057511645642997397083298442516516097905;
    uint256 constant IC29y = 119515176942927032404919294332059201147406486703266755350412652183218119923;
    
    uint256 constant IC30x = 19823018269837270216450370039324573198236255215347505962339074065731736791641;
    uint256 constant IC30y = 6838772351231097083713442561939547981918892456140079613121009317069802642286;
    
    uint256 constant IC31x = 15502117371405607261331355973585719390013308815088806157336619058556699253397;
    uint256 constant IC31y = 13238591894646255944744148067714707305279569679207280824477758881201991618693;
    
    uint256 constant IC32x = 9975626980473988844505174683087418513426818106027373804565227080151492670544;
    uint256 constant IC32y = 16680870887993645910984433182312268204248375020329566705081393186421653490628;
    
    uint256 constant IC33x = 11561383384565639707714789274374734335259503010392908418679878344421046541209;
    uint256 constant IC33y = 9560347904271160556363900329362269911100362545487842339246599842861603700078;
    
    uint256 constant IC34x = 1919573274717007164003525793762586886798581490319010926225213966915187344003;
    uint256 constant IC34y = 13729297843338400518170655325999141756191071108611462863841411440816655173636;
    
    uint256 constant IC35x = 18718903386952205643782966565581345862696507567264000319051637502110660967276;
    uint256 constant IC35y = 20980365647000731817018767392565157555938772318777335449753325244820923681227;
    
    uint256 constant IC36x = 15178137727199546840039587645315847166469029031498289847294668591402711718705;
    uint256 constant IC36y = 12962401424059789927132344058590907950322981889630398375710973130674124015584;
    
    uint256 constant IC37x = 18230948832435363191984278444059036164341769495913225412125254011859288686110;
    uint256 constant IC37y = 10699916621597678850036737132476270385678437860030485272691418355849477613264;
    
    uint256 constant IC38x = 2124795388948599316529854341215983811101917623350769378448090303045717159161;
    uint256 constant IC38y = 19705056138963718198512983116618063050547439731978909103383512702466441015791;
    
    uint256 constant IC39x = 8339382687656019958343685873232980525342026687774371373369823292428580466614;
    uint256 constant IC39y = 1960020100198135450342858870893645302995534103877887338407335588234136460477;
    
    uint256 constant IC40x = 10974861428124435349055617478334775897264823337754404016072866337748477234870;
    uint256 constant IC40y = 18359987675555800251086372621574770576991912906182844538095660092807653738688;
    
    uint256 constant IC41x = 20480795274118136119422301475586068316597149978443529710240851274019923240027;
    uint256 constant IC41y = 108404452142128899715148698767249828886363352370350915654637562757849807513;
    
    uint256 constant IC42x = 16492645256210844739260840362103064296339364255659416628691754429133784750978;
    uint256 constant IC42y = 17161191411489782307818612767548367100640098231138944036986124432174564474112;
    
    uint256 constant IC43x = 15942286789957242056197637476655754293567522638248226947984921604980118072736;
    uint256 constant IC43y = 9001111957965499714021232745085339106410113841848661157245546162988295695040;
    
    uint256 constant IC44x = 16683224668599396756524959944039503525174765796980664624813283142208974624933;
    uint256 constant IC44y = 7755816506748829033565884162623680059854961267470806818191625005385286994270;
    
    uint256 constant IC45x = 6955492733239580471100223010119350673949896951440676700788639622616097395193;
    uint256 constant IC45y = 2245644824957722790873765132957502199636051802046815269290594502407425066657;
    
    uint256 constant IC46x = 15607561970504127487303691017499888885895306937435626251983642366544493100856;
    uint256 constant IC46y = 6090254334582201186354245864974980370433888176290830768330969953029590771269;
    
    uint256 constant IC47x = 3438664006320306558992990869166607430516635087204696659011444031215085798970;
    uint256 constant IC47y = 17881578735621142150945104955662390934182477400103220043506833489478305899323;
    
    uint256 constant IC48x = 3220715285788111266470743303846827575843888985240956798930517474698483605605;
    uint256 constant IC48y = 14874331807924467146671361388876578391729903037467883652861662363019599010561;
    
 
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
