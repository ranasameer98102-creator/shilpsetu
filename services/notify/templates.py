"""SMS / IVR message templates in regional languages. Falls back to Hindi, then English."""

TEMPLATES: dict[str, dict[str, str]] = {
    "otp": {
        "en": "{code} is your ShilpSetu login code. It is valid for 10 minutes. Do not share it.",
        "hi": "{code} आपका शिल्पसेतु लॉगिन कोड है। यह 10 मिनट तक मान्य है। इसे किसी से साझा न करें।",
        "bn": "{code} আপনার শিল্পসেতু লগইন কোড। এটি ১০ মিনিট বৈধ। কাউকে জানাবেন না।",
        "mr": "{code} हा तुमचा शिल्पसेतु लॉगिन कोड आहे. तो 10 मिनिटे वैध आहे. कोणालाही सांगू नका.",
        "gu": "{code} તમારો શિલ્પસેતુ લૉગિન કોડ છે. તે 10 મિનિટ માટે માન્ય છે. કોઈને જણાવશો નહીં.",
        "ta": "{code} உங்கள் ஷில்ப்சேது உள்நுழைவு குறியீடு. 10 நிமிடங்கள் செல்லும். யாரிடமும் பகிர வேண்டாம்.",
        "te": "{code} మీ శిల్ప్‌సేతు లాగిన్ కోడ్. ఇది 10 నిమిషాలు చెల్లుతుంది. ఎవరికీ చెప్పవద్దు.",
        "ur": "{code} آپ کا شلپ سیتو لاگ اِن کوڈ ہے۔ یہ 10 منٹ تک درست ہے۔ کسی کو نہ بتائیں۔",
    },
    "new_order": {
        "en": "New order! {buyer_city} wants your \"{title}\" (x{qty}) for Rs {amount}. You receive Rs {share}. Reply 1 to accept, 2 to decline, or open ShilpSetu.",
        "hi": "नया ऑर्डर! {buyer_city} से आपके \"{title}\" (x{qty}) का ऑर्डर ₹{amount} में आया है। आपको ₹{share} मिलेंगे। स्वीकार करने के लिए 1, मना करने के लिए 2 भेजें या शिल्पसेतु खोलें।",
        "bn": "নতুন অর্ডার! {buyer_city} থেকে আপনার \"{title}\" (x{qty}) ₹{amount}-তে। আপনি পাবেন ₹{share}। গ্রহণ করতে 1, বাতিল করতে 2 পাঠান।",
        "mr": "नवीन ऑर्डर! {buyer_city} मधून तुमच्या \"{title}\" (x{qty}) साठी ₹{amount}. तुम्हाला ₹{share} मिळतील. स्वीकारण्यासाठी 1, नाकारण्यासाठी 2 पाठवा.",
        "gu": "નવો ઑર્ડર! {buyer_city} થી તમારા \"{title}\" (x{qty}) માટે ₹{amount}. તમને ₹{share} મળશે. સ્વીકારવા 1, નકારવા 2 મોકલો.",
        "ta": "புதிய ஆர்டர்! {buyer_city}-இலிருந்து உங்கள் \"{title}\" (x{qty}) ₹{amount}. உங்களுக்கு ₹{share}. ஏற்க 1, மறுக்க 2 அனுப்பவும்.",
        "te": "కొత్త ఆర్డర్! {buyer_city} నుండి మీ \"{title}\" (x{qty}) ₹{amount}. మీకు ₹{share} వస్తుంది. అంగీకరించడానికి 1, తిరస్కరించడానికి 2 పంపండి.",
        "ur": "نیا آرڈر! {buyer_city} سے آپ کے \"{title}\" (x{qty}) کا آرڈر ₹{amount} میں۔ آپ کو ₹{share} ملیں گے۔ قبول کرنے کے لیے 1، انکار کے لیے 2 بھیجیں۔",
    },
    "payout": {
        "en": "Rs {net} has been sent to your account for order {order}. Sale Rs {gross} - platform fee Rs {commission} - shipping Rs {logistics}.",
        "hi": "ऑर्डर {order} के लिए ₹{net} आपके खाते में भेज दिए गए हैं। बिक्री ₹{gross} − प्लेटफ़ॉर्म शुल्क ₹{commission} − डिलीवरी ₹{logistics}।",
        "bn": "অর্ডার {order}-এর জন্য ₹{net} আপনার অ্যাকাউন্টে পাঠানো হয়েছে। বিক্রি ₹{gross} − প্ল্যাটফর্ম ফি ₹{commission} − ডেলিভারি ₹{logistics}।",
        "mr": "ऑर्डर {order} साठी ₹{net} तुमच्या खात्यात पाठवले आहेत. विक्री ₹{gross} − शुल्क ₹{commission} − डिलिव्हरी ₹{logistics}.",
        "gu": "ઑર્ડર {order} માટે ₹{net} તમારા ખાતામાં મોકલ્યા છે. વેચાણ ₹{gross} − ફી ₹{commission} − ડિલિવરી ₹{logistics}.",
        "ta": "ஆர்டர் {order}-க்கு ₹{net} உங்கள் கணக்கில் அனுப்பப்பட்டது.",
        "te": "ఆర్డర్ {order} కోసం ₹{net} మీ ఖాతాకు పంపబడింది.",
        "ur": "آرڈر {order} کے لیے ₹{net} آپ کے کھاتے میں بھیج دیے گئے ہیں۔",
    },
    "listing_live": {
        "en": "Your \"{title}\" is now live on ShilpSetu and ONDC at Rs {price}. Rs {share} of every sale comes to you.",
        "hi": "आपका \"{title}\" अब शिल्पसेतु और ONDC पर ₹{price} में लाइव है। हर बिक्री पर ₹{share} आपको मिलेंगे।",
        "bn": "আপনার \"{title}\" এখন শিল্পসেতু ও ONDC-তে ₹{price}-তে লাইভ। প্রতিটি বিক্রিতে আপনি পাবেন ₹{share}।",
        "mr": "तुमचे \"{title}\" आता शिल्पसेतु आणि ONDC वर ₹{price} ला उपलब्ध आहे. प्रत्येक विक्रीत ₹{share} तुम्हाला मिळतील.",
        "gu": "તમારું \"{title}\" હવે શિલ્પસેતુ અને ONDC પર ₹{price} માં લાઇવ છે. દરેક વેચાણે ₹{share} તમને મળશે.",
        "ta": "உங்கள் \"{title}\" இப்போது ஷில்ப்சேது மற்றும் ONDC-யில் ₹{price}-க்கு நேரலையில் உள்ளது.",
        "te": "మీ \"{title}\" ఇప్పుడు శిల్ప్‌సేతు మరియు ONDC లో ₹{price} కు లైవ్‌లో ఉంది.",
        "ur": "آپ کا \"{title}\" اب شلپ سیتو اور ONDC پر ₹{price} میں دستیاب ہے۔",
    },
    "certificate_issued": {
        "en": "A provenance certificate has been issued for \"{title}\". Buyers can scan its QR to see your name and story. {url}",
        "hi": "\"{title}\" के लिए प्रमाणपत्र जारी हो गया है। खरीदार QR स्कैन करके आपका नाम और कहानी देख सकते हैं। {url}",
        "bn": "\"{title}\"-এর জন্য প্রমাণপত্র জারি হয়েছে। ক্রেতারা QR স্ক্যান করে আপনার নাম ও গল্প দেখতে পাবেন। {url}",
        "mr": "\"{title}\" साठी प्रमाणपत्र जारी झाले आहे. खरेदीदार QR स्कॅन करून तुमचे नाव आणि कथा पाहू शकतात. {url}",
        "gu": "\"{title}\" માટે પ્રમાણપત્ર જારી થયું છે. ખરીદદારો QR સ્કેન કરીને તમારું નામ અને વાર્તા જોઈ શકે છે. {url}",
        "ta": "\"{title}\"-க்கு சான்றிதழ் வழங்கப்பட்டது. {url}",
        "te": "\"{title}\" కోసం ధృవపత్రం జారీ చేయబడింది. {url}",
        "ur": "\"{title}\" کے لیے سرٹیفکیٹ جاری ہو گیا ہے۔ {url}",
    },
    "order_status": {
        "en": "Your ShilpSetu order {order} is now {status}.",
        "hi": "आपका शिल्पसेतु ऑर्डर {order} अब {status} है।",
    },
}

