import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../providers/locale_provider.dart';

class LegalModulesScreen extends StatelessWidget {
  const LegalModulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final isHindi = localeProvider.locale.languageCode == 'hi';

    final modules = _getLegalModules(isHindi);

    return Scaffold(
      appBar: AppBar(
        title: Text(isHindi ? 'कानूनी साक्षरता' : 'Legal Literacy'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: modules.length,
        itemBuilder: (context, index) {
          final module = modules[index];
          return _ModuleCard(
            icon: module['icon']!,
            title: module['title']!,
            duration: module['duration']!,
            content: module['content']!,
            category: module['category']!,
            isHindi: isHindi,
          ).animate(delay: Duration(milliseconds: 80 * index)).fadeIn().slideY(begin: 0.1, end: 0);
        },
      ),
    );
  }

  List<Map<String, String>> _getLegalModules(bool isHindi) {
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
        'title': isHindi ? 'भारत में अदालतों के प्रकार' : 'Types of Courts in India',
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
        'title': isHindi ? 'परीक्षा में क्या आता है?' : 'What Comes in the Exam?',
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
        'title': isHindi ? 'कानूनी सहायता कहाँ मिले?' : 'Where to Get Legal Help?',
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

  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.duration,
    required this.content,
    required this.category,
    required this.isHindi,
  });

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
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
                      child: Text(widget.icon, style: const TextStyle(fontSize: 26)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
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
                  child: Text(
                    widget.content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                        ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
