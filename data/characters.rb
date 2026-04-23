# ==========================================
# DATA: Character Pools & Rarity
# DESCRIPTION: Defines the VTuber rosters for all banners.
# ==========================================

CHARACTER_POOLS = {
  pool_a: {
    name: '🌐 Western Indies & VShojo Banner',
    characters: {
      common: [
        { name: 'Filian', gif: 'https://media.discordapp.net/attachments/1475889769820192861/1475906142571073709/Filian.full.3794780.png?ex=699f3035&is=699ddeb5&hm=0fa5a3108c7ab2f09cbc25075057215447f0bd7039df1a28dd2ac778cd9bb1f7&=&format=webp&quality=lossless&width=599&height=800' },
        { name: 'Bao', gif: 'https://media.discordapp.net/attachments/1475889769820192861/1475906000530706505/Bao.Vtuber.full.3715040.png?ex=699f3013&is=699dde93&hm=73bc6e60238efd9cee449aba416451af0a3d8d6d2299f24ba57f81e315e906b7&=&format=webp&quality=lossless&width=1421&height=800' },
        { name: 'Silvervale', gif: 'https://media.discordapp.net/attachments/1475889769820192861/1475906146434027550/Silvervale.600.3382388.jpg?ex=699f3036&is=699ddeb6&hm=344ae1a0e630f4473f63487aa2636687951057b5858877fae7ba544fc30f9ca2&=&format=webp&width=750&height=423' },
        { name: 'Zentreya', gif: 'https://media.discordapp.net/attachments/1475889769820192861/1475905997036978319/9735eb3be571a7b355ad43e5c84e1740.jpg?ex=699f3012&is=699dde92&hm=5cad4719732dab191191c17d1f3037c1afc67e355387d171aa9fcb65b32bd1c8&=&format=webp&width=919&height=519' },
        { name: 'Obkatiekat', gif: 'https://media.discordapp.net/attachments/1475889769820192861/1475905996638650421/0bc6e44c-d7ef-46c9-a650-60af46b11ab5_png_9d136497-9c84-459e-af6d-542073d3c03fsharable.png?ex=699f3012&is=699dde92&hm=f69abada94390d8c8cce7acbe4e6a2fbf1c77e6322ad7469f60d3346094b9db7&=&format=webp&quality=lossless&width=1463&height=800' },
        { name: 'Sinder', gif: 'https://media.discordapp.net/attachments/1475889769820192861/1475906145574064310/nanoless-sinder-vtuber-snow-coats-brunette-hd-wallpaper-preview.jpg?ex=699f3036&is=699ddeb6&hm=2cbecf900ae3e42bb6f542e76bd7aca9ea0269be6e2836c153792e5809701b61&=&format=webp&width=910&height=513' },
        { name: 'Trickywi', gif: 'https://media.discordapp.net/attachments/1475889769820192861/1475906141266379076/E-8_UgOXoBQM58Z.png?ex=699f3035&is=699ddeb5&hm=c5853c11c35cf12e25a08b1a64398c590c627bae90a24132423fcf57b5c252a6&=&format=webp&quality=lossless' },
        { name: 'CottontailVA', gif: 'https://media.discordapp.net/attachments/1475889769820192861/1475906002032398386/CottonTailF.png?ex=699f3013&is=699dde93&hm=cf34733a8b26394d8457a089842012b45dd0b5eadc1620bebd1a8c391d5db42c&=&format=webp&quality=lossless&width=1116&height=800' },
        { name: 'Haruka Karibu', gif: 'https://media.discordapp.net/attachments/1475889769820192861/1475906143044898998/haruka-karibu-v0-vfrk3706as4e1.webp?ex=699f3035&is=699ddeb5&hm=e82372d5ab3056ba22edd827f0d756eded667d7fab2c5034b9c1ea3de5496402&=&format=webp&width=566&height=800' },
        { name: 'Kuro Kurenai', gif: 'https://media.discordapp.net/attachments/1475889769820192861/1475905999092187238/b342fcdcd50602e096cc7b5205561522.jpg?ex=699f3013&is=699dde93&hm=954a6a7456add7e97286a679fbafe70857d1777ca689aea51c613e881309ee11&=&format=webp&width=600&height=800' },
        { name: 'GirlDM', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482859498702897344/girldm.png?ex=69b87c06&is=69b72a86&hm=dc26f437be02303594721d2bc9931d0b47130394afaf7905791df41990668ab6&=&format=webp&quality=lossless' },
        { name: 'Squchan', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482859630261436558/squchan.jfif?ex=69b87c26&is=69b72aa6&hm=1ac96ed6696ce7122265d110b470d4e86b8255b2364ee776de39ae8ed68031ad&=&format=webp&width=1198&height=856' },
        { name: 'Buffpup', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482859495871746220/buffpup.jpg?ex=69b87c06&is=69b72a86&hm=d03c0ae68d5308910b5384135b9b32b72d1b6b84ed46ec8b573ec3fb404f817c&=&format=webp&width=554&height=856' },
        { name: 'Nikki Rei', gif: 'https://media.discordapp.net/attachments/1486442109153186042/1486452126363160716/nikki_rei_chromashift_drawn_by_nyori__sample-bfe4c1e954a0adad27f3ff8500a88f6d.jpg?ex=69c58deb&is=69c43c6b&hm=65b3207b4761a0fa51a3e5a3e5a47836c7aacf3b37affb407da64f9b50e23700&=&format=webp&width=679&height=960'},
        { name: 'Sayu Sincronisity', gif: 'https://media.discordapp.net/attachments/1486442109153186042/1486445031152681021/5577600_635381_softiered_untitled-5577600.1d65fef5c07d88516342bcab73d01722.jpg?ex=69c58750&is=69c435d0&hm=2230d0c0609d4d6cbc7a63c662316b4f0ef70882d1f271289d6535e25b0b8309&=&format=webp&width=662&height=960' },
        { name: 'Kuwanano', gif: 'https://media.discordapp.net/attachments/1486442109153186042/1486466812483735612/image03.jpg?ex=69c59b99&is=69c44a19&hm=54a3a51d0271d4d3ae6964447c75e87080603e7da43655c1ed4d91d35119263f&=&format=webp' },
        { name: 'Captain Camille', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494365660367814656/20260326_044709.jpg?ex=69e257f9&is=69e10679&hm=3b24d8a206e200b5440918e35f98385ba192a2a0c37da9b924bc2c5237904a18&=&format=webp&width=930&height=930' },
        { name: 'CherryLemonade', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494365757675536504/20260325_232612.jpg?ex=69e25810&is=69e10690&hm=705b7403847e7f2c4eea1eba6837969b1ea9bd2081e68fe0a0ab0940d0fbabf7&=&format=webp&width=720&height=720' },
        { name: 'Chloe Sakamata', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494366265538511039/20260330_041037.jpg?ex=69e25889&is=69e10709&hm=fe79de8601d8ee218bdf7ee7bb718554e256b9ed03241172a0bf16f4a57b923c&=&format=webp&width=658&height=930' },
        { name: 'Cyno', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494366368794022019/20260331_035359.jpg?ex=69e258a2&is=69e10722&hm=cb6a5f444935b92e913f22aba696df5d9763c58caa7252abce57876668dc1b38&=&format=webp&width=598&height=930' },
        { name: 'Elia Stellaria', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494366476906401853/20260331_052500.jpg?ex=69e258bc&is=69e1073c&hm=19a77dde7684657b2353e378e9e8c12fb5165547a14eef2ab723ca7ac3fb3a8a&=&format=webp&width=1423&height=800' },
        { name: 'FoxPlushy', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494366622440493168/GbX8ZchbgAA-P-f.jpg?ex=69e258de&is=69e1075e&hm=a04b35ec637f60399659885caf955335156a677def7bcef3956e097c78ce596d&=&format=webp&width=1386&height=800' },
        { name: 'Goblin Fia', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494366714207539352/20260331_022724.jpg?ex=69e258f4&is=69e10774&hm=70a7bac138a26890bd9b26c8398af98cf9dfd453a1992412179f79ad24a7e596&=&format=webp&width=1240&height=884' },
        { name: 'Kairyu Crocodile', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494366970668257341/20260331_032209.jpg?ex=69e25931&is=69e107b1&hm=aea47811e2650660ed85fb498f2dcb7fea6f3dcfbec4e450f019b10c018150e9&=&format=webp&width=1423&height=800' },
        { name: 'KittyMina', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494367135642685521/20260401_034736.jpg?ex=69e25959&is=69e107d9&hm=cd86cf962b674911e67007d9cebb4096e119303a510ddf8ead69082c08e93228&=&format=webp&width=1424&height=800' },
        { name: 'Kromia', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494367398617419937/20260331_050403.jpg?ex=69e25997&is=69e10817&hm=66bb877a7858a840d0cccdf5f7c263302f929cce33750b48d8eb1370a5318934&=&format=webp&width=1423&height=800' },
        { name: 'Mina Mischi', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494367506960351262/20260401_032753.jpg?ex=69e259b1&is=69e10831&hm=8b3cb68d18fa3a8f92dd34cfd8a9ddf3f8334be7383a4de5cf73a7c9d3194378&=&format=webp&width=744&height=930' },
        { name: 'MoobooVT', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494367602015867001/20260331_024903.jpg?ex=69e259c8&is=69e10848&hm=c163587326d81936100dc55c26c9a6a07cb6d9e593a06e527abe1da8bcfd700f&=&format=webp&width=558&height=929' },
        { name: 'Froggyloch', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494378393339166951/IMG_3888-1.jpg?ex=69e263d5&is=69e11255&hm=1cbd76080f719dc052a060697c5135778a1ed916a737383a9b75d8896239805d&=&format=webp&width=375&height=538' }
      ],
      rare: [
        { name: 'Shylily', gif: 'https://media.discordapp.net/attachments/1475889769820192861/1475906143846006794/hk4dryof6mtf1.jpeg?ex=699f3035&is=699ddeb5&hm=0c98e6844bcd82f7608abbefb600ed9d085dcfb485132488f41480c4d82ddc36&=&format=webp&width=1195&height=800' },
        { name: 'Nihmune', gif: 'https://media.discordapp.net/attachments/1475889769820192861/1475906141803511940/fhilippe124-commission-final.jpg?ex=699f3035&is=699ddeb5&hm=0786a97762222f681df738434d219d58cf5cd0ec59d4f2dc1a24e3e67a1043a3&=&format=webp&width=1420&height=800' },
        { name: 'Apricot', gif: 'https://media.discordapp.net/attachments/1475889769820192861/1475905997422727249/Apricot.the.Lich.600.3795523.jpg?ex=699f3012&is=699dde92&hm=172c77800e707b2a545c5a10872567cd1e6a31ee53df0ca9a76d4d774a1ab5ee&=&format=webp&width=750&height=530' },
        { name: 'Henya the Genius', gif: 'https://media.discordapp.net/attachments/1475889769820192861/1475906145154629743/light_artist-henya-the-genius-artgift01-by-light-artist.jpg?ex=699f3036&is=699ddeb6&hm=6f8101137f3465bca5e0cf88f4dfc34eb0f6f1e2eee70fd9ba0bd0c084df1346&=&format=webp&width=1421&height=800' },
        { name: 'Kson', gif: 'https://media.discordapp.net/attachments/1475889769820192861/1475906144605311106/Kson.full.3906147.jpg?ex=699f3035&is=699ddeb5&hm=d591d4058fd2e783d3f4e9387f61f00ad4ff465ed772870aa51203e505b895df&=&format=webp&width=576&height=800' },
        { name: 'Veibae', gif: 'https://media.discordapp.net/attachments/1475889769820192861/1475905997905199205/arden-galdones-vshojo-veibae-merch-illustration-lowres.jpg?ex=699f3012&is=699dde92&hm=141624dc3c9b32a82e063612d8c0909cb25902bfdf613e5d290fc090dacfdfd1&=&format=webp' },
        { name: 'Juniper Actias', gif: 'https://media.discordapp.net/attachments/1486442109153186042/1486452669160755341/GgPpgAIWIAAulUk.jfif?ex=69c58e6d&is=69c43ced&hm=641816b0d9826cdb908ebe77fde89e3da3f2ce581e8ab2cac6ff2fbae158ca83&=&format=webp'},
        { name: 'Monarch (AmaLee)', gif: 'https://media.discordapp.net/attachments/1475889769820192861/1475906157569773679/wp15698433.webp?ex=699f3038&is=699ddeb8&hm=b7f907a8df900947318c23d481f5c18808fc9b3980cd4c9e9488f68ea93bf976&=&format=webp&width=1423&height=800' },
        { name: 'Chibidoki', gif: 'https://media.discordapp.net/attachments/1475889769820192861/1475905996130881596/0a5dc010-2156-477e-b897-d9deb9c1fc1e-profile_banner-480.png?ex=699f3012&is=699dde92&hm=046a21cb56344a9022c622de326c2bbee6621c52bb2b3024df449356ec13f1ee&=&format=webp&quality=lossless&width=1066&height=600' },
        { name: 'Hime Hajime', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482859499202023474/himehajime.jpg?ex=69b87c06&is=69b72a86&hm=1dcbd1f5dfe729c6e44b5e09fdfedb76f5688c861def2e3fc7a0ce4c8abd1028&=&format=webp' },
        { name: 'Kumi', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482859521264324758/kumi.jfif?ex=69b87c0c&is=69b72a8c&hm=207a02cbeef7deb5d5f98c03df3adfa3c6b5571bc8b8c5c162138e61cabc2095&=&format=webp&width=1521&height=856' },
        { name: 'Layna Lazar', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482859521780219985/laynalazar.webp?ex=69b87c0c&is=69b72a8c&hm=519e190476aa78bbff568a3fea2c836d694cbf4384abfab04098a9b97bc103d9&=&format=webp&width=497&height=855' },
        { name: 'Kaori Lupine', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494379745134116985/FydSGmTXwAEHsxJ.jpg?ex=69e26517&is=69e11397&hm=c337aa068d8ea97b795981fc68fe50582725964b6362dab04c3aedb93ace3c5f&=&format=webp&width=1093&height=616' },
        { name: 'Chacha', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494379746350334023/58ddad6e-4880-4c2b-9263-c08c1414af6a-profile_banner-480.png?ex=69e26517&is=69e11397&hm=5e6b7dc781d538cae2b736d76693c98a8b03c2f8cab359b19db242bc66895c4b&=&format=webp&quality=lossless&width=1213&height=600' },
        { name: 'CelestaaVT', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494377204082020392/HD4NdqNXwAAwDGX.jfif?ex=69e262b9&is=69e11139&hm=0c93c207087d481d083fcfb63db4b617f8a8d7a5bf3bfbe75b89c331fe97c9ac&=&format=webp&width=658&height=930' },
        { name: 'Atlas Anarchy', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494377610723983481/Atlas_PNG_1.webp?ex=69e2631a&is=69e1119a&hm=131d3fa33de0eef03d3a340a82157307350d89b04d9a8044e9f5ccdecbcc82ee&=&format=webp&width=385&height=590' },
        { name: 'ProjektMomo', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494377881336545482/6817d49e677ba2_51822013.jpg?ex=69e2635b&is=69e111db&hm=6aedb65b6772f0540d48fa1ea62ba29a561c5d5b29d57bc90909fa49363db89f&=&format=webp&width=563&height=563' },
        { name: 'Mimcubus', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494378014845177957/GGALDBpWoAAb9Qa.jpg?ex=69e2637a&is=69e111fa&hm=bc91b8acaeef06bb4b92da69c66c37bff6f8592112635665153c940104905681&=&format=webp&width=1239&height=930' },
        { name: 'Kabhaal', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494378207187570788/Kabaall.webp?ex=69e263a8&is=69e11228&hm=304843f6a16187fa7091c5673e4448d60a8c9bcc664246ebd8259d9384892abf&=&format=webp&width=580&height=486' },
        { name: 'Radia', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494375938195193996/3c93272d-e1cf-44e2-bb13-356976dbb49d-profile_banner-480.png?ex=69e2618b&is=69e1100b&hm=194f90e073c74ba03810255b9753865a67ef785801e030d1773362aee3702897&=&format=webp&quality=lossless&width=1066&height=600' },
        { name: 'MeowMoonified', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494376843380261076/465852225_17946452540872037_7336535501276113320_n.jpg?ex=69e26263&is=69e110e3&hm=2347e1847f3d9842585c8edcd8c840f84c1d211c247c4bd127f1653414ed8a27&=&format=webp&width=1423&height=800' },
        { name: 'Skiddosaurus Rex', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494369320464285837/20260330_044752.jpg?ex=69e25b62&is=69e109e2&hm=1b577c33c42024cd92adb4693f0e141c3221799ae686ba18394299a0fac121c6&=&format=webp&width=750&height=930' },
        { name: 'Totless', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494369456112013576/20260331_035011.jpg?ex=69e25b82&is=69e10a02&hm=c44f635d9d38d2c97a1cfd998f0da1f18d7dfb42152f1fe42b734606b891b4c8&=&format=webp&width=433&height=930' },
        { name: 'Undyne Arashi', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494369551775961178/20260330_045632.jpg?ex=69e25b99&is=69e10a19&hm=bb8ebf6b777aafb127a99d2b4454fab36e3add257796e9f104d48061ea5382c3&=&format=webp&width=724&height=930' },
        { name: 'MooMooClover', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494375632568582245/Screenshot_2026-04-16_123447.png?ex=69e26142&is=69e10fc2&hm=4f9cecce16c09331b76e39b517e0380873b8e6beaa6ec248f1a49da4a26411ec&=&format=webp&quality=lossless&width=1503&height=800' }
      ],
      legendary: [
        { name: 'Ironmouse', gif: 'https://media.discordapp.net/attachments/1475889769820192861/1475935719846445293/CollabCafe-1024x576.png?ex=699f4bc1&is=699dfa41&hm=f387f1b170955e07f479453c2d318c8a244862e26ab892bceb28cc1c7830917c&=&format=webp&quality=lossless&width=1280&height=720' },
        { name: 'Nyanners', gif: 'https://media.discordapp.net/attachments/1475889769820192861/1475905998542606408/b58caa30-643b-4c5d-be1c-5dbac45c7af9_nyah2.jpg?ex=699f3013&is=699dde93&hm=7043c68b94244b02d8aa2187de90167237f6c3fb9eb3692860bcd5f70f901134&=&format=webp&width=975&height=673' },
        { name: 'Snuffy', gif: 'https://media.discordapp.net/attachments/1475889769820192861/1475906147092267049/Snuffy_Swimsuit_Outfit_Icon.webp?ex=699f3036&is=699ddeb6&hm=4be3bc13db7a6dddd7b4c680d5237564dd6e8a8feedc54fe97e01c626608906d&=&format=webp&width=800&height=800' },
        { name: 'Projekt Melody', gif: 'https://media.discordapp.net/attachments/1475889769820192861/1475906001340469313/cb7ff336-3108-4b37-8786-666d90afa5ca-profile_banner-480.png?ex=699f3013&is=699dde93&hm=71e0ac911cbbe52094aca7960a38b782cc07ed8e62c562e4e9395765389253c4&=&format=webp&quality=lossless&width=1066&height=600' },
        { name: 'Lord Aethelstan', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482864892380709056/FXuTh84UcAQCzsp.jfif?ex=69b8810c&is=69b72f8c&hm=b56ad473b9ec7f66fab6f056d22a7a7b42f05f3487640408e0c2a3e9e19f644c&=&format=webp&width=621&height=960' },
        { name: 'Nuxanor', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482859611689324544/nuxanor.png?ex=69b87c21&is=69b72aa1&hm=f251d5ca85621812ee6815c53a51303b8187ddbd1a330da1403ffd5e4c22b1c1&=&format=webp&quality=lossless&width=1521&height=856' },
        { name: 'Geega', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482859497855783092/geega.webp?ex=69b87c06&is=69b72a86&hm=888a0636c3d32800457c9a98405363786434a57d7dbba46aef3af30d4cfc4c4e&=&format=webp&width=1525&height=856' },
        { name: 'Ai Candii', gif: 'https://media.discordapp.net/attachments/1486442109153186042/1486452846462374062/tzge5remb5mg1.png?ex=69c58e97&is=69c43d17&hm=554af1b5fdafba4a2e3fdae87f32c9c557e2470810ed40ef62cca1656b6c1ce4&=&format=webp&quality=lossless&width=679&height=960'},
        { name: 'Vienna', gif: 'https://media.discordapp.net/attachments/1486442109153186042/1486451753028157550/E9K9F6_XsAIBVeF.jpg?ex=69c58d92&is=69c43c12&hm=33dfead3c6b061677bf707bc066bb5640a8f4740bd1dc9d4f77b602d509eab16&=&format=webp'},
        { name: 'DokiDoMiki', gif: 'https://media.discordapp.net/attachments/1475890017443516476/1487170776909217912/20260327_152501.jpg?ex=69cb76f7&is=69ca2577&hm=71e076a4d33f8a3ea356ce14f6cca1b3363cf3d4cf8b5e051af8a58d55e30678&=&format=webp&width=661&height=960'},
        { name: 'Pupuna Mai', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494368859082195047/20260330_050634.jpg?ex=69e25af4&is=69e10974&hm=a1725148c4f66d2ac5315d58dff330fb35e7001cdc61d24caec8fbec3c482822&=&format=webp&width=1423&height=800' },
        { name: 'Rei Stingray', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494368950857760878/20260331_025751.jpg?ex=69e25b09&is=69e10989&hm=c0e4d356ce8ab80edf37b63d13cd30329270388c1817adaacf2c1a97c8c6c62b&=&format=webp&width=1424&height=800' },
        { name: 'Ririsya', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494369067572924416/20260331_031243.jpg?ex=69e25b25&is=69e109a5&hm=b29c98fed189c5beff7b66d2dedab032abc95b86f31e245acf7fb358ae476c65&=&format=webp&width=676&height=929' },
        { name: 'Sagiki Ihori', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494369191191384285/20260330_044120.jpg?ex=69e25b43&is=69e109c3&hm=98f47c92d9d60b6f43bb8a4f48472a53afa639f368733fef683a34ac84164462&=&format=webp&width=1196&height=930' },
        { name: 'MysticLight', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494367715014611086/20260331_072400.jpg?ex=69e259e3&is=69e10863&hm=4ce7d1588186fa7ac152b4f1d4c96af70cee3fb1a55d839a179f48f1ecad3124&=&format=webp&width=908&height=930' },
        { name: 'Platinum Meg', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494367835588132874/20260401_043901.jpg?ex=69e25a00&is=69e10880&hm=c1eb80707c20fbfb85778ebef45630ac48f3c556d9552a97c98920b11e88ea28&=&format=webp&width=658&height=930' },
        { name: 'PeachyPill', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494368756892172298/GupsdsOXwAAijzV.png?ex=69e25adb&is=69e1095b&hm=52441d56c93653626df9d475b2bf2ce5cdfd1de181db132cb01918b06877785b&=&format=webp&quality=lossless&width=819&height=689' },
        { name: 'Ravennanya', gif: 'https://media.discordapp.net/attachments/1494986646339190804/1494986701154816131/Gi4rBtfXwAAUxeE.jfif?ex=69e9379d&is=69e7e61d&hm=0fa65ff6cc2e6883feeb416f3987c0f99e9be842b389839906329569c0d63416&=&format=webp&width=785&height=779' },
        { name: 'Megalodon', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494379745595625702/megalodonvt-v0-5o51ox242jde1.webp?ex=69e26517&is=69e11397&hm=a8b99868b0cd89974d74e18fa9a2806906cc4805c3583db3bb730bcd87a87a26&=&format=webp&width=800&height=565' },
        { name: 'MOTHERv3', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494378826455584880/G6FBgvhXsAAfTae.jpg?ex=69e2643c&is=69e112bc&hm=ac4959a2b79bc891f13865329c0cfec65c6f962df39241b261da545ac30c9d03&=&format=webp&width=1219&height=930' }
      ],
      goddess: [
        { name: 'baonuki', gif: 'https://media.discordapp.net/attachments/1475890017443516476/1476339091653005312/Gemini_Generated_Image_z3jz8tz3jz8tz3jz.png?ex=69c8f92c&is=69c7a7ac&hm=a4d0f680da0d16822ff5177df63bc2afee74ad1c017c36b04eee6587480c2f52&=&format=webp&quality=lossless&width=747&height=960' },
        { name: 'Blossom', gif: 'https://media.discordapp.net/attachments/1475890017443516476/1485555394532343818/Gemini_Generated_Image_grwxaagrwxaagrwx.png?ex=69c24ac6&is=69c0f946&hm=e045c4d593d17ce8999f0a611c708d9fe0c5377072a87c32482912e323fa11ac&=&format=webp&quality=lossless&width=600&height=960' },
        { name: 'Cweamcat', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1485887383265218580/HD3ZWDMXIAIjPfU.jfif?ex=69c428b6&is=69c2d736&hm=93d7090dfa304ff1c66c05dd53d9a7abbc102ef50e12a3fc86eac7aa11392216&=&format=webp&width=640&height=960'},
        { name: 'Cheriyfu', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1485852371027361812/share.jpg?ex=69c4081b&is=69c2b69b&hm=6f80c8ec2558a31e206770da13d1158a6a7a39c35a7b2a2e0bbbb6449f19be13&=&format=webp'},
        { name: 'little nii', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1485851144910540951/GsAf3WhXIAAM0gm.jfif?ex=69c406f6&is=69c2b576&hm=0ac4ebeb7a2db81a3061ea7cdc1338356ee8686bf8ffc459c3707d226c07c827&=&format=webp&width=1280&height=960'},
        { name: 'Hexchu', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1485852140873187389/f6097bce-bf5e-4b24-a01d-e35864faaba6_shygb.png?ex=69e25a64&is=69e108e4&hm=7f08871be26639d93397e86407e8b9ad95ebafc9235ef988a94ff61892cc30bc&=&format=webp&quality=lossless&width=975&height=759'},
        { name: 'baonuki', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494370178719289616/Gemini_Generated_Image_yjaqkzyjaqkzyjaq.png?ex=69e25c2e&is=69e10aae&hm=737d70183bec93737f1a51a2480e8c92ac3b79d3c5902f10e38a19941c0c91ee&=&format=webp&quality=lossless&width=1436&height=800'},
        { name: 'Katoh Eli', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494378681681055934/481204457_610534128501579_2237011361763406195_n.jpg?ex=69e26419&is=69e11299&hm=97c4eccae2e652ce606fc474a729fda54bfdf27895703b01875b8c0204c3e711&=&format=webp&width=1348&height=800'},
        { name: 'Megrocks.exe', gif: 'https://media.discordapp.net/attachments/1494986646339190804/1494986756628418561/G1W7B9sXcAApWWp.jfif?ex=69e937aa&is=69e7e62a&hm=ae4dd8a35c1c8cc98ca97c0a6dd6148b758ad971b35b3dac9a9074598ec474f7&=&format=webp&width=795&height=779'},
        { name: 'Suko', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1486442609265213601/Suko15.webp?ex=69c5850e&is=69c4338e&hm=98235b0b2d953a8db322c692ad92b38f0d360c87cb05c7c1930174a3fac5cd23&=&format=webp&width=594&height=960'},
        { name: 'Robopup', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1486814336675614831/ab67616d0000b2734fd48b59a6debf9ebfe2222b.jfif?ex=69c8d981&is=69c78801&hm=5453a5b13bf367faef56a5e5e384e588f55c8fd6643cdf9ebe10bc340f6b5fe8&=&format=webp'},
        { name: 'Mika Akakuma', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1486482338031603762/1500x500.jfif?ex=69c8f5ce&is=69c7a44e&hm=c3ed815fd9bdb2461f62256870512ecc3a387c000ed1ea0c1f1fea8811a66fe1&=&format=webp'}
      ]
    }
  },
  pool_b: {
    name: '🌸 Hololive & Nijisanji Banner',
    characters: {
      common: [
        { name: 'Elira Pendora', gif: 'https://media.discordapp.net/attachments/1475906261533851768/1475938363319259428/Elira.Pendora.600.3788087.jpg?ex=699f4e37&is=699dfcb7&hm=c81b504c3259443d20f46bedf6d9ed5e113184f22e0f199404fdfc53231eaeb0&=&format=webp&width=750&height=511' },
        { name: 'Finana Ryugu', gif: 'https://media.discordapp.net/attachments/1475906261533851768/1475938364942192673/Finana.Ryugu.600.3334984.jpg?ex=699f4e37&is=699dfcb7&hm=d960df4ee102925deeb25791d3da3fd0044e1312027057f17ea89167963bd617&=&format=webp&width=750&height=423' },
        { name: 'Pomu Rainpuff', gif: 'https://media.discordapp.net/attachments/1475906261533851768/1475941147322093721/PomuRainpuff.jpg?ex=699f50cf&is=699dff4f&hm=730ba603cfda4342c6acf950a90b767af3ca978a92dc1f7866358b794fd4dca0&=&format=webp&width=966&height=543' },
        { name: 'Rosemi Lovelock', gif: 'https://media.discordapp.net/attachments/1475906261533851768/1475941146986545153/rosemi_lovelock_by_29292ni_deptprc-fullview.jpg?ex=699f50cf&is=699dff4f&hm=ee3b6152abc7444e7c3ea992a90df67a56490093f4d5404f66aec5bbebd9fb50&=&format=webp&width=831&height=543' },
        { name: 'Enna Alouette', gif: 'https://media.discordapp.net/attachments/1475906261533851768/1475941146571178134/EnnaAlouette.jpg?ex=699f50cf&is=699dff4f&hm=4bed3d27f51db14bf01f5ec66a583f26c6d1d0e6569dfda5a1f8d1395c407f95&=&format=webp&width=769&height=544' },
        { name: 'Millie Parfait', gif: 'https://media.discordapp.net/attachments/1475906261533851768/1475941146097094657/Millie.Parfait.600.3549930.jpg?ex=699f50ce&is=699dff4e&hm=3cb5afffef9ec6e4265ea8997c26fdd38f5f7bd87e2531dbf6e5da32e9521513&=&format=webp' },
        { name: 'Luca Kaneshiro', gif: 'https://media.discordapp.net/attachments/1475906261533851768/1475941145530990633/HD-wallpaper-anime-virtual-youtuber-luca-kaneshiro-luxiem.jpg?ex=699f50ce&is=699dff4e&hm=3e25a60a2ad77f5976ef60c0de1e830d389bb19d8d3e33bb51a966872f843144&=&format=webp' },
        { name: 'Shu Yamino', gif: 'https://media.discordapp.net/attachments/1475906261533851768/1475941144985862278/ShuYamino.jpg?ex=699f50ce&is=699dff4e&hm=c7b115aefd38732dfeb79a082759624fb76c53a7ff8f5d417a0f43a97c5a6765&=&format=webp&width=797&height=544' },
        { name: 'Oliver Evans', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482859612024602775/oliverevans.webp?ex=69b87c21&is=69b72aa1&hm=af1596f875a8667f24e433b1fd0e92c9446dc4843583cb35e2042005ec7204a7&=&format=webp' },
        { name: 'Nina Kosaka', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482859523382181950/ninakousaka.webp?ex=69b87c0c&is=69b72a8c&hm=eef47ccfedd525a7cbc54f44d1bfd9369867a6c4e05d709f33880b3ce3a1311f&=&format=webp' },
        { name: 'Scarle Yonaguni', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482859614684057731/scarle.webp?ex=69b87c22&is=69b72aa2&hm=eeb7c834f8f36b8bbda8fdd7050dfaf6add2e7af2f983ecae53ddccdc7acedb7&=&format=webp' },
        { name: 'Petra Gurin', gif: 'https://media.discordapp.net/attachments/1486442109153186042/1486450612416811288/Petra_Gurin_Lore_Illustration.webp?ex=69c58c82&is=69c43b02&hm=4f0d82da880a875e5e1eea766c31078cfdb4641998472095e0b6ddd0fafc6e52&=&format=webp'},
        { name: 'Reimu Endou', gif: 'https://media.discordapp.net/attachments/1486442109153186042/1486449970704810004/maxresdefault_1.jpg?ex=69c58be9&is=69c43a69&hm=e4094a8a74a0273fc7ab94ee62623ba8f81b34285f861410eec1fabebfeaf233&=&format=webp'}
      ],
      rare: [
        { name: 'Hoshimachi Suisei', gif: 'https://media.discordapp.net/attachments/1475906261533851768/1475938363956658248/fbf9d6edb0e65fd538a931dd4047fd52.jpg?ex=699f4e37&is=699dfcb7&hm=715a15170a3b303acc00dde50d0aa477da58c64769078147d82ef4844602fdd7&=&format=webp&width=750&height=494' },
        { name: 'Shirakami Fubuki', gif: 'https://media.discordapp.net/attachments/1475906261533851768/1475938366947065856/HD-wallpaper-anime-virtual-youtuber-shirakami-fubuki.jpg?ex=699f4e38&is=699dfcb8&hm=ba40afc03ebb8fd14a06c1a0bbbc999450508fa450894d00b05be785c782c2ea&=&format=webp&width=961&height=680' },
        { name: 'Kobo Kanaeru', gif: 'https://media.discordapp.net/attachments/1475906261533851768/1475938367983063213/Kobo.Kanaeru.600.3723600.jpg?ex=699f4e38&is=699dfcb8&hm=df5f4bfe4dcbcc6e237f17049b07f1039ae82469570742f8c008ea1a534768e1&=&format=webp&width=750&height=498' },
        { name: 'Vox Akuma', gif: 'https://media.discordapp.net/attachments/1475906261533851768/1475938362861948958/1271665.jpg?ex=699f4e37&is=699dfcb7&hm=db21815b603c551756b3bbe01f8f54bd4e634d664ee89d726ee9d9548587899d&=&format=webp&width=961&height=680' },
        { name: 'Ouro Kronii', gif: 'https://media.discordapp.net/attachments/1475906261533851768/1475943955748094162/OuroKronii.jpg?ex=699f536c&is=699e01ec&hm=46ceea51f7f8d62c13db325892791982db01796ed749097b074b0df52acb41c9&=&format=webp&width=653&height=544' },
        { name: 'Nanashi Mumei', gif: 'https://media.discordapp.net/attachments/1475906261533851768/1475943954946986065/NanashiMumei.jpg?ex=699f536c&is=699e01ec&hm=166a0e67edec3e20fcd17b68a0b5453eea54a1770bb255a7a4c4acf005a07e8c&=&format=webp&width=966&height=543' },
        { name: 'Hakos Baelz', gif: 'https://media.discordapp.net/attachments/1475906261533851768/1475943954582212772/HakosBaelz.png?ex=699f536c&is=699e01ec&hm=9fa4ab957e9cf3094c4d15e90e111b51a2f009881ade94aadc4717c879c09f9c&=&format=webp&quality=lossless&width=966&height=543' },
        { name: 'Ike Eveland', gif: 'https://media.discordapp.net/attachments/1475906261533851768/1475943954045337650/IkeEveland.jpg?ex=699f536c&is=699e01ec&hm=cdb5309d642d0f1c2d61caafd6d77d8cb48744ae197aaa43a8d2e3ded60430bf&=&format=webp' },
        { name: 'Mysta Rias', gif: 'https://media.discordapp.net/attachments/1475906261533851768/1475943953533636649/MystaRias.jpg?ex=699f536c&is=699e01ec&hm=dfa34231f1f996b2264a975eb5561beb0ce89a965eb0bbbb66b1688722a3b340&=&format=webp' },
        { name: 'Ninomae Inanis', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482859611152449657/Ninomae-Inanis.webp?ex=69b87c21&is=69b72aa1&hm=3387b1ceaf396d58e9cf5a33f6ff21d7257170985d392286b2b2b485329ae841&=&format=webp' },
        { name: 'Watson Amelia', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482859631511605318/watsonamelia.jpg?ex=69b87c26&is=69b72aa6&hm=32ed4b5c42850e2ed49c0cf81480f725a6b7587a5758ea18dc7d85862f2192ed&=&format=webp' },
        { name: 'Selen Tatsuki', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482859614994169977/selentatsuki.webp?ex=69b87c22&is=69b72aa2&hm=6b332ee928519b98b589b5ec645dc5ea8eddde0d080268883a4a3969ca2f4154&=&format=webp' },
        { name: 'Aster Arcadia', gif: 'https://media.discordapp.net/attachments/1486442109153186042/1486449772486197318/thumb-1920-1265724.jpg?ex=69c58bba&is=69c43a3a&hm=2a9199102da9618256f24c6a97bacdd0490f3774aeb4c1dbe7e76077a4c4b986&=&format=webp&width=1356&height=960'},
        { name: 'Maria Marionette', gif: 'https://media.discordapp.net/attachments/1486442109153186042/1486449637534601256/Maria.Marionette.full.3922760.png?ex=69c58b9a&is=69c43a1a&hm=920aac1dc39ea723410f89e1d6d42d1801a4d1181b6066fdb93c71d6fdefbdfa&=&format=webp&quality=lossless&width=690&height=960'},
        { name: 'Natsuiro Matsuri', gif: 'https://media.discordapp.net/attachments/1486442109153186042/1486447697685909594/Natsuiro_Matsuri_Between_a_Tease_and_a_Lap_Pillow_Which_One_do_You_Like_ASMR_Voice_Pack_Key_Visual_by_Jiwoo_Owo9.webp?ex=69c589cb&is=69c4384b&hm=2c6de9ce01f1011873d72de533b2d6618fa8f5ce300d956e76ec24aacbcb8d04&=&format=webp'}
      ],
      legendary: [
        { name: 'Gawr Gura', gif: 'https://media.discordapp.net/attachments/1475906261533851768/1475938365806481428/flat750x075f-pad750x1000f8f8f8.jpg?ex=699f4e38&is=699dfcb8&hm=4f5d5e7adc7ec6dc2dcffbfd8e57eba422a79bac25c0091a9cabd706b895e929&=&format=webp&width=510&height=680' },
        { name: 'Houshou Marine', gif: 'https://media.discordapp.net/attachments/1475906261533851768/1475943953013412014/HoushouMarine.jpg?ex=699f536c&is=699e01ec&hm=539b5b6b941443aad2c12d0f6e227169222c03aec310828f47e75ec24a7b91cc&=&format=webp&width=769&height=544' },
        { name: 'Kuzuha', gif: 'https://media.discordapp.net/attachments/1475906261533851768/1475938368582844436/Kuzuha-Nijisanji-VTuber-tops-charts.jpg?ex=699f4e38&is=699dfcb8&hm=cecf434b0e7c8b78f44a28eb87d3783bd50cb899e77c39909d4f629bae0e9c7b&=&format=webp&width=1208&height=679' },
        { name: 'Kizuna AI', gif: 'https://media.discordapp.net/attachments/1475906261533851768/1475938370537652326/thumb-1920-904634.jpg?ex=699f4e39&is=699dfcb9&hm=b9e4deb40be13cac638b762b632fb813c0d78666d63b0da4290df5f2368fce5e&=&format=webp&width=869&height=680' },
        { name: 'Mori Calliope', gif: 'https://media.discordapp.net/attachments/1475906261533851768/1475938369530761318/soho-2.jpg?ex=699f4e38&is=699dfcb8&hm=3f2200456052531e049b6b7735035d711ac0ec6461723c139ed8f662aada1297&=&format=webp&width=1115&height=680' },
        { name: 'Usada Pekora', gif: 'https://media.discordapp.net/attachments/1475906261533851768/1475943952321482812/UsadaPekora.jpg?ex=699f536b&is=699e01eb&hm=9349a07fcee33f1b3823999a3f82e9a2318c8c9faa216a7ffa2482e1669a89b3&=&format=webp' },
        { name: 'Inugami Korone', gif: 'https://media.discordapp.net/attachments/1475906261533851768/1475943951302393856/InugamiKorone.png?ex=699f536b&is=699e01eb&hm=cf5612517aeb458d853557320257ae6a93a19ced29562595168392ed9367e9bc&=&format=webp&quality=lossless&width=966&height=543' },
        { name: 'Tokino Sora', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482859630693712043/tokinosora.png?ex=69b87c26&is=69b72aa6&hm=a4ebbbe7fca72fbb58bf7c377253e3f42e4f5db8abf2353873419ee392ce8d5e&=&format=webp&quality=lossless&width=1521&height=856' },
        { name: 'Takanashi Kiara', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482859520525860988/kiara.jpeg?ex=69b87c0b&is=69b72a8b&hm=d1410f8b24a5ee74a469661d9980da9d935f632dff4774b5842ffcb422f665bf&=&format=webp&width=685&height=856' },
        { name: 'Sakura Miko', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482859614344315081/sakuramiko.jpg?ex=69b87c22&is=69b72aa2&hm=7938e4d7dedecded7bc2019f87efe24c92e399a8d196067da5c0cc398b7d81cb&=&format=webp&width=684&height=856' },
        { name: 'Kyo Kaneko', gif: 'https://media.discordapp.net/attachments/1486442109153186042/1486449298970247360/1283512.jpg?ex=69c58b49&is=69c439c9&hm=fe1ddc8b005028df061a619c0530dbb3c658db9480175a763b156f508caab709&=&format=webp&width=1522&height=856'},
        { name: 'Vestia Zeta', gif: 'https://media.discordapp.net/attachments/1486442109153186042/1486449025291915416/Vestia_Zeta_2023_Birthday_Merch_Illustration_by_Arutera.webp?ex=69c58b08&is=69c43988&hm=481d227681c2d4c92ca4e2d8148cb2ab185e9124ae6054d60458317e332042da&=&format=webp&width=672&height=960'},
        { name: 'Minato Aqua', gif: 'https://media.discordapp.net/attachments/1486442109153186042/1486447970386710528/interview-minato-aqua-talks-about-her-visual-novel-aquarium-1.webp?ex=69c58a0d&is=69c4388d&hm=c9d0283a60f4319a29da35040a0bda6a09ec23591d716e2136825ca334fd5c39&=&format=webp' },
        { name: 'Hyakumantenbara Salome', gif: 'https://media.discordapp.net/attachments/1486442109153186042/1486447066321260825/thumb-1920-1290058.png?ex=69c58935&is=69c437b5&hm=1866ae5824b2efb974d84c34c9f9b3b27770c04c5e6be144adf25b0b719317cb&=&format=webp&quality=lossless&width=1152&height=960'}
      ],
      goddess: [
        { name: 'baonuki', gif: 'https://media.discordapp.net/attachments/1475890017443516476/1476339091653005312/Gemini_Generated_Image_z3jz8tz3jz8tz3jz.png?ex=69c8f92c&is=69c7a7ac&hm=a4d0f680da0d16822ff5177df63bc2afee74ad1c017c36b04eee6587480c2f52&=&format=webp&quality=lossless&width=747&height=960' },
        { name: 'Blossom', gif: 'https://media.discordapp.net/attachments/1475890017443516476/1485555394532343818/Gemini_Generated_Image_grwxaagrwxaagrwx.png?ex=69c24ac6&is=69c0f946&hm=e045c4d593d17ce8999f0a611c708d9fe0c5377072a87c32482912e323fa11ac&=&format=webp&quality=lossless&width=600&height=960' },
        { name: 'Cweamcat', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1485887383265218580/HD3ZWDMXIAIjPfU.jfif?ex=69c428b6&is=69c2d736&hm=93d7090dfa304ff1c66c05dd53d9a7abbc102ef50e12a3fc86eac7aa11392216&=&format=webp&width=640&height=960'},
        { name: 'Cheriyfu', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1485852371027361812/share.jpg?ex=69c4081b&is=69c2b69b&hm=6f80c8ec2558a31e206770da13d1158a6a7a39c35a7b2a2e0bbbb6449f19be13&=&format=webp'},
        { name: 'little nii', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1485851144910540951/GsAf3WhXIAAM0gm.jfif?ex=69c406f6&is=69c2b576&hm=0ac4ebeb7a2db81a3061ea7cdc1338356ee8686bf8ffc459c3707d226c07c827&=&format=webp&width=1280&height=960'},
        { name: 'Hexchu', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1485852140873187389/f6097bce-bf5e-4b24-a01d-e35864faaba6_shygb.png?ex=69e25a64&is=69e108e4&hm=7f08871be26639d93397e86407e8b9ad95ebafc9235ef988a94ff61892cc30bc&=&format=webp&quality=lossless&width=975&height=759'},
        { name: 'baonuki', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494370178719289616/Gemini_Generated_Image_yjaqkzyjaqkzyjaq.png?ex=69e25c2e&is=69e10aae&hm=737d70183bec93737f1a51a2480e8c92ac3b79d3c5902f10e38a19941c0c91ee&=&format=webp&quality=lossless&width=1436&height=800'},
        { name: 'Katoh Eli', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494378681681055934/481204457_610534128501579_2237011361763406195_n.jpg?ex=69e26419&is=69e11299&hm=97c4eccae2e652ce606fc474a729fda54bfdf27895703b01875b8c0204c3e711&=&format=webp&width=1348&height=800'},
        { name: 'Megrocks.exe', gif: 'https://media.discordapp.net/attachments/1494986646339190804/1494986756628418561/G1W7B9sXcAApWWp.jfif?ex=69e937aa&is=69e7e62a&hm=ae4dd8a35c1c8cc98ca97c0a6dd6148b758ad971b35b3dac9a9074598ec474f7&=&format=webp&width=795&height=779'},
        { name: 'Suko', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1486442609265213601/Suko15.webp?ex=69c5850e&is=69c4338e&hm=98235b0b2d953a8db322c692ad92b38f0d360c87cb05c7c1930174a3fac5cd23&=&format=webp&width=594&height=960'},
        { name: 'Robopup', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1486814336675614831/ab67616d0000b2734fd48b59a6debf9ebfe2222b.jfif?ex=69c8d981&is=69c78801&hm=5453a5b13bf367faef56a5e5e384e588f55c8fd6643cdf9ebe10bc340f6b5fe8&=&format=webp'},
        { name: 'Mika Akakuma', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1486482338031603762/1500x500.jfif?ex=69c8f5ce&is=69c7a44e&hm=c3ed815fd9bdb2461f62256870512ecc3a387c000ed1ea0c1f1fea8811a66fe1&=&format=webp'}
      ]
    }
  },
  pool_c: {
    name: '🌀 The Multiverse Banner',
    characters: {
      common: [
        { name: 'Pippa Pipkin', gif: 'https://media.discordapp.net/attachments/1475906306912292906/1476350347705585695/634845571_18378049066093079_5006460205440247214_n.webp?ex=69a0cde8&is=699f7c68&hm=189b2a4c9777e1f230d827218e38e193bbfe8da7a08e456864c5472beb4ae887&=&format=webp' },
        { name: 'Tenma Maemi', gif: 'https://media.discordapp.net/attachments/1475906306912292906/1476350351178207374/tenmamaemi.jpg?ex=69a0cde8&is=699f7c68&hm=3227e9afd4ce453e50b46328c4dab24f943d5abcf9a0c8dea06c8e211748a636&=&format=webp&width=1521&height=856' },
        { name: 'Rin Penrose', gif: 'https://media.discordapp.net/attachments/1475906306912292906/1476350350746452028/rinpenrose.jpg?ex=69a0cde8&is=699f7c68&hm=afd5f94109b85124453c40a6538df751e65324326c80cb441921d7fec955bdb1&=&format=webp' },
        { name: 'Yuko Yurei', gif: 'https://media.discordapp.net/attachments/1475906306912292906/1476350349852803282/yukoyurei.jpg?ex=69a0cde8&is=699f7c68&hm=a661efae7ffd4769fa50907bce7485a0a1ef470977794ff1f168a97253cdc96d&=&format=webp' },
        { name: 'Poko', gif: 'https://media.discordapp.net/attachments/1475906306912292906/1476350349525778513/poko.jpg?ex=69a0cde8&is=699f7c68&hm=c61e9d66cca5e47ab75a8017e623e13d2855c1e1a76421ffbcfc1b3700908586&=&format=webp' },
        { name: 'Lumi', gif: 'https://media.discordapp.net/attachments/1475906306912292906/1476350349143965797/lumi.jpg?ex=69a0cde8&is=699f7c68&hm=a70103f25a7f77ba5cfd0ecd5ff177b4170c44dce52f9eaccb2576b5526847c0&=&format=webp' },
        { name: 'Erina Makina', gif: 'https://media.discordapp.net/attachments/1475906306912292906/1476350348800294984/erinamakina.png?ex=69a0cde8&is=699f7c68&hm=e32dccb9be7078930cd4a85742df115c32415c6bc9b2e06db118474f3543a305&=&format=webp&quality=lossless' },
        { name: 'PorcelainMaid', gif: 'https://media.discordapp.net/attachments/1475906306912292906/1476350348406034635/jowol.jpg?ex=69a0cde8&is=699f7c68&hm=04063c55f5852187bab29e6f242321d5bdbf58a4e4ae2b8e12caed43b5ad5341&=&format=webp' },
        { name: 'Onigiri', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482859613153132685/onigiri.jpg?ex=69b87c21&is=69b72aa1&hm=808d34667087aba7dab969db045101d74b31384a59acd5e6ed31233231ad272a&=&format=webp&width=1521&height=856' },
        { name: 'Yuzu', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482859632174174319/yuzu.jpg?ex=69b87c26&is=69b72aa6&hm=b1a83eece43be18724c61b075df22cfb9ac2a5e737f7b1b2c29a368c3ff7db9b&=&format=webp&width=856&height=856' },
        { name: 'Amiya Aranha', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482859494391419001/amiyaaranha.png?ex=69b87c05&is=69b72a85&hm=1a9f1c14dedc2dd9e56f5fb29e54549416caf7195fe4fdccd8c2cb4b28058870&=&format=webp&quality=lossless&width=1607&height=856' },
        { name: 'IRyS', gif: 'https://media.discordapp.net/attachments/1486442109153186042/1486448583258542280/1271645.jpg?ex=69c58a9f&is=69c4391f&hm=06f88f85ddc5a2c371d5edb2aac770b4c8616b7e32183e027c311f3ed66332bf&=&format=webp&width=1450&height=856'},
        { name: 'Luto Araka', gif: 'https://media.discordapp.net/attachments/1486442109153186042/1486443919993475232/artworks-sxRE8BXpYFl2MDVb-GdBqqg-t1080x1080.jpg?ex=69c58647&is=69c434c7&hm=3ac59156e49efe215b2b0019d8bf650c2fd4a900ae23d556e311032667ae1a8c&=&format=webp&width=960&height=960'},
        { name: 'Dayumdahlia', gif: 'https://media.discordapp.net/attachments/1486442109153186042/1486443358959435967/hq720.jpg?ex=69c585c1&is=69c43441&hm=abfba4d976e665d818114cf50fd5b485dca24e7142ebc56a5bd12dcfdba7122f&=&format=webp'}
      ],
      rare: [
        { name: 'Dokibird', gif: 'https://media.discordapp.net/attachments/1475906306912292906/1476350348103913624/dokibird.webp?ex=69a0cde8&is=699f7c68&hm=2a6d947415a6589bb302205677613475e76c471286d8e8308fa1f2c103f55a10&=&format=webp' },
        { name: 'Mint Fantome', gif: 'https://media.discordapp.net/attachments/1475906306912292906/1476350509639012372/mint.jpg?ex=69a0ce0e&is=699f7c8e&hm=abd7a80ea1de890033fdc638a0ef4b69a0de4ae81819ddbfaada720b4ae209af&=&format=webp' },
        { name: 'Uruka Fujikura', gif: 'https://media.discordapp.net/attachments/1475906306912292906/1476350509312118886/uruka.jpg?ex=69a0ce0e&is=699f7c8e&hm=ffe7c00cdabff82fb89f053bcc415df8932e1496e72ada3f35130d8779f8645a&=&format=webp' },
        { name: 'Shiina', gif: 'https://media.discordapp.net/attachments/1475906306912292906/1476350509047746670/shiina.jpg?ex=69a0ce0e&is=699f7c8e&hm=c7b45c23a70e089bd19d92884d86d8ea570ae38c23e20b2f8d75546aa47d93cb&=&format=webp' },
        { name: 'Riro Ron', gif: 'https://media.discordapp.net/attachments/1475906306912292906/1476350508695289906/riro.jpg?ex=69a0ce0e&is=699f7c8e&hm=76e4ac5ea6a635b986bc41e01da8cd229980fab9fe5bb879334370172aedcc82&=&format=webp&width=856&height=856' },
        { name: 'Kureiji Ollie', gif: 'https://media.discordapp.net/attachments/1475906306912292906/1476352054292381756/thumb-1920-1139466.jpg?ex=69a0cf7f&is=699f7dff&hm=d99d64ee4198e06142c53e757da07c312e8f537beff258894dbc5fc7d9247482&=&format=webp&width=1211&height=856' },
        { name: 'Dizzy Dokuro', gif: 'https://media.discordapp.net/attachments/1475906306912292906/1476350507944644648/dizzy.webp?ex=69a0ce0e&is=699f7c8e&hm=be9da9237c403dec58c692028390c5db6880e8747c5155a9988ac975d64ba2cc&=&format=webp' },
        { name: 'Shoto', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482859615401279619/shoto.webp?ex=69b87c22&is=69b72aa2&hm=abae09da6676f5f22cf1e9ae11c2c0b94acd3cf32baf5676cd26d31e564d8e55&=&format=webp&width=1522&height=856' },
        { name: 'Kenji', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482859519963959479/kenji.png?ex=69b87c0b&is=69b72a8b&hm=d741726d04f76f6db9dc916f1365feb559fae7b62517a76788ad3efd116a8c55&=&format=webp&quality=lossless' },
        { name: 'Uto Amatsuka', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482859631092043887/utoamatsuka.webp?ex=69b87c26&is=69b72aa6&hm=47ac71483e15e3b60418ace2eade6ad0f3dd07263b1d7a59a064d5bff0e86f84&=&format=webp' },
        { name: 'Alban Knox', gif: 'https://media.discordapp.net/attachments/1486442109153186042/1486448341649850445/1269131.jpg?ex=69c58a65&is=69c438e5&hm=33780ea8d47c61c4705afa2e726db1a4d19088b8c3b1624597e40a0bce2e1522&=&format=webp&width=1522&height=856'},
        { name: 'Kattarina Qutie', gif: 'https://media.discordapp.net/attachments/1486442109153186042/1486445329246195826/Kattarina_Qutie_1_by_HaruYuki.webp?ex=69c58797&is=69c43617&hm=39d0b5098bc30b18cade83f2e8ce4e2927224e5a5e4d36d6cbd310cb0b59edda&=&format=webp'},
        { name: 'Haruna Swift', gif: 'https://media.discordapp.net/attachments/1486442109153186042/1486444771923722500/5db1700b-704c-43a5-b258-1b1190f7af2c-profile_banner-480.png?ex=69c58712&is=69c43592&hm=c1012764e5ff6c14eb9c28e53114acbf1d8d3ed17330e17f6f3a96f324d5cd77&=&format=webp&quality=lossless'}
      ],
      legendary: [
        { name: 'Neuro-sama', gif: 'https://media.discordapp.net/attachments/1475906306912292906/1476350507017699369/neuro.jpg?ex=69a0ce0e&is=699f7c8e&hm=5ea4d9bbb36f4d96dadf72a89dac1329a41d6fb12b2ab5908281c219d170fb52&=&format=webp&width=1695&height=856' },
        { name: 'Vedal987 (Turtle)', gif: 'https://media.discordapp.net/attachments/1475906306912292906/1476350501007130644/vedal.png?ex=69a0ce0c&is=699f7c8c&hm=72cb83d0278f81c37d9f48148a667780128ee3ca6deb14d4184c0a7f29c233fc&=&format=webp&quality=lossless' },
        { name: 'Hoshikawa Sara', gif: 'https://media.discordapp.net/attachments/1475906306912292906/1476352053528887448/download.jfif?ex=69a0cf7e&is=699f7dfe&hm=f292090c17baefd13635fde89267b42d16b135b9831551a65523b51d96fea0ff&=&format=webp&width=856&height=856' },
        { name: 'Kanae', gif: 'https://media.discordapp.net/attachments/1475906306912292906/1476350499908485181/kanae.png?ex=69a0ce0c&is=699f7c8c&hm=e66a6827a42a6f2420aba4e5d2b9770f5306ac65d7f22f4ef442c3f3234da88e&=&format=webp&quality=lossless' },
        { name: 'Amano Pikamee', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482868263032590346/youtube-vtuber-pikamee-graduation.avif?ex=69b88430&is=69b732b0&hm=ab49d54b72014c0ea1c4e9db7a11eba25a77e9ef61e3e6c1f38275f4a302ae1d&=&format=webp&quality=lossless' },
        { name: 'Kaguya Luna', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482859519628546108/kaguyaluna.jpg?ex=69b87c0b&is=69b72a8b&hm=d496b628415c3bae8e7812e2ea94a05df733118478d6544eb4ffa2edc7c6dc2b&=&format=webp' },
        { name: 'Mirai Akari', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482859522715549828/miraiakari.webp?ex=69b87c0c&is=69b72a8c&hm=b5bcc3eda6edeb308c0e606c742912678aa5343350f26c765864cc73ca11fb4f&=&format=webp&width=695&height=856' },
        { name: 'Fulgur Ovid', gif: 'https://media.discordapp.net/attachments/1486442109153186042/1486448153552097454/thumb-1920-1250507.png?ex=69c58a38&is=69c438b8&hm=5f370db9f8a784ed9fb38915a6c23682f111f02ff0b8ef695b29d86a2c21449f&=&format=webp&quality=lossless&width=1406&height=856'}
      ],
      goddess: [
        { name: 'baonuki', gif: 'https://media.discordapp.net/attachments/1475890017443516476/1476339091653005312/Gemini_Generated_Image_z3jz8tz3jz8tz3jz.png?ex=69c8f92c&is=69c7a7ac&hm=a4d0f680da0d16822ff5177df63bc2afee74ad1c017c36b04eee6587480c2f52&=&format=webp&quality=lossless&width=747&height=960' },
        { name: 'Blossom', gif: 'https://media.discordapp.net/attachments/1475890017443516476/1485555394532343818/Gemini_Generated_Image_grwxaagrwxaagrwx.png?ex=69c24ac6&is=69c0f946&hm=e045c4d593d17ce8999f0a611c708d9fe0c5377072a87c32482912e323fa11ac&=&format=webp&quality=lossless&width=600&height=960' },
        { name: 'Cweamcat', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1485887383265218580/HD3ZWDMXIAIjPfU.jfif?ex=69c428b6&is=69c2d736&hm=93d7090dfa304ff1c66c05dd53d9a7abbc102ef50e12a3fc86eac7aa11392216&=&format=webp&width=640&height=960'},
        { name: 'Cheriyfu', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1485852371027361812/share.jpg?ex=69c4081b&is=69c2b69b&hm=6f80c8ec2558a31e206770da13d1158a6a7a39c35a7b2a2e0bbbb6449f19be13&=&format=webp'},
        { name: 'little nii', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1485851144910540951/GsAf3WhXIAAM0gm.jfif?ex=69c406f6&is=69c2b576&hm=0ac4ebeb7a2db81a3061ea7cdc1338356ee8686bf8ffc459c3707d226c07c827&=&format=webp&width=1280&height=960'},
        { name: 'Hexchu', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1485852140873187389/f6097bce-bf5e-4b24-a01d-e35864faaba6_shygb.png?ex=69e25a64&is=69e108e4&hm=7f08871be26639d93397e86407e8b9ad95ebafc9235ef988a94ff61892cc30bc&=&format=webp&quality=lossless&width=975&height=759'},
        { name: 'baonuki', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494370178719289616/Gemini_Generated_Image_yjaqkzyjaqkzyjaq.png?ex=69e25c2e&is=69e10aae&hm=737d70183bec93737f1a51a2480e8c92ac3b79d3c5902f10e38a19941c0c91ee&=&format=webp&quality=lossless&width=1436&height=800'},
        { name: 'Katoh Eli', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494378681681055934/481204457_610534128501579_2237011361763406195_n.jpg?ex=69e26419&is=69e11299&hm=97c4eccae2e652ce606fc474a729fda54bfdf27895703b01875b8c0204c3e711&=&format=webp&width=1348&height=800'},
        { name: 'Megrocks.exe', gif: 'https://media.discordapp.net/attachments/1494986646339190804/1494986756628418561/G1W7B9sXcAApWWp.jfif?ex=69e937aa&is=69e7e62a&hm=ae4dd8a35c1c8cc98ca97c0a6dd6148b758ad971b35b3dac9a9074598ec474f7&=&format=webp&width=795&height=779'},
        { name: 'Suko', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1486442609265213601/Suko15.webp?ex=69c5850e&is=69c4338e&hm=98235b0b2d953a8db322c692ad92b38f0d360c87cb05c7c1930174a3fac5cd23&=&format=webp&width=594&height=960'},
        { name: 'Robopup', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1486814336675614831/ab67616d0000b2734fd48b59a6debf9ebfe2222b.jfif?ex=69c8d981&is=69c78801&hm=5453a5b13bf367faef56a5e5e384e588f55c8fd6643cdf9ebe10bc340f6b5fe8&=&format=webp'},
        { name: 'Mika Akakuma', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1486482338031603762/1500x500.jfif?ex=69c8f5ce&is=69c7a44e&hm=c3ed815fd9bdb2461f62256870512ecc3a387c000ed1ea0c1f1fea8811a66fe1&=&format=webp'}
      ]
    }
  },
  pool_d: {
    name: '☄️ Creators & Advent Banner',
    characters: {
      common: [
        { name: 'Isaa Corva', gif: 'https://media.discordapp.net/attachments/1477495373449658458/1477495414956494948/0x1900-000000-80-0-0_11.jpg?ex=69a649d5&is=69a4f855&hm=9e30965dd93bb4530d457b60aef889e89da0b9b95242ae6bb1961ab16167c9fa&=&format=webp&width=856&height=856' },
        { name: 'Selphius', gif: 'https://media.discordapp.net/attachments/1477495373449658458/1477495415615262720/hanh-chu-selphius-illustration.jpg?ex=69a649d5&is=69a4f855&hm=3b5119455f701a58f79ae4f833e4b5634bf2ef0b5f7c94fac8e40166c905c36d&=&format=webp&width=1114&height=856' },
        { name: 'Gh0stmp4', gif: 'https://media.discordapp.net/attachments/1477495373449658458/1477495416080695416/HBhM0VLXIAA8e8z.jpg?ex=69a649d5&is=69a4f855&hm=92eed8202182da919f49733e612c62a0b25c16aca9ccf5b157fed2ce52ca0d2e&=&format=webp' },
        { name: 'K1ttencore', gif: 'https://media.discordapp.net/attachments/1477495373449658458/1477495416621895711/K1ttencore_2a.webp?ex=69a649d5&is=69a4f855&hm=3ac0d606c00b3bfefcc4ed863c09a80f7f3ada857aa8be6973a7ac7413c9f69e&=&format=webp&width=1146&height=856' },
        { name: 'Sylla', gif: 'https://media.discordapp.net/attachments/1477495373449658458/1477499312358293637/20260228_215426.jpg?ex=69a64d76&is=69a4fbf6&hm=6a85a8b3728d69e73655a1bc8522fcd27d58055e20e61c6984c12c0394c6f85d&=&format=webp' },
        { name: 'Saba', gif: 'https://media.discordapp.net/attachments/1477495373449658458/1477499319505653812/images_27.jpg?ex=69a64d78&is=69a4fbf8&hm=cfed49f38ebe4ecb12b1aeae082e3abe9a30c9719b0131e35b6b58d018fe0d38&=&format=webp' },
        { name: 'Marina', gif: 'https://media.discordapp.net/attachments/1477495373449658458/1477499320701026384/bafkreiagthwazm5lc7cqcqawniwrqhsj2xot772wl4453ngxuwxsadyoqu.jpg?ex=69a64d78&is=69a4fbf8&hm=f32aca9c5e44442f993c21516347e01ffc21bb447f956e688aba62e4c52bf454&=&format=webp&width=856&height=856' },
        { name: 'Futakuchi Mana', gif: 'https://media.discordapp.net/attachments/1477495373449658458/1477505110157426823/futakuchi-mana-solo-top_1.jpg?ex=69a652dc&is=69a5015c&hm=3321e542ddf42488a3e35230bffc23f2cabb9dca2f8fa732e5f000725e167142&=&format=webp' },
        { name: 'Sakurai Hana', gif: 'https://media.discordapp.net/attachments/1477495373449658458/1477505110547632428/sakurai_hana_indie_virtual_youtuber_drawn_by_haku_yuan__sample-182fe8386746e0d22efbd950e53eb9f3.jpg?ex=69a652dd&is=69a5015d&hm=aa06d9ce78bb07b4aa7f7f4dcd14da8d87c48b95a89107daab0c42b25adf5d20&=&format=webp' },
        { name: 'Camila', gif: 'https://media.discordapp.net/attachments/1477495373449658458/1477505132710203452/Camila.VTuber.600.4509868.jpg?ex=69a652e2&is=69a50162&hm=021d6a47ccea8f6ce0c327f47bbc553c27266f77811230d6e89f8da63abdacea&=&format=webp' },
        { name: 'Pixiee', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482859613618704657/pixiee.jpg?ex=69b87c22&is=69b72aa2&hm=62f60d577261d91ff24525e5c71fed989603281643b876b944e1478cc5be5a23&=&format=webp&width=1521&height=856' },
        { name: 'el XoX', gif: 'https://media.discordapp.net/attachments/1477495373449658458/1477507169044660224/wanna-share-my-fanart-of-el-xox-vtuber-also-ive-been-doing-v0-13i9l79xhk1d1.png?ex=69a654c7&is=69a50347&hm=111929623d19169419987ca620740436808b5cda3b8623c8c0bb0fb5bafe7469&=&format=webp&quality=lossless&width=1522&height=856' },
        { name: 'Monii', gif: 'https://media.discordapp.net/attachments/1477495373449658458/1477842199147184239/20260301_203534.jpg?ex=69a6e40d&is=69a5928d&hm=4acc9207fe1508f393c0f62e4e9ee7978819e7951728b115a805f528cc4a201f&=&format=webp&width=704&height=960' },
        { name: 'Gigi Murin', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482859498287792139/gigimurin.png?ex=69b87c06&is=69b72a86&hm=0fc035251c0251ec93a51f3259f9b340b1aee7b78b953ec65a5859c296642aa5&=&format=webp&quality=lossless' },
        { name: 'Raora Panthera', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482859614016897093/raora.jpg?ex=69b87c22&is=69b72aa2&hm=5649ce85e24b493c083bc3a4bee45d763004189165d84f81265d9aa52d024077&=&format=webp&width=685&height=856' },
        { name: 'Jurard T Rexford', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482859519137677464/jurardtrexford.avif?ex=69b87c0b&is=69b72a8b&hm=a72ee12733116b97da99ccc88c8838af5f8b6c1ab6d62b2e5e58e809860f8364&=&format=webp&quality=lossless' },
        { name: 'FalseEyed', gif: 'https://media.discordapp.net/attachments/1486442109153186042/1486446757255839815/False_Uploading_Data....webp?ex=69c588eb&is=69c4376b&hm=e18fcbcfd9bd8db9c1e12c06388a8fe93c2719f7aa834109f7bc010eb2cedd47&=&format=webp'},
        { name: 'Miori Celesta', gif: 'https://media.discordapp.net/attachments/1486442109153186042/1486446312940372231/Miori_Celesta_4_by_OZ.webp?ex=69c58881&is=69c43701&hm=555d1e4470dd431f7c4e0bbc5ef403b0e7a81da07fb3c7ad1b7977dde9b0f3b6&=&format=webp&width=622&height=960'},
        { name: 'Utano Pandora', gif: 'https://media.discordapp.net/attachments/1486442109153186042/1486445899671404564/Utano_Pandora_Chibi_Fullbody.webp?ex=69c5881f&is=69c4369f&hm=e064429d0a67622eb4e3680198a2721748f4228637853bcb9d7839ae24297e65&=&format=webp'},
        { name: 'Roca Rourin', gif: 'https://media.discordapp.net/attachments/1486442109153186042/1486443631031091210/Roca_Rourin2C_sparkling_beam.webp?ex=69c58602&is=69c43482&hm=0fed98abdccd9c81d3e1f3306a3cd189d080e206de1f3a3d8bad4505b941c8bb&=&format=webp'}
      ],
      rare: [
        { name: 'Shiori Novella', gif: 'https://media.discordapp.net/attachments/1477495373449658458/1477505107997364458/images_28.jpg?ex=69a652dc&is=69a5015c&hm=9d3f49a5140c6733d1f1ed59041bb86135ca75dbc6e7bc21fe7f86d5d2cdead1&=&format=webp' },
        { name: 'Koseki Bijou', gif: 'https://media.discordapp.net/attachments/1477495373449658458/1477505107112497234/cbd47025bd6ac0577e3693e6ddbbbe32.jpg?ex=69a652dc&is=69a5015c&hm=95d431f3a1caefe61b83caa7efe3a8328cd3be23cfb99d96ed3381d19d1f9014&=&format=webp&width=497&height=856' },
        { name: 'YukkoEX', gif: 'https://media.discordapp.net/attachments/1477495373449658458/1477499321535697110/P1432B_1.jpg?ex=69a64d78&is=69a4fbf8&hm=a621150456c5b4373858e996875eeb9328ef02b8aed8a348e0e25ce5fffb94fd&=&format=webp&width=535&height=856' },
        { name: 'CyYu', gif: 'https://media.discordapp.net/attachments/1477495373449658458/1477499318955937882/20260228_215125.jpg?ex=69a64d78&is=69a4fbf8&hm=4edde357ca3ab623ce5dfe97d12048a43109d54383a4f894ea85a85fee401ff6&=&format=webp&width=1518&height=856' },
        { name: 'Rosedoodle', gif: 'https://media.discordapp.net/attachments/1477495373449658458/1477505108987215952/1f45c515-6e16-4ef9-99ed-46c790fd218e-profile_banner-480.png?ex=69a652dc&is=69a5015c&hm=2fc2987bac24347f1eb307ce216dc0fde9c0852d7171bb43ca14a8760d80c841&=&format=webp&quality=lossless' },
        { name: 'Rainhoe', gif: 'https://media.discordapp.net/attachments/1477495373449658458/1477505111113728071/de008a49-37c4-479a-9b0f-822bbe18e6c6-profile_banner-480_1.png?ex=69a652dd&is=69a5015d&hm=51f540611364f62c9cfdf09fe9c25fb3da35276c38a68dd76ecbfd9cd5b6140a&=&format=webp&quality=lossless' },
        { name: 'Yoclesh', gif: 'https://media.discordapp.net/attachments/1477495373449658458/1477505132408340611/akumi_fanart_by_insanejohnson_delg5vy-fullview.jpg?ex=69a652e2&is=69a50162&hm=5d94c8ca3ca16e17c4a30b77069b1c244a815e37c20a2b37b3aedfd15b91807a&=&format=webp&width=1454&height=856' },
        { name: 'YFUBaby', gif: 'https://media.discordapp.net/attachments/1477495373449658458/1477505133494538410/YFU_BABY_2024.webp?ex=69a652e2&is=69a50162&hm=b1d18885b16e223fa970666399beba9337fb3eb0b2d8bc4b0c5f8411c74927e1&=&format=webp&width=856&height=856' },
        { name: 'Cecilia Immergreen', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482859496345829479/ceciliaimmergreen.webp?ex=69b87c06&is=69b72a86&hm=21c44de12ecf309c53495f5a61f4357e283f526b1f5525bd53a21eb36ab888a6&=&format=webp&width=605&height=855' },
        { name: 'Elizabeth Rose Bloodflame', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482859496840630448/elizabethrosebloodflame.webp?ex=69b87c06&is=69b72a86&hm=6e0bca1116bfab923e1dfa63ccd32891dc2e87bf6d4ef973813e4f2c3a8dafec&=&format=webp' },
        { name: 'Gavis Bettel', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482859497406988308/gavisbettel.jfif?ex=69b87c06&is=69b72a86&hm=03f98f83381a048425f6c1c32d0c3ba0c27cb9d9335afe7f51f5db7f404e2744&=&format=webp&width=1222&height=856' },
        { name: 'Yuzuya', gif: 'https://media.discordapp.net/attachments/1486442109153186042/1486451476682506311/7cb31ace-a175-47ee-bdc1-432cc70201cb-profile_banner-480.png?ex=69c58d50&is=69c43bd0&hm=ee312eabecd7712405e1d21f456f99795fc22fc9abb72d399bc982c99728da78&=&format=webp&quality=lossless'}
      ],
      legendary: [
        { name: 'FUWAMOCO', gif: 'https://media.discordapp.net/attachments/1477495373449658458/1477505107544506524/sm5h12c20zmf1.jpg?ex=69a652dc&is=69a5015c&hm=f59a5a5ca8d0d506edbcc0d1fefc6175ba6a46be2ab09c5ba1c0eebedf19bc11&=&format=webp&width=1123&height=856' },
        { name: 'Nerissa Ravencroft', gif: 'https://media.discordapp.net/attachments/1477495373449658458/1477505106663702661/nerissa-ravencroft-v0-xwgwx6zl8f9f1.jpg?ex=69a652dc&is=69a5015c&hm=ca775f690ceb0c0ce044ae6589bde87ce5a15c43d60701648211f405ce18a8de&=&format=webp&width=554&height=856' },
        { name: 'Matara Kun', gif: 'https://media.discordapp.net/attachments/1477495373449658458/1477505108576305283/Matraya_Banner.png?ex=69a652dc&is=69a5015c&hm=198c5b03e03813ef7e19ab217f155b49469dff53f0021211ae36d6a2c63e1ad0&=&format=webp&quality=lossless&width=1521&height=856' },
        { name: 'Michi Mochivee', gif: 'https://media.discordapp.net/attachments/1477495373449658458/1477505109641658520/Michi_Aishite_Aishite_Aishite_Art_2.webp?ex=69a652dc&is=69a5015c&hm=3dc880e052ff5b94ecfda89ca66884065c4f6087cf7526e039c239bf7c15aa9a&=&format=webp&width=1527&height=856' },
        { name: 'Josuiji Shinri', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482859518743416872/josuijishinri.jpg?ex=69b87c0b&is=69b72a8b&hm=0717282444c059ef84ca9a1efd2f61de23e7414406d30fdf2fbb15f13c1ef367&=&format=webp&width=1521&height=856' },
        { name: 'Banzoin Hakka', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482859494923829408/banzoinhakka.jpg?ex=69b87c05&is=69b72a85&hm=2bc79af88e7fd2dcbc4273d190c8cd7bb1b1d22c66b1137d9e4e16fb8549664e&=&format=webp' },
        { name: 'Machina X Flayon', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1482859522317095003/machinaxflayon.jpeg?ex=69b87c0c&is=69b72a8c&hm=77bb8fc6e9011b7115816107d56ee174a930e9815c23c18e3712172b77702d53&=&format=webp&width=685&height=856' },
        { name: 'Saruei', gif: 'https://media.discordapp.net/attachments/1486442109153186042/1486451317932163192/gloria-the-animator-composited.jpg?ex=69c58d2b&is=69c43bab&hm=b6e1663c1b3e8dd65e5ac02cb4f3458998f9dbe392c516ba8b54a1293be0edf2&=&format=webp&width=640&height=960'}
      ],
      goddess: [
        { name: 'baonuki', gif: 'https://media.discordapp.net/attachments/1475890017443516476/1476339091653005312/Gemini_Generated_Image_z3jz8tz3jz8tz3jz.png?ex=69c8f92c&is=69c7a7ac&hm=a4d0f680da0d16822ff5177df63bc2afee74ad1c017c36b04eee6587480c2f52&=&format=webp&quality=lossless&width=747&height=960' },
        { name: 'Blossom', gif: 'https://media.discordapp.net/attachments/1475890017443516476/1485555394532343818/Gemini_Generated_Image_grwxaagrwxaagrwx.png?ex=69c24ac6&is=69c0f946&hm=e045c4d593d17ce8999f0a611c708d9fe0c5377072a87c32482912e323fa11ac&=&format=webp&quality=lossless&width=600&height=960' },
        { name: 'Cweamcat', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1485887383265218580/HD3ZWDMXIAIjPfU.jfif?ex=69c428b6&is=69c2d736&hm=93d7090dfa304ff1c66c05dd53d9a7abbc102ef50e12a3fc86eac7aa11392216&=&format=webp&width=640&height=960'},
        { name: 'Cheriyfu', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1485852371027361812/share.jpg?ex=69c4081b&is=69c2b69b&hm=6f80c8ec2558a31e206770da13d1158a6a7a39c35a7b2a2e0bbbb6449f19be13&=&format=webp'},
        { name: 'little nii', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1485851144910540951/GsAf3WhXIAAM0gm.jfif?ex=69c406f6&is=69c2b576&hm=0ac4ebeb7a2db81a3061ea7cdc1338356ee8686bf8ffc459c3707d226c07c827&=&format=webp&width=1280&height=960'},
        { name: 'Hexchu', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1485852140873187389/f6097bce-bf5e-4b24-a01d-e35864faaba6_shygb.png?ex=69e25a64&is=69e108e4&hm=7f08871be26639d93397e86407e8b9ad95ebafc9235ef988a94ff61892cc30bc&=&format=webp&quality=lossless&width=975&height=759'},
        { name: 'baonuki', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494370178719289616/Gemini_Generated_Image_yjaqkzyjaqkzyjaq.png?ex=69e25c2e&is=69e10aae&hm=737d70183bec93737f1a51a2480e8c92ac3b79d3c5902f10e38a19941c0c91ee&=&format=webp&quality=lossless&width=1436&height=800'},
        { name: 'Katoh Eli', gif: 'https://media.discordapp.net/attachments/1494365483598876834/1494378681681055934/481204457_610534128501579_2237011361763406195_n.jpg?ex=69e26419&is=69e11299&hm=97c4eccae2e652ce606fc474a729fda54bfdf27895703b01875b8c0204c3e711&=&format=webp&width=1348&height=800'},
        { name: 'Megrocks.exe', gif: 'https://media.discordapp.net/attachments/1494986646339190804/1494986756628418561/G1W7B9sXcAApWWp.jfif?ex=69e937aa&is=69e7e62a&hm=ae4dd8a35c1c8cc98ca97c0a6dd6148b758ad971b35b3dac9a9074598ec474f7&=&format=webp&width=795&height=779'},
        { name: 'Suko', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1486442609265213601/Suko15.webp?ex=69c5850e&is=69c4338e&hm=98235b0b2d953a8db322c692ad92b38f0d360c87cb05c7c1930174a3fac5cd23&=&format=webp&width=594&height=960'},
        { name: 'Robopup', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1486814336675614831/ab67616d0000b2734fd48b59a6debf9ebfe2222b.jfif?ex=69c8d981&is=69c78801&hm=5453a5b13bf367faef56a5e5e384e588f55c8fd6643cdf9ebe10bc340f6b5fe8&=&format=webp'},
        { name: 'Mika Akakuma', gif: 'https://media.discordapp.net/attachments/1482859369543630868/1486482338031603762/1500x500.jfif?ex=69c8f5ce&is=69c7a44e&hm=c3ed815fd9bdb2461f62256870512ecc3a387c000ed1ea0c1f1fea8811a66fe1&=&format=webp'}
      ]
    }
  }
}.freeze

# ------------------------------------------
# UNIVERSAL POOL (All banners merged, deduplicated)
# ------------------------------------------
require 'set'

UNIVERSAL_POOL = {
  name: '🌌 Neon Arcade Universal Banner',
  characters: { common: [], rare: [], legendary: [], goddess: [] }
}

_seen = { common: Set.new, rare: Set.new, legendary: Set.new, goddess: Set.new }
CHARACTER_POOLS.values.each do |pool|
  pool[:characters].each do |rarity, chars|
    chars.each do |c|
      unless _seen[rarity].include?(c[:name])
        _seen[rarity].add(c[:name])
        UNIVERSAL_POOL[:characters][rarity] << c
      end
    end
  end
end
UNIVERSAL_POOL.freeze

# ------------------------------------------
# THE RARITY TABLE
# ------------------------------------------
RARITY_TABLE = [
  [:common, 70],
  [:rare, 24],
  [:legendary, 5],
  [:goddess, 1]
].freeze

# Event rarity table — used during event months for boosted event character rates
# 10% chance per pull to get an event character instead of the normal pool
EVENT_PULL_CHANCE = 10

# ------------------------------------------
# STATS CALCULATION
# ------------------------------------------
TOTAL_UNIQUE_CHARS = { 'common' => [], 'rare' => [], 'legendary' => [], 'goddess' => [] }

UNIVERSAL_POOL[:characters].each do |rarity, list|
  TOTAL_UNIQUE_CHARS[rarity.to_s].concat(list.map { |c| c[:name] })
end
TOTAL_UNIQUE_CHARS.transform_values!(&:size)