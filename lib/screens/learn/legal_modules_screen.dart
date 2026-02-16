import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_theme.dart';
import '../../providers/locale_provider.dart';

class LegalModulesScreen extends StatelessWidget {
  const LegalModulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final isHindi = localeProvider.locale.languageCode == 'hi';

    final modules = _getLegalModules(isHindi);
    final quizzes = _getModuleQuizzes(isHindi);
    for (int i = 0; i < modules.length && i < quizzes.length; i++) {
      modules[i]['quiz'] = quizzes[i];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isHindi ? 'Legal Literacy' : 'Legal Literacy'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 18, color: Colors.brown),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isHindi
                        ? 'This is educational guidance. Always verify eligibility and exam rules from the latest official notification.'
                        : 'This is educational guidance. Always verify eligibility and exam rules from the latest official notification.',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.brown,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: modules.length,
              itemBuilder: (context, index) {
                final module = modules[index];
                return _ModuleCard(
                      icon: module['icon']! as String,
                      title: module['title']! as String,
                      duration: module['duration']! as String,
                      content: module['content']! as String,
                      category: module['category']! as String,
                      isHindi: isHindi,
                      quiz: module['quiz'] as Map<String, dynamic>?,
                    )
                    .animate(delay: Duration(milliseconds: 80 * index))
                    .fadeIn()
                    .slideY(begin: 0.1, end: 0);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getLegalModules(bool isHindi) {
    return [
      // === BASICS ===
      {
        'icon': '👨‍⚖️',
        'category': isHindi ? '🔰 मूल बातें' : '🔰 Basics',
        'title': isHindi ? 'न्यायाधीश कौन होते हैं?' : 'Who is a Judge?',
        'duration': '60 sec',
        'content': isHindi
            ? '''न्यायाधीश वह व्यक्ति है जो कोर्ट में बैठकर मुकदमों का फैसला करता है।

🔹 मुख्य कार्य:
• दोनों पक्षों की बात सुनना
• साक्ष्य (evidence) की जांच करना
• कानून के अनुसार निर्णय देना

🔹 गुण:
• निष्पक्ष (impartial) होना
• ईमानदार और धैर्यवान होना
• कानून का गहरा ज्ञान

💡 याद रखें: न्यायाधीश की शपथ में वे वादा करते हैं कि बिना भय या पक्षपात के न्याय करेंगे।'''
            : '''A judge is a person who sits in a court and decides legal cases.

🔹 Main Duties:
• Listen to both parties
• Examine evidence carefully
• Give decisions according to law

🔹 Qualities Required:
• Must be impartial (no favorites)
• Honest and patient
• Deep knowledge of law

💡 Remember: In their oath, judges promise to deliver justice "without fear or favor."''',
      },
      {
        'icon': '⚖️',
        'category': isHindi ? '🔰 मूल बातें' : '🔰 Basics',
        'title': isHindi ? 'अदालत कैसे काम करती है?' : 'How Does a Court Work?',
        'duration': '90 sec',
        'content': isHindi
            ? '''अदालत में न्याय प्रक्रिया कई चरणों में होती है:

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

⚠️ महत्वपूर्ण: "Innocent until proven guilty" - जब तक दोष सिद्ध न हो, व्यक्ति निर्दोष माना जाता है।'''
            : '''Justice in court follows a clear process:

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
      },
      {
        'icon': '🏛️',
        'category': isHindi ? '🔰 मूल बातें' : '🔰 Basics',
        'title': isHindi
            ? 'भारत में अदालतों के प्रकार'
            : 'Types of Courts in India',
        'duration': '90 sec',
        'content': isHindi
            ? '''भारत में तीन स्तरीय न्यायालय प्रणाली है:

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
• लोक अदालत (आपसी समझौते)'''
            : '''India has a three-tier court system:

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
      },
      {
        'icon': '📜',
        'category': isHindi ? '🔰 मूल बातें' : '🔰 Basics',
        'title': isHindi ? 'संविधान क्या है?' : 'What is the Constitution?',
        'duration': '90 sec',
        'content': isHindi
            ? '''भारत का संविधान देश का सर्वोच्च कानून है।

📅 लागू: 26 जनवरी 1950 (गणतंत्र दिवस)

📖 मुख्य विशेषताएं:

🔹 मौलिक अधिकार (Part III)
   • समानता का अधिकार
   • स्वतंत्रता का अधिकार
   • शोषण के विरुद्ध अधिकार
   • धर्म की स्वतंत्रता
   • शिक्षा का अधिकार
   • संवैधानिक उपचार का अधिकार

🔹 मौलिक कर्तव्य (Part IV-A)
   • संविधान का पालन करना
   • राष्ट्रीय ध्वज और गान का सम्मान
   • देश की रक्षा करना

⚖️ न्यायाधीश संविधान के संरक्षक होते हैं।
हर कानून और फैसला संविधान के अनुरूप होना चाहिए।'''
            : '''The Constitution of India is the supreme law of the country.

📅 Came into effect: 26 January 1950 (Republic Day)

📖 Key Features:

🔹 Fundamental Rights (Part III)
   • Right to Equality
   • Right to Freedom
   • Right Against Exploitation
   • Right to Freedom of Religion
   • Right to Education
   • Right to Constitutional Remedies

🔹 Fundamental Duties (Part IV-A)
   • Follow the Constitution
   • Respect National Flag and Anthem
   • Defend the country

⚖️ Judges are the guardians of the Constitution.
Every law and decision must follow the Constitution.''',
      },

      // === COURT SYSTEM ===
      {
        'icon': '👮',
        'category': isHindi ? '⚖️ न्यायालय प्रणाली' : '⚖️ Court System',
        'title': isHindi ? 'वकील और उनकी भूमिका' : 'Lawyers and Their Role',
        'duration': '90 sec',
        'content': isHindi
            ? '''वकील कानूनी मामलों में अपने मुवक्किल का प्रतिनिधित्व करते हैं।

👨‍💼 वकीलों के प्रकार:

1️⃣ निजी वकील (Private Lawyer)
   • व्यक्तिगत मामलों के लिए
   • फीस लेकर काम करते हैं

2️⃣ सरकारी वकील (Public Prosecutor)
   • अपराधिक मामलों में सरकार की तरफ से
   • पीड़ित का पक्ष रखते हैं

3️⃣ बचाव पक्ष का वकील (Defense Lawyer)
   • आरोपी का पक्ष रखता है
   • "हर आरोपी को वकील का अधिकार है"

4️⃣ सरकारी अधिवक्ता (Advocate General)
   • राज्य सरकार का कानूनी सलाहकार

📚 वकील बनने के लिए:
LLB डिग्री + Bar Council में रजिस्ट्रेशन

⚠️ वकील सच का पता नहीं लगाते, वे अपने पक्ष की बात रखते हैं।
न्यायाधीश सच का पता लगाते हैं!'''
            : '''Lawyers represent their clients in legal matters.

👨‍💼 Types of Lawyers:

1️⃣ Private Lawyer
   • For personal cases
   • Works for fees

2️⃣ Public Prosecutor
   • Represents government in criminal cases
   • Speaks for the victim

3️⃣ Defense Lawyer
   • Represents the accused
   • "Every accused has the right to a lawyer"

4️⃣ Advocate General
   • Legal advisor to state government

📚 To become a Lawyer:
LLB degree + Registration with Bar Council

⚠️ Lawyers don't find the truth, they present their side.
Judges find the truth!''',
      },
      {
        'icon': '📋',
        'category': isHindi ? '⚖️ न्यायालय प्रणाली' : '⚖️ Court System',
        'title': isHindi ? 'साक्ष्य का महत्व' : 'Importance of Evidence',
        'duration': '90 sec',
        'content': isHindi
            ? '''साक्ष्य (Evidence) वह प्रमाण है जो किसी बात को सिद्ध करता है।

📎 साक्ष्य के प्रकार:

1️⃣ दस्तावेजी साक्ष्य (Documentary)
   📄 कॉन्ट्रैक्ट, रसीद, पत्र, ईमेल

2️⃣ मौखिक साक्ष्य (Oral/Testimony)
   🗣️ गवाहों की गवाही

3️⃣ भौतिक साक्ष्य (Physical)
   🔍 हथियार, फिंगरप्रिंट, DNA

4️⃣ इलेक्ट्रॉनिक साक्ष्य (Electronic)
   📱 CCTV, फोन रिकॉर्ड, WhatsApp चैट

⚖️ साक्ष्य के नियम:

✅ प्रत्यक्ष साक्ष्य (Direct) - जो खुद देखा
❌ सुनी-सुनाई (Hearsay) - आमतौर पर मान्य नहीं
✅ परिस्थितिजन्य (Circumstantial) - संकेत देने वाला

💡 महत्वपूर्ण सिद्धांत:
"जो दावा करता है, उसे साबित करना होता है"
(Burden of Proof)'''
            : '''Evidence is proof that establishes facts in a case.

📎 Types of Evidence:

1️⃣ Documentary Evidence
   📄 Contracts, receipts, letters, emails

2️⃣ Oral Evidence (Testimony)
   🗣️ Witness statements

3️⃣ Physical Evidence
   🔍 Weapons, fingerprints, DNA

4️⃣ Electronic Evidence
   📱 CCTV, phone records, WhatsApp chats

⚖️ Rules of Evidence:

✅ Direct Evidence - What you saw yourself
❌ Hearsay - Usually not acceptable
✅ Circumstantial - Indicates something

💡 Important Principle:
"He who claims must prove"
(Burden of Proof)''',
      },
      {
        'icon': '🔨',
        'category': isHindi ? '⚖️ न्यायालय प्रणाली' : '⚖️ Court System',
        'title': isHindi ? 'न्यायिक प्रक्रिया' : 'Judicial Procedure',
        'duration': '90 sec',
        'content': isHindi
            ? '''कोर्ट में मुकदमा कई चरणों से गुजरता है:

📋 सिविल मामले (Civil Cases):

1️⃣ वाद (Plaint) दायर करना
2️⃣ समन भेजना (Summons)
3️⃣ लिखित बयान (Written Statement)
4️⃣ मुद्दों का निर्धारण (Framing Issues)
5️⃣ साक्ष्य प्रस्तुति
6️⃣ बहस (Arguments)
7️⃣ फैसला (Judgment)

📋 आपराधिक मामले (Criminal Cases):

1️⃣ FIR दर्ज करना
2️⃣ जांच (Investigation)
3️⃣ चार्जशीट दाखिल
4️⃣ आरोप तय करना (Charges)
5️⃣ मुकदमा चलाना (Trial)
6️⃣ फैसला और सजा

⏱️ समय सीमा:
• जमानत अर्जी - 24 घंटे में सुनवाई
• हत्या के मामले - 2 साल में ट्रायल पूरा (आदर्श)

💡 "Justice delayed is justice denied"'''
            : '''A case goes through many stages in court:

📋 Civil Cases:

1️⃣ Filing the Plaint
2️⃣ Sending Summons
3️⃣ Written Statement by defendant
4️⃣ Framing of Issues
5️⃣ Evidence presentation
6️⃣ Arguments
7️⃣ Judgment

📋 Criminal Cases:

1️⃣ FIR Registration
2️⃣ Investigation
3️⃣ Chargesheet filing
4️⃣ Framing Charges
5️⃣ Trial
6️⃣ Verdict and Sentence

⏱️ Time Limits:
• Bail application - hearing within 24 hours
• Murder cases - trial in 2 years (ideal)

💡 "Justice delayed is justice denied"''',
      },

      // === LEGAL CONCEPTS ===
      {
        'icon': '🎯',
        'category': isHindi ? '📚 कानूनी अवधारणाएं' : '📚 Legal Concepts',
        'title': isHindi ? 'निष्पक्षता क्या है?' : 'What is Impartiality?',
        'duration': '90 sec',
        'content': isHindi
            ? '''निष्पक्षता (Impartiality) न्यायाधीश का सबसे महत्वपूर्ण गुण है।

🎯 निष्पक्ष होने का मतलब:

✅ क्या करना है:
• दोनों पक्षों को समान अवसर देना
• केवल साक्ष्य पर भरोसा करना
• व्यक्तिगत राय को अलग रखना
• धीरज से सुनना

❌ क्या नहीं करना है:
• किसी पक्ष से सहानुभूति दिखाना
• पूर्वाग्रह (bias) रखना
• जाति, धर्म, लिंग का भेदभाव
• रिश्वत या दबाव में आना

🔍 पहचान कैसे करें?
अगर आप फैसले से पहले सोचते हैं "इसका पक्ष सही लगता है" - तो रुकें!

⚖️ न्यायाधीश की शपथ:
"मैं बिना भय या पक्षपात के, बिना स्नेह या द्वेष के न्याय करूंगा।"'''
            : '''Impartiality is the most important quality of a judge.

🎯 Being Impartial means:

✅ What to do:
• Give equal opportunity to both sides
• Trust only the evidence
• Keep personal opinions aside
• Listen patiently

❌ What NOT to do:
• Show sympathy to one party
• Have bias or prejudice
• Discriminate based on caste, religion, gender
• Accept bribes or pressure

🔍 How to check yourself?
If you think "this side seems right" before hearing everything - STOP!

⚖️ Judge's Oath:
"I will do justice without fear or favor, without affection or ill-will."''',
      },
      {
        'icon': '🔒',
        'category': isHindi ? '📚 कानूनी अवधारणाएं' : '📚 Legal Concepts',
        'title': isHindi ? 'जमानत कैसे काम करती है?' : 'How Does Bail Work?',
        'duration': '90 sec',
        'content': isHindi
            ? '''जमानत (Bail) वह प्रक्रिया है जिससे आरोपी को मुकदमे के दौरान रिहाई मिलती है।

📋 जमानत के प्रकार:

1️⃣ नियमित जमानत (Regular Bail)
   • मजिस्ट्रेट/सेशन कोर्ट से
   • गिरफ्तारी के बाद

2️⃣ अग्रिम जमानत (Anticipatory Bail)
   • गिरफ्तारी से पहले
   • संभावित गिरफ्तारी से बचाव

3️⃣ अंतरिम जमानत (Interim Bail)
   • अस्थायी राहत
   • नियमित जमानत तक

⚖️ जमानत देते समय विचार:
• अपराध की गंभीरता
• भागने की संभावना
• साक्ष्य खराब करने का खतरा
• आरोपी का पूर्व रिकॉर्ड

💡 "Bail is the rule, jail is exception"
जमानत नियम है, जेल अपवाद है।'''
            : '''Bail is the process by which an accused is released during trial.

📋 Types of Bail:

1️⃣ Regular Bail
   • From Magistrate/Sessions Court
   • After arrest

2️⃣ Anticipatory Bail
   • Before arrest
   • To prevent possible arrest

3️⃣ Interim Bail
   • Temporary relief
   • Until regular bail is decided

⚖️ Considerations for Bail:
• Seriousness of the crime
• Flight risk (will they run away?)
• Risk of tampering evidence
• Past criminal record

💡 "Bail is the rule, jail is the exception"''',
      },
      {
        'icon': '📝',
        'category': isHindi ? '📚 कानूनी अवधारणाएं' : '📚 Legal Concepts',
        'title': isHindi ? 'FIR और शिकायत में अंतर' : 'FIR vs Complaint',
        'duration': '90 sec',
        'content': isHindi
            ? '''कानूनी कार्रवाई शुरू करने के दो तरीके हैं:

📋 FIR (First Information Report):

🔹 कहाँ: पुलिस स्टेशन में
🔹 किसके लिए: गंभीर अपराध (cognizable)
   - हत्या, चोरी, मारपीट, बलात्कार
🔹 पुलिस क्या करती है:
   - तुरंत जांच शुरू
   - गिरफ्तारी कर सकती है

📋 शिकायत (Complaint):

🔹 कहाँ: मजिस्ट्रेट कोर्ट में
🔹 किसके लिए: गैर-गंभीर अपराध
   - धोखाधड़ी, अपमान, मानहानि
🔹 प्रक्रिया:
   - कोर्ट जांच का आदेश दे सकती है

⚠️ महत्वपूर्ण:
• FIR कॉपी मुफ्त मिलनी चाहिए
• ऑनलाइन FIR भी दर्ज हो सकती है
• Zero FIR - किसी भी थाने में दर्ज करें'''
            : '''There are two ways to start legal action:

📋 FIR (First Information Report):

🔹 Where: Police Station
🔹 For what: Serious crimes (cognizable)
   - Murder, theft, assault, rape
🔹 What police does:
   - Starts investigation immediately
   - Can make arrest

📋 Complaint:

🔹 Where: Magistrate Court
🔹 For what: Less serious offenses
   - Cheating, insult, defamation
🔹 Process:
   - Court may order investigation

⚠️ Important:
• FIR copy must be given free
• Online FIR can also be filed
• Zero FIR - file at any police station''',
      },

      // === YOUR CAREER ===
      {
        'icon': '🎓',
        'category': isHindi ? '💼 आपका करियर' : '💼 Your Career',
        'title': isHindi ? 'न्यायाधीश कैसे बनें?' : 'How to Become a Judge?',
        'duration': '90 sec',
        'content': isHindi
            ? '''न्यायाधीश बनने के दो रास्ते हैं:

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
Class 12 से शुरू करें → 8-10 साल में जज!'''
            : '''There are two paths to become a judge:

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
      },
      {
        'icon': '📖',
        'category': isHindi ? '💼 आपका करियर' : '💼 Your Career',
        'title': isHindi
            ? 'परीक्षा में क्या आता है?'
            : 'What Comes in the Exam?',
        'duration': '90 sec',
        'content': isHindi
            ? '''न्यायिक सेवा परीक्षा का पैटर्न:

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

💡 टिप: Bare Acts पढ़ना जरूरी है!'''
            : '''Judicial Service Exam Pattern:

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
      },
      {
        'icon': '📊',
        'category': isHindi ? '💼 आपका करियर' : '💼 Your Career',
        'title': isHindi ? 'राज्यवार परीक्षा जानकारी' : 'State-wise Exam Info',
        'duration': '90 sec',
        'content': isHindi
            ? '''भारत में न्यायिक सेवा परीक्षाएं राज्य स्तर पर होती हैं:

📋 प्रमुख राज्य परीक्षाएं:

🔹 उत्तर प्रदेश (UP PCS-J)
   • सबसे ज्यादा पद
   • प्रतियोगिता कठिन

🔹 राजस्थान (RJS)
   • हर साल परीक्षा
   • अच्छी पोस्टिंग

🔹 मध्य प्रदेश (MP JMFC)
   • नियमित भर्ती

🔹 बिहार (BPSC Judicial)
   • बढ़ती सीटें

🔹 दिल्ली (DJS)
   • केंद्रीय स्तर
   • अच्छा वेतन

📅 कब होती है परीक्षा?
• अधिकांश राज्य: साल में एक बार
• आवेदन: ऑनलाइन

⚠️ आयु सीमा अलग-अलग राज्यों में अलग
अपने राज्य की जानकारी लें!'''
            : '''Judicial Service exams in India are conducted at the state level:

📋 Major State Exams:

🔹 Uttar Pradesh (UP PCS-J)
   • Maximum posts
   • Tough competition

🔹 Rajasthan (RJS)
   • Annual exam
   • Good posting

🔹 Madhya Pradesh (MP JMFC)
   • Regular recruitment

🔹 Bihar (BPSC Judicial)
   • Increasing seats

🔹 Delhi (DJS)
   • Central level
   • Good salary

📅 When are exams held?
• Most states: Once a year
• Application: Online

⚠️ Age limit varies by state
Check your state's requirements!''',
      },

      // === PRACTICAL KNOWLEDGE ===
      {
        'icon': '🛡️',
        'category': isHindi ? '🔍 व्यावहारिक ज्ञान' : '🔍 Practical Knowledge',
        'title': isHindi ? 'नागरिक अधिकार जानें' : 'Know Your Rights',
        'duration': '90 sec',
        'content': isHindi
            ? '''हर भारतीय नागरिक को ये अधिकार हैं:

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
"अधिकारों को जानना पहला कदम है।"'''
            : '''Every Indian citizen has these rights:

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
      },
      {
        'icon': '🆘',
        'category': isHindi ? '🔍 व्यावहारिक ज्ञान' : '🔍 Practical Knowledge',
        'title': isHindi
            ? 'कानूनी सहायता कहाँ मिले?'
            : 'Where to Get Legal Help?',
        'duration': '90 sec',
        'content': isHindi
            ? '''भारत में मुफ्त कानूनी सहायता उपलब्ध है:

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

💡 "गरीबी न्याय में बाधा नहीं बननी चाहिए"'''
            : '''Free legal aid is available in India:

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
      },

      // === LANDMARK CASES ===
      // 1. Vishaka vs State of Rajasthan (Women Rights)
      {
        'icon': '👩‍⚖️',
        'category': isHindi ? '⚖️ ऐतिहासिक फैसले' : '⚖️ Landmark Cases',
        'title': isHindi
            ? 'विशाखा बनाम राजस्थान राज्य (1997)'
            : 'Vishaka vs State of Rajasthan (1997)',
        'duration': '2 min',
        'content': isHindi
            ? '''⚖️ विशाखा बनाम राजस्थान राज्य (1997)
📌 विषय: महिला अधिकार - कार्यस्थल पर यौन उत्पीड़न

📋 क्या हुआ:
राजस्थान में एक सामाजिक कार्यकर्ता भंवरी देवी के साथ बाल विवाह रोकने की कोशिश के कारण सामूहिक बलात्कार किया गया। इस घटना ने महिला अधिकार संगठनों को सर्वोच्च न्यायालय में याचिका दायर करने के लिए प्रेरित किया।

⚖️ अदालत का फैसला:
सर्वोच्च न्यायालय ने कार्यस्थल पर यौन उत्पीड़न की रोकथाम के लिए "विशाखा दिशानिर्देश" जारी किए। इसने कानूनी रूप से बाध्यकारी नियम बनाए जब तक कि संसद कानून नहीं बनाती।

💡 यह महत्वपूर्ण क्यों है:
इस फैसले ने 2013 में "कार्यस्थल पर महिलाओं का यौन उत्पीड़न (रोकथाम, निषेध और निवारण) अधिनियम" का आधार तैयार किया। हर कार्यस्थल पर ICC (आंतरिक शिकायत समिति) अनिवार्य हुई।

📄 आधिकारिक दस्तावेज़:
indiankanoon.org/doc/1031794/

🎬 YouTube पर देखें:
https://www.youtube.com/results?search_query=vishaka+vs+state+of+rajasthan+explained'''
            : '''⚖️ Vishaka vs State of Rajasthan (1997)
📌 Topic: Women Rights - Sexual Harassment at Workplace

📋 What Happened:
Bhanwari Devi, a social worker in Rajasthan, was gang-raped for trying to prevent a child marriage. This incident prompted women's rights organizations to file a PIL in the Supreme Court.

⚖️ Court Decision:
The Supreme Court issued the "Vishaka Guidelines" for prevention of sexual harassment at the workplace. It created legally binding rules until Parliament enacted legislation.

💡 Why It Matters:
This judgment laid the foundation for the "Sexual Harassment of Women at Workplace (Prevention, Prohibition and Redressal) Act, 2013." Every workplace must have an ICC (Internal Complaints Committee).

📄 Official Document:
indiankanoon.org/doc/1031794/

🎬 Watch on YouTube:
https://www.youtube.com/results?search_query=vishaka+vs+state+of+rajasthan+explained''',
      },
      // 2. Shayara Bano vs Union of India (Women Rights)
      {
        'icon': '👩‍⚖️',
        'category': isHindi ? '⚖️ ऐतिहासिक फैसले' : '⚖️ Landmark Cases',
        'title': isHindi
            ? 'शायरा बानो बनाम भारत संघ (2017)'
            : 'Shayara Bano vs Union of India (2017)',
        'duration': '2 min',
        'content': isHindi
            ? '''⚖️ शायरा बानो बनाम भारत संघ (2017)
📌 विषय: महिला अधिकार - तीन तलाक

📋 क्या हुआ:
शायरा बानो को उनके पति ने तीन बार "तलाक" बोलकर तलाक दे दिया (तीन तलाक/तलाक-ए-बिद्दत)। उन्होंने इस प्रथा को असंवैधानिक घोषित करने के लिए सर्वोच्च न्यायालय में याचिका दायर की।

⚖️ अदालत का फैसला:
सर्वोच्च न्यायालय ने 3-2 बहुमत से तीन तलाक को असंवैधानिक और शून्य घोषित किया। इसे अनुच्छेद 14 (समानता) और अनुच्छेद 15 (भेदभाव निषेध) का उल्लंघन माना।

💡 यह महत्वपूर्ण क्यों है:
इससे 2019 में "मुस्लिम महिला (विवाह पर अधिकारों का संरक्षण) अधिनियम" बना, जिसने तीन तलाक को दंडनीय अपराध बनाया। यह मुस्लिम महिलाओं के अधिकारों की रक्षा का ऐतिहासिक कदम था।

📄 आधिकारिक दस्तावेज़:
indiankanoon.org/doc/115701246/

🎬 YouTube पर देखें:
https://www.youtube.com/results?search_query=shayara+bano+triple+talaq+case+explained'''
            : '''⚖️ Shayara Bano vs Union of India (2017)
📌 Topic: Women Rights - Triple Talaq

📋 What Happened:
Shayara Bano was divorced by her husband who pronounced "talaq" three times (Triple Talaq / Talaq-e-Biddat). She filed a petition in the Supreme Court to declare this practice unconstitutional.

⚖️ Court Decision:
The Supreme Court, by a 3-2 majority, declared Triple Talaq unconstitutional and void. It was held to violate Article 14 (Equality) and Article 15 (Non-Discrimination).

💡 Why It Matters:
This led to the "Muslim Women (Protection of Rights on Marriage) Act, 2019" which made Triple Talaq a punishable offense. It was a historic step in protecting the rights of Muslim women.

📄 Official Document:
indiankanoon.org/doc/115701246/

🎬 Watch on YouTube:
https://www.youtube.com/results?search_query=shayara+bano+triple+talaq+case+explained''',
      },
      // 3. Justice K.S. Puttaswamy vs Union of India (Right to Privacy)
      {
        'icon': '🔒',
        'category': isHindi ? '⚖️ ऐतिहासिक फैसले' : '⚖️ Landmark Cases',
        'title': isHindi
            ? 'के.एस. पुट्टस्वामी बनाम भारत संघ (2017)'
            : 'Justice K.S. Puttaswamy vs Union of India (2017)',
        'duration': '2 min',
        'content': isHindi
            ? '''⚖️ के.एस. पुट्टस्वामी बनाम भारत संघ (2017)
📌 विषय: निजता का अधिकार

📋 क्या हुआ:
सेवानिवृत्त न्यायाधीश के.एस. पुट्टस्वामी ने आधार कार्ड योजना को चुनौती दी, जिसमें नागरिकों का बायोमेट्रिक डेटा एकत्र किया जा रहा था। सवाल यह था कि क्या निजता (Privacy) एक मौलिक अधिकार है।

⚖️ अदालत का फैसला:
9 न्यायाधीशों की संविधान पीठ ने सर्वसम्मति से निजता के अधिकार को अनुच्छेद 21 (जीवन का अधिकार) के तहत मौलिक अधिकार घोषित किया।

💡 यह महत्वपूर्ण क्यों है:
इसने डिजिटल युग में नागरिकों के डेटा संरक्षण का आधार तैयार किया। 2023 का "डिजिटल व्यक्तिगत डेटा संरक्षण अधिनियम" इसी फैसले पर आधारित है। LGBTQ+ अधिकारों के लिए भी यह मार्गदर्शक बना।

📄 आधिकारिक दस्तावेज़:
indiankanoon.org/doc/127517806/

🎬 YouTube पर देखें:
https://www.youtube.com/results?search_query=puttaswamy+right+to+privacy+case+explained'''
            : '''⚖️ Justice K.S. Puttaswamy vs Union of India (2017)
📌 Topic: Right to Privacy

📋 What Happened:
Retired Justice K.S. Puttaswamy challenged the Aadhaar card scheme, which collected citizens' biometric data. The question was whether Privacy is a fundamental right.

⚖️ Court Decision:
A 9-judge Constitution Bench unanimously declared the Right to Privacy as a fundamental right under Article 21 (Right to Life).

💡 Why It Matters:
It laid the foundation for citizens' data protection in the digital age. The "Digital Personal Data Protection Act, 2023" is based on this judgment. It also became a guiding precedent for LGBTQ+ rights.

📄 Official Document:
indiankanoon.org/doc/127517806/

🎬 Watch on YouTube:
https://www.youtube.com/results?search_query=puttaswamy+right+to+privacy+case+explained''',
      },
      // 4. Kesavananda Bharati vs State of Kerala (Constitutional Rights)
      {
        'icon': '📜',
        'category': isHindi ? '⚖️ ऐतिहासिक फैसले' : '⚖️ Landmark Cases',
        'title': isHindi
            ? 'केशवानंद भारती बनाम केरल राज्य (1973)'
            : 'Kesavananda Bharati vs State of Kerala (1973)',
        'duration': '2 min',
        'content': isHindi
            ? '''⚖️ केशवानंद भारती बनाम केरल राज्य (1973)
📌 विषय: संवैधानिक अधिकार - मूल संरचना सिद्धांत

📋 क्या हुआ:
केरल सरकार ने भूमि सुधार कानूनों के तहत केशवानंद भारती (एक मठ प्रमुख) की संपत्ति अधिग्रहित की। उन्होंने इसे चुनौती दी और सवाल उठा कि क्या संसद संविधान में कोई भी संशोधन कर सकती है।

⚖️ अदालत का फैसला:
13 न्यायाधीशों की सबसे बड़ी संविधान पीठ ने 7-6 बहुमत से "मूल संरचना सिद्धांत" (Basic Structure Doctrine) प्रतिपादित किया। संसद संविधान में संशोधन कर सकती है, लेकिन उसकी मूल संरचना को नहीं बदल सकती।

💡 यह महत्वपूर्ण क्यों है:
यह भारतीय संविधानिक कानून का सबसे महत्वपूर्ण फैसला है। इसने संविधान को तानाशाही से बचाया। न्यायिक समीक्षा, लोकतंत्र, धर्मनिरपेक्षता, मौलिक अधिकार - ये सब मूल संरचना का हिस्सा हैं।

📄 आधिकारिक दस्तावेज़:
indiankanoon.org/doc/257876/

🎬 YouTube पर देखें:
https://www.youtube.com/results?search_query=kesavananda+bharati+basic+structure+doctrine+explained'''
            : '''⚖️ Kesavananda Bharati vs State of Kerala (1973)
📌 Topic: Constitutional Rights - Basic Structure Doctrine

📋 What Happened:
The Kerala government acquired land belonging to Kesavananda Bharati (a religious leader) under land reform laws. He challenged this, raising the question of whether Parliament can make any amendment to the Constitution.

⚖️ Court Decision:
The largest-ever 13-judge Constitution Bench, by 7-6 majority, established the "Basic Structure Doctrine." Parliament can amend the Constitution but cannot alter its basic structure.

💡 Why It Matters:
This is the most important judgment in Indian constitutional law. It protected the Constitution from authoritarian changes. Judicial review, democracy, secularism, fundamental rights — all are part of the basic structure.

📄 Official Document:
indiankanoon.org/doc/257876/

🎬 Watch on YouTube:
https://www.youtube.com/results?search_query=kesavananda+bharati+basic+structure+doctrine+explained''',
      },
      // 5. Maneka Gandhi vs Union of India (Constitutional Rights)
      {
        'icon': '📜',
        'category': isHindi ? '⚖️ ऐतिहासिक फैसले' : '⚖️ Landmark Cases',
        'title': isHindi
            ? 'मेनका गांधी बनाम भारत संघ (1978)'
            : 'Maneka Gandhi vs Union of India (1978)',
        'duration': '2 min',
        'content': isHindi
            ? '''⚖️ मेनका गांधी बनाम भारत संघ (1978)
📌 विषय: संवैधानिक अधिकार - अनुच्छेद 21 का विस्तार

📋 क्या हुआ:
मेनका गांधी का पासपोर्ट सरकार ने बिना कारण बताए जब्त कर लिया। उन्होंने इसे अनुच्छेद 21 (जीवन और व्यक्तिगत स्वतंत्रता) के उल्लंघन के रूप में चुनौती दी।

⚖️ अदालत का फैसला:
सर्वोच्च न्यायालय ने अनुच्छेद 21 की व्याख्या का विस्तार किया। "जीवन का अधिकार" केवल जीवित रहने का अधिकार नहीं, बल्कि "गरिमा के साथ जीने का अधिकार" है। कोई भी कानून जो मनमाना, अन्यायपूर्ण या अनुचित हो, वह अनुच्छेद 21 का उल्लंघन है।

💡 यह महत्वपूर्ण क्यों है:
इस फैसले ने "Due Process of Law" की अवधारणा भारत में लागू की। अनुच्छेद 14, 19 और 21 को एक साथ पढ़ने की परंपरा शुरू हुई। आज के सभी मानवाधिकार मामलों में इस फैसले का हवाला दिया जाता है।

📄 आधिकारिक दस्तावेज़:
indiankanoon.org/doc/1766147/

🎬 YouTube पर देखें:
https://www.youtube.com/results?search_query=maneka+gandhi+vs+union+of+india+explained'''
            : '''⚖️ Maneka Gandhi vs Union of India (1978)
📌 Topic: Constitutional Rights - Expansion of Article 21

📋 What Happened:
Maneka Gandhi's passport was impounded by the government without giving any reason. She challenged this as a violation of Article 21 (Right to Life and Personal Liberty).

⚖️ Court Decision:
The Supreme Court expanded the interpretation of Article 21. "Right to Life" is not merely the right to survive but the "right to live with dignity." Any law that is arbitrary, unjust, or unfair violates Article 21.

💡 Why It Matters:
This judgment introduced the concept of "Due Process of Law" in India. It established the practice of reading Articles 14, 19, and 21 together. This case is cited in almost all human rights cases today.

📄 Official Document:
indiankanoon.org/doc/1766147/

🎬 Watch on YouTube:
https://www.youtube.com/results?search_query=maneka+gandhi+vs+union+of+india+explained''',
      },
      // 6. Nirbhaya Case (Criminal Law)
      {
        'icon': '⚔️',
        'category': isHindi ? '⚖️ ऐतिहासिक फैसले' : '⚖️ Landmark Cases',
        'title': isHindi
            ? 'निर्भया केस - मुकेश बनाम NCT दिल्ली (2017)'
            : 'Nirbhaya Case - Mukesh vs NCT of Delhi (2017)',
        'duration': '2 min',
        'content': isHindi
            ? '''⚖️ निर्भया केस - मुकेश बनाम NCT दिल्ली (2017)
📌 विषय: आपराधिक कानून - यौन अपराध

📋 क्या हुआ:
16 दिसंबर 2012 को दिल्ली में एक 23 वर्षीय फिजियोथेरेपी छात्रा ("निर्भया") के साथ चलती बस में सामूहिक बलात्कार और क्रूर हिंसा की गई। उनकी 13 दिन बाद मृत्यु हो गई। इस घटना ने पूरे भारत में व्यापक विरोध प्रदर्शन किए।

⚖️ अदालत का फैसला:
सर्वोच्च न्यायालय ने चार दोषियों की मृत्युदंड की सजा बरकरार रखी। वर्मा समिति की सिफारिशों पर "Criminal Law (Amendment) Act, 2013" बना।

💡 यह महत्वपूर्ण क्यों है:
इसने भारतीय दंड विधान में क्रांतिकारी बदलाव लाए:
• बलात्कार की परिभाषा का विस्तार
• एसिड अटैक, Stalking, Voyeurism — नए अपराध बने
• सामूहिक बलात्कार में मृत्युदंड का प्रावधान
• फास्ट-ट्रैक कोर्ट की स्थापना

📄 आधिकारिक दस्तावेज़:
indiankanoon.org/doc/78529648/

🎬 YouTube पर देखें:
https://www.youtube.com/results?search_query=nirbhaya+case+india+explained'''
            : '''⚖️ Nirbhaya Case - Mukesh vs NCT of Delhi (2017)
📌 Topic: Criminal Law - Sexual Offenses

📋 What Happened:
On December 16, 2012, a 23-year-old physiotherapy student ("Nirbhaya") was gang-raped and brutally assaulted on a moving bus in Delhi. She died 13 days later. The incident sparked massive protests across India.

⚖️ Court Decision:
The Supreme Court upheld the death sentence of four convicts. Based on the Justice Verma Committee recommendations, the "Criminal Law (Amendment) Act, 2013" was enacted.

💡 Why It Matters:
It brought revolutionary changes to Indian criminal law:
• Expanded definition of rape
• Acid attack, Stalking, Voyeurism — made new offenses
• Provision for death penalty in gang rape cases
• Establishment of Fast-Track Courts

📄 Official Document:
indiankanoon.org/doc/78529648/

🎬 Watch on YouTube:
https://www.youtube.com/results?search_query=nirbhaya+case+india+explained''',
      },
      // 7. DK Basu vs State of West Bengal (Criminal Law)
      {
        'icon': '⚔️',
        'category': isHindi ? '⚖️ ऐतिहासिक फैसले' : '⚖️ Landmark Cases',
        'title': isHindi
            ? 'डी.के. बसु बनाम पश्चिम बंगाल राज्य (1997)'
            : 'DK Basu vs State of West Bengal (1997)',
        'duration': '2 min',
        'content': isHindi
            ? '''⚖️ डी.के. बसु बनाम पश्चिम बंगाल राज्य (1997)
📌 विषय: आपराधिक कानून - हिरासत में अधिकार

📋 क्या हुआ:
"लीगल एड सर्विसेज" के कार्यकारी अध्यक्ष डी.के. बसु ने पुलिस हिरासत में होने वाली मौतों और यातनाओं के विरुद्ध सर्वोच्च न्यायालय को पत्र लिखा, जिसे जनहित याचिका (PIL) के रूप में स्वीकार किया गया।

⚖️ अदालत का फैसला:
सर्वोच्च न्यायालय ने गिरफ्तारी के समय पालन किए जाने वाले 11 अनिवार्य दिशानिर्देश जारी किए:
• गिरफ्तारी मेमो तैयार करना
• परिवार को सूचित करना
• मेडिकल जांच कराना
• गिरफ्तारी का रिकॉर्ड रखना

💡 यह महत्वपूर्ण क्यों है:
इसने पुलिस के मनमाने व्यवहार पर लगाम लगाई। गिरफ्तार व्यक्ति के अधिकारों को संवैधानिक संरक्षण मिला। हर पुलिस स्टेशन में इन नियमों का पालन अनिवार्य है।

📄 आधिकारिक दस्तावेज़:
indiankanoon.org/doc/501198/

🎬 YouTube पर देखें:
https://www.youtube.com/results?search_query=dk+basu+vs+state+of+west+bengal+explained'''
            : '''⚖️ DK Basu vs State of West Bengal (1997)
📌 Topic: Criminal Law - Rights During Arrest/Custody

📋 What Happened:
DK Basu, Executive Chairman of "Legal Aid Services," wrote to the Supreme Court about custodial deaths and torture by police, which was treated as a PIL (Public Interest Litigation).

⚖️ Court Decision:
The Supreme Court issued 11 mandatory guidelines to be followed at the time of arrest:
• Prepare arrest memo
• Inform the family
• Conduct medical examination
• Maintain arrest records

💡 Why It Matters:
It curbed arbitrary police behavior. Arrested persons received constitutional protection of their rights. These rules are mandatory in every police station.

📄 Official Document:
indiankanoon.org/doc/501198/

🎬 Watch on YouTube:
https://www.youtube.com/results?search_query=dk+basu+vs+state+of+west+bengal+explained''',
      },
      // 8. Unnikrishnan vs State of AP (Right to Education)
      {
        'icon': '🎓',
        'category': isHindi ? '⚖️ ऐतिहासिक फैसले' : '⚖️ Landmark Cases',
        'title': isHindi
            ? 'उन्नीकृष्णन बनाम आंध्र प्रदेश राज्य (1993)'
            : 'Unnikrishnan vs State of AP (1993)',
        'duration': '2 min',
        'content': isHindi
            ? '''⚖️ उन्नीकृष्णन बनाम आंध्र प्रदेश राज्य (1993)
📌 विषय: शिक्षा का अधिकार

📋 क्या हुआ:
आंध्र प्रदेश में निजी शिक्षण संस्थानों की मनमानी फीस के खिलाफ याचिका दायर की गई। सवाल यह था कि क्या शिक्षा का अधिकार एक मौलिक अधिकार है।

⚖️ अदालत का फैसला:
सर्वोच्च न्यायालय ने 14 वर्ष तक के बच्चों के लिए शिक्षा के अधिकार को अनुच्छेद 21 (जीवन का अधिकार) के तहत मौलिक अधिकार घोषित किया। निजी संस्थानों को भी सामाजिक दायित्व निभाना होगा।

💡 यह महत्वपूर्ण क्यों है:
इस फैसले ने 2002 में 86वें संविधान संशोधन का मार्ग प्रशस्त किया, जिसने अनुच्छेद 21-A (6-14 वर्ष के बच्चों को मुफ्त और अनिवार्य शिक्षा) जोड़ा। 2009 में "शिक्षा का अधिकार अधिनियम" (RTE Act) बना।

📄 आधिकारिक दस्तावेज़:
indiankanoon.org/doc/1775396/

🎬 YouTube पर देखें:
https://www.youtube.com/results?search_query=unnikrishnan+right+to+education+case+explained'''
            : '''⚖️ Unnikrishnan vs State of AP (1993)
📌 Topic: Right to Education

📋 What Happened:
A petition was filed against arbitrary fees by private educational institutions in Andhra Pradesh. The question was whether the Right to Education is a fundamental right.

⚖️ Court Decision:
The Supreme Court declared the Right to Education for children up to 14 years as a fundamental right under Article 21 (Right to Life). Private institutions also have social obligations.

💡 Why It Matters:
This judgment paved the way for the 86th Constitutional Amendment in 2002, which added Article 21-A (free and compulsory education for children aged 6-14). The "Right to Education Act" (RTE Act) was enacted in 2009.

📄 Official Document:
indiankanoon.org/doc/1775396/

🎬 Watch on YouTube:
https://www.youtube.com/results?search_query=unnikrishnan+right+to+education+case+explained''',
      },
      // 9. Olga Tellis vs Bombay Municipal Corporation (Right to Livelihood)
      {
        'icon': '🏠',
        'category': isHindi ? '⚖️ ऐतिहासिक फैसले' : '⚖️ Landmark Cases',
        'title': isHindi
            ? 'ओल्गा टेलिस बनाम बॉम्बे म्यूनिसिपल कॉर्पोरेशन (1985)'
            : 'Olga Tellis vs Bombay Municipal Corporation (1985)',
        'duration': '2 min',
        'content': isHindi
            ? '''⚖️ ओल्गा टेलिस बनाम बॉम्बे म्यूनिसिपल कॉर्पोरेशन (1985)
📌 विषय: आजीविका का अधिकार

📋 क्या हुआ:
बॉम्बे (मुंबई) नगरपालिका ने फुटपाथ पर रहने वालों (pavement dwellers) और झुग्गी-झोपड़ियों को हटाने का आदेश दिया। पत्रकार ओल्गा टेलिस ने इन गरीब लोगों की ओर से सर्वोच्च न्यायालय में याचिका दायर की।

⚖️ अदालत का फैसला:
सर्वोच्च न्यायालय ने कहा कि "आजीविका का अधिकार" अनुच्छेद 21 (जीवन का अधिकार) का अभिन्न हिस्सा है। कोई भी व्यक्ति जो जीवन जीने के लिए किसी जगह पर रहता है, उसे बिना उचित पुनर्वास के नहीं हटाया जा सकता।

💡 यह महत्वपूर्ण क्यों है:
इस फैसले ने "आजीविका का अधिकार" को मौलिक अधिकार के रूप में मान्यता दी। शहरी गरीबों के अधिकारों की रक्षा हुई। बेदखली से पहले पुनर्वास अनिवार्य बना। यह सामाजिक न्याय का मील का पत्थर है।

📄 आधिकारिक दस्तावेज़:
indiankanoon.org/doc/709776/

🎬 YouTube पर देखें:
https://www.youtube.com/results?search_query=olga+tellis+vs+bombay+municipal+corporation+explained'''
            : '''⚖️ Olga Tellis vs Bombay Municipal Corporation (1985)
📌 Topic: Right to Livelihood

📋 What Happened:
The Bombay (Mumbai) Municipal Corporation ordered the eviction of pavement dwellers and slum residents. Journalist Olga Tellis filed a petition in the Supreme Court on behalf of these poor people.

⚖️ Court Decision:
The Supreme Court held that the "Right to Livelihood" is an integral part of Article 21 (Right to Life). No person living in a place for livelihood can be evicted without proper rehabilitation.

💡 Why It Matters:
This judgment recognized the "Right to Livelihood" as a fundamental right. It protected the rights of urban poor. Rehabilitation before eviction became mandatory. It is a milestone in social justice.

📄 Official Document:
indiankanoon.org/doc/709776/

🎬 Watch on YouTube:
https://www.youtube.com/results?search_query=olga+tellis+vs+bombay+municipal+corporation+explained''',
      },
    ];
  }

  // Quiz data for each module (bilingual)
  List<Map<String, dynamic>> _getModuleQuizzes(bool isHindi) {
    return [
      // 1. Who is a Judge?
      {
        'question': isHindi
            ? 'न्यायाधीश का मुख्य कर्तव्य क्या है?'
            : 'What is the main duty of a judge?',
        'options': isHindi
            ? <String>[
                'सजा देना',
                'कानून के अनुसार निष्पक्ष निर्णय देना',
                'वकीलों से सहमत होना',
              ]
            : <String>[
                'To punish the accused',
                'To give impartial decisions according to law',
                'To agree with lawyers',
              ],
        'correct': 1,
      },
      // 2. How Does a Court Work?
      {
        'question': isHindi
            ? '"Innocent until proven guilty" का मतलब क्या है?'
            : 'What does "Innocent until proven guilty" mean?',
        'options': isHindi
            ? <String>[
                'आरोपी हमेशा दोषी है',
                'दोष सिद्ध होने तक व्यक्ति निर्दोष है',
                'जज तय करता है कौन दोषी है',
              ]
            : <String>[
                'The accused is always guilty',
                'A person is innocent until proven guilty',
                'The judge decides who is guilty first',
              ],
        'correct': 1,
      },
      // 3. Court Hierarchy (3-tier)
      {
        'question': isHindi
            ? 'भारत में सबसे ऊँची अदालत कौन सी है?'
            : 'What is the highest court in India?',
        'options': isHindi
            ? <String>['जिला न्यायालय', 'उच्च न्यायालय', 'सर्वोच्च न्यायालय']
            : <String>['District Court', 'High Court', 'Supreme Court'],
        'correct': 2,
      },
      // 4. What is the Constitution?
      {
        'question': isHindi
            ? 'भारत का संविधान कब लागू हुआ?'
            : 'When did the Indian Constitution come into effect?',
        'options': isHindi
            ? <String>['15 अगस्त 1947', '26 जनवरी 1950', '26 नवंबर 1949']
            : <String>['15 August 1947', '26 January 1950', '26 November 1949'],
        'correct': 1,
      },
      // 5. Fundamental Rights
      {
        'question': isHindi
            ? 'मौलिक अधिकार संविधान के किस भाग में हैं?'
            : 'In which part of the Constitution are Fundamental Rights?',
        'options': isHindi
            ? <String>['भाग II', 'भाग III', 'भाग IV']
            : <String>['Part II', 'Part III', 'Part IV'],
        'correct': 1,
      },
      // 6. Criminal vs Civil Law
      {
        'question': isHindi
            ? 'संपत्ति का विवाद किस प्रकार का केस है?'
            : 'A property dispute is which type of case?',
        'options': isHindi
            ? <String>[
                'आपराधिक (Criminal)',
                'दीवानी (Civil)',
                'संवैधानिक (Constitutional)',
              ]
            : <String>['Criminal', 'Civil', 'Constitutional'],
        'correct': 1,
      },
      // 7. FIR Process
      {
        'question': isHindi
            ? 'FIR का पूरा नाम क्या है?'
            : 'What is the full form of FIR?',
        'options': isHindi
            ? <String>[
                'First Inquiry Report',
                'First Information Report',
                'Final Investigation Report',
              ]
            : <String>[
                'First Inquiry Report',
                'First Information Report',
                'Final Investigation Report',
              ],
        'correct': 1,
      },
      // 8. Consumer Rights
      {
        'question': isHindi
            ? 'उपभोक्ता शिकायत कहाँ दर्ज कर सकते हैं?'
            : 'Where can a consumer file a complaint?',
        'options': isHindi
            ? <String>[
                'पुलिस स्टेशन',
                'उपभोक्ता फोरम / consumerhelpline.gov.in',
                'सुप्रीम कोर्ट',
              ]
            : <String>[
                'Police station only',
                'Consumer Forum / consumerhelpline.gov.in',
                'Supreme Court only',
              ],
        'correct': 1,
      },
      // 9. Cyber Law
      {
        'question': isHindi
            ? 'साइबर अपराध के लिए कौन सा कानून है?'
            : 'Which law deals with cyber crimes in India?',
        'options': isHindi
            ? <String>['IPC', 'IT Act 2000', 'Consumer Protection Act']
            : <String>['IPC', 'IT Act 2000', 'Consumer Protection Act'],
        'correct': 1,
      },
      // 10. RTI
      {
        'question': isHindi
            ? 'RTI आवेदन की फीस कितनी है?'
            : 'What is the fee for an RTI application?',
        'options': isHindi
            ? <String>['₹100', '₹10', 'कोई फीस नहीं']
            : <String>['₹100', '₹10', 'No fee required'],
        'correct': 1,
      },
      // 11. Family Law
      {
        'question': isHindi
            ? 'पारिवारिक मामले कहाँ सुने जाते हैं?'
            : 'Where are family matters heard?',
        'options': isHindi
            ? <String>['फैमिली कोर्ट', 'सुप्रीम कोर्ट', 'पुलिस स्टेशन']
            : <String>['Family Court', 'Supreme Court', 'Police Station'],
        'correct': 0,
      },
      // 12. Legal Aid
      {
        'question': isHindi
            ? 'नि:शुल्क कानूनी सहायता का हेल्पलाइन नंबर क्या है?'
            : 'What is the helpline number for free legal aid?',
        'options': isHindi
            ? <String>['100', '15100', '112']
            : <String>['100', '15100', '112'],
        'correct': 1,
      },
      // 13. Vishaka vs State of Rajasthan
      {
        'question': isHindi
            ? 'विशाखा दिशानिर्देश किससे संबंधित हैं?'
            : 'What are the Vishaka Guidelines related to?',
        'options': isHindi
            ? <String>['बाल श्रम', 'कार्यस्थल पर यौन उत्पीड़न', 'भूमि सुधार']
            : <String>[
                'Child labor',
                'Sexual harassment at workplace',
                'Land reforms',
              ],
        'correct': 1,
      },
      // 14. Shayara Bano vs Union of India
      {
        'question': isHindi
            ? 'शायरा बानो केस में क्या असंवैधानिक घोषित किया गया?'
            : 'What was declared unconstitutional in the Shayara Bano case?',
        'options': isHindi
            ? <String>['बहुविवाह', 'तीन तलाक (तलाक-ए-बिद्दत)', 'दहेज प्रथा']
            : <String>[
                'Polygamy',
                'Triple Talaq (Talaq-e-Biddat)',
                'Dowry system',
              ],
        'correct': 1,
      },
      // 15. Puttaswamy - Right to Privacy
      {
        'question': isHindi
            ? 'पुट्टस्वामी केस में निजता का अधिकार किस अनुच्छेद के तहत मौलिक अधिकार माना गया?'
            : 'Under which Article was Right to Privacy declared fundamental in the Puttaswamy case?',
        'options': isHindi
            ? <String>['अनुच्छेद 14', 'अनुच्छेद 19', 'अनुच्छेद 21']
            : <String>['Article 14', 'Article 19', 'Article 21'],
        'correct': 2,
      },
      // 16. Kesavananda Bharati
      {
        'question': isHindi
            ? 'केशवानंद भारती केस ने कौन सा सिद्धांत स्थापित किया?'
            : 'Which doctrine was established by the Kesavananda Bharati case?',
        'options': isHindi
            ? <String>[
                'पृथक्करण सिद्धांत',
                'मूल संरचना सिद्धांत',
                'समानता सिद्धांत',
              ]
            : <String>[
                'Doctrine of Separation',
                'Basic Structure Doctrine',
                'Doctrine of Equality',
              ],
        'correct': 1,
      },
      // 17. Maneka Gandhi
      {
        'question': isHindi
            ? 'मेनका गांधी केस ने अनुच्छेद 21 में कौन सी अवधारणा जोड़ी?'
            : 'Which concept did the Maneka Gandhi case add to Article 21?',
        'options': isHindi
            ? <String>[
                'राज्य नीति',
                'विधि की सम्यक प्रक्रिया (Due Process)',
                'मतदान का अधिकार',
              ]
            : <String>['State Policy', 'Due Process of Law', 'Right to Vote'],
        'correct': 1,
      },
      // 18. Nirbhaya Case
      {
        'question': isHindi
            ? 'निर्भया केस के बाद कौन सा कानून बना?'
            : 'Which law was enacted after the Nirbhaya case?',
        'options': isHindi
            ? <String>[
                'RTI Act 2005',
                'Criminal Law (Amendment) Act 2013',
                'POCSO Act 2012',
              ]
            : <String>[
                'RTI Act 2005',
                'Criminal Law (Amendment) Act 2013',
                'POCSO Act 2012',
              ],
        'correct': 1,
      },
      // 19. DK Basu
      {
        'question': isHindi
            ? 'डी.के. बसु केस में कितने दिशानिर्देश जारी किए गए?'
            : 'How many guidelines were issued in the DK Basu case?',
        'options': isHindi
            ? <String>['5', '11', '15']
            : <String>['5', '11', '15'],
        'correct': 1,
      },
      // 20. Unnikrishnan - Right to Education
      {
        'question': isHindi
            ? 'उन्नीकृष्णन केस ने किस आयु तक के बच्चों के लिए शिक्षा को मौलिक अधिकार माना?'
            : 'Up to what age did the Unnikrishnan case recognize education as a fundamental right?',
        'options': isHindi
            ? <String>['10 वर्ष', '14 वर्ष', '18 वर्ष']
            : <String>['10 years', '14 years', '18 years'],
        'correct': 1,
      },
      // 21. Olga Tellis - Right to Livelihood
      {
        'question': isHindi
            ? 'ओल्गा टेलिस केस ने किसके अधिकारों की रक्षा की?'
            : 'Whose rights did the Olga Tellis case protect?',
        'options': isHindi
            ? <String>[
                'सरकारी कर्मचारी',
                'फुटपाथ पर रहने वाले (शहरी गरीब)',
                'किसान',
              ]
            : <String>[
                'Government employees',
                'Pavement dwellers (urban poor)',
                'Farmers',
              ],
        'correct': 1,
      },
    ];
  }
}

class _ModuleCard extends StatefulWidget {
  final String icon;
  final String title;
  final String duration;
  final String content;
  final String category;
  final bool isHindi;
  final Map<String, dynamic>? quiz;

  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.duration,
    required this.content,
    required this.category,
    required this.isHindi,
    this.quiz,
  });

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard> {
  bool _isExpanded = false;
  int? _selectedAnswer;
  bool _quizSubmitted = false;

  // TTS
  static final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  static String? _currentSpeakingTitle;

  @override
  void initState() {
    super.initState();
    _tts.setCompletionHandler(() {
      if (mounted && _currentSpeakingTitle == widget.title) {
        setState(() => _isSpeaking = false);
        _currentSpeakingTitle = null;
      }
    });
    _tts.setCancelHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  @override
  void dispose() {
    if (_currentSpeakingTitle == widget.title) {
      _tts.stop();
      _currentSpeakingTitle = null;
    }
    super.dispose();
  }

  Future<void> _toggleTts() async {
    if (_isSpeaking) {
      await _tts.stop();
      setState(() => _isSpeaking = false);
      _currentSpeakingTitle = null;
    } else {
      // Stop any other card that might be speaking
      await _tts.stop();

      final lang = widget.isHindi ? 'hi-IN' : 'en-US';
      await _tts.setLanguage(lang);
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);

      _currentSpeakingTitle = widget.title;
      setState(() => _isSpeaking = true);

      // Speak title first, then content
      final textToRead = '${widget.title}. ${widget.content}';
      await _tts.speak(textToRead);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: _isExpanded ? 4 : 1,
      shadowColor: AppTheme.primaryColor.withAlpha(30),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: _isExpanded
            ? BorderSide(color: AppTheme.primaryColor.withAlpha(40))
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.category,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        widget.icon,
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withAlpha(40),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '⏱️ ${widget.duration}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.accentDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _buildClickableContent(
                    context,
                    widget.content,
                    Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(height: 1.6) ??
                        const TextStyle(fontSize: 14, height: 1.6),
                  ),
                ),
                // Read Aloud button
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: _toggleTts,
                    icon: Icon(
                      _isSpeaking
                          ? Icons.stop_circle_outlined
                          : Icons.volume_up_outlined,
                      size: 18,
                    ),
                    label: Text(
                      _isSpeaking
                          ? (widget.isHindi ? 'रोकें' : 'Stop')
                          : (widget.isHindi ? '🔊 सुनें' : '🔊 Read Aloud'),
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _isSpeaking
                          ? Colors.red.shade600
                          : AppTheme.primaryColor,
                      side: BorderSide(
                        color: _isSpeaking
                            ? Colors.red.shade300
                            : AppTheme.primaryColor.withAlpha(100),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                // Quiz section
                if (widget.quiz != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withAlpha(15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.accentColor.withAlpha(40),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('🧠 ', style: TextStyle(fontSize: 18)),
                            Text(
                              widget.isHindi ? 'त्वरित प्रश्न' : 'Quick Quiz',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentDark,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.quiz!['question'] as String,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(
                          (widget.quiz!['options'] as List<String>).length,
                          (i) {
                            final options =
                                widget.quiz!['options'] as List<String>;
                            final correctIdx = widget.quiz!['correct'] as int;
                            final isSelected = _selectedAnswer == i;
                            final isCorrect = i == correctIdx;

                            Color bgColor;
                            Color borderColor;
                            if (_quizSubmitted) {
                              if (isCorrect) {
                                bgColor = Colors.green.withAlpha(30);
                                borderColor = Colors.green;
                              } else if (isSelected) {
                                bgColor = Colors.red.withAlpha(30);
                                borderColor = Colors.red;
                              } else {
                                bgColor = Colors.transparent;
                                borderColor = Colors.grey.shade300;
                              }
                            } else {
                              bgColor = isSelected
                                  ? AppTheme.primaryColor.withAlpha(20)
                                  : Colors.transparent;
                              borderColor = isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.grey.shade300;
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                onTap: _quizSubmitted
                                    ? null
                                    : () {
                                        setState(() {
                                          _selectedAnswer = i;
                                          _quizSubmitted = true;
                                        });
                                      },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        String.fromCharCode(65 + i),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          options[i],
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                      if (_quizSubmitted && isCorrect)
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 20,
                                        ),
                                      if (_quizSubmitted &&
                                          isSelected &&
                                          !isCorrect)
                                        const Icon(
                                          Icons.cancel,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        if (_quizSubmitted)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _selectedAnswer ==
                                      (widget.quiz!['correct'] as int)
                                  ? (widget.isHindi
                                        ? '✅ सही उत्तर! बहुत बढ़िया!'
                                        : '✅ Correct! Well done!')
                                  : (widget.isHindi
                                        ? '❌ सही उत्तर: ${(widget.quiz!["options"] as List<String>)[widget.quiz!["correct"] as int]}'
                                        : '❌ Correct answer: ${(widget.quiz!["options"] as List<String>)[widget.quiz!["correct"] as int]}'),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color:
                                    _selectedAnswer ==
                                        (widget.quiz!['correct'] as int)
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Renders text with auto-detected clickable URLs.
  Widget _buildClickableContent(
    BuildContext context,
    String text,
    TextStyle style,
  ) {
    final urlRegex = RegExp(
      r'(https?://[^\s,)]+|www\.[^\s,)]+|[a-zA-Z0-9-]+\.[a-z]{2,}(?:/[^\s,)]*)?)',
      caseSensitive: false,
    );

    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final matches = urlRegex.allMatches(line).toList();
        if (matches.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(line, style: style),
          );
        }

        final spans = <InlineSpan>[];
        int lastEnd = 0;

        for (final match in matches) {
          if (match.start > lastEnd) {
            spans.add(
              TextSpan(
                text: line.substring(lastEnd, match.start),
                style: style,
              ),
            );
          }
          final urlText = match.group(0)!;
          final fullUrl = urlText.startsWith('http')
              ? urlText
              : 'https://$urlText';
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: GestureDetector(
                onTap: () async {
                  final uri = Uri.parse(fullUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Text(
                  urlText,
                  style: style.copyWith(
                    color: Colors.blue.shade700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          );
          lastEnd = match.end;
        }

        if (lastEnd < line.length) {
          spans.add(TextSpan(text: line.substring(lastEnd), style: style));
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: RichText(text: TextSpan(children: spans)),
        );
      }).toList(),
    );
  }
}
