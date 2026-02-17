/// Legal modules data - separated from UI for better performance.
/// This data is loaded once and cached.

class LegalModule {
  final String icon;
  final String category;
  final String titleEn;
  final String titleHi;
  final String duration;
  final String contentEn;
  final String contentHi;
  final ModuleQuiz? quiz;

  const LegalModule({
    required this.icon,
    required this.category,
    required this.titleEn,
    required this.titleHi,
    required this.duration,
    required this.contentEn,
    required this.contentHi,
    this.quiz,
  });

  String getTitle(bool isHindi) => isHindi ? titleHi : titleEn;
  String getContent(bool isHindi) => isHindi ? contentHi : contentEn;
  String getCategory(bool isHindi) => category;
}

class ModuleQuiz {
  final String questionEn;
  final String questionHi;
  final List<String> optionsEn;
  final List<String> optionsHi;
  final int correctIndex;

  const ModuleQuiz({
    required this.questionEn,
    required this.questionHi,
    required this.optionsEn,
    required this.optionsHi,
    required this.correctIndex,
  });

  String getQuestion(bool isHindi) => isHindi ? questionHi : questionEn;
  List<String> getOptions(bool isHindi) => isHindi ? optionsHi : optionsEn;
}

/// Cached legal modules data - loaded once at app start
class LegalModulesData {
  static List<LegalModule>? _cachedModules;
  static List<LegalModule>? _cachedLandmarkCases;

  /// Get all legal literacy modules (cached)
  static List<LegalModule> getModules() {
    _cachedModules ??= _buildModules();
    return _cachedModules!;
  }

  /// Get landmark cases (cached)
  static List<LegalModule> getLandmarkCases() {
    _cachedLandmarkCases ??= _buildLandmarkCases();
    return _cachedLandmarkCases!;
  }

