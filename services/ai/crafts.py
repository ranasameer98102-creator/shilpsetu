"""Craft knowledge base: history, how it is made and a "did you know" for each art form (keys = lexicon TECHNIQUES).

Shown on the product page ("About this art form") and used by the assistant. English and Hindi are written by hand;
other languages fall back to English. Kept to widely documented facts.
"""
from __future__ import annotations

from . import lexicon as L

# key: (region, {en: (history, making, fact)}, {hi: (history, making, fact)})
CRAFTS: dict[str, dict] = {
    "blue_pottery": {
        "region": "Jaipur, Rajasthan",
        "en": ("A Turko-Persian art that reached India with the Mughals, blue pottery flourished in Jaipur under Sawai Ram "
               "Singh II in the 19th century and was revived in the 1960s by Kamaladevi Chattopadhyay and painter Kripal "
               "Singh Shekhawat.",
               "It uses no clay: quartz powder, powdered glass, Multani mitti, borax and gum are shaped by hand, painted "
               "with cobalt-blue oxide and fired once at a low temperature.",
               "It is one of the very few pottery traditions in the world made without clay, so every piece is light and "
               "slightly translucent."),
        "hi": ("मुग़लों के साथ भारत आई यह तुर्क-फ़ारसी कला 19वीं सदी में सवाई राम सिंह द्वितीय के समय जयपुर में फली-फूली और "
               "1960 के दशक में कमलादेवी चट्टोपाध्याय व कृपाल सिंह शेखावत ने इसे फिर जीवित किया।",
               "इसमें मिट्टी नहीं लगती: क्वार्ट्ज़ पाउडर, काँच का चूरा, मुल्तानी मिट्टी, सुहागा और गोंद से आकार बनाकर कोबाल्ट नीले "
               "रंग से चित्र बनाए जाते हैं और एक बार कम तापमान पर पकाया जाता है।",
               "यह दुनिया की उन गिनी-चुनी मिट्टी-कला परंपराओं में है जिनमें मिट्टी का इस्तेमाल नहीं होता।"),
    },
    "dhokra": {
        "region": "Bastar (Chhattisgarh), Odisha, West Bengal, Jharkhand",
        "en": ("Dhokra is lost-wax metal casting practised for more than 4,000 years; the famous 'Dancing Girl' of "
               "Mohenjo-daro was cast the same way. The name comes from the Dhokra Damar nomadic metalsmiths.",
               "A clay core is wrapped in fine threads of beeswax, covered in clay and heated. The wax melts away and "
               "molten brass is poured into the space it leaves, so the mould is broken open after every casting.",
               "Because the mould is destroyed each time, no two Dhokra pieces can ever be identical."),
        "hi": ("ढोकरा 4,000 साल से भी पुरानी 'लुप्त मोम' ढलाई कला है; मोहनजोदड़ो की प्रसिद्ध 'नर्तकी' भी इसी तरह ढाली गई थी।",
               "मिट्टी के ढाँचे पर मोम के बारीक धागे लपेटे जाते हैं, ऊपर मिट्टी चढ़ाकर गरम किया जाता है; मोम पिघलकर निकल जाता है और "
               "उसकी जगह पिघला पीतल भरा जाता है।",
               "हर ढलाई के बाद साँचा तोड़ना पड़ता है, इसलिए कोई भी दो ढोकरा मूर्तियाँ एक जैसी नहीं होतीं।"),
    },
    "kantha": {
        "region": "West Bengal and Bangladesh",
        "en": ("Kantha began as women in rural Bengal layering worn-out saris and dhotis and stitching them into quilts "
               "and wraps. Nakshi kantha, covered with motifs, became a way of telling family stories in thread.",
               "Layers of soft cotton are held together with a simple running stitch; the ripple of thousands of small "
               "stitches creates the texture, and threads pulled from old sari borders give the colours.",
               "Kantha is one of India's oldest forms of upcycling - a new kantha often carries fabric from three "
               "generations."),
        "hi": ("कांथा की शुरुआत बंगाल की ग्रामीण महिलाओं से हुई, जो पुरानी साड़ियों और धोतियों की परतें सिलकर रज़ाई और ओढ़नी "
               "बनाती थीं। नक्शी कांथा धागों से परिवार की कहानियाँ कहने का तरीका बन गया।",
               "सूती कपड़े की परतें सीधे 'रनिंग स्टिच' से जोड़ी जाती हैं; हज़ारों छोटे टाँकों से इसकी बनावट बनती है।",
               "कांथा भारत की सबसे पुरानी 'अपसाइक्लिंग' कलाओं में से है - एक कांथा में अक्सर तीन पीढ़ियों का कपड़ा होता है।"),
    },
    "block_print": {
        "region": "Sanganer and Bagru, Rajasthan",
        "en": ("Hand block printing has been practised in Rajasthan for over 400 years by the Chhipa community of "
               "printers, whose name comes from the word for stamping.",
               "Designs are carved into teak-wood blocks and stamped by hand, colour by colour. Bagru printers use a mud "
               "resist called dabu and natural dyes such as indigo, pomegranate rind and madder.",
               "A single bedsheet can need more than a thousand precise impressions of the block, all lined up by eye."),
        "hi": ("राजस्थान में छीपा समुदाय 400 से अधिक वर्षों से हाथ की ठप्पा छपाई कर रहा है।",
               "सागवान की लकड़ी के ठप्पों पर डिज़ाइन खोदकर हर रंग अलग से हाथ से छापा जाता है; बगरू में 'दाबू' मिट्टी और नील, अनार "
               "के छिलके जैसे प्राकृतिक रंग लगते हैं।",
               "एक चादर पर हज़ार से ज़्यादा ठप्पे आँख के अंदाज़े से सीधी पंक्ति में लगाए जाते हैं।"),
    },
    "handloom": {
        "region": "Across India",
        "en": ("India's handloom sector employs more than 35 lakh weavers and allied workers, most of them women. "
               "Handloom cloth became a symbol of self-reliance during the Swadeshi movement.",
               "Yarn is dyed, wound and set on a pit or frame loom, and every thread of the weft is passed through by hand "
               "with a shuttle - a saree can take anywhere from a week to several months.",
               "National Handloom Day, 7 August, marks the launch of the Swadeshi movement on that day in 1905."),
        "hi": ("भारत के हथकरघा क्षेत्र में 35 लाख से अधिक बुनकर और सहायक कामगार हैं, जिनमें ज़्यादातर महिलाएँ हैं। स्वदेशी आंदोलन में "
               "हथकरघा आत्मनिर्भरता का प्रतीक बना।",
               "सूत रंगकर करघे पर चढ़ाया जाता है और बाने का हर धागा हाथ से ढरकी चलाकर डाला जाता है।",
               "7 अगस्त को राष्ट्रीय हथकरघा दिवस मनाया जाता है - 1905 में इसी दिन स्वदेशी आंदोलन शुरू हुआ था।"),
    },
    "madhubani": {
        "region": "Mithila, Bihar",
        "en": ("Mithila painting was made for centuries by women on the mud walls and floors of homes for weddings and "
               "festivals. After a drought in the 1960s it moved onto paper and cloth and reached the world.",
               "Artists paint with twigs, nib pens and fingers using natural colours - soot, turmeric, flowers and "
               "indigo. Double outlines are filled with bold colour (bharni) or fine lines (kachni).",
               "A Madhubani painting leaves no empty space: every gap is filled with flowers, fish, birds or geometric "
               "patterns."),
        "hi": ("मिथिला चित्रकला सदियों तक महिलाएँ शादी-त्योहारों पर घर की दीवारों और आँगन में बनाती थीं। 1960 के दशक के सूखे के बाद यह "
               "कागज़ और कपड़े पर आई और दुनिया भर में पहुँची।",
               "टहनी, निब और उँगलियों से काजल, हल्दी, फूल और नील जैसे प्राकृतिक रंगों से चित्र बनते हैं; भरनी और कचनी इसकी दो प्रमुख शैलियाँ हैं।",
               "मधुबनी चित्र में कोई जगह खाली नहीं छोड़ी जाती - हर कोना फूल, मछली, पक्षी या आकृतियों से भरा होता है।"),
    },
    "warli": {
        "region": "Palghar and Thane, Maharashtra",
        "en": ("Warli art belongs to the Warli tribe of the Sahyadri foothills, painted on the walls of homes for "
               "weddings and harvests. Jivya Soma Mashe brought it to the world and received the Padma Shri in 2011.",
               "Only three shapes are used - circle, triangle and square - painted in white rice paste on a mud-and-cow-"
               "dung wall with a chewed bamboo stick.",
               "The spiral of dancers you often see is the tarpa dance, circling a musician playing the tarpa horn."),
        "hi": ("वारली कला सह्याद्रि की तलहटी में रहने वाली वारली जनजाति की है, जो शादी और फ़सल पर घर की दीवारों पर बनाई जाती है। जिव्या "
               "सोमा मशे ने इसे दुनिया तक पहुँचाया और 2011 में पद्मश्री पाया।",
               "सिर्फ़ तीन आकार - गोला, त्रिभुज और चौकोर - चावल के सफ़ेद घोल से गोबर-मिट्टी की दीवार पर बाँस की कूँची से बनाए जाते हैं।",
               "नाचते लोगों का गोल घेरा 'तारपा नृत्य' है, जो तारपा वाद्य बजाने वाले के चारों ओर होता है।"),
    },
    "pattachitra": {
        "region": "Raghurajpur, Odisha",
        "en": ("Pattachitra ('picture on cloth') is tied to the Jagannath temple in Puri and has been painted for "
               "centuries by chitrakar families. Raghurajpur is a heritage village where almost every home is a studio.",
               "Cotton cloth is coated with tamarind-seed paste and chalk to make a canvas, then painted with natural "
               "colours - white from conch shell, black from lamp soot - and finished with lacquer.",
               "Artists sketch directly with the brush: there is no pencil drawing underneath a Pattachitra."),
        "hi": ("पटचित्र ('कपड़े पर चित्र') पुरी के जगन्नाथ मंदिर से जुड़ा है और सदियों से चित्रकार परिवार इसे बनाते आए हैं। रघुराजपुर में लगभग "
               "हर घर एक कार्यशाला है।",
               "सूती कपड़े पर इमली के बीज का लेप और खड़िया लगाकर कैनवास बनता है; शंख से सफ़ेद और दीये की कालिख से काला रंग बनता है।",
               "कलाकार सीधे ब्रश से चित्र बनाते हैं - पटचित्र के नीचे पेंसिल का कोई खाका नहीं होता।"),
    },
    "ikat": {
        "region": "Pochampally, Telangana (also Odisha and Gujarat)",
        "en": ("Ikat is one of the oldest resist-dyeing techniques in the world. Pochampally, the 'silk city of India', "
               "was named one of the best tourism villages by the UN World Tourism Organization in 2021.",
               "The pattern is dyed into the yarn before weaving: bundles of threads are tied tightly and dipped in "
               "colour, then untied and aligned on the loom so the design appears as the cloth is woven.",
               "The slightly blurred edges of the motifs are the signature of real ikat - printed copies have sharp "
               "edges."),
        "hi": ("इकत दुनिया की सबसे पुरानी 'रेज़िस्ट डाई' तकनीकों में है। 'भारत का सिल्क सिटी' पोचमपल्ली 2021 में संयुक्त राष्ट्र पर्यटन संगठन "
               "द्वारा सर्वश्रेष्ठ पर्यटन गाँवों में चुना गया।",
               "बुनाई से पहले ही धागों को कसकर बाँधकर रंगा जाता है, फिर करघे पर इस तरह जमाया जाता है कि बुनते-बुनते डिज़ाइन उभर आए।",
               "असली इकत की पहचान उसकी हल्की धुँधली किनारियाँ हैं - छपी हुई नकल में किनारे तीखे होते हैं।"),
    },
    "bandhani": {
        "region": "Kutch (Gujarat) and Rajasthan",
        "en": ("Bandhani takes its name from the Sanskrit 'bandh', to tie. It is worn at weddings and festivals across "
               "Gujarat and Rajasthan, and the Khatri community of Kutch is known for its finest work.",
               "Tiny points of cloth are pinched up and tied tightly with thread, often with a fingernail grown long for "
               "the purpose, then dyed; the tied points stay undyed and form dots once opened.",
               "A single fine bandhani dupatta can hold thousands of hand-tied knots."),
        "hi": ("बांधनी नाम संस्कृत के 'बंध' (बाँधना) से आया है। गुजरात और राजस्थान में शादी-त्योहारों पर पहनी जाती है; कच्छ का खत्री समुदाय "
               "इसके बारीक काम के लिए जाना जाता है।",
               "कपड़े के छोटे-छोटे हिस्से उठाकर धागे से कसकर बाँधे जाते हैं और फिर रंगा जाता है; खोलने पर बँधी जगहें बिंदियाँ बन जाती हैं।",
               "एक बारीक बांधनी दुपट्टे में हज़ारों गाँठें हाथ से बाँधी जाती हैं।"),
    },
    "chikankari": {
        "region": "Lucknow, Uttar Pradesh",
        "en": ("Chikankari is Lucknow's delicate white-on-white embroidery, which grew under Mughal patronage and is "
               "traditionally worked on fine muslin.",
               "A design is block-printed in washable blue, then embroidered with more than 30 stitches such as tepchi, "
               "bakhia, phanda and jaali, and the print is washed away.",
               "In the bakhia (shadow) stitch the thread is worked on the back, so the pattern glows softly through the "
               "fabric."),
        "hi": ("चिकनकारी लखनऊ की नाज़ुक सफ़ेद-पर-सफ़ेद कढ़ाई है, जो मुग़ल संरक्षण में बढ़ी और पारंपरिक रूप से मलमल पर होती है।",
               "पहले धुल जाने वाले नीले रंग से डिज़ाइन छापा जाता है, फिर टेपची, बखिया, फंदा, जाली जैसे 30 से ज़्यादा टाँकों से कढ़ाई होती है।",
               "बखिया टाँका कपड़े के उल्टी तरफ़ किया जाता है, इसलिए डिज़ाइन कपड़े के आर-पार हल्का-सा चमकता है।"),
    },
    "channapatna": {
        "region": "Channapatna, Karnataka",
        "en": ("Channapatna is known as the 'toy town' (Gombegala ooru) of Karnataka. Local tradition links the craft "
               "to Tipu Sultan's time, and it was modernised in the 20th century by the master craftsman Bavas Miyan.",
               "Soft ivory-wood (aale mara) is turned on a lathe, then coloured with lac mixed with natural dyes; the "
               "friction of the spinning wood melts the lac into a glossy finish.",
               "The colours are from turmeric, indigo and other natural sources, which is why Channapatna toys are safe "
               "for babies to chew."),
        "hi": ("चन्नपटना कर्नाटक का 'खिलौनों का शहर' (गोम्बेगला ऊरु) कहलाता है। स्थानीय परंपरा इस कला को टीपू सुल्तान के समय से जोड़ती है; "
               "20वीं सदी में उस्ताद बावस मियाँ ने इसे आधुनिक बनाया।",
               "हल्की 'आले मरा' लकड़ी को खराद पर घुमाकर प्राकृतिक रंग मिली लाख से रंगा जाता है; घर्षण से लाख पिघलकर चमकदार परत बन जाती है।",
               "रंग हल्दी, नील जैसे प्राकृतिक स्रोतों से बनते हैं, इसलिए चन्नपटना खिलौने छोटे बच्चों के लिए भी सुरक्षित हैं।"),
    },
    "terracotta": {
        "region": "Across India",
        "en": ("Terracotta ('baked earth') is among the oldest crafts in India - fired clay figures have been found at "
               "Harappan sites. Village potters still make votive horses, lamps and pots for local shrines.",
               "Local clay is kneaded, shaped on the wheel or by hand, dried in the shade and fired in an open kiln, "
               "which gives the warm red-brown colour.",
               "Unglazed terracotta 'breathes', which is why water in a matka stays cool in summer."),
        "hi": ("टेराकोटा ('पकी मिट्टी') भारत की सबसे पुरानी कलाओं में है - हड़प्पा में भी पकी मिट्टी की मूर्तियाँ मिली हैं।",
               "स्थानीय मिट्टी गूँथकर चाक पर या हाथ से आकार दिया जाता है, छाँव में सुखाकर खुले भट्ठे में पकाया जाता है।",
               "बिना चमकाई टेराकोटा 'साँस' लेती है, इसीलिए मटके का पानी गर्मी में ठंडा रहता है।"),
    },
    "bankura": {
        "region": "Panchmura, Bankura, West Bengal",
        "en": ("The long-necked Bankura horse from Panchmura village is offered at village shrines in Bengal and became "
               "the emblem of the All India Handicrafts Board.",
               "The body is thrown on the wheel in separate parts, joined, coated with a clay slip and fired to its "
               "glowing red or black finish.",
               "The horse's ears and neck are made separately and joined before firing - a skilled potter needs about "
               "a week for a large one."),
        "hi": ("पाँचमुड़ा गाँव का लंबी गर्दन वाला बांकुड़ा घोड़ा बंगाल के गाँवों के देवस्थानों पर चढ़ाया जाता है और अखिल भारतीय हस्तशिल्प बोर्ड "
               "का प्रतीक बना।",
               "शरीर के हिस्से अलग-अलग चाक पर बनाकर जोड़े जाते हैं, मिट्टी का घोल चढ़ाकर लाल या काली चमक तक पकाया जाता है।",
               "घोड़े के कान और गर्दन अलग बनाकर जोड़े जाते हैं - बड़े घोड़े में एक कुम्हार को लगभग एक हफ़्ता लगता है।"),
    },
    "gond": {
        "region": "Patangarh, Dindori, Madhya Pradesh",
        "en": ("Gond art comes from the Pardhan Gond community, whose bards sang the tribe's stories. In the 1980s "
               "Jangarh Singh Shyam took it from village walls to canvas at Bharat Bhavan, Bhopal.",
               "Animals, trees and spirits are drawn in bold outlines and filled with patterns of dots, dashes and fine "
               "lines that give them movement.",
               "Every Gond artist develops a personal 'signature' fill pattern, so you can often tell who painted a "
               "piece."),
        "hi": ("गोंड कला परधान गोंड समुदाय की है, जिनके गायक जनजाति की कथाएँ गाते थे। 1980 के दशक में जनगढ़ सिंह श्याम इसे भोपाल के "
               "भारत भवन में दीवारों से कैनवास तक लाए।",
               "जानवर, पेड़ और देव मोटी रेखाओं में बनाकर बिंदुओं, डैश और बारीक रेखाओं के पैटर्न से भरे जाते हैं।",
               "हर गोंड कलाकार का अपना 'हस्ताक्षर' पैटर्न होता है, जिससे अक्सर पहचान हो जाती है कि चित्र किसने बनाया।"),
    },
    "kalamkari": {
        "region": "Srikalahasti and Machilipatnam, Andhra Pradesh",
        "en": ("Kalamkari means 'pen-work'. Srikalahasti artists draw temple stories freehand with a bamboo pen, while "
               "Machilipatnam is known for block-printed Persian-inspired motifs.",
               "Cloth is soaked in myrobalan and milk, outlined with iron-rust 'kasimi' ink, and coloured with natural "
               "dyes fixed with alum - over a dozen stages of dyeing, washing and sun-drying.",
               "The kalam is a sharpened bamboo stick wrapped in a wad of cloth that holds the dye like a fountain pen."),
        "hi": ("कलमकारी का अर्थ है 'कलम का काम'। श्रीकालहस्ती में बाँस की कलम से मंदिर कथाएँ हाथ से बनती हैं, मछलीपट्टनम में ठप्पे से "
               "फ़ारसी शैली के नमूने छपते हैं।",
               "कपड़े को हरड़ और दूध में भिगोकर लोहे की जंग की स्याही से रेखाएँ बनती हैं; फिटकरी से पक्के प्राकृतिक रंगों में दर्जन से अधिक चरण लगते हैं।",
               "कलम बाँस की नुकीली डंडी होती है जिस पर कपड़े की गद्दी लिपटी रहती है, जो फ़ाउंटेन पेन की तरह रंग पकड़ती है।"),
    },
    "tanjore": {
        "region": "Thanjavur, Tamil Nadu",
        "en": ("Thanjavur painting flourished under the Maratha rulers of Thanjavur in the 17th-19th centuries, "
               "mostly depicting Hindu deities, especially a child Krishna.",
               "A wooden board is covered with cloth and a chalk paste; parts of the figure are raised in relief, "
               "decorated with gold foil and glass or semi-precious stones, then painted in rich colours.",
               "Real 22-carat gold foil is used, which is why old Tanjore paintings still shine after two centuries."),
        "hi": ("तंजौर चित्रकला 17वीं से 19वीं सदी में तंजावुर के मराठा शासकों के समय फली-फूली, जिसमें ज़्यादातर देवी-देवता, ख़ासकर बाल "
               "कृष्ण बनाए जाते हैं।",
               "लकड़ी के पटरे पर कपड़ा और खड़िया का लेप लगाकर आकृति उभारी जाती है, सोने के वर्क और रत्नों से सजाकर गाढ़े रंग भरे जाते हैं।",
               "इसमें 22 कैरेट सोने का वर्क लगता है, इसलिए पुराने तंजौर चित्र दो सौ साल बाद भी चमकते हैं।"),
    },
    "pichwai": {
        "region": "Nathdwara, Rajasthan",
        "en": ("Pichwai ('that which hangs behind') are cloth paintings hung behind the idol of Shrinathji in the "
               "Nathdwara temple, changed with the seasons and festivals.",
               "Artists grind mineral and natural pigments, sometimes with real gold and silver, and paint with "
               "squirrel-hair brushes in layer after layer of fine detail.",
               "Many pichwais show lotus ponds and cows because Krishna is worshipped here as a cowherd child."),
        "hi": ("पिछवाई ('जो पीछे लटके') नाथद्वारा मंदिर में श्रीनाथजी की मूर्ति के पीछे लगाई जाने वाली कपड़े की पेंटिंग हैं, जो ऋतु और "
               "त्योहार के साथ बदली जाती हैं।",
               "कलाकार खनिज और प्राकृतिक रंग - कभी असली सोना-चाँदी भी - पीसकर गिलहरी के बालों के ब्रश से परत-दर-परत बारीक चित्र बनाते हैं।",
               "कई पिछवाइयों में कमल के तालाब और गायें होती हैं, क्योंकि यहाँ कृष्ण की ग्वाल-बाल रूप में पूजा होती है।"),
    },
    "kalighat": {
        "region": "Kolkata, West Bengal",
        "en": ("Kalighat paintings began in the 19th century near the Kalighat Kali temple, sold to pilgrims as "
               "souvenirs. Artists also painted witty scenes of city life and poked fun at the 'babu' culture.",
               "Painters worked fast on mill-made paper with watercolours, using bold sweeping outlines and shading done "
               "in a single stroke.",
               "Kalighat's bold, simple lines are said to have influenced modern Indian artists such as Jamini Roy."),
        "hi": ("कालीघाट चित्र 19वीं सदी में कोलकाता के कालीघाट मंदिर के पास तीर्थयात्रियों के लिए बनने लगे; कलाकारों ने शहर के जीवन और "
               "'बाबू' संस्कृति पर व्यंग्य भी बनाए।",
               "मिल के कागज़ पर जल रंगों से तेज़, मोटी और एक ही स्ट्रोक वाली रेखाओं में चित्र बनते हैं।",
               "कहा जाता है कि कालीघाट की सरल, मोटी रेखाओं ने जामिनी रॉय जैसे आधुनिक चित्रकारों को प्रभावित किया।"),
    },
    "phulkari": {
        "region": "Punjab",
        "en": ("Phulkari ('flower-work') is Punjab's embroidery, traditionally stitched by women for weddings; a bagh "
               "('garden') covers the whole cloth so that the base fabric hardly shows.",
               "Untwisted silk floss is darned from the back of hand-spun khaddar cloth, counting the threads, so the "
               "long stitches catch the light in geometric patterns.",
               "A grandmother would often begin a bagh at a granddaughter's birth, to give it at her wedding."),
        "hi": ("फुलकारी ('फूलों का काम') पंजाब की कढ़ाई है, जो महिलाएँ शादी के लिए बनाती थीं; 'बाग़' में पूरा कपड़ा कढ़ाई से ढका होता है।",
               "हाथ से कते खद्दर पर उल्टी तरफ़ से धागे गिनकर बिना बटे रेशमी धागे से टाँके लगाए जाते हैं, जिससे ज्यामितीय नमूने चमकते हैं।",
               "कई दादियाँ पोती के जन्म पर बाग़ बनाना शुरू करती थीं, ताकि उसकी शादी पर दे सकें।"),
    },
    "banarasi": {
        "region": "Varanasi, Uttar Pradesh",
        "en": ("Banarasi brocade grew under Mughal patronage, when Persian motifs met Indian weaving. A Banarasi silk "
               "saree is still part of many Indian bridal trousseaus.",
               "Silk is woven with zari - thread wrapped in silver or gold - on handlooms, often with three weavers "
               "working together; intricate sarees can take from two weeks to six months.",
               "The patterns (jangla, butidar, tanchoi) are 'programmed' into the loom with punched cards, a system "
               "much like early computers."),
        "hi": ("बनारसी ज़री का काम मुग़ल काल में बढ़ा, जब फ़ारसी नमूने भारतीय बुनाई से मिले। आज भी बनारसी रेशमी साड़ी कई दुल्हनों के "
               "सामान का हिस्सा है।",
               "रेशम में ज़री (चाँदी या सोने से लिपटा धागा) डालकर हथकरघे पर बुनाई होती है; बारीक साड़ी में दो हफ़्ते से छह महीने लगते हैं।",
               "जंगला, बूटीदार जैसे नमूने छेद वाले कार्डों से करघे में 'डाले' जाते हैं - यह शुरुआती कंप्यूटरों जैसी प्रणाली है।"),
    },
    "pashmina": {
        "region": "Kashmir (fibre from Changthang, Ladakh)",
        "en": ("Pashmina comes from the soft undercoat of the Changthangi goat, which lives above 4,000 m in Ladakh; "
               "Kashmiri spinners and weavers have turned it into shawls for centuries.",
               "The fibre is combed by hand in spring, cleaned, spun on a wooden charkha - traditionally by women - and "
               "woven on handlooms; a shawl can take weeks.",
               "Pashmina fibre is only about 12-16 microns thick, around one-sixth of a human hair."),
        "hi": ("पश्मीना लद्दाख में 4,000 मीटर से ऊपर रहने वाली चांगथांगी बकरी के मुलायम भीतरी बालों से बनती है; कश्मीरी कारीगर सदियों से "
               "इससे शॉल बनाते आए हैं।",
               "वसंत में हाथ से कंघी कर रेशा निकाला जाता है, चरखे पर काता जाता है - परंपरागत रूप से महिलाएँ - और हथकरघे पर बुना जाता है।",
               "पश्मीना का रेशा सिर्फ़ 12-16 माइक्रॉन मोटा होता है, इंसानी बाल का लगभग छठा हिस्सा।"),
    },
    "kutch_embroidery": {
        "region": "Kutch, Gujarat",
        "en": ("Each community of Kutch - Rabari, Ahir, Jat, Mutwa, Sodha and others - has its own embroidery style, "
               "worn as a sign of identity on clothes, dowry textiles and animal trappings.",
               "Small mirrors (abhla) are held down with a ring of buttonhole stitches and surrounded by chain, "
               "interlacing and satin stitches in bright silk and cotton threads.",
               "Women of Kutch can often tell a stranger's community and even village just by looking at her embroidery."),
        "hi": ("कच्छ के हर समुदाय - रबारी, अहीर, जत, मुतवा, सोढ़ा आदि - की अपनी कढ़ाई शैली है, जो कपड़ों और दहेज़ के सामान पर पहचान "
               "की तरह पहनी जाती है।",
               "छोटे शीशे (आभला) काज के टाँकों के घेरे से बाँधे जाते हैं और चेन, इंटरलेसिंग व साटन टाँकों से चमकीले धागों में सजाए जाते हैं।",
               "कच्छ की महिलाएँ कढ़ाई देखकर ही बता देती हैं कि पहनने वाली किस समुदाय और गाँव की है।"),
    },
    "zardozi": {
        "region": "Lucknow, Uttar Pradesh",
        "en": ("Zardozi comes from the Persian 'zar' (gold) and 'dozi' (embroidery). It adorned royal robes, tents "
               "and horse trappings at the Mughal court.",
               "Cloth is stretched on a wooden frame (adda) and embroidered with metallic wires, sequins and beads using "
               "a hooked needle called an aari.",
               "Real zardozi once used wires of pure gold and silver; today gilded copper wire makes it affordable."),
        "hi": ("ज़रदोज़ी फ़ारसी 'ज़र' (सोना) और 'दोज़ी' (कढ़ाई) से बना है। मुग़ल दरबार में शाही पोशाकें, तंबू और घोड़ों के साज़ इससे सजते थे।",
               "कपड़ा लकड़ी के 'अड्डे' पर तानकर आरी सुई से धातु के तार, सितारे और मोतियों से कढ़ाई की जाती है।",
               "पहले असली सोने-चाँदी के तार लगते थे; आज सोने का पानी चढ़े ताँबे के तार से यह किफ़ायती हो गई है।"),
    },
    "bidri": {
        "region": "Bidar, Karnataka",
        "en": ("Bidriware began under the Bahmani sultans of Bidar in the 14th-15th centuries, blending Persian design "
               "with local skill.",
               "An alloy of zinc and copper is cast, engraved, and inlaid with pure silver wire or sheet; it is then "
               "rubbed with a paste of soil from the Bidar fort that turns the metal deep black while the silver shines.",
               "Craftsmen say only soil from the old fort, which never sees sunlight, gives the true Bidri black."),
        "hi": ("बिदरी काम 14वीं-15वीं सदी में बीदर के बहमनी सुल्तानों के समय शुरू हुआ, जिसमें फ़ारसी डिज़ाइन और स्थानीय कारीगरी मिली।",
               "जस्ता और ताँबे की मिश्रधातु ढालकर उस पर नक्काशी की जाती है और शुद्ध चाँदी जड़ी जाती है; फिर बीदर क़िले की मिट्टी के लेप "
               "से धातु गहरी काली हो जाती है और चाँदी चमक उठती है।",
               "कारीगर कहते हैं कि असली बिदरी कालापन सिर्फ़ पुराने क़िले की उस मिट्टी से आता है जिस पर धूप नहीं पड़ती।"),
    },
    "moradabad_brass": {
        "region": "Moradabad, Uttar Pradesh",
        "en": ("Moradabad is called 'Peetal Nagri', the brass city, and exports brassware all over the world; the "
               "craft grew there from the 17th century.",
               "Brass is cast or beaten into shape, then engraved, embossed or enamelled by hand, and polished to a "
               "golden shine.",
               "A single ornate plate can be engraved with thousands of tiny hand-cut marks."),
        "hi": ("मुरादाबाद को 'पीतल नगरी' कहा जाता है; यहाँ के पीतल के बर्तन दुनिया भर में जाते हैं और यह कला 17वीं सदी से बढ़ी।",
               "पीतल को ढालकर या पीटकर आकार दिया जाता है, फिर हाथ से नक्काशी, उभार या मीना का काम कर चमकाया जाता है।",
               "एक सजी थाली पर हाथ से हज़ारों बारीक निशान खोदे जाते हैं।"),
    },
    "meenakari": {
        "region": "Jaipur, Rajasthan (also Varanasi)",
        "en": ("Meenakari, the art of enamelling metal, is said to have come to Jaipur in the 16th century with "
               "craftsmen invited by Raja Man Singh I.",
               "Grooves are engraved into gold, silver or copper and filled with powdered coloured glass, which is "
               "fused in a furnace one colour at a time, starting with the colour that needs the most heat.",
               "Jaipur is famous for a pigeon-blood red enamel that very few craftsmen know how to make."),
        "hi": ("धातु पर मीना करने की कला मीनाकारी कहा जाता है कि 16वीं सदी में राजा मान सिंह प्रथम के बुलाए कारीगरों के साथ जयपुर आई।",
               "सोने, चाँदी या ताँबे पर खाँचे खोदकर रंगीन काँच का चूरा भरा जाता है और एक-एक रंग भट्ठी में पकाया जाता है।",
               "जयपुर कबूतर के ख़ून जैसे गहरे लाल मीना के लिए मशहूर है, जिसे बहुत कम कारीगर बना पाते हैं।"),
    },
    "filigree": {
        "region": "Cuttack, Odisha",
        "en": ("Cuttack's silver filigree, 'tarakasi', has been made for centuries; the city's Durga Puja pandals are "
               "famous for silver tableaux made in this craft.",
               "Silver is drawn into hair-thin wire, twisted, curled into patterns and soldered inside a thicker frame, "
               "like lace made of metal.",
               "A pair of filigree earrings can contain more than a metre of silver wire."),
        "hi": ("कटक की चाँदी की तारकशी सदियों पुरानी है; शहर के दुर्गा पूजा पंडालों की चाँदी की झाँकियाँ इसी कला से बनती हैं।",
               "चाँदी को बाल जितने पतले तार में खींचकर मोड़ा जाता है और मोटे ढाँचे के भीतर टाँका जाता है - धातु की जाली जैसा।",
               "तारकशी के एक जोड़ी झुमकों में एक मीटर से ज़्यादा चाँदी का तार लग सकता है।"),
    },
    "lac_craft": {
        "region": "Jaipur (Rajasthan) and Hyderabad (Telangana)",
        "en": ("Lac bangles are a symbol of married life in Rajasthan; Jaipur's Maniharon ka Rasta and Hyderabad's "
               "Laad Bazaar are lanes full of lac workers.",
               "Natural lac resin, secreted by a tiny insect, is heated over coals, mixed with colour, rolled around a "
               "wooden mandrel and studded with glass, beads or stones while still warm.",
               "Lac is one of the few natural resins in the world made by an insect."),
        "hi": ("लाख की चूड़ियाँ राजस्थान में सुहाग का प्रतीक हैं; जयपुर का मनिहारों का रास्ता और हैदराबाद का लाड बाज़ार लाख कारीगरों से भरे हैं।",
               "एक छोटे कीट से बनने वाली प्राकृतिक लाख को कोयले पर गरम कर रंग मिलाया जाता है, सलाख पर लपेटकर गरम रहते ही काँच, मोती या नग जड़े जाते हैं।",
               "लाख दुनिया की उन गिनी-चुनी प्राकृतिक रालों में है जिसे एक कीट बनाता है।"),
    },
    "kondapalli": {
        "region": "Kondapalli, Andhra Pradesh",
        "en": ("Kondapalli toys have been carved for about 400 years by the Aryakshatriya families of Kondapalli, "
               "showing village life, animals and gods.",
               "Soft, light tella poniki wood is carved in parts, joined with tamarind-seed paste and painted in bright "
               "colours.",
               "Tella poniki wood is so light that a large Kondapalli figure weighs less than you expect."),
        "hi": ("कोंडापल्ली खिलौने लगभग 400 साल से कोंडापल्ली के आर्यक्षत्रिय परिवार बनाते आए हैं, जिनमें गाँव का जीवन, जानवर और देवता दिखते हैं।",
               "हल्की 'तेल्ला पोनिकी' लकड़ी के हिस्से तराशकर इमली के बीज के लेप से जोड़े जाते हैं और चटख रंग भरे जाते हैं।",
               "तेल्ला पोनिकी लकड़ी इतनी हल्की होती है कि बड़ी मूर्ति भी उम्मीद से कम वज़नी लगती है।"),
    },
    "saharanpur": {
        "region": "Saharanpur, Uttar Pradesh",
        "en": ("Saharanpur is India's best-known wood-carving centre, with a tradition dating to the Mughal period and "
               "thousands of carvers still at work.",
               "Sheesham (Indian rosewood) is carved with chisels into floral patterns and fine jaali (lattice), and "
               "sometimes inlaid with brass or bone.",
               "A carver can spend days on a single jaali panel, where one slip means starting again."),
        "hi": ("सहारनपुर भारत का सबसे प्रसिद्ध लकड़ी नक्काशी केंद्र है, जिसकी परंपरा मुग़ल काल से है और आज भी हज़ारों कारीगर यहाँ काम करते हैं।",
               "शीशम की लकड़ी पर छेनी से फूल-पत्ती और बारीक जाली तराशी जाती है, कभी पीतल या हड्डी जड़ी जाती है।",
               "एक जाली पर कारीगर कई दिन लगाता है - एक चूक और सब फिर से शुरू करना पड़ता है।"),
    },
    "sandalwood": {
        "region": "Mysuru and Shivamogga, Karnataka",
        "en": ("Karnataka's gudigar carvers have carved sandalwood for generations, making deities, boxes and "
               "decorative pieces prized for their fragrance.",
               "Pieces are carved with fine chisels following the grain; only the fragrant heartwood is used.",
               "Good sandalwood keeps its fragrance for decades - rubbing the surface brings the scent back."),
        "hi": ("कर्नाटक के गुडिगार कारीगर पीढ़ियों से चंदन पर नक्काशी करते आए हैं - मूर्तियाँ, डिब्बे और सजावटी सामान, जो अपनी सुगंध के लिए प्रिय हैं।",
               "बारीक छेनियों से रेशे की दिशा में नक्काशी की जाती है; सिर्फ़ सुगंधित भीतरी लकड़ी का इस्तेमाल होता है।",
               "अच्छा चंदन दशकों तक महकता है - सतह रगड़ने पर ख़ुशबू लौट आती है।"),
    },
    "longpi": {
        "region": "Longpi, Ukhrul, Manipur",
        "en": ("Longpi pottery is made by the Tangkhul Naga people of Longpi village in Manipur and is used in homes "
               "and for cooking.",
               "No potter's wheel is used: a paste of ground black serpentine stone and weathered rock is shaped by hand "
               "with moulds, fired, and polished with a local leaf to its matte black sheen.",
               "Longpi pots can go straight from the fire to the table, and the stone keeps food warm for longer."),
        "hi": ("लोंगपी मिट्टी के बर्तन मणिपुर के लोंगपी गाँव के तांगखुल नागा लोग बनाते हैं, जो घरों और खाना पकाने में इस्तेमाल होते हैं।",
               "इसमें चाक नहीं लगता: काले सर्पेंटाइन पत्थर और घिसी चट्टान के चूर्ण से हाथ से आकार देकर पकाया जाता है और स्थानीय पत्ते से चमकाया जाता है।",
               "लोंगपी बर्तन सीधे आग से मेज़ पर आ सकते हैं और पत्थर खाने को देर तक गरम रखता है।"),
    },
    "sikki": {
        "region": "Mithila, Bihar",
        "en": ("Sikki is a golden wild grass from the wetlands of north Bihar. Women of Mithila have long woven it into "
               "baskets, boxes and toys given to daughters at weddings.",
               "The grass is cut, dried until golden, sometimes dyed, and coiled around a core of munj grass with a "
               "needle-like tool called takua.",
               "Sikki needs no machine and no glue - the tightly coiled grass holds its shape on its own."),
        "hi": ("सिक्की उत्तर बिहार के दलदली इलाकों की सुनहरी जंगली घास है। मिथिला की महिलाएँ इससे टोकरी, डिब्बे और खिलौने बनाती हैं जो "
               "बेटियों को शादी में दिए जाते हैं।",
               "घास को काटकर सुनहरा होने तक सुखाया जाता है, कभी रंगा जाता है और 'टकुआ' नाम के औज़ार से मूँज के चारों ओर लपेटा जाता है।",
               "सिक्की में न मशीन लगती है न गोंद - कसकर लपेटी घास अपना आकार ख़ुद बनाए रखती है।"),
    },
    "assam_cane": {
        "region": "Assam",
        "en": ("Cane and bamboo are part of daily life in Assam, from houses and fishing traps to the japi, the "
               "conical hat that is a symbol of Assamese culture.",
               "Bamboo and cane are split into fine strips, smoked or sun-dried to resist insects, and woven or bound by "
               "hand - often with palm leaves for the japi.",
               "A japi is traditionally presented to honour guests in Assam."),
        "hi": ("असम में बेंत और बाँस रोज़ के जीवन का हिस्सा हैं - घर, मछली पकड़ने के जाल से लेकर 'जापी' टोपी तक, जो असमिया संस्कृति का प्रतीक है।",
               "बाँस और बेंत की पतली पट्टियाँ चीरकर कीड़ों से बचाने के लिए धुएँ या धूप में सुखाई जाती हैं और हाथ से बुनी जाती हैं।",
               "असम में मेहमानों के सम्मान में जापी भेंट की जाती है।"),
    },
    "kolhapuri": {
        "region": "Kolhapur (Maharashtra) and Belagavi (Karnataka)",
        "en": ("Kolhapuri chappals have been made since around the 12th-13th century and received a GI tag in 2019 "
               "for eight districts of Maharashtra and Karnataka.",
               "Leather is vegetable-tanned with bark and natural oils, cut and stitched entirely by hand, often "
               "with braided leather straps and no nails.",
               "Traditional Kolhapuris are made without a single nail, so they soften and shape to the wearer's foot."),
        "hi": ("कोल्हापुरी चप्पलें लगभग 12वीं-13वीं सदी से बनती हैं और 2019 में महाराष्ट्र-कर्नाटक के आठ ज़िलों के लिए GI टैग मिला।",
               "चमड़ा छाल और प्राकृतिक तेलों से पकाया जाता है और पूरी तरह हाथ से काटकर सिला जाता है, अक्सर गूँथी चमड़े की पट्टियों के साथ।",
               "पारंपरिक कोल्हापुरी में एक भी कील नहीं होती, इसलिए ये पहनने वाले के पैर के हिसाब से ढल जाती हैं।"),
    },
    "leather_puppet": {
        "region": "Nimmalakunta, Andhra Pradesh",
        "en": ("Tholu Bommalata ('dance of leather dolls') is Andhra Pradesh's shadow-puppet theatre, telling the "
               "Ramayana and Mahabharata through the night by lamplight.",
               "Goat or deer skin is scraped until translucent, cut and punched into figures, painted with vegetable "
               "colours and jointed so the puppeteer can move arms and heads.",
               "Some Tholu Bommalata puppets are taller than a person and need two puppeteers."),
        "hi": ("तोलु बोम्मलाटा ('चमड़े की गुड़ियों का नाच') आंध्र प्रदेश का छाया-कठपुतली रंगमंच है, जिसमें दीये की रोशनी में रात भर रामायण-महाभारत "
               "की कथाएँ दिखाई जाती हैं।",
               "चमड़े को पारदर्शी होने तक घिसकर आकृतियाँ काटी और छेदी जाती हैं, वनस्पति रंग भरे जाते हैं और जोड़ बनाए जाते हैं।",
               "कुछ कठपुतलियाँ इंसान से भी ऊँची होती हैं और उन्हें दो कलाकार चलाते हैं।"),
    },
    "mamallapuram": {
        "region": "Mamallapuram, Tamil Nadu",
        "en": ("Mamallapuram's stone carving continues the legacy of the Pallava kings, whose 7th-8th century "
               "monuments here are a UNESCO World Heritage Site.",
               "Sculptors carve granite and soapstone with hammers and chisels following the proportions of the "
               "ancient Shilpa Shastra texts.",
               "The whole town is full of workshops; you can hear the chisels ringing along its streets."),
        "hi": ("महाबलीपुरम की पत्थर नक्काशी पल्लव राजाओं की विरासत है, जिनके 7वीं-8वीं सदी के स्मारक यूनेस्को विश्व धरोहर हैं।",
               "मूर्तिकार शिल्प शास्त्र के अनुपातों के अनुसार हथौड़े और छेनी से ग्रेनाइट और सोपस्टोन तराशते हैं।",
               "पूरे शहर में कार्यशालाएँ हैं; गलियों में छेनियों की आवाज़ गूँजती रहती है।"),
    },
    "marble_inlay": {
        "region": "Agra, Uttar Pradesh",
        "en": ("Parchin kari, marble inlay, reached its peak in the Taj Mahal. Descendants of the craftsmen who worked "
               "on it still practise the art in Agra.",
               "Tiny pieces of semi-precious stone - lapis, malachite, carnelian - are cut and ground to shape and fitted "
               "into grooves carved in white marble.",
               "Hold a torch to a good inlay piece and the light glows through the marble around the stones."),
        "hi": ("पच्चीकारी (संगमरमर में जड़ाई) ताजमहल में अपने शिखर पर पहुँची। उस पर काम करने वाले कारीगरों के वंशज आज भी आगरा में यह कला करते हैं।",
               "लाजवर्द, मैलाकाइट, कार्नेलियन जैसे रत्नों के छोटे टुकड़े घिसकर सफ़ेद संगमरमर में खोदे खाँचों में बैठाए जाते हैं।",
               "अच्छे पच्चीकारी के टुकड़े पर टॉर्च डालें तो पत्थरों के आसपास संगमरमर से रोशनी झिलमिलाती है।"),
    },
    "kathputli": {
        "region": "Rajasthan",
        "en": ("Kathputli, from 'kath' (wood) and 'putli' (doll), is Rajasthan's string-puppet theatre, performed by "
               "the Bhat community, often telling the story of Amar Singh Rathore.",
               "Heads are carved from mango wood and painted; bodies are stuffed cloth dressed in bright mirror-work "
               "costumes and worked with strings tied to the puppeteer's fingers.",
               "Kathputlis have no legs - their long skirts swirl as they dance."),
        "hi": ("कठपुतली - 'काठ' (लकड़ी) और 'पुतली' (गुड़िया) - राजस्थान का धागे वाली कठपुतलियों का रंगमंच है, जिसे भाट समुदाय करता है।",
               "आम की लकड़ी से सिर तराशकर रंगे जाते हैं; कपड़े के शरीर पर शीशे जड़ी चटख पोशाक होती है और धागे कलाकार की उँगलियों से बँधे रहते हैं।",
               "कठपुतलियों के पैर नहीं होते - नाचते समय उनके लंबे घाघरे घूमते हैं।"),
    },
    "papier_mache": {
        "region": "Srinagar, Kashmir",
        "en": ("Papier-mâché came to Kashmir from Persia around the 14th-15th century and became one of the valley's "
               "best-known crafts.",
               "Paper pulp mixed with rice glue is shaped over moulds (sakhtsazi), smoothed and then painted by hand "
               "(naqashi) with flowers, birds and chinar leaves, finished with varnish.",
               "Many Kashmiri Christmas ornaments sold around the world are painted by hand in Srinagar."),
        "hi": ("पेपर माशी 14वीं-15वीं सदी के आसपास फ़ारस से कश्मीर आई और घाटी की सबसे मशहूर कलाओं में बन गई।",
               "कागज़ की लुगदी को चावल के गोंद में मिलाकर साँचों पर आकार दिया जाता है (साख़्तसाज़ी), फिर हाथ से फूल, पक्षी और चिनार के पत्ते बनाए जाते हैं (नक़्क़ाशी)।",
               "दुनिया भर में बिकने वाले कई क्रिसमस सजावटी गोले श्रीनगर में हाथ से रंगे जाते हैं।"),
    },
    "navalgund": {
        "region": "Navalgund, Dharwad, Karnataka",
        "en": ("Navalgund durries are flat-woven cotton rugs made for generations, largely by women of the Jamkhan "
               "community, with bold geometric and bird motifs.",
               "Dyed cotton yarn is woven by hand on a vertical loom, each colour block packed tightly with a comb.",
               "The designs are woven from memory - no drawing is used."),
        "hi": ("नवलगुंद दरियाँ पीढ़ियों से ज़्यादातर जमखान समुदाय की महिलाएँ बनाती हैं, जिनमें ज्यामितीय और पक्षियों के नमूने होते हैं।",
               "रंगे सूती धागे को खड़े करघे पर हाथ से बुना जाता है और हर रंग कंघी से कसकर दबाया जाता है।",
               "डिज़ाइन याद से बुने जाते हैं - कोई चित्र या खाका नहीं होता।"),
    },
    "jute_craft": {
        "region": "West Bengal",
        "en": ("Bengal grows most of India's jute, the 'golden fibre', and artisans turn it into bags, mats and "
               "décor as a green alternative to plastic.",
               "Jute is retted, dried, spun into yarn or braided, and then woven, crocheted or stitched by hand.",
               "Jute is fully biodegradable and one of the cheapest natural fibres in the world."),
        "hi": ("भारत का ज़्यादातर जूट - 'सुनहरा रेशा' - बंगाल में उगता है और कारीगर इससे प्लास्टिक का हरा विकल्प, थैले, चटाई और सजावट बनाते हैं।",
               "जूट को सड़ाकर, सुखाकर धागा या चोटी बनाई जाती है और फिर हाथ से बुना, क्रोशिया या सिला जाता है।",
               "जूट पूरी तरह प्राकृतिक रूप से घुल जाता है और दुनिया के सबसे सस्ते प्राकृतिक रेशों में है।"),
    },
}