# IVR prompts (spoken via the telephony provider's TTS in the chosen language).
IVR = {
    "welcome": {
        "en": "Welcome to ShilpSetu. For Hindi press 1. For English press 2. For Bengali press 3. For Marathi press 4.",
        "hi": "शिल्पसेतु में आपका स्वागत है। हिंदी के लिए 1 दबाएं। अंग्रेज़ी के लिए 2। बांग्ला के लिए 3। मराठी के लिए 4।",
    },
    "menu": {
        "en": "To hear your latest orders press 1. To hear your earnings press 2. To request a call back from a helper press 3.",
        "hi": "अपने नए ऑर्डर सुनने के लिए 1 दबाएं। अपनी कमाई सुनने के लिए 2 दबाएं। सहायक से वापस कॉल के लिए 3 दबाएं।",
        "bn": "নতুন অর্ডার শুনতে 1 টিপুন। আয় শুনতে 2 টিপুন। সহায়কের কল পেতে 3 টিপুন।",
        "mr": "नवीन ऑर्डर ऐकण्यासाठी 1 दाबा. कमाई ऐकण्यासाठी 2 दाबा. मदतनीसाचा कॉल हवा असल्यास 3 दाबा.",
    },
    "no_orders": {"en": "You have no new orders.", "hi": "आपके कोई नए ऑर्डर नहीं हैं।",
                  "bn": "আপনার কোনো নতুন অর্ডার নেই।", "mr": "तुमच्या कोणत्याही नवीन ऑर्डर नाहीत."},
    "order_item": {"en": "Order for {title}, {qty} piece, {amount} rupees. Status: {status}.",
                   "hi": "{title} का ऑर्डर, {qty} नग, {amount} रुपये। स्थिति: {status}।",
                   "bn": "{title}-এর অর্ডার, {qty}টি, {amount} টাকা। অবস্থা: {status}।",
                   "mr": "{title} ची ऑर्डर, {qty} नग, {amount} रुपये. स्थिती: {status}."},
    "earnings": {"en": "This month you earned {amount} rupees from {orders} orders.",
                 "hi": "इस महीने आपने {orders} ऑर्डर से {amount} रुपये कमाए।",
                 "bn": "এই মাসে আপনি {orders}টি অর্ডার থেকে {amount} টাকা আয় করেছেন।",
                 "mr": "या महिन्यात तुम्ही {orders} ऑर्डरमधून {amount} रुपये कमावले."},
    "callback": {"en": "Thank you. A helper will call you back soon in your language.",
                 "hi": "धन्यवाद। एक सहायक जल्द ही आपकी भाषा में आपको वापस कॉल करेगा।",
                 "bn": "ধন্যবাদ। একজন সহায়ক শীঘ্রই আপনার ভাষায় কল করবেন।",
                 "mr": "धन्यवाद. एक मदतनीस लवकरच तुमच्या भाषेत कॉल करेल."},
    "order_alert": {"en": "New order for {title}, {amount} rupees. You will receive {share} rupees. Press 1 to accept. Press 2 to decline.",
                    "hi": "{title} का नया ऑर्डर, {amount} रुपये। आपको {share} रुपये मिलेंगे। स्वीकार करने के लिए 1 दबाएं। मना करने के लिए 2 दबाएं।",
                    "bn": "{title}-এর নতুন অর্ডার, {amount} টাকা। আপনি পাবেন {share} টাকা। গ্রহণ করতে 1, বাতিল করতে 2 টিপুন।",
                    "mr": "{title} ची नवीन ऑर्डर, {amount} रुपये. तुम्हाला {share} रुपये मिळतील. स्वीकारण्यासाठी 1, नाकारण्यासाठी 2 दाबा."},
    "accepted": {"en": "Order accepted. Thank you.", "hi": "ऑर्डर स्वीकार हो गया। धन्यवाद।",
                 "bn": "অর্ডার গ্রহণ করা হয়েছে। ধন্যবাদ।", "mr": "ऑर्डर स्वीकारली. धन्यवाद."},
    "declined": {"en": "Order declined.", "hi": "ऑर्डर मना कर दिया गया।", "bn": "অর্ডার বাতিল করা হয়েছে।",
                 "mr": "ऑर्डर नाकारली."},
    "invalid": {"en": "Sorry, that was not a valid choice.", "hi": "माफ़ कीजिए, यह सही विकल्प नहीं है।"},
}

IVR_LANGS = {"1": "hi", "2": "en", "3": "bn", "4": "mr"}


def render(table: dict, key: str, language: str, **params) -> str:
    t = table[key]
    text = t.get(language) or t.get("hi") or t["en"]
    return text.format(**params)


def sms(key: str, language: str, **params) -> str:
    return render(TEMPLATES, key, language, **params)


def ivr(key: str, language: str, **params) -> str:
    return render(IVR, key, language, **params)