  static List<LegalModule> _buildModules() {
    return const [
      // === BASICS ===
      LegalModule(
        icon: '👨‍⚖️',
        category: '🔰 Basics',
        titleEn: 'Who is a Judge?',
        titleHi: 'न्यायाधीश कौन होते हैं?',
        duration: '60 sec',
        contentEn: '''A judge is a person who sits in a court and decides legal cases.

🔹 Main Duties:
• Listen to both parties
• Examine evidence carefully
• Give decisions according to law

🔹 Qualities Required:
• Must be impartial (no favorites)
• Honest and patient
• Deep knowledge of law

💡 Remember: In their oath, judges promise to deliver justice "without fear or favor."''',
        contentHi: '''न्यायाधीश वह व्यक्ति है जो कोर्ट में बैठकर मुकदमों का फैसला करता है।

🔹 मुख्य कार्य:
• दोनों पक्षों की बात सुनना
• साक्ष्य (evidence) की जांच करना
• कानून के अनुसार निर्णय देना

🔹 गुण:
• निष्पक्ष (impartial) होना
• ईमानदार और धैर्यवान होना
• कानून का गहरा ज्ञान

💡 याद रखें: न्यायाधीश की शपथ में वे वादा करते हैं कि बिना भय या पक्षपात के न्याय करेंगे।''',
        quiz: ModuleQuiz(
          questionEn: 'What is the most important quality of a judge?',
          questionHi: 'न्यायाधीश का सबसे महत्वपूर्ण गुण क्या है?',
          optionsEn: ['Strict personality', 'Impartiality (no favorites)', 'Fast decision making'],
          optionsHi: ['कड़ा व्यक्तित्व', 'निष्पक्षता (कोई पक्षपात नहीं)', 'तेज़ निर्णय लेना'],
          correctIndex: 1,
        ),
      ),
      LegalModule(
        icon: '⚖️',
        category: '🔰 Basics',
        titleEn: 'How Does a Court Work?',
        titleHi: 'अदालत कैसे काम करती है?',
        duration: '90 sec',
        contentEn: '''Justice in court follows a clear process:

📋 Court Proceedings:

1️⃣ Filing the Case
   Victim files complaint with police or court

2️⃣ Calling Both Parties
   Plaintiff (who files) and Defendant (who is accused)

3️⃣ Arguments by Lawyers
   Both sides present their case

4️⃣ Presenting Evidence
   Witnesses, documents, photos, etc.

5️⃣ Judge's Verdict
   Final decision after hearing everything

⚠️ Important: "Innocent until proven guilty" - A person is considered innocent unless proven otherwise.''',
        contentHi: '''अदालत में न्याय प्रक्रिया कई चरणों में होती है:

📋 मुकदमे की प्रक्रिया:

1️⃣ FIR/याचिका दायर करना
   पीड़ित व्यक्ति पुलिस या कोर्ट में शिकायत करता है

2️⃣ दोनों पक्षों को बुलाना
   वादी (plaintiff) और प्रतिवादी (defendant)

3️⃣ वकीलों की बहस
   दोनों पक्ष अपनी बात रखते हैं

4️⃣ साक्ष्य प्रस्तुत करना
   गवाह, दस्तावेज़, फोटो आदि

5️⃣ न्यायाधीश का फैसला
   सभी बातें सुनकर अंतिम निर्णय

⚠️ महत्वपूर्ण: "Innocent until proven guilty" - जब तक दोष सिद्ध न हो, व्यक्ति निर्दोष माना जाता है।''',
        quiz: ModuleQuiz(
          questionEn: 'What does "innocent until proven guilty" mean?',
          questionHi: '"Innocent until proven guilty" का क्या मतलब है?',
          optionsEn: ['Accused is always innocent', 'Accused is guilty', 'Accused is innocent until court proves otherwise'],
          optionsHi: ['आरोपी हमेशा निर्दोष है', 'आरोपी दोषी है', 'जब तक अदालत दोष सिद्ध न करे, आरोपी निर्दोष है'],
          correctIndex: 2,
        ),
      ),
      LegalModule(
        icon: '🏛️',
        category: '🔰 Basics',
        titleEn: 'Types of Courts in India',
        titleHi: 'भारत में अदालतों के प्रकार',
        duration: '90 sec',
        contentEn: '''India has a three-tier court system:

🏛️ 1. Supreme Court
   📍 New Delhi
   👨‍⚖️ Chief Justice + 33 other judges
   📜 Highest court of the country

🏛️ 2. High Court
   📍 In every state
   👨‍⚖️ Highest court at state level
   📜 All state appeals come here

🏛️ 3. District Court
   📍 In every district
   👨‍⚖️ This is where YOU become a judge!
   📜 Most cases start here

🔄 Appeal Process:
District → High Court → Supreme Court

💼 Special Courts:
• Family Court (family matters)
• Consumer Court (customer complaints)
• Lok Adalat (mutual settlements)''',
        contentHi: '''भारत में तीन स्तरीय न्यायालय प्रणाली है:

🏛️ 1. सर्वोच्च न्यायालय (Supreme Court)
   📍 नई दिल्ली
   👨‍⚖️ मुख्य न्यायाधीश + 33 अन्य न्यायाधीश
   📜 देश की सबसे बड़ी अदालत

🏛️ 2. उच्च न्यायालय (High Court)
   📍 हर राज्य में
   👨‍⚖️ राज्य स्तर की सबसे बड़ी अदालत
   📜 राज्य के सभी अपील यहीं आते हैं

🏛️ 3. जिला न्यायालय (District Court)
   📍 हर जिले में
   👨‍⚖️ यहीं आप न्यायाधीश बनते हैं!
   📜 अधिकांश मुकदमे यहीं शुरू होते हैं

🔄 अपील प्रक्रिया:
District → High Court → Supreme Court

💼 विशेष अदालतें:
• फैमिली कोर्ट (पारिवारिक मामले)
• उपभोक्ता कोर्ट (ग्राहक शिकायतें)
• लोक अदालत (आपसी समझौते)''',
        quiz: ModuleQuiz(
          questionEn: 'Where do you start as a Civil Judge?',
          questionHi: 'सिविल जज के रूप में आप कहाँ से शुरू करते हैं?',
          optionsEn: ['Supreme Court', 'High Court', 'District Court'],
          optionsHi: ['सर्वोच्च न्यायालय', 'उच्च न्यायालय', 'जिला न्यायालय'],
          correctIndex: 2,
        ),
      ),
      // Career related
      LegalModule(
        icon: '🎓',
        category: '💼 Career',
        titleEn: 'How to Become a Judge?',
        titleHi: 'न्यायाधीश कैसे बनें?',
        duration: '90 sec',
        contentEn: '''There are two paths to become a judge:

📚 Path 1: Judicial Service Exam (PCS-J)

➡️ Eligibility:
• LLB degree (3 or 5 year)
• Age: 21-35 years (varies by state)

➡️ Exam:
• Prelims - MCQs
• Mains - Descriptive
• Interview

➡️ Position:
Start as Civil Judge (Junior Division)

📚 Path 2: After Practicing Law (Elevation)

➡️ 7+ years as advocate
➡️ Appointment to High Court/District Court

💰 Salary:
• Junior Civil Judge: ₹50,000 - ₹80,000/month
• District Judge: ₹1,00,000 - ₹1,50,000/month
• High Court Judge: ₹2,50,000+/month

📅 Preparation Time:
Start from Class 12 → Judge in 8-10 years!''',
        contentHi: '''न्यायाधीश बनने के दो रास्ते हैं:

📚 रास्ता 1: न्यायिक सेवा परीक्षा (PCS-J)

➡️ योग्यता:
• LLB डिग्री (3 या 5 वर्षीय)
• उम्र: 21-35 वर्ष (राज्य अनुसार)

➡️ परीक्षा:
• प्रारंभिक (Prelims) - MCQ
• मुख्य (Mains) - लिखित
• साक्षात्कार (Interview)

➡️ पद:
Civil Judge (Junior Division) से शुरू

📚 रास्ता 2: वकालत के बाद (Elevation)

➡️ 7+ वर्ष वकालत
➡️ High Court/District Judge के लिए नियुक्ति

💰 वेतन:
• Junior Civil Judge: ₹50,000 - ₹80,000/माह
• District Judge: ₹1,00,000 - ₹1,50,000/माह
• High Court Judge: ₹2,50,000+/माह

📅 तैयारी समय:
Class 12 से शुरू करें → 8-10 साल में जज!''',
        quiz: ModuleQuiz(
          questionEn: 'What is the starting position after clearing PCS-J exam?',
          questionHi: 'PCS-J परीक्षा पास करने के बाद शुरुआती पद क्या है?',
          optionsEn: ['District Judge', 'Civil Judge (Junior Division)', 'High Court Judge'],
          optionsHi: ['जिला न्यायाधीश', 'सिविल जज (जूनियर डिवीजन)', 'उच्च न्यायालय न्यायाधीश'],
          correctIndex: 1,
        ),
      ),
      LegalModule(
        icon: '📖',
        category: '💼 Career',
        titleEn: 'What Comes in the Exam?',
        titleHi: 'परीक्षा में क्या आता है?',
        duration: '90 sec',
        contentEn: '''Judicial Service Exam Pattern:

📝 Preliminary Exam (Prelims):
MCQ format - 2-3 hours

Subjects:
• General Knowledge
• General Knowledge of Law
• Language (Hindi/English)

📝 Main Exam (Mains):
Written - 3-4 papers

Subjects:
📚 Paper 1: Civil Law
   - CPC, Contract Act, Property Act
   
📚 Paper 2: Criminal Law
   - IPC, CrPC, Evidence Act
   
📚 Paper 3: Language
   - Essay, Translation in Hindi
   
📚 Paper 4: GK/Constitution

🎤 Interview:
• Personality test
• Legal knowledge
• Logical thinking

💡 Tip: Reading Bare Acts is essential!''',
        contentHi: '''न्यायिक सेवा परीक्षा का पैटर्न:

📝 प्रारंभिक परीक्षा (Prelims):
MCQ प्रारूप - 2-3 घंटे

विषय:
• सामान्य ज्ञान
• कानून का सामान्य ज्ञान
• भाषा (हिंदी/अंग्रेजी)

📝 मुख्य परीक्षा (Mains):
लिखित - 3-4 पेपर

विषय:
📚 Paper 1: सिविल कानून
   - CPC, Contract Act, Property Act
   
📚 Paper 2: आपराधिक कानून
   - IPC, CrPC, Evidence Act
   
📚 Paper 3: भाषा
   - हिंदी में निबंध, अनुवाद
   
📚 Paper 4: सामान्य ज्ञान/संविधान

🎤 साक्षात्कार:
• व्यक्तित्व परीक्षण
• कानूनी ज्ञान
• तार्किक सोच

💡 टिप: Bare Acts पढ़ना जरूरी है!''',
      ),
      // Practical Knowledge
      LegalModule(
        icon: '🛡️',
        category: '🔍 Practical',
        titleEn: 'Know Your Rights',
        titleHi: 'नागरिक अधिकार जानें',
        duration: '90 sec',
        contentEn: '''Every Indian citizen has these rights:

⚖️ During Arrest:
✅ Right to know reason for arrest
✅ Right to meet a lawyer
✅ Right to inform family
✅ Must be presented before magistrate in 24 hours
✅ Protection from torture

👩 Special Rights for Women:
✅ No arrest after sunset (generally)
✅ Search only by female police
✅ Protection from workplace harassment

👶 Children's Rights:
✅ Free and compulsory education (6-14 years)
✅ Protection from child labor
✅ Hearing at Juvenile Justice Board

💡 Remember:
"Knowing your rights is the first step."''',
        contentHi: '''हर भारतीय नागरिक को ये अधिकार हैं:

⚖️ गिरफ्तारी के समय:
✅ गिरफ्तारी का कारण जानने का अधिकार
✅ वकील से मिलने का अधिकार
✅ परिवार को सूचित करने का अधिकार
✅ 24 घंटे में मजिस्ट्रेट के सामने पेश होना
✅ मारपीट या यातना से सुरक्षा

👩 महिलाओं के विशेष अधिकार:
✅ सूर्यास्त के बाद गिरफ्तारी नहीं (सामान्यतः)
✅ महिला पुलिस द्वारा तलाशी
✅ कार्यस्थल पर यौन उत्पीड़न से सुरक्षा

👶 बच्चों के अधिकार:
✅ मुफ्त और अनिवार्य शिक्षा (6-14 वर्ष)
✅ बाल श्रम से सुरक्षा
✅ बाल न्याय बोर्ड में सुनवाई

💡 याद रखें:
"अधिकारों को जानना पहला कदम है।"''',
        quiz: ModuleQuiz(
          questionEn: 'Within how many hours must an arrested person be presented before a magistrate?',
          questionHi: 'गिरफ्तार व्यक्ति को कितने घंटे में मजिस्ट्रेट के सामने पेश करना होता है?',
          optionsEn: ['12 hours', '24 hours', '48 hours'],
          optionsHi: ['12 घंटे', '24 घंटे', '48 घंटे'],
          correctIndex: 1,
        ),
      ),
      LegalModule(
        icon: '🆘',
        category: '🔍 Practical',
        titleEn: 'Where to Get Legal Help?',
        titleHi: 'कानूनी सहायता कहाँ मिले?',
        duration: '90 sec',
        contentEn: '''Free legal aid is available in India:

🆓 Free Legal Aid (NALSA):

Eligible persons:
• Women and children
• SC/ST communities
• Economically weak (income < ₹3 lakh)
• Persons with disabilities
• Persons in custody

📞 Where to contact:

🔹 District Legal Services Authority (DLSA)
   In every district

🔹 Taluk Legal Services Committee
   At tehsil level

🔹 National Helpline: 15100
   or "NALSA" app

💻 Online:
• nalsa.gov.in
• eCourts Services app

💡 "Poverty should not be a barrier to justice"''',
        contentHi: '''भारत में मुफ्त कानूनी सहायता उपलब्ध है:

🆓 मुफ्त कानूनी सहायता (NALSA):

पात्र व्यक्ति:
• महिलाएं और बच्चे
• SC/ST समुदाय
• आर्थिक रूप से कमजोर (₹3 लाख से कम आय)
• विकलांग व्यक्ति
• कारावास में बंद व्यक्ति

📞 कहाँ संपर्क करें:

🔹 जिला कानूनी सेवा प्राधिकरण (DLSA)
   हर जिले में

🔹 तालुक कानूनी सेवा समिति
   तहसील स्तर पर

🔹 राष्ट्रीय हेल्पलाइन: 15100
   या "NALSA" ऐप

💻 ऑनलाइन:
• nalsa.gov.in
• eCourts Services ऐप

💡 "गरीबी न्याय में बाधा नहीं बननी चाहिए"''',
      ),
    ];
  }

