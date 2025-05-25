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

contract Update89G16Verifier {
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

    
    uint256 constant IC0x = 10282509642664157801598582329825790276850478509460980865770740000866199512390;
    uint256 constant IC0y = 12616089914998333146995712756488123510158307408651163011411446316465188558146;
    
    uint256 constant IC1x = 4937784084011771784589258620646447948577900047918049012268329996794815461378;
    uint256 constant IC1y = 15629380577664926129536020885973219313397398011659574035732206050797951909096;
    
    uint256 constant IC2x = 10019358294432337472757066501420509281893039388962542412107852291380173626125;
    uint256 constant IC2y = 21873133685263868422324478975288376190254536706125678696172600618052585297524;
    
    uint256 constant IC3x = 11246164226752378338468845632582694122151630383067283301977998261073364428860;
    uint256 constant IC3y = 563684434196103077828178489765137405351258715500534694856577004915678613230;
    
    uint256 constant IC4x = 16055470913631755035415486859196188013017348025048346758756438979691638471005;
    uint256 constant IC4y = 1623001156443406670944806700613385435763021558636043500887425344124340968517;
    
    uint256 constant IC5x = 7385434018508525855443786867311630477316259475489480506427916032975895621220;
    uint256 constant IC5y = 9083985171055065846641083610913055076896809530186728563757960501959229417707;
    
    uint256 constant IC6x = 16090042174199958904608181984514916922325888138812486263086307401040057574062;
    uint256 constant IC6y = 7680104535122735807448434805138643503982705516810703357664855042383770555520;
    
    uint256 constant IC7x = 9449888774367951773229298035954995654510324025535464987657964147417354045131;
    uint256 constant IC7y = 612311008649492549488792028834399140506696845518681789130687758601533310836;
    
    uint256 constant IC8x = 8665789001103951629085102041738680694164335520956070944218858207736486996443;
    uint256 constant IC8y = 16046174040735029659810203041141575228856472667806564866862258385681987437371;
    
    uint256 constant IC9x = 21778854956832110963975613604619199935060909817928674920245469250195789718747;
    uint256 constant IC9y = 1003806203653011195847657375089322123416653934980014673948328642287333203813;
    
    uint256 constant IC10x = 6076595978234144069677762208900784037600536195512021578407836824840722499932;
    uint256 constant IC10y = 2440320447692417673080341302197783258518564670921864994570924280988703600920;
    
    uint256 constant IC11x = 6060213055961576350735594398004306599129147528850904215908032977710305345723;
    uint256 constant IC11y = 4642958920309380168226220820454681954970563556610477809754272588495450099557;
    
    uint256 constant IC12x = 7476380110283989356433791601166367778791063254546527483513024069441684162302;
    uint256 constant IC12y = 15817444535197536265760042974536547357049613641401020405817484240883235244599;
    
    uint256 constant IC13x = 10817798312211118469106948201747146553140716159127852666407892748128737684780;
    uint256 constant IC13y = 9640079132978810145395122027090052336229375201492152099812487279972051749393;
    
    uint256 constant IC14x = 4983965811664033427341219128290256188771555731846255742548399584872529220513;
    uint256 constant IC14y = 3403656198455194864564472660976558748875123876502772861523607017999176154167;
    
    uint256 constant IC15x = 9954181872562024105050389462264767165272650566897481325279431250901810915894;
    uint256 constant IC15y = 18155395018629988056878448124507487933894411368952721743152907528966106430472;
    
    uint256 constant IC16x = 2870927223646458695726505360210842316589276907367834357355862123164170990989;
    uint256 constant IC16y = 4488842492888686955399126903928309675265801138820309323070358722258774256487;
    
    uint256 constant IC17x = 17397348924350444060109604218948920627845458656418273845280006679959946267323;
    uint256 constant IC17y = 7238591147031943024229699168206915158466060630273827483993106418826428685120;
    
    uint256 constant IC18x = 10818533108278376591018774784608890240447582813840583831824480492607132502097;
    uint256 constant IC18y = 17721220995704766816398608764867457728839715164016061415085619759715448061391;
    
    uint256 constant IC19x = 13126320541540992789476165375216165076009622614372755237606738224738251375989;
    uint256 constant IC19y = 1073372489868594875595634062089871835220242772350109882810988787513727871907;
    
    uint256 constant IC20x = 13053283833220097718422114001875918855378947546674571190513903683834691113977;
    uint256 constant IC20y = 17250922813742426967883676688971036828194663248397279319524660788972457191032;
    
    uint256 constant IC21x = 11079165480097705178199541653652631721787402362910897474454051559969152502235;
    uint256 constant IC21y = 3644955627516620592638611525615208711494809535202767738677729652164981051567;
    
    uint256 constant IC22x = 15269380634943926877410203780157838974042325863579198082623717117358141625722;
    uint256 constant IC22y = 4598548656446447305686208301693534866482189300960822503007055284176592864109;
    
    uint256 constant IC23x = 4989612948897801439580950679769258881070666477031186532062235620678315224523;
    uint256 constant IC23y = 18968510820148777345920608680655048023921724391194654261750230562429868227513;
    
    uint256 constant IC24x = 11006270521844377647515366992374384748303388455964971584301085617509930294075;
    uint256 constant IC24y = 21085247247246014761843746308823392235602286388066847612445568268443522762547;
    
    uint256 constant IC25x = 10249585213123625365347363852121119236983394600103656845633149993337041980485;
    uint256 constant IC25y = 6780310941569082750389748062617613061926447626568794177941246759987843300717;
    
    uint256 constant IC26x = 2812019224177322847228222782192828246488487026243077741117103668405956479344;
    uint256 constant IC26y = 14568818860430031889635647368673305494870588333940660312333551802842569641840;
    
    uint256 constant IC27x = 5937455970094298035461859685322475940209215091636650608237882074082612776097;
    uint256 constant IC27y = 392803986144429696801454142489272599543203548936111294589785928191710192978;
    
    uint256 constant IC28x = 12622595074133902724188361537403930596109751896482240866240280135595840675356;
    uint256 constant IC28y = 19040226261340121529654332144473319157563288885097166883687967898918963619917;
    
    uint256 constant IC29x = 4323079253288227836010283853080669419119102164681190063833081528630520222985;
    uint256 constant IC29y = 3057265487960823126183978660817762588954418523684906504155299284583147924496;
    
    uint256 constant IC30x = 18710308354449618006404434477434172436771644358736022139969839364751742004985;
    uint256 constant IC30y = 19923883253943301095784009755527185377314609830230002073476218000877939951165;
    
    uint256 constant IC31x = 17794573990190169318369805916665323537662747678357472132004748776312265790238;
    uint256 constant IC31y = 14432243211249986171192886588841607524500412277464907801839081042561938480337;
    
    uint256 constant IC32x = 14906115131149091544849442424701112632634790404337609645966974174048178119683;
    uint256 constant IC32y = 14428794783656342061953415531481004093038029511841183559430438247124181317230;
    
    uint256 constant IC33x = 13203952556351729069364114474586679423558732267827676334255012133673388983809;
    uint256 constant IC33y = 13273321603778309310288952999856741348516729398818481568424565849116580347849;
    
    uint256 constant IC34x = 16817318882497432592919118045369267792914783458800510246720319382758274684915;
    uint256 constant IC34y = 15717110175903393612064227495672009545873643497396925689456562571242097653200;
    
    uint256 constant IC35x = 14779290395696986472737370312911893024300190336327769214927346600242969410160;
    uint256 constant IC35y = 21223648137058646642618298187404341186274612179038686348645632932194014184546;
    
    uint256 constant IC36x = 8785180584386304986000200225495152056430674201483252844552618906947095184973;
    uint256 constant IC36y = 5044122880566204747604793892168496722034400705325365457676877911350482517098;
    
    uint256 constant IC37x = 14209142634858784397432107338083845776758607385043424211325496234174021954235;
    uint256 constant IC37y = 21789983592321596686382217170841214834355107806372353954620595149612544975734;
    
    uint256 constant IC38x = 8992958343578098584534475865669321409857468151062212049461159747945305121874;
    uint256 constant IC38y = 7460994267260107659190810953787952441479449946599914602550371856375766599454;
    
    uint256 constant IC39x = 352212899859087541777039691583357061142867682463375404237166470802152454563;
    uint256 constant IC39y = 21268946585494769877162953982597944495512644077297324418990101215196730344013;
    
    uint256 constant IC40x = 3389941781396391968666486882312729213237415070177673076009796282406790607290;
    uint256 constant IC40y = 2661185728717825082018517672022997179590582169487345703790420257694011043900;
    
    uint256 constant IC41x = 14890095338367381217860417835582091576339104642199333888580560356676352692415;
    uint256 constant IC41y = 9349804734810645987453466888848842805126507782580678397566273763077238911844;
    
    uint256 constant IC42x = 8035316589892805858489630715546773764091020976282485922030655857704884973794;
    uint256 constant IC42y = 3173533046113167024338993684531782837849580151011426166465311902043603108099;
    
    uint256 constant IC43x = 11009157622818472561719318820108517315348222293218051907076742008187990683870;
    uint256 constant IC43y = 2586079756652869499545428751801907981157532387547348198029479977638117355983;
    
    uint256 constant IC44x = 386433093293146918593162157453643181317315000902511384774299162414445227810;
    uint256 constant IC44y = 19579232827607556895366742801046884160810223577750128474235189099658785254768;
    
    uint256 constant IC45x = 2021873675010286068493336484527984902697915937564860100041613907414338068568;
    uint256 constant IC45y = 20263366742938561122445839606608362749343513862800678459368608478630125291879;
    
    uint256 constant IC46x = 5651541532575646286192009289823579980050868954822667523242668146566051493107;
    uint256 constant IC46y = 20443689039678431079737822806231118052049071288441544749598472897726960026135;
    
    uint256 constant IC47x = 19302109329255453494001160406562729295203669722866474571051517587684305031577;
    uint256 constant IC47y = 19383127185427111918455037058386933475724515386056163936727157285952839367178;
    
    uint256 constant IC48x = 11453483338556583829252298692836941593930918050425532419819210709608435359783;
    uint256 constant IC48y = 13493483219347122016527235825831157985755688669639407541608421294106956355190;
    
    uint256 constant IC49x = 9775137554567959599108201462742492417280728825775442911039903437264081848013;
    uint256 constant IC49y = 5186401573682083417872449708203110268679659949530031089554176847146369518796;
    
    uint256 constant IC50x = 20699858940532052321017600379257817326328309221064264117449422842847758581934;
    uint256 constant IC50y = 18569830953386909554972458437860582321153358281782620866444901559814636652863;
    
    uint256 constant IC51x = 1371447945803620435075100001506771578161567043817702431496649040475763554237;
    uint256 constant IC51y = 20491092576626516977727813963555620963784125180112102026036914272188382149027;
    
    uint256 constant IC52x = 8688251083545083774317484666582220456276060505768785203932815439525850455024;
    uint256 constant IC52y = 11340014398595314836666265579824960118847559022216116885958013247555495886561;
    
    uint256 constant IC53x = 3706491109013951008273342140483999154860892347920959851337572905067920704928;
    uint256 constant IC53y = 12826787150328918902266347857799908779384484438173874811232412318025142018504;
    
    uint256 constant IC54x = 7256038130400819503397932234692572339285244085323323561233623175502063187176;
    uint256 constant IC54y = 12765349927979153402765188508938208631696640248853230966536692112518736366233;
    
    uint256 constant IC55x = 9429600332711076303388227896189952515037397842367805873797751183743066819996;
    uint256 constant IC55y = 19402488692855760531221849965193602476304392812592234988176046599435248030943;
    
    uint256 constant IC56x = 17194383905677486472273840247889457484884964075832684951471641526989482602815;
    uint256 constant IC56y = 6114483897188704037168713450435257960112391703721495975463730536586686631927;
    
    uint256 constant IC57x = 9457856957877196262726660092809154546203190526526940265050691597159208316672;
    uint256 constant IC57y = 10562494835764748929699560378508285283111628370818252018932573594444175188761;
    
    uint256 constant IC58x = 19349450842299620630928747155215578393551025119154120235750034027762201944672;
    uint256 constant IC58y = 4673143426743801563272316678436986846770699679617583673545653817022770849317;
    
    uint256 constant IC59x = 17350951458692820952747578034884009244998424348847671484408674204325781268204;
    uint256 constant IC59y = 3186573742139608554916593982749946606627861151600377012489037440865122553853;
    
    uint256 constant IC60x = 14048909472284409523092000078071888553013543666865500846759807939121712970268;
    uint256 constant IC60y = 14700122409754004949989775592432279727723106280679543724040308313876489608024;
    
    uint256 constant IC61x = 3353060901188506802536731946846380122332439731785036176047154545291196782130;
    uint256 constant IC61y = 2090178856087712107154591113584248540802442167566535305235090286331673524159;
    
    uint256 constant IC62x = 3308820441425913606250510215257637769249938012286232129400556349514060300066;
    uint256 constant IC62y = 5136674960036015165773703428178078231556297647945559061354704403291887713569;
    
    uint256 constant IC63x = 15344731357389882293904556757173034227784455589516762552432172538998552490795;
    uint256 constant IC63y = 12886807132835614150117971319039148865218379012612739905441421118605132284892;
    
    uint256 constant IC64x = 8592968807361635919906765005613774776789278788429769334798622239673263849998;
    uint256 constant IC64y = 20989209401677636562107616390488476255654728448090680706473644882884621463753;
    
    uint256 constant IC65x = 21782575625973211204170928529508135629614868710430403621405063740182380451925;
    uint256 constant IC65y = 3205583881237351907044822980607997865991977711137959272339928183220083006323;
    
    uint256 constant IC66x = 8777722692595520881352209055003251595783158109805232494674165070687080906823;
    uint256 constant IC66y = 3855265162554654244146038193125892823461017937666696715937351991707961322288;
    
    uint256 constant IC67x = 20717114912264606416760297643058095045733872195508021690004973156456057673199;
    uint256 constant IC67y = 9181362878860662806306088166283044598236526448032055043736017989806162729290;
    
    uint256 constant IC68x = 17485446378375462175650233714622897563811119221782376463672366922432886824699;
    uint256 constant IC68y = 10724649605779825845807502392185311426576047802459811058732292980159710203513;
    
    uint256 constant IC69x = 17997131797856097544937413212323626073250529707246586399084141413563940972964;
    uint256 constant IC69y = 21232219174791642023736516982381715755978766232168224735658407180310745980818;
    
    uint256 constant IC70x = 15747143747105237790257367212169092108002047393013283700614580993893942439824;
    uint256 constant IC70y = 4574329253726878683316961756138552303925057563654604253339683894837383348047;
    
    uint256 constant IC71x = 15392788969948843629286742458019337829560196726983862118873355788119989718637;
    uint256 constant IC71y = 2061903110113986573231851207963471254558532008686051100370122234717219627312;
    
    uint256 constant IC72x = 264290647253564485939273837934526213750525495594368184285790937779604062672;
    uint256 constant IC72y = 17582000268786147422161669196910731192787800652919246093302499002919856982239;
    
    uint256 constant IC73x = 16566210188974383465577732063429858075010805180315147371521630112092562705274;
    uint256 constant IC73y = 6333967951317764138384747207034268213745340295062735140361500170205193182357;
    
    uint256 constant IC74x = 21225852512649018413374369286470888135660516642290979332979309135209036936359;
    uint256 constant IC74y = 18743878483948598681186143116735797567844067380988758903992716444185697295212;
    
    uint256 constant IC75x = 21028035007250705213435978377891916316134140820737315280246894801040952621188;
    uint256 constant IC75y = 18557708435978035967983227519305407873376246695246346969253580983272619383209;
    
    uint256 constant IC76x = 4401788426706298132573696517417368519863653273339887034822233264248041898658;
    uint256 constant IC76y = 20336761752122946838814289215091664548302032705555587555066687767438107440250;
    
    uint256 constant IC77x = 10743319124586907089376015137858241266574817234461803651557837793689327270234;
    uint256 constant IC77y = 827330118640629197288509438752404460447279129995236445292385527502218113659;
    
    uint256 constant IC78x = 16654564608233894403368083822849813182208702687845393664322852057350239737729;
    uint256 constant IC78y = 9924087947898661183960857878573171255544635761204986711029309271077810511586;
    
    uint256 constant IC79x = 13510397197853251492810719608248485193539553732896710852829747953300585523813;
    uint256 constant IC79y = 11218940799270532329850123274475926258708031587957292832509145853395004228585;
    
    uint256 constant IC80x = 20709661518306869533084130198103898242633325983874437566927672921671815756779;
    uint256 constant IC80y = 3662126585361556127607180993917580834600548690621677266518527253054166006546;
    
    uint256 constant IC81x = 20616395970876986721031273714216786834205352442993226008199916897478082919157;
    uint256 constant IC81y = 13851532017036027582852898984680375333141547169839510815643740254582306797575;
    
    uint256 constant IC82x = 15040515795359409170469057320031698295426036927068473044826830289140594082785;
    uint256 constant IC82y = 7616029468925778112145430553247244685008616241080962975526531594501882258609;
    
    uint256 constant IC83x = 14124291377439087820669573837922930201859510008167941976541063894634785217950;
    uint256 constant IC83y = 6854744010274258141315125741753595783068816413288467931235187446472063112291;
    
    uint256 constant IC84x = 20792059773787887970487935361525509580898773586992699152132210293555705558341;
    uint256 constant IC84y = 5723124177116971844445010411761515321717247082435481599092972091849204816817;
    
    uint256 constant IC85x = 6425492692155978353866312698248210801893845938072729647676028947604271235383;
    uint256 constant IC85y = 12990986037618851003440514287046806920449808271840936005306956306722947181652;
    
    uint256 constant IC86x = 2515994116129226496139638748495572545834829612019793996883622261749420105891;
    uint256 constant IC86y = 17944030710834837185011994217140898906431886586859861940435895010833671010541;
    
    uint256 constant IC87x = 6738082230099175331591153093882858222938770837927250074926583832056836664350;
    uint256 constant IC87y = 20663288340176851306977061352041582476142702605727501062624113922703943845264;
    
    uint256 constant IC88x = 14343837741455755797978283295843677762054311768841795474640763001313197290338;
    uint256 constant IC88y = 4173357623945489664058135511950689095457236015217886111658380103839514140416;
    
    uint256 constant IC89x = 1797079114920278514313884459114423315399936295319876298803965543658945487377;
    uint256 constant IC89y = 8319002599985089981070095995238219245178702837395776284749587179805454147892;
    
    uint256 constant IC90x = 16823205615605609439155597244651660625500634463839810028585142634956240605295;
    uint256 constant IC90y = 11249616246805104967199058908337323031533917146649266313945974109248341177844;
    
    uint256 constant IC91x = 2213591795694488852499573789395890571120112691868207284806303994524380859776;
    uint256 constant IC91y = 16262642979592173253963766991808880847795223690658723235667977999898076650953;
    
    uint256 constant IC92x = 14074992501912123949070976835203165234649130220280470986845257022010165704585;
    uint256 constant IC92y = 2129902778223867969543648511440129794212397463215240958473813719885131077047;
    
    uint256 constant IC93x = 21451335349036151118387109552214496338864951658612699874812463352691694867278;
    uint256 constant IC93y = 9410101729002586502096357813127163940752998866149365158768878058377374556644;
    
 
    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pPairing = 128;

    uint16 constant pLastMem = 896;

    function verifyProof(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[93] calldata _pubSignals) public view returns (bool) {
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
                
                g1_mulAccC(_pVk, IC50x, IC50y, calldataload(add(pubSignals, 1568)))
                
                g1_mulAccC(_pVk, IC51x, IC51y, calldataload(add(pubSignals, 1600)))
                
                g1_mulAccC(_pVk, IC52x, IC52y, calldataload(add(pubSignals, 1632)))
                
                g1_mulAccC(_pVk, IC53x, IC53y, calldataload(add(pubSignals, 1664)))
                
                g1_mulAccC(_pVk, IC54x, IC54y, calldataload(add(pubSignals, 1696)))
                
                g1_mulAccC(_pVk, IC55x, IC55y, calldataload(add(pubSignals, 1728)))
                
                g1_mulAccC(_pVk, IC56x, IC56y, calldataload(add(pubSignals, 1760)))
                
                g1_mulAccC(_pVk, IC57x, IC57y, calldataload(add(pubSignals, 1792)))
                
                g1_mulAccC(_pVk, IC58x, IC58y, calldataload(add(pubSignals, 1824)))
                
                g1_mulAccC(_pVk, IC59x, IC59y, calldataload(add(pubSignals, 1856)))
                
                g1_mulAccC(_pVk, IC60x, IC60y, calldataload(add(pubSignals, 1888)))
                
                g1_mulAccC(_pVk, IC61x, IC61y, calldataload(add(pubSignals, 1920)))
                
                g1_mulAccC(_pVk, IC62x, IC62y, calldataload(add(pubSignals, 1952)))
                
                g1_mulAccC(_pVk, IC63x, IC63y, calldataload(add(pubSignals, 1984)))
                
                g1_mulAccC(_pVk, IC64x, IC64y, calldataload(add(pubSignals, 2016)))
                
                g1_mulAccC(_pVk, IC65x, IC65y, calldataload(add(pubSignals, 2048)))
                
                g1_mulAccC(_pVk, IC66x, IC66y, calldataload(add(pubSignals, 2080)))
                
                g1_mulAccC(_pVk, IC67x, IC67y, calldataload(add(pubSignals, 2112)))
                
                g1_mulAccC(_pVk, IC68x, IC68y, calldataload(add(pubSignals, 2144)))
                
                g1_mulAccC(_pVk, IC69x, IC69y, calldataload(add(pubSignals, 2176)))
                
                g1_mulAccC(_pVk, IC70x, IC70y, calldataload(add(pubSignals, 2208)))
                
                g1_mulAccC(_pVk, IC71x, IC71y, calldataload(add(pubSignals, 2240)))
                
                g1_mulAccC(_pVk, IC72x, IC72y, calldataload(add(pubSignals, 2272)))
                
                g1_mulAccC(_pVk, IC73x, IC73y, calldataload(add(pubSignals, 2304)))
                
                g1_mulAccC(_pVk, IC74x, IC74y, calldataload(add(pubSignals, 2336)))
                
                g1_mulAccC(_pVk, IC75x, IC75y, calldataload(add(pubSignals, 2368)))
                
                g1_mulAccC(_pVk, IC76x, IC76y, calldataload(add(pubSignals, 2400)))
                
                g1_mulAccC(_pVk, IC77x, IC77y, calldataload(add(pubSignals, 2432)))
                
                g1_mulAccC(_pVk, IC78x, IC78y, calldataload(add(pubSignals, 2464)))
                
                g1_mulAccC(_pVk, IC79x, IC79y, calldataload(add(pubSignals, 2496)))
                
                g1_mulAccC(_pVk, IC80x, IC80y, calldataload(add(pubSignals, 2528)))
                
                g1_mulAccC(_pVk, IC81x, IC81y, calldataload(add(pubSignals, 2560)))
                
                g1_mulAccC(_pVk, IC82x, IC82y, calldataload(add(pubSignals, 2592)))
                
                g1_mulAccC(_pVk, IC83x, IC83y, calldataload(add(pubSignals, 2624)))
                
                g1_mulAccC(_pVk, IC84x, IC84y, calldataload(add(pubSignals, 2656)))
                
                g1_mulAccC(_pVk, IC85x, IC85y, calldataload(add(pubSignals, 2688)))
                
                g1_mulAccC(_pVk, IC86x, IC86y, calldataload(add(pubSignals, 2720)))
                
                g1_mulAccC(_pVk, IC87x, IC87y, calldataload(add(pubSignals, 2752)))
                
                g1_mulAccC(_pVk, IC88x, IC88y, calldataload(add(pubSignals, 2784)))
                
                g1_mulAccC(_pVk, IC89x, IC89y, calldataload(add(pubSignals, 2816)))
                
                g1_mulAccC(_pVk, IC90x, IC90y, calldataload(add(pubSignals, 2848)))
                
                g1_mulAccC(_pVk, IC91x, IC91y, calldataload(add(pubSignals, 2880)))
                
                g1_mulAccC(_pVk, IC92x, IC92y, calldataload(add(pubSignals, 2912)))
                
                g1_mulAccC(_pVk, IC93x, IC93y, calldataload(add(pubSignals, 2944)))
                

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
            
            checkField(calldataload(add(_pubSignals, 1568)))
            
            checkField(calldataload(add(_pubSignals, 1600)))
            
            checkField(calldataload(add(_pubSignals, 1632)))
            
            checkField(calldataload(add(_pubSignals, 1664)))
            
            checkField(calldataload(add(_pubSignals, 1696)))
            
            checkField(calldataload(add(_pubSignals, 1728)))
            
            checkField(calldataload(add(_pubSignals, 1760)))
            
            checkField(calldataload(add(_pubSignals, 1792)))
            
            checkField(calldataload(add(_pubSignals, 1824)))
            
            checkField(calldataload(add(_pubSignals, 1856)))
            
            checkField(calldataload(add(_pubSignals, 1888)))
            
            checkField(calldataload(add(_pubSignals, 1920)))
            
            checkField(calldataload(add(_pubSignals, 1952)))
            
            checkField(calldataload(add(_pubSignals, 1984)))
            
            checkField(calldataload(add(_pubSignals, 2016)))
            
            checkField(calldataload(add(_pubSignals, 2048)))
            
            checkField(calldataload(add(_pubSignals, 2080)))
            
            checkField(calldataload(add(_pubSignals, 2112)))
            
            checkField(calldataload(add(_pubSignals, 2144)))
            
            checkField(calldataload(add(_pubSignals, 2176)))
            
            checkField(calldataload(add(_pubSignals, 2208)))
            
            checkField(calldataload(add(_pubSignals, 2240)))
            
            checkField(calldataload(add(_pubSignals, 2272)))
            
            checkField(calldataload(add(_pubSignals, 2304)))
            
            checkField(calldataload(add(_pubSignals, 2336)))
            
            checkField(calldataload(add(_pubSignals, 2368)))
            
            checkField(calldataload(add(_pubSignals, 2400)))
            
            checkField(calldataload(add(_pubSignals, 2432)))
            
            checkField(calldataload(add(_pubSignals, 2464)))
            
            checkField(calldataload(add(_pubSignals, 2496)))
            
            checkField(calldataload(add(_pubSignals, 2528)))
            
            checkField(calldataload(add(_pubSignals, 2560)))
            
            checkField(calldataload(add(_pubSignals, 2592)))
            
            checkField(calldataload(add(_pubSignals, 2624)))
            
            checkField(calldataload(add(_pubSignals, 2656)))
            
            checkField(calldataload(add(_pubSignals, 2688)))
            
            checkField(calldataload(add(_pubSignals, 2720)))
            
            checkField(calldataload(add(_pubSignals, 2752)))
            
            checkField(calldataload(add(_pubSignals, 2784)))
            
            checkField(calldataload(add(_pubSignals, 2816)))
            
            checkField(calldataload(add(_pubSignals, 2848)))
            
            checkField(calldataload(add(_pubSignals, 2880)))
            
            checkField(calldataload(add(_pubSignals, 2912)))
            
            checkField(calldataload(add(_pubSignals, 2944)))
            

            // Validate all evaluations
            let isValid := checkPairing(_pA, _pB, _pC, _pubSignals, pMem)

            mstore(0, isValid)
             return(0, 0x20)
         }
     }
 }
