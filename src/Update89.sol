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

    
    uint256 constant IC0x = 16056621016658544427551151870027459910685890598416235471748283863717160139985;
    uint256 constant IC0y = 5742544942380908582663243216382490863663587865309165558390676545793825109898;
    
    uint256 constant IC1x = 10845810307209971529317306656996361731621049172113989424712780552946225696126;
    uint256 constant IC1y = 2070853522088400125338650761739283859296506424779425014258786555358524800387;
    
    uint256 constant IC2x = 16790658068350771051423201949210928373737373977273510952107867133545001778646;
    uint256 constant IC2y = 19100925771454207843597146713727997327569029284895473322792514175700409648039;
    
    uint256 constant IC3x = 7656767701083305297849753796942732369848656221095663852430873884381287093701;
    uint256 constant IC3y = 19689991084234832368646959380080636982865886081281461675903304219483562854522;
    
    uint256 constant IC4x = 2000727872488639877246439622941211491999349612465394716358909021093589367814;
    uint256 constant IC4y = 9321560659898177104335592727807327259233145185203699719782928634835503423977;
    
    uint256 constant IC5x = 3807326076710298790043841324560373414960029111357139342649526050623839204031;
    uint256 constant IC5y = 13576480329784949457772045505689092052932863227264620572387360078532659234049;
    
    uint256 constant IC6x = 14127415309683984026686022368117762408804311152270034567423974567882330922187;
    uint256 constant IC6y = 13171776100385695046642459223792191737828960241025140659080516997681078828895;
    
    uint256 constant IC7x = 11631724756467050838362921473193179816777352077851380053225637826888871444821;
    uint256 constant IC7y = 15784421325697341110105652754301487258521387330896236642441478585325039678800;
    
    uint256 constant IC8x = 10848923455242171226791009285899262673226973706435928590651962306057699507806;
    uint256 constant IC8y = 9228902690300599008554126525264813863285680936270709868040738313500768038093;
    
    uint256 constant IC9x = 1601716007991318378507392638632616812911326682005288084202104192082473334158;
    uint256 constant IC9y = 8712296532139032156591994389105680258360586648902264446515448466794446155275;
    
    uint256 constant IC10x = 3485994246233982872718362731584380827487786022417326098152895487222081486716;
    uint256 constant IC10y = 13462494214269675966647514723588976265068679107324100588098808716372556603987;
    
    uint256 constant IC11x = 7019750048716872244899516111659206565805686480548074638038087762450518196896;
    uint256 constant IC11y = 20968817079696645719576656576677222240326732418023944044375300913097336351042;
    
    uint256 constant IC12x = 12818990240489796293809304609023364987496031251623663632127855816618588207002;
    uint256 constant IC12y = 17467366308419612363329953587108738258476610622447596506912533137557273836382;
    
    uint256 constant IC13x = 13532425495172031305142617563003968212927130077582887444777338130300915840025;
    uint256 constant IC13y = 15418162440555201556046090758337792582026404631189332037035387065105966945533;
    
    uint256 constant IC14x = 10844839581295168768627262846837439019007660744618081550081756177575330819477;
    uint256 constant IC14y = 15998964616009243223634030525894280982573319693061579916511954551267273622778;
    
    uint256 constant IC15x = 8231773412753873485851947561613508256814061240696614716895835839404536090854;
    uint256 constant IC15y = 3072488541804898033508317181752214934413217937020632333571577820220908454458;
    
    uint256 constant IC16x = 2765940843494046625403105598568134887090389269129663489681840877380956630535;
    uint256 constant IC16y = 18018679983561354245254583176788525652354773596768541865179146840990077826220;
    
    uint256 constant IC17x = 20245915052703176307091731297626625736172333284505128823319548886538457149859;
    uint256 constant IC17y = 16603109385463755859094581279212931163985308183263815475905724447085139859896;
    
    uint256 constant IC18x = 10192034941578341536773586098625977649877408587744169672238572366744844872624;
    uint256 constant IC18y = 6363211508447313943333042314918921221507179629582351012919520402823243419032;
    
    uint256 constant IC19x = 14197130653715631335569956656138983991622029841961651492757130757204180826312;
    uint256 constant IC19y = 16242477186641864395243140704983888867797262920619986908546136185290292463401;
    
    uint256 constant IC20x = 8580220901596500424174940564907545808525544680686235637517218053303970376689;
    uint256 constant IC20y = 13971872216389568735153158696866754047426726330607937364848917909984829840156;
    
    uint256 constant IC21x = 7780830613801851221676496567411223509941842551798448530427277192808323183433;
    uint256 constant IC21y = 1843937302373494079084201757784476863056632906286566540400220317045889427085;
    
    uint256 constant IC22x = 11260318976596143229732707311577961034769909756865858431771273711039788024167;
    uint256 constant IC22y = 16487755026857631085609682977375535871950562933893967373722288201003062060960;
    
    uint256 constant IC23x = 265035855057080264865569036804766708386043492240935987851711537877790232412;
    uint256 constant IC23y = 21317491211383323131474515008804106215705085288211285880050250472078831371165;
    
    uint256 constant IC24x = 1370385846016007261755101197947730774368552974570443506890873125353913966965;
    uint256 constant IC24y = 6195139770690063281703692031734483630865936162256751859388248858748388451943;
    
    uint256 constant IC25x = 17846043066706925245434888629868347370194193712738703415232603366146643927756;
    uint256 constant IC25y = 10377180026786911199128138064706414428517468327495588215110769934006641805617;
    
    uint256 constant IC26x = 14482341754029909352889853986945544101978006366909922920771572524918369392648;
    uint256 constant IC26y = 20935304948118454450942331783585753244494744669203405677680918886490114542046;
    
    uint256 constant IC27x = 12103404459348184656357387577512143505207816485187176312443430149763353303242;
    uint256 constant IC27y = 8945504110908273830599257061624949831916657642420399485575741581279689095560;
    
    uint256 constant IC28x = 4513669295830730431600450254771958286483313770056751502130024861244722222982;
    uint256 constant IC28y = 20018658842597354581859085632332350285349337795709168633591956382506873681685;
    
    uint256 constant IC29x = 12737101885202058517125188071525105799715347647963865369296083372697606687073;
    uint256 constant IC29y = 5947940455415054785133539252289425786298970848602823642247062625888154801105;
    
    uint256 constant IC30x = 21854456785934149150992678271409999480839303932290555253896070346394840182032;
    uint256 constant IC30y = 8437182755484387435918725337879796114249156233179782290797424274859974461749;
    
    uint256 constant IC31x = 11609374519522348559764765738392915626524023200720838883737071687676361692888;
    uint256 constant IC31y = 18105569191511208169614946839173121416958473818548365092877086637795439525522;
    
    uint256 constant IC32x = 10367817145714015122395747970406933146004163331024184576781547113489180041920;
    uint256 constant IC32y = 13096950720378779585005161291791056586494712950602939409801413598693180505900;
    
    uint256 constant IC33x = 13640347903312938286168869053589656561331253764783836836473046441286087344579;
    uint256 constant IC33y = 19402784148802665237362064667960233741554728594339425007127328025532139614690;
    
    uint256 constant IC34x = 21207470804343220723951162020205426989918671081145305716980829195141199705656;
    uint256 constant IC34y = 14528776096050990392607604245222624801522463489605468508596631163342671286820;
    
    uint256 constant IC35x = 20533539048285550149414166025793505496015169168973666382671880089962186173118;
    uint256 constant IC35y = 11201226346588054622595276619325786516487762964441801986080641091975524950743;
    
    uint256 constant IC36x = 16033790030685214120831789263898797507389962381779790367252413261911810627487;
    uint256 constant IC36y = 16574082638124065781417057188433582695144875982533271010305162325504930150906;
    
    uint256 constant IC37x = 4153396830220429501005227197550890448680002391215928893513667037963024979095;
    uint256 constant IC37y = 14074331198030538040157318529616174328199461758242296105654515440471835854447;
    
    uint256 constant IC38x = 15284981086001215974737423561104267378524244605241865024776325318960829617908;
    uint256 constant IC38y = 6573414218483452808657403731413367984881417894099735646673556125796033138263;
    
    uint256 constant IC39x = 7599742578928295525815048949817334135015523077248737242609296596485449278885;
    uint256 constant IC39y = 6624490948003329996852764031079381101870885824059939291124577686310291641243;
    
    uint256 constant IC40x = 21122094910631556703066767651903742006817098745225135529760219840427435592932;
    uint256 constant IC40y = 20041301414617033442034348448763327841527659416078613373431855731949755740646;
    
    uint256 constant IC41x = 15815723305676110083930019318310011660593686831662527278563720184672017517015;
    uint256 constant IC41y = 11780436914965073479980071350160678537166904039038387696753063423089195717890;
    
    uint256 constant IC42x = 578815394166450616606728849792068831553496971865110774793231286520865354609;
    uint256 constant IC42y = 2978117007495105614579567979492250016300349879777330067814035074015821141271;
    
    uint256 constant IC43x = 19419046658583721313450233823045467304753906963787126023559207096194405777212;
    uint256 constant IC43y = 8650100535390821772561662123641018971551813213008164520393695470456981306574;
    
    uint256 constant IC44x = 15798593214922194039526924854058277758605422513049331856665452008567089859530;
    uint256 constant IC44y = 128558010318781896580882077110271818234901339065652225889647371153519280454;
    
    uint256 constant IC45x = 17813867608293429675594552536298308632469010704324628575137222586797459210785;
    uint256 constant IC45y = 7720332568146683958223831793183802375338713518114913941846802565975921324367;
    
    uint256 constant IC46x = 13200062202788726809651783536571125694870365841223656906230825294196412301231;
    uint256 constant IC46y = 2077057509244082604127160570245535041803468056821077381051871007701640113371;
    
    uint256 constant IC47x = 2341215885841252506765460355837855507318805204884590053578846496697345346499;
    uint256 constant IC47y = 3956817919412183420287680365784891886155470482647693346118498622608854656152;
    
    uint256 constant IC48x = 6680742353695615276165682361379324857182360947714728165945988584917854552585;
    uint256 constant IC48y = 13073444775738591116537646223243723313188788187809044657328641673771325213489;
    
    uint256 constant IC49x = 19331071427774735606572223327122120978594903592308634224008300810117479463261;
    uint256 constant IC49y = 20779736661405510396618729747846495161445355471579947887481399053311381818190;
    
    uint256 constant IC50x = 7078319818387476873816414297624914936455946410277096674152843594751646464152;
    uint256 constant IC50y = 18225604578934731017132927906892553228516239227982719935907201054567370694760;
    
    uint256 constant IC51x = 15923294549316134152563744723864583231000034782348398279088855201017612042110;
    uint256 constant IC51y = 7115430418044364522986066631069871755867009568360565416118500504706176682427;
    
    uint256 constant IC52x = 2818762577975959989775022247494583520273788583906150108143614866215253442602;
    uint256 constant IC52y = 14911397262107090256610906876317010655149614335672723262785566216712890781086;
    
    uint256 constant IC53x = 12239809995608674609870112817144800613524568749364031061222413591258467598277;
    uint256 constant IC53y = 18212446035341591087764122043418208586367077895954199569291961659621534077351;
    
    uint256 constant IC54x = 13709089315382745840590170550138537242901662349746909231950768620233474550874;
    uint256 constant IC54y = 4195187458880103764150864516518558229377473788422712618548664452004018366961;
    
    uint256 constant IC55x = 11215950230766421228858675504353383672903665517158992462143994774332117070433;
    uint256 constant IC55y = 13137289644492557492403883835568900799674176019782465299684525858845307136084;
    
    uint256 constant IC56x = 598415818043385856744179502152545660763387583080034468083369072718426217097;
    uint256 constant IC56y = 368548788559306085768499023765231980666974334196348700376591000862982585073;
    
    uint256 constant IC57x = 12381176030429004955851342403204112255921951762103207299941094973155636168199;
    uint256 constant IC57y = 14299925511811447213847490911611360350811278994273236290052095212305108800048;
    
    uint256 constant IC58x = 4510596286321364605020583206513254489418772067944055296651555183205018864778;
    uint256 constant IC58y = 2367255245497426117568114724180520138201675320280666857657254623432892313153;
    
    uint256 constant IC59x = 4549395804268539753401439322388442347345440197632136528211593314619536558304;
    uint256 constant IC59y = 13962633643071944736177181456245992765672927484680697662703954128792330578045;
    
    uint256 constant IC60x = 13714139393451126510723827327440663152922457612606941634290907994363714245985;
    uint256 constant IC60y = 20131041091865310891547584550265955220579261647038376242704547481898157180917;
    
    uint256 constant IC61x = 3776811657843159137026323325213713634103333890652432954014281401197741426921;
    uint256 constant IC61y = 16401820849836600999114251464735885445566580278321809698745237997300111776030;
    
    uint256 constant IC62x = 8048656444044048775119345376373233893864591062770400401451598390844220129578;
    uint256 constant IC62y = 10826618853471479306438026498051171607348020495129749354668293582716810200556;
    
    uint256 constant IC63x = 13212460802097198658030204405915982336393871343836704906108146202514558319302;
    uint256 constant IC63y = 21032121717905858994405005705950921207528574752739133155849182072999175984336;
    
    uint256 constant IC64x = 19475366548427752075037807000057979054541522253526551340662066235019806327436;
    uint256 constant IC64y = 14997553226332338234287565349570730077631348335648763597041423169472367491785;
    
    uint256 constant IC65x = 14493232538208233867738280393338499786124586185405512563275733986411147953555;
    uint256 constant IC65y = 4003998246058977405628495251872303926778409529679150188071233723748208622852;
    
    uint256 constant IC66x = 18855606168246952224681338246753176379104810268032942014620475440538058806811;
    uint256 constant IC66y = 5129139994368368388468548842852651928981208569600979465454137708811524301246;
    
    uint256 constant IC67x = 13650941783494219263397660150257194763176813705753325142457917490301847873938;
    uint256 constant IC67y = 4775775700490555003851377745301526909262683587236696601636116294783719804681;
    
    uint256 constant IC68x = 10258126729571914831216530313408109845142515319779931186047286897003380438721;
    uint256 constant IC68y = 1698490123255661780042451526536263692794463186907862298794299003646822832961;
    
    uint256 constant IC69x = 13239024504277485897619668603141257933014337741626994043049435398508550761305;
    uint256 constant IC69y = 16107467500750721353818169993357657568242159559361095519651025735840040243052;
    
    uint256 constant IC70x = 20512734697697903056494123253041538251518981797318600426026345135939298659606;
    uint256 constant IC70y = 4738611314070127151057956225993636918711789242680510135186495643505948830428;
    
    uint256 constant IC71x = 1471379723876469129719047480711878368428995334717337932517845086457263641837;
    uint256 constant IC71y = 16523502236646813691546579190568303102741682234485313549305664753711081923926;
    
    uint256 constant IC72x = 17589121088060739954087687202182929192590387257529946587673863485166732252099;
    uint256 constant IC72y = 5342544781174834413991409554412630827635590086784128570314560884453295986025;
    
    uint256 constant IC73x = 11508245997628213689849563719531316754634835265358994026772013041539715581730;
    uint256 constant IC73y = 14415752660072170321101038882763207334721563240503157652367105307050866906561;
    
    uint256 constant IC74x = 19836223343147855670883890356222011279082588601157444153839844827756031107720;
    uint256 constant IC74y = 156572899008284409437408448836344265037052504870993572478355694440247874761;
    
    uint256 constant IC75x = 14165467265228263568923648413609951921708227435404969759844219039758405442558;
    uint256 constant IC75y = 9047011874965978215359432475742909414182352802646124785059035621111895801292;
    
    uint256 constant IC76x = 1040625857103961735701905878558877144709831301766455598302625269356231359525;
    uint256 constant IC76y = 1193480627900316162011472321100468065207948158375021728280113577834078151805;
    
    uint256 constant IC77x = 8995134519284137730799424244758619062747518352593234327276645819300944507776;
    uint256 constant IC77y = 15456894926483046641698943698031306918184948488605648115198912887090828782721;
    
    uint256 constant IC78x = 12204159188636213755173613485349507514791896023830659033233346231021771401115;
    uint256 constant IC78y = 13140322843541131619010363885399976136696079697951754388040388373386131273422;
    
    uint256 constant IC79x = 12722504052519930424798510540648979029247668956355875950930209013105521612073;
    uint256 constant IC79y = 3725042903360877690477830514340335749584352688402286838576984555158649844490;
    
    uint256 constant IC80x = 21410392961959260755876831286624717582632961541879258150646361182341605224325;
    uint256 constant IC80y = 20170787533950419984846715007984971734510496009963404690615377865411738188020;
    
    uint256 constant IC81x = 4744840149472268208893573695709071547510100821991177825828273016384627320774;
    uint256 constant IC81y = 21034319190794765962855997121853920006022073447769227770151941916941764807467;
    
    uint256 constant IC82x = 14287010433410346411884830074123903241990063402325405351021768028100228122249;
    uint256 constant IC82y = 10349775237408048568623677075792746980057445064895623293497821312338943778556;
    
    uint256 constant IC83x = 3244476179314205653417374852295885780943539248135312782506979443114091439994;
    uint256 constant IC83y = 8520407651723866469404298687981659005159387529987842535664963282548867221875;
    
    uint256 constant IC84x = 17579734152997818582181335360248201320706253432622215498064681078752973232894;
    uint256 constant IC84y = 17938402626124404942919771622552635544587037994049126084458629449639086011453;
    
    uint256 constant IC85x = 21771195552812740824277535665460244696939654798865263164998231074776726574676;
    uint256 constant IC85y = 9408978163753439276455728020252731829141844725426818454428379367610506033257;
    
    uint256 constant IC86x = 8632355382057649343196077089831207780245805592504990473932916712969081437947;
    uint256 constant IC86y = 20562770075492846738362194108612181422836272225623835208543280266224425174016;
    
    uint256 constant IC87x = 2904923797567191530319929902431813072686187032639835837988107171183970107348;
    uint256 constant IC87y = 16169797266072159872494182890528227406607564126189329540378647791574018278861;
    
    uint256 constant IC88x = 15131496559953890261060230622072324410032047953171991231182600599797137399028;
    uint256 constant IC88y = 11968448187095112253016365996321346359689380955996373429141626016137853148649;
    
    uint256 constant IC89x = 482037699251180799755608139245352069573606889537909782577151833805029889263;
    uint256 constant IC89y = 16128368366233341504502520049644035399829831396836769518798519546602114466691;
    
    uint256 constant IC90x = 9064331622708934110935628028457738380557313654878021724278538967754152189845;
    uint256 constant IC90y = 3871886773532391112114738645372826102036069041337879546515218442039098532980;
    
    uint256 constant IC91x = 3838708183571334540256586794876496444902294966378853043760030026107079729569;
    uint256 constant IC91y = 21359560777273485474858375945185861893239413637857999139896362168450698840008;
    
    uint256 constant IC92x = 1267590403734413526113948024402650529205280998917426235057221398992667477853;
    uint256 constant IC92y = 18891127618777896903265485669726894932992695953664209904229259292220416652529;
    
    uint256 constant IC93x = 9338136003466961916550275609764949627005379439440519028836225986111207736227;
    uint256 constant IC93y = 507045168833417027783100933599372795389583325762849808361725178459017754913;
    
 
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
