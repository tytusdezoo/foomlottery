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

    
    uint256 constant IC0x = 9237815063603711840191365104041777941006088467547411591661082107749416378379;
    uint256 constant IC0y = 19178328867759299709571164090740696114514478628401858017442110527239377726867;
    
    uint256 constant IC1x = 6191901346651489251756946659428804231447462679598290678129637663965994316415;
    uint256 constant IC1y = 6879503426621181990674781842049224379900244597686290538150104818772304968699;
    
    uint256 constant IC2x = 8330439835096501022182772843629484883839218515265496423123318256331692522685;
    uint256 constant IC2y = 8783803138661638486944180538438271797919149472700461481551635536676185157325;
    
    uint256 constant IC3x = 20506823938617012098071588206961282807477949012639763240634624216785946032022;
    uint256 constant IC3y = 14358735449302140265635331927841117477232138414667052174994078360769814273265;
    
    uint256 constant IC4x = 4971300329773393859409930614719333071237918153501990979203174118563564745153;
    uint256 constant IC4y = 14956054239205426462409623180167839533256525693286319883266270384924937920153;
    
    uint256 constant IC5x = 12736464506651225920754370071709972390598385817280679771324509294166759063071;
    uint256 constant IC5y = 18217689805105734060529356103004509024458721369381758202244238668515619434492;
    
    uint256 constant IC6x = 1156482748391663069152719843584261460396632680107618518989058894033498489376;
    uint256 constant IC6y = 10481224414264754661949936014204569293874279839347141661302134116247914267191;
    
    uint256 constant IC7x = 10683206939223451351181693382241564604421526582368548775627973883349618913791;
    uint256 constant IC7y = 9101358309278315352893750634245703697786059675437051944245623503485702827019;
    
    uint256 constant IC8x = 7702064169075780623129986622819816160419039874956794724816381675265601424110;
    uint256 constant IC8y = 11746161939465745053347138386805744069133102543653158798659575574645060611262;
    
    uint256 constant IC9x = 10425447458624346430396131219760005683437297125975267643697557196532703692049;
    uint256 constant IC9y = 5169762519882960740836843440891095807033456746267239569264298985481299662070;
    
    uint256 constant IC10x = 10582646664174702906141987084175758813287273161398483814312702966334841503518;
    uint256 constant IC10y = 16807481861821711127497089078398445569981166945559930972572226079785759307380;
    
    uint256 constant IC11x = 16779587631533496172457245176654511289961331010011759527533107695831007215621;
    uint256 constant IC11y = 11808414054733179531863396919513034059669070057821677074324322059332073150319;
    
    uint256 constant IC12x = 6057536690016219267827768244712182569795768154051034615062393832280030497962;
    uint256 constant IC12y = 19052537238364306624920669500065594254333943926484561013489667610474490258511;
    
    uint256 constant IC13x = 18701283606658966217102789421461478476497245561016549305755786880942054686896;
    uint256 constant IC13y = 7705561907978327269398814266114922882815898956520759326040214221331053027787;
    
    uint256 constant IC14x = 16109468118944640228374313613691893366349958564762454608462644016150464432842;
    uint256 constant IC14y = 17383786017414414617832265840889851968267185346464123603167292491308685933431;
    
    uint256 constant IC15x = 1560790223490785349077157516345397429426043441188171689883832564358928712770;
    uint256 constant IC15y = 1081726906982043878880786399255698436681892536775524958039983642309452171638;
    
    uint256 constant IC16x = 4997126398019529959133168058062766798827115057943823169758904517339721010020;
    uint256 constant IC16y = 3496492800784609547903404060221773753465276324598823578893519098174235601003;
    
    uint256 constant IC17x = 20334772418209886389014485038535938951089871230282892426394007277848525697559;
    uint256 constant IC17y = 10358720181326635486487835822088842788738615875053735917787209683983210861811;
    
    uint256 constant IC18x = 21628970260594759119773411839006633848456316065571369275599388729170426797235;
    uint256 constant IC18y = 20788608517903153078926956545102220096123185290259484903288213592044046257154;
    
    uint256 constant IC19x = 10581536225431019739064541156361001089879067975133992688749040279891085830199;
    uint256 constant IC19y = 12080073812186765350328767514236373112037288506232415009770416812953716123723;
    
    uint256 constant IC20x = 19991122206871630074257630682001385530814668997799225087534446431756703306845;
    uint256 constant IC20y = 18752795352907369449727615146461979418280604043094878773662737830947476621975;
    
    uint256 constant IC21x = 13839458974015131475222473567796707796032887576960688958379586610021453305592;
    uint256 constant IC21y = 1102793682575818899447449238738161203655362246806154382631231816707078470692;
    
    uint256 constant IC22x = 19289665601893273443100033064561210135178805562363770917066252417140147856529;
    uint256 constant IC22y = 4547407535083288724094347813119052860720764150480761524693466600350507818361;
    
    uint256 constant IC23x = 20905151481639212501388384324342577470881046327142380130205562669275011466699;
    uint256 constant IC23y = 13854819139790713205078782056264612652226363765792442942238955896059807136465;
    
    uint256 constant IC24x = 17392737162424211252919218606522872674994503845368314148951226856634877577584;
    uint256 constant IC24y = 16254269632389463643824384017615712813547150662322360990333898331385102829610;
    
    uint256 constant IC25x = 16347955714506664913764914086339723527111169914697434750619435593244442367032;
    uint256 constant IC25y = 2151871707870134413368870899085931501820950462064008522197964456808290793575;
    
    uint256 constant IC26x = 1231466386328137777650894416788862207375733022191867558689547925807946162007;
    uint256 constant IC26y = 1629802504854213633925127070420627700738573731421079444927214749770974070630;
    
    uint256 constant IC27x = 10824619728197386021605623681550603828164011968228929563448180197888631997885;
    uint256 constant IC27y = 10848512838954409588312779995533549962347991010171298360616891182014085977961;
    
    uint256 constant IC28x = 18579099670332545395041123596744055592765548812976674341758848175483740316615;
    uint256 constant IC28y = 13306546775927510412641611446043111257066021449640624060957013390789049851494;
    
    uint256 constant IC29x = 9646380070949229122407710615133174761472580978102641054948315012950731049131;
    uint256 constant IC29y = 18409448569513625320837383296428112322013135966262217407736486743928338915431;
    
    uint256 constant IC30x = 455215824748878146115739505845913042508521517467681652767831184278756126627;
    uint256 constant IC30y = 11883399425683222445683919788212124887346443220520833196181066270427275828366;
    
    uint256 constant IC31x = 8999470589849712953524340247993239723996449648254120436731362923015975329005;
    uint256 constant IC31y = 13558510196144582862709297615030715464055002941725086022947465992480292894517;
    
    uint256 constant IC32x = 21082896066496534546192368782673311857985469501015425382257260529591121524894;
    uint256 constant IC32y = 13612242592360451232050440209779389351604748858512770572892002120167941801161;
    
    uint256 constant IC33x = 16648602095277575475169642497238759360374006716895236405262358475966034465038;
    uint256 constant IC33y = 13108680703892722680572507936957903153951059317009865826774477598071885783435;
    
    uint256 constant IC34x = 18964188485361369407495589986147460826092185200631223444942842038259274864189;
    uint256 constant IC34y = 697280363164472174330053140786070016815342149991036794685059710067598844698;
    
    uint256 constant IC35x = 12641789944957705101446375438458159258260325068662432183165920116811941660134;
    uint256 constant IC35y = 17788498849314594050427675260590539415641955489290095370832256299232062370305;
    
    uint256 constant IC36x = 17983745234541717204616911571065267785630035491836337920206997996348605869083;
    uint256 constant IC36y = 11927971042849393811117193550558599487326660424347325731855719050210173616407;
    
    uint256 constant IC37x = 4506111671569691962533622349504276194649185424977600666901493968686821114182;
    uint256 constant IC37y = 5330622908569083519655019243135901227798663526429350654428094385753980508905;
    
    uint256 constant IC38x = 17500342307486403635437112202136031380716266977657781304484478685218838311418;
    uint256 constant IC38y = 884740860394013640341239820656073169132161472076889742914249011420945146478;
    
    uint256 constant IC39x = 886940423757000104567311803474879963960943194919328656064198496156588875549;
    uint256 constant IC39y = 1955104249693474252241517352302437150473592025700841959097056060416085211722;
    
    uint256 constant IC40x = 21155080055267499104009077548174515784534104302484287535743306095889065702180;
    uint256 constant IC40y = 1828288662262546364304078199393407478430812886333218269805320837595853215478;
    
    uint256 constant IC41x = 20108698486672864709806497596554952499538926455850471325364309814365646530610;
    uint256 constant IC41y = 20696322530309295886082703939114172229247376758196616165316662083748436092387;
    
    uint256 constant IC42x = 6652251112746534340632951282719153870005599929824354659401941499801814723102;
    uint256 constant IC42y = 18692806917214169255218301422866338229568658102118560822324038264748901507126;
    
    uint256 constant IC43x = 9261406073747388935336274462834184558836509004917517588743503086549882226162;
    uint256 constant IC43y = 14519316502196222836274102279661992123609651042152964292941711529760443439719;
    
    uint256 constant IC44x = 21562250167958448167445261695845606390934819260827432452674617576881364026312;
    uint256 constant IC44y = 15785860356993086309280304618901067691918193149828467914515851300038206646927;
    
    uint256 constant IC45x = 2318765587175091306191515916533156568527261436646616169507304125710708484664;
    uint256 constant IC45y = 11094153522999187467496489515993732009976585334269041558554907126379838527164;
    
    uint256 constant IC46x = 6068444059274575462602158587134102152145701132375177570889224357775125488428;
    uint256 constant IC46y = 21010963041962649570256196155013497455826496208986604878400265783342326055755;
    
    uint256 constant IC47x = 8052156769511209103835600810434743133388386378358840589292003236756719244613;
    uint256 constant IC47y = 12394019297141681638287006644755914867474248132892847042781478958938861166692;
    
    uint256 constant IC48x = 3008892575060007707296510731819086921400496560277739426074054343914795175239;
    uint256 constant IC48y = 99067310016687576308063983803769247057456593384463708094440101870785718825;
    
 
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