  static List<LegalModule> _buildLandmarkCases() {
    return const [
      LegalModule(
        icon: '👩‍⚖️',
        category: '⚖️ Landmark',
        titleEn: 'Vishaka vs State of Rajasthan (1997)',
        titleHi: 'विशाखा बनाम राजस्थान राज्य (1997)',
        duration: '2 min',
        contentEn: '''⚖️ Vishaka vs State of Rajasthan (1997)
📌 Topic: Women Rights - Sexual Harassment at Workplace

📋 What Happened:
Bhanwari Devi, a social worker in Rajasthan, was gang-raped for trying to prevent a child marriage. This incident prompted women's rights organizations to file a PIL in the Supreme Court.

⚖️ Court Decision:
The Supreme Court issued the "Vishaka Guidelines" for prevention of sexual harassment at the workplace. It created legally binding rules until Parliament enacted legislation.

💡 Why It Matters:
This judgment laid the foundation for the "Sexual Harassment of Women at Workplace (Prevention, Prohibition and Redressal) Act, 2013." Every workplace must have an ICC (Internal Complaints Committee).

📄 Read More: https://indiankanoon.org/doc/1031794/''',
        contentHi: '''⚖️ विशाखा बनाम राजस्थान राज्य (1997)
📌 विषय: महिला अधिकार - कार्यस्थल पर यौन उत्पीड़न

📋 क्या हुआ:
राजस्थान में एक सामाजिक कार्यकर्ता भंवरी देवी के साथ बाल विवाह रोकने की कोशिश के कारण सामूहिक बलात्कार किया गया।

⚖️ अदालत का फैसला:
सर्वोच्च न्यायालय ने कार्यस्थल पर यौन उत्पीड़न की रोकथाम के लिए "विशाखा दिशानिर्देश" जारी किए।

💡 यह महत्वपूर्ण क्यों है:
इस फैसले ने 2013 में "कार्यस्थल पर महिलाओं का यौन उत्पीड़न (रोकथाम, निषेध और निवारण) अधिनियम" का आधार तैयार किया।

📄 अधिक जानें: https://indiankanoon.org/doc/1031794/''',
        quiz: ModuleQuiz(
          questionEn: 'What was the outcome of the Vishaka case?',
          questionHi: 'विशाखा केस का परिणाम क्या था?',
          optionsEn: ['Child labor ban', 'Sexual harassment guidelines at workplace', 'Land reforms'],
          optionsHi: ['बाल श्रम', 'कार्यस्थल पर यौन उत्पीड़न दिशानिर्देश', 'भूमि सुधार'],
          correctIndex: 1,
        ),
      ),
      LegalModule(
        icon: '👩‍⚖️',
        category: '⚖️ Landmark',
        titleEn: 'Shayara Bano vs Union of India (2017)',
        titleHi: 'शायरा बानो बनाम भारत संघ (2017)',
        duration: '2 min',
        contentEn: '''⚖️ Shayara Bano vs Union of India (2017)
📌 Topic: Women Rights - Triple Talaq

📋 What Happened:
Shayara Bano was divorced by her husband who pronounced "talaq" three times. She filed a petition to declare this practice unconstitutional.

⚖️ Court Decision:
The Supreme Court, by a 3-2 majority, declared Triple Talaq unconstitutional and void. It violated Article 14 (Equality) and Article 15 (Non-Discrimination).

💡 Why It Matters:
This led to the "Muslim Women (Protection of Rights on Marriage) Act, 2019" which made Triple Talaq a punishable offense.

📄 Read More: https://indiankanoon.org/doc/115701246/''',
        contentHi: '''⚖️ शायरा बानो बनाम भारत संघ (2017)
📌 विषय: महिला अधिकार - तीन तलाक

📋 क्या हुआ:
शायरा बानो को उनके पति ने तीन बार "तलाक" बोलकर तलाक दे दिया।

⚖️ अदालत का फैसला:
सर्वोच्च न्यायालय ने 3-2 बहुमत से तीन तलाक को असंवैधानिक और शून्य घोषित किया।

💡 यह महत्वपूर्ण क्यों है:
इससे 2019 में "मुस्लिम महिला (विवाह पर अधिकारों का संरक्षण) अधिनियम" बना।

📄 अधिक जानें: https://indiankanoon.org/doc/115701246/''',
        quiz: ModuleQuiz(
          questionEn: 'What was declared unconstitutional in the Shayara Bano case?',
          questionHi: 'शायरा बानो केस में क्या असंवैधानिक घोषित किया गया?',
          optionsEn: ['Polygamy', 'Triple Talaq (Talaq-e-Biddat)', 'Dowry system'],
          optionsHi: ['बहुविवाह', 'तीन तलाक (तलाक-ए-बिद्दत)', 'दहेज प्रथा'],
          correctIndex: 1,
        ),
      ),
      LegalModule(
        icon: '🔒',
        category: '⚖️ Landmark',
        titleEn: 'Puttaswamy - Right to Privacy (2017)',
        titleHi: 'पुट्टस्वामी - निजता का अधिकार (2017)',
        duration: '2 min',
        contentEn: '''⚖️ K.S. Puttaswamy vs Union of India (2017)
📌 Topic: Fundamental Rights - Privacy

📋 What Happened:
Justice K.S. Puttaswamy challenged the Aadhaar scheme, questioning whether citizens have a right to privacy.

⚖️ Court Decision:
A 9-judge bench unanimously declared that Right to Privacy is a fundamental right under Article 21 (Right to Life and Personal Liberty).

💡 Why It Matters:
This landmark judgment protects citizens' personal data, bodily autonomy, and informational privacy. It affects laws related to surveillance, data protection, and personal choices.

📄 Read More: https://indiankanoon.org/doc/127517806/''',
        contentHi: '''⚖️ के.एस. पुट्टस्वामी बनाम भारत संघ (2017)
📌 विषय: मौलिक अधिकार - निजता

📋 क्या हुआ:
जस्टिस पुट्टस्वामी ने आधार योजना को चुनौती दी।

⚖️ अदालत का फैसला:
9 न्यायाधीशों की पीठ ने सर्वसम्मति से निजता के अधिकार को अनुच्छेद 21 के तहत मौलिक अधिकार घोषित किया।

💡 यह महत्वपूर्ण क्यों है:
यह फैसला नागरिकों के व्यक्तिगत डेटा, शारीरिक स्वायत्तता और सूचना गोपनीयता की रक्षा करता है।

📄 अधिक जानें: https://indiankanoon.org/doc/127517806/''',
        quiz: ModuleQuiz(
          questionEn: 'Under which Article was Right to Privacy declared fundamental?',
          questionHi: 'निजता का अधिकार किस अनुच्छेद के तहत मौलिक अधिकार घोषित किया गया?',
          optionsEn: ['Article 14', 'Article 19', 'Article 21'],
          optionsHi: ['अनुच्छेद 14', 'अनुच्छेद 19', 'अनुच्छेद 21'],
          correctIndex: 2,
        ),
      ),
      LegalModule(
        icon: '📜',
        category: '⚖️ Landmark',
        titleEn: 'Kesavananda Bharati (1973)',
        titleHi: 'केशवानंद भारती (1973)',
        duration: '2 min',
        contentEn: '''⚖️ Kesavananda Bharati vs State of Kerala (1973)
📌 Topic: Constitutional Law - Basic Structure

📋 What Happened:
Swami Kesavananda Bharati challenged the Kerala government's land reform laws that affected his religious math's property.

⚖️ Court Decision:
A 13-judge bench (7-6 majority) established the "Basic Structure Doctrine" - Parliament can amend any part of the Constitution but cannot alter its basic structure.

💡 Basic Structure includes:
• Supremacy of Constitution
• Rule of Law
• Judicial Review
• Separation of Powers
• Federalism
• Secularism
• Unity and Sovereignty of India

📄 One of the most important constitutional cases ever!''',
        contentHi: '''⚖️ केशवानंद भारती बनाम केरल राज्य (1973)
📌 विषय: संवैधानिक कानून - मूल संरचना

📋 क्या हुआ:
स्वामी केशवानंद भारती ने केरल सरकार के भूमि सुधार कानूनों को चुनौती दी।

⚖️ अदालत का फैसला:
13 न्यायाधीशों की पीठ ने "मूल संरचना सिद्धांत" स्थापित किया - संसद संविधान के किसी भी भाग में संशोधन कर सकती है लेकिन इसकी मूल संरचना को नहीं बदल सकती।

💡 मूल संरचना में शामिल:
• संविधान की सर्वोच्चता
• कानून का शासन
• न्यायिक समीक्षा
• शक्तियों का पृथक्करण
• संघवाद
• धर्मनिरपेक्षता

📄 सबसे महत्वपूर्ण संवैधानिक मामलों में से एक!''',
        quiz: ModuleQuiz(
          questionEn: 'Which doctrine was established by the Kesavananda Bharati case?',
          questionHi: 'केशवानंद भारती केस ने कौन सा सिद्धांत स्थापित किया?',
          optionsEn: ['Doctrine of Separation', 'Basic Structure Doctrine', 'Doctrine of Equality'],
          optionsHi: ['पृथक्करण सिद्धांत', 'मूल संरचना सिद्धांत', 'समानता सिद्धांत'],
          correctIndex: 1,
        ),
      ),
    ];
  }
}