# Display names where the title word alone would be unclear ("Rajasthani" puppet -> Kathputli).
NAMES = {
    "kathputli": {"en": "Kathputli string puppets", "hi": "कठपुतली"},
    "handloom": {"en": "Handloom weaving", "hi": "हथकरघा बुनाई"},
    "moradabad_brass": {"en": "Moradabad brassware", "hi": "मुरादाबादी पीतल"},
    "jute_craft": {"en": "Jute craft", "hi": "जूट शिल्प"},
    "lac_craft": {"en": "Lac bangles", "hi": "लाख की चूड़ियाँ"},
    "kutch_embroidery": {"en": "Kutch embroidery", "hi": "कच्छी कढ़ाई"},
    "assam_cane": {"en": "Assam cane and bamboo", "hi": "असम का बेंत और बाँस"},
    "leather_puppet": {"en": "Tholu Bommalata leather puppets", "hi": "तोलु बोम्मलाटा"},
}

# Artisan craft_type or cluster words that point to a craft when the product itself names no technique.
_ALIASES = {"blue pottery": "blue_pottery", "dhokra": "dhokra", "kantha": "kantha", "block": "block_print",
            "handloom": "handloom", "saree": "handloom", "weav": "handloom", "terracotta": "terracotta",
            "madhubani": "madhubani", "warli": "warli", "pattachitra": "pattachitra", "bamboo": "assam_cane",
            "cane": "assam_cane", "jute": "jute_craft"}


def craft_key(techniques: list[str], craft_type: str | None = None) -> str | None:
    for t in techniques:
        if t in CRAFTS:
            return t
    low = (craft_type or "").lower()
    for word, key in _ALIASES.items():
        if word in low:
            return key
    return None


def craft_story(key: str | None, lang: str | None = None) -> dict | None:
    if not key or key not in CRAFTS:
        return None
    c = CRAFTS[key]
    history, making, fact = c.get(lang or "en") or c["en"]
    tech = L.TECHNIQUES.get(key, {})
    names = NAMES.get(key, {})
    name = names.get(lang or "en") or names.get("en") or tech.get(lang or "en") or tech.get("en") or key.replace("_", " ").title()
    return {"key": key, "name": name,
            "region": c["region"], "gi": tech.get("gi"), "history": history, "making": making, "fact": fact}
