import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../config/app_theme.dart';
import '../../providers/locale_provider.dart';

class FaqAssistantScreen extends StatefulWidget {
  const FaqAssistantScreen({super.key});

  @override
  State<FaqAssistantScreen> createState() => _FaqAssistantScreenState();
}

class _FaqAssistantScreenState extends State<FaqAssistantScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _filteredFaqs = [];
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _filteredFaqs = [];
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) =>
          setState(() => _isListening = status == 'listening'),
      onError: (error) => setState(() => _isListening = false),
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _startListening(bool isHindi) async {
    if (!_speechAvailable) return;

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _searchController.text = result.recognizedWords;
          _onSearch(result.recognizedWords, isHindi);
        });
      },
      localeId: isHindi ? 'hi_IN' : 'en_US',
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  void _onSearch(String query, bool isHindi) {
    setState(() {
      _searchQuery = query.toLowerCase();

      // Voice Intent Detection (3 hardcoded intents)
      final intentDetected = _detectVoiceIntent(_searchQuery, isHindi);
      if (intentDetected != null) {
        _searchQuery = intentDetected;
      }

      if (_searchQuery.isEmpty) {
        _filteredFaqs = [];
      } else {
        final allFaqs = _getFaqs(isHindi);
        _filteredFaqs = allFaqs.where((faq) {
          final question = (faq['question'] as String).toLowerCase();
          final keywords = (faq['keywords'] as List<String>)
              .map((k) => k.toLowerCase())
              .toList();
          return question.contains(_searchQuery) ||
              keywords.any((k) => k.contains(_searchQuery));
        }).toList();
      }
    });
  }

  // Voice Intent Detection - 3 hardcoded common intents
  String? _detectVoiceIntent(String query, bool isHindi) {
    final q = query.toLowerCase().trim();

    // Intent 1: "After 12th/graduation judge" → Convert to eligibility query
    if ((q.contains('12') || q.contains('बारहवीं') || q.contains('12th')) &&
        (q.contains('judge') || q.contains('जज'))) {
      return '12th judge';
    }

    if ((q.contains('graduation') ||
            q.contains('graduate') ||
            q.contains('ग्रेजुएशन')) &&
        (q.contains('judge') || q.contains('जज'))) {
      return 'graduation judge';
    }

    // Intent 2: "Salary" or "pay" → Direct to salary FAQ
    if (q.contains('salary') ||
        q.contains('pay') ||
        q.contains('सैलरी') ||
        q.contains('वेतन') ||
        q.contains('income')) {
      return 'salary';
    }

    // Intent 3: "Age limit" or "eligibility" → Direct to age/eligibility
    if ((q.contains('age') || q.contains('आयु') || q.contains('उम्र')) ||
        (q.contains('eligibility') || q.contains('पात्रता'))) {
      return 'age eligibility';
    }

    return null;
  }

  List<Map<String, dynamic>> _getFaqs(bool isHindi) {
    return [
      // Becoming a Judge
      {
        'category': isHindi ? 'न्यायाधीश बनना' : 'Becoming a Judge',
        'icon': '⚖️',
        'question': isHindi
            ? '12वीं के बाद जज कैसे बनें?'
            : 'How can I become a judge after 12th?',
        'answer': isHindi
            ? '''12वीं के बाद जज बनने के चरण:

1. **लॉ एंट्रेंस एग्जाम दें** - CLAT, AILET, या राज्य CET
2. **5 वर्षीय LLB करें** - किसी मान्यता प्राप्त विश्वविद्यालय से
3. **अनुभव प्राप्त करें** - 3-7 वर्ष वकालत का अनुभव (राज्य के अनुसार)
4. **PCS-J परीक्षा दें** - राज्य न्यायिक सेवा परीक्षा
5. **इंटरव्यू पास करें** - High Court द्वारा आयोजित

कुल समय: लगभग 10-12 वर्ष'''
            : '''Steps to become a judge after 12th:

1. **Clear Law Entrance** - CLAT, AILET, or State CET
2. **Complete 5-year LLB** - From a recognized university
3. **Gain Experience** - 3-7 years practice (varies by state)
4. **Pass PCS-J Exam** - State Judicial Services Examination
5. **Clear Interview** - Conducted by High Court

Total time: Approximately 10-12 years''',
        'keywords': [
          '12th',
          'after 12th',
          'judge',
          'become',
          'बाद',
          'जज',
          'बनना',
        ],
      },
      {
        'category': isHindi ? 'न्यायाधीश बनना' : 'Becoming a Judge',
        'icon': '🎓',
        'question': isHindi
            ? 'ग्रेजुएशन के बाद जज कैसे बनें?'
            : 'How to become a judge after graduation?',
        'answer': isHindi
            ? '''ग्रेजुएशन के बाद:

1. **3 वर्षीय LLB करें** - किसी भी स्ट्रीम से ग्रेजुएट होने के बाद
2. **एंट्रेंस एग्जाम** - CLAT PG या राज्य LLB एंट्रेंस
3. **वकालत करें** - 3-7 वर्ष का अनुभव
4. **न्यायिक सेवा परीक्षा** - PCS-J पास करें

कुल समय: लगभग 7-10 वर्ष'''
            : '''After graduation:

1. **Complete 3-year LLB** - After graduation in any stream
2. **Entrance Exam** - CLAT PG or State LLB entrance
3. **Practice Law** - 3-7 years experience
4. **Judicial Services Exam** - Pass PCS-J

Total time: Approximately 7-10 years''',
        'keywords': ['graduation', 'graduate', 'ग्रेजुएशन', 'after'],
      },
      // Exams
      {
        'category': isHindi ? 'परीक्षाएं' : 'Examinations',
        'icon': '📝',
        'question': isHindi
            ? 'मेरे राज्य में कौन सी परीक्षा देनी होगी?'
            : 'Which exam is needed in my state?',
        'answer': isHindi
            ? '''हर राज्य की अपनी न्यायिक सेवा परीक्षा होती है:

• **उत्तर प्रदेश** - UP PCS-J (UPPSC द्वारा)
• **मध्य प्रदेश** - MP Judiciary (MPHC द्वारा)
• **राजस्थान** - RJS (Rajasthan HC द्वारा)
• **बिहार** - Bihar Judiciary (BPSC द्वारा)
• **महाराष्ट्र** - Maharashtra Judiciary (Bombay HC द्वारा)

सभी परीक्षाओं में:
✅ प्रारंभिक परीक्षा (Objective)
✅ मुख्य परीक्षा (Descriptive)
✅ साक्षात्कार (Interview)'''
            : '''Each state has its own Judicial Services Exam:

• **Uttar Pradesh** - UP PCS-J (by UPPSC)
• **Madhya Pradesh** - MP Judiciary (by MPHC)
• **Rajasthan** - RJS (by Rajasthan HC)
• **Bihar** - Bihar Judiciary (by BPSC)
• **Maharashtra** - Maharashtra Judiciary (by Bombay HC)

All exams have:
✅ Preliminary (Objective)
✅ Mains (Descriptive)
✅ Interview''',
        'keywords': ['exam', 'state', 'PCS-J', 'परीक्षा', 'राज्य', 'which'],
      },
      {
        'category': isHindi ? 'परीक्षाएं' : 'Examinations',
        'icon': '📚',
        'question': isHindi ? 'CLAT क्या है?' : 'What is CLAT?',
        'answer': isHindi
            ? '''**CLAT - Common Law Admission Test**

• राष्ट्रीय स्तर की लॉ एंट्रेंस परीक्षा
• 22 National Law Universities (NLUs) में प्रवेश के लिए
• 12वीं के बाद 5 वर्षीय LLB के लिए
• ग्रेजुएशन के बाद LLM के लिए

**परीक्षा पैटर्न:**
• अंग्रेजी - 28-32 प्रश्न
• करंट अफेयर्स - 35-39 प्रश्न  
• लीगल रीजनिंग - 35-39 प्रश्न
• लॉजिकल रीजनिंग - 28-32 प्रश्न
• क्वांटिटेटिव - 13-17 प्रश्न'''
            : '''**CLAT - Common Law Admission Test**

• National level law entrance exam
• For admission to 22 National Law Universities (NLUs)
• For 5-year LLB after 12th
• For LLM after graduation

**Exam Pattern:**
• English - 28-32 questions
• Current Affairs - 35-39 questions
• Legal Reasoning - 35-39 questions
• Logical Reasoning - 28-32 questions
• Quantitative - 13-17 questions''',
        'keywords': ['CLAT', 'entrance', 'NLU', 'law', 'क्लैट'],
      },
      // Eligibility
      {
        'category': isHindi ? 'पात्रता' : 'Eligibility',
        'icon': '✅',
        'question': isHindi
            ? 'जज बनने के लिए उम्र सीमा क्या है?'
            : 'What is the age limit to become a judge?',
        'answer': isHindi
            ? '''**न्यायिक सेवा के लिए आयु सीमा:**

• **न्यूनतम आयु:** 21-23 वर्ष (राज्य के अनुसार)
• **अधिकतम आयु:** 35-40 वर्ष (सामान्य)

**आरक्षित वर्ग के लिए छूट:**
• SC/ST: 5 वर्ष
• OBC: 3 वर्ष
• विकलांग: 10 वर्ष

नोट: High Court/Supreme Court Judge के लिए अलग नियम हैं'''
            : '''**Age Limit for Judicial Services:**

• **Minimum Age:** 21-23 years (varies by state)
• **Maximum Age:** 35-40 years (General)

**Relaxation for Reserved Categories:**
• SC/ST: 5 years
• OBC: 3 years
• PWD: 10 years

Note: Different rules apply for High Court/Supreme Court Judges''',
        'keywords': ['age', 'limit', 'eligibility', 'आयु', 'सीमा', 'पात्रता'],
      },
      {
        'category': isHindi ? 'पात्रता' : 'Eligibility',
        'icon': '📋',
        'question': isHindi
            ? 'LLB के लिए कौन सी स्ट्रीम जरूरी है?'
            : 'Which stream is required for LLB?',
        'answer': isHindi
            ? '''**LLB के लिए कोई स्ट्रीम बाध्यता नहीं है!**

आप किसी भी स्ट्रीम से LLB कर सकते हैं:
• Arts ✅
• Commerce ✅
• Science ✅

**न्यूनतम अंक:**
• 5 वर्षीय LLB: 12वीं में 45%+ (सामान्य) / 40%+ (SC/ST)
• 3 वर्षीय LLB: ग्रेजुएशन में 45%+

**सुझाव:** Humanities/Arts पृष्ठभूमि फायदेमंद हो सकती है'''
            : '''**No stream restriction for LLB!**

You can pursue LLB from any stream:
• Arts ✅
• Commerce ✅
• Science ✅

**Minimum Marks:**
• 5-year LLB: 45%+ in 12th (General) / 40%+ (SC/ST)
• 3-year LLB: 45%+ in Graduation

**Tip:** Humanities/Arts background can be beneficial''',
        'keywords': ['stream', 'arts', 'science', 'commerce', 'स्ट्रीम', 'LLB'],
      },
      // Career
      {
        'category': isHindi ? 'करियर' : 'Career',
        'icon': '💼',
        'question': isHindi
            ? 'जज की सैलरी कितनी होती है?'
            : 'What is the salary of a judge?',
        'answer': isHindi
            ? '''**न्यायाधीशों का वेतन (7वें वेतन आयोग के बाद):**

| पद | वेतन (₹/माह) |
|---|---|
| Civil Judge (Junior) | ₹77,840 - 1,51,670 |
| Civil Judge (Senior) | ₹98,440 - 1,68,275 |
| District Judge | ₹1,44,840 - 2,24,050 |
| High Court Judge | ₹2,25,000 |
| Supreme Court Judge | ₹2,50,000 |

**अन्य लाभ:**
• सरकारी आवास
• वाहन सुविधा
• पेंशन
• मेडिकल बेनिफिट्स'''
            : '''**Judges' Salary (Post 7th Pay Commission):**

| Position | Salary (₹/month) |
|---|---|
| Civil Judge (Junior) | ₹77,840 - 1,51,670 |
| Civil Judge (Senior) | ₹98,440 - 1,68,275 |
| District Judge | ₹1,44,840 - 2,24,050 |
| High Court Judge | ₹2,25,000 |
| Supreme Court Judge | ₹2,50,000 |

**Other Benefits:**
• Government accommodation
• Vehicle facility
• Pension
• Medical benefits''',
        'keywords': ['salary', 'pay', 'वेतन', 'सैलरी', 'income'],
      },
      {
        'category': isHindi ? 'करियर' : 'Career',
        'icon': '📈',
        'question': isHindi
            ? 'जज का करियर ग्रोथ कैसा होता है?'
            : 'What is the career growth of a judge?',
        'answer': isHindi
            ? '''**न्यायिक करियर पदानुक्रम:**

```
1. Civil Judge (Junior Division)
        ↓ (5-7 वर्ष)
2. Civil Judge (Senior Division)
        ↓ (5-7 वर्ष)
3. District & Sessions Judge
        ↓ (प्रमोशन/चयन के आधार पर)
4. High Court Judge
        ↓ (कॉलेजियम नियुक्ति)
5. Supreme Court Judge
```

**विशेष अवसर:**
• Tribunal सदस्य
• Law Commission सदस्य
• Legal Advisor पद'''
            : '''**Judicial Career Hierarchy:**

```
1. Civil Judge (Junior Division)
        ↓ (5-7 years)
2. Civil Judge (Senior Division)
        ↓ (5-7 years)
3. District & Sessions Judge
        ↓ (Based on promotion/selection)
4. High Court Judge
        ↓ (Collegium appointment)
5. Supreme Court Judge
```

**Special Opportunities:**
• Tribunal Member
• Law Commission Member
• Legal Advisor positions''',
        'keywords': [
          'growth',
          'career',
          'promotion',
          'करियर',
          'ग्रोथ',
          'प्रमोशन',
        ],
      },
      // Understanding Courts
      {
        'category': isHindi ? 'न्यायालय प्रणाली' : 'Court System',
        'icon': '🏛️',
        'question': isHindi
            ? 'भारत में कितने प्रकार के न्यायालय हैं?'
            : 'What are the different types of courts in India?',
        'answer': isHindi
            ? '''**भारतीय न्यायालय प्रणाली:**

**1. सर्वोच्च न्यायालय (Supreme Court)**
• दिल्ली में स्थित
• सर्वोच्च अपील न्यायालय
• मुख्य न्यायाधीश + 33 अन्य न्यायाधीश

**2. उच्च न्यायालय (High Court)**
• प्रत्येक राज्य/UT में
• 25 उच्च न्यायालय
• राज्य का सर्वोच्च न्यायालय

**3. जिला न्यायालय (District Court)**
• जिला एवं सत्र न्यायाधीश
• सिविल और आपराधिक मामले

**4. अधीनस्थ न्यायालय**
• मजिस्ट्रेट कोर्ट
• सिविल कोर्ट (मुंसिफ)'''
            : '''**Indian Court System:**

**1. Supreme Court**
• Located in Delhi
• Highest appellate court
• Chief Justice + 33 other judges

**2. High Court**
• In each State/UT
• 25 High Courts
• Highest court in state

**3. District Court**
• District & Sessions Judge
• Civil and Criminal cases

**4. Subordinate Courts**
• Magistrate Courts
• Civil Courts (Munsif)''',
        'keywords': ['courts', 'types', 'system', 'न्यायालय', 'प्रकार'],
      },
      {
        'category': isHindi ? 'न्यायालय प्रणाली' : 'Court System',
        'icon': '👨‍⚖️',
        'question': isHindi
            ? 'जज का काम क्या होता है?'
            : 'What does a judge do?',
        'answer': isHindi
            ? '''**न्यायाधीश की भूमिका:**

**मुख्य कार्य:**
• दोनों पक्षों की सुनवाई करना
• साक्ष्यों का विश्लेषण करना
• कानून के अनुसार निर्णय देना
• न्याय सुनिश्चित करना

**गुण जो आवश्यक हैं:**
✅ निष्पक्षता
✅ धैर्य
✅ तार्किक सोच
✅ कानून का ज्ञान
✅ नैतिक साहस

**दैनिक कार्य:**
• केस सुनवाई
• आदेश लिखना
• जमानत याचिकाएं
• विचारण (Trial) आयोजित करना'''
            : '''**Role of a Judge:**

**Main Duties:**
• Hearing both parties
• Analyzing evidence
• Delivering judgment per law
• Ensuring justice

**Qualities Required:**
✅ Impartiality
✅ Patience
✅ Logical thinking
✅ Knowledge of law
✅ Moral courage

**Daily Work:**
• Case hearings
• Writing orders
• Bail petitions
• Conducting trials''',
        'keywords': ['role', 'work', 'duties', 'काम', 'भूमिका', 'judge'],
      },
      // Preparation Tips
      {
        'category': isHindi ? 'तैयारी सुझाव' : 'Preparation Tips',
        'icon': '💡',
        'question': isHindi
            ? 'न्यायिक सेवा की तैयारी कैसे करें?'
            : 'How to prepare for Judicial Services exam?',
        'answer': isHindi
            ? '''**PCS-J तैयारी रणनीति:**

**1. मुख्य विषय:**
• संविधान (Constitution)
• IPC & CrPC
• CPC & Evidence Act
• Transfer of Property Act
• Contract Act

**2. तैयारी का तरीका:**
• Bare Acts पढ़ें
• Previous Year Papers हल करें
• Judgment Writing अभ्यास करें
• Current Legal Affairs पढ़ें

**3. समय सीमा:**
• Prelims: 6-8 महीने
• Mains: 4-6 महीने अतिरिक्त

**सुझाव:** नियमित Mock Test दें'''
            : '''**PCS-J Preparation Strategy:**

**1. Core Subjects:**
• Constitution
• IPC & CrPC
• CPC & Evidence Act
• Transfer of Property Act
• Contract Act

**2. Preparation Method:**
• Read Bare Acts
• Solve Previous Year Papers
• Practice Judgment Writing
• Follow Current Legal Affairs

**3. Timeline:**
• Prelims: 6-8 months
• Mains: 4-6 months additional

**Tip:** Take regular Mock Tests''',
        'keywords': [
          'prepare',
          'preparation',
          'tips',
          'study',
          'तैयारी',
          'पढ़ाई',
        ],
      },
      {
        'category': isHindi ? 'तैयारी सुझाव' : 'Preparation Tips',
        'icon': '📖',
        'question': isHindi
            ? 'कौन सी किताबें पढ़नी चाहिए?'
            : 'Which books should I read?',
        'answer': isHindi
            ? '''**न्यायिक सेवा के लिए पुस्तकें:**

**संविधान:**
• D.D. Basu - Introduction to Constitution
• M. Laxmikanth - Indian Polity

**IPC & CrPC:**
• K.D. Gaur - Indian Penal Code
• Ratanlal & Dhirajlal

**CPC & Evidence:**
• C.K. Takwani - Civil Procedure
• Batuk Lal - Law of Evidence

**सामान्य:**
• Bare Acts (अनिवार्य)
• Previous Year Papers

**नोट:** राज्य विशेष Local Laws भी पढ़ें'''
            : '''**Books for Judicial Services:**

**Constitution:**
• D.D. Basu - Introduction to Constitution
• M. Laxmikanth - Indian Polity

**IPC & CrPC:**
• K.D. Gaur - Indian Penal Code
• Ratanlal & Dhirajlal

**CPC & Evidence:**
• C.K. Takwani - Civil Procedure
• Batuk Lal - Law of Evidence

**General:**
• Bare Acts (Essential)
• Previous Year Papers

**Note:** Also read state-specific Local Laws''',
        'keywords': ['books', 'read', 'study', 'किताब', 'पुस्तक', 'पढ़ना'],
      },
    ];
  }

  List<String> _getQuickQuestions(bool isHindi) {
    return isHindi
        ? [
            '12वीं के बाद जज कैसे बनें?',
            'मेरे राज्य में कौन सी परीक्षा?',
            'जज की सैलरी कितनी है?',
            'CLAT क्या है?',
            'उम्र सीमा क्या है?',
            'तैयारी कैसे करें?',
          ]
        : [
            'How to become a judge after 12th?',
            'Which exam in my state?',
            'What is a judge\'s salary?',
            'What is CLAT?',
            'What is the age limit?',
            'How to prepare?',
          ];
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final isHindi = localeProvider.locale.languageCode == 'hi';
    final allFaqs = _getFaqs(isHindi);
    final quickQuestions = _getQuickQuestions(isHindi);

    // Group FAQs by category
    final categories = <String, List<Map<String, dynamic>>>{};
    for (final faq in allFaqs) {
      final category = faq['category'] as String;
      categories[category] ??= [];
      categories[category]!.add(faq);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isHindi ? 'सहायक' : 'Assistant'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHindi ? 'आपका कोई सवाल है?' : 'Have a question?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Voice Input Banner (Prominent)
                if (_speechAvailable)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade50, Colors.purple.shade50],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _isListening
                                ? Colors.red.shade100
                                : Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isListening ? Icons.mic : Icons.mic_none,
                            color: _isListening
                                ? Colors.red
                                : AppTheme.primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isHindi
                                    ? '🎤 वॉइस से पूछें'
                                    : '🎤 Ask with Voice',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                isHindi
                                    ? 'माइक पर टैप करें और बोलें'
                                    : 'Tap mic and speak your question',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (_isListening) {
                              _stopListening();
                            } else {
                              _startListening(isHindi);
                            }
                          },
                          icon: Icon(
                            _isListening ? Icons.stop : Icons.mic,
                            size: 18,
                          ),
                          label: Text(
                            _isListening
                                ? (isHindi ? 'रोकें' : 'Stop')
                                : (isHindi ? 'बोलें' : 'Speak'),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isListening
                                ? Colors.red
                                : AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: -0.1, end: 0),

                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => _onSearch(value, isHindi),
                    decoration: InputDecoration(
                      hintText: isHindi
                          ? 'जैसे: "जज कैसे बनें?"'
                          : 'e.g., "How to become a judge?"',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_speechAvailable)
                            IconButton(
                              icon: Icon(
                                _isListening ? Icons.mic : Icons.mic_none,
                                color: _isListening
                                    ? Colors.red
                                    : AppTheme.primaryColor,
                              ),
                              tooltip: isHindi ? 'वॉइस खोजें' : 'Voice Search',
                              onPressed: () {
                                if (_isListening) {
                                  _stopListening();
                                } else {
                                  _startListening(isHindi);
                                }
                              },
                            ),
                          if (_searchQuery.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _onSearch('', isHindi);
                              },
                            ),
                        ],
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _searchQuery.isNotEmpty
                ? _buildSearchResults(isHindi)
                : _buildDefaultContent(categories, quickQuestions, isHindi),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(bool isHindi) {
    if (_filteredFaqs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text(
              isHindi ? 'कोई परिणाम नहीं मिला' : 'No results found',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isHindi
                  ? 'कृपया अलग शब्दों से खोजें'
                  : 'Try searching with different words',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredFaqs.length,
      itemBuilder: (context, index) {
        return _buildFaqCard(_filteredFaqs[index], isHindi, index);
      },
    );
  }

  Widget _buildDefaultContent(
    Map<String, List<Map<String, dynamic>>> categories,
    List<String> quickQuestions,
    bool isHindi,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Questions
          Text(
            isHindi ? 'सामान्य प्रश्न' : 'Common Questions',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ).animate().fadeIn(),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: quickQuestions.asMap().entries.map((entry) {
              return ActionChip(
                    label: Text(
                      entry.value,
                      style: const TextStyle(fontSize: 12),
                    ),
                    onPressed: () {
                      _searchController.text = entry.value;
                      _onSearch(entry.value, isHindi);
                    },
                    backgroundColor: AppTheme.primaryColor.withAlpha(25),
                  )
                  .animate(delay: (100 * entry.key).ms)
                  .fadeIn()
                  .slideX(begin: 0.1);
            }).toList(),
          ),
          const SizedBox(height: 24),

          // All FAQs by category
          ...categories.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                ...entry.value.asMap().entries.map((faqEntry) {
                  return _buildFaqCard(faqEntry.value, isHindi, faqEntry.key);
                }),
                const SizedBox(height: 16),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFaqCard(Map<String, dynamic> faq, bool isHindi, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              faq['icon'] as String,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        title: Text(
          faq['question'] as String,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildRichAnswer(faq['answer'] as String),
            ),
          ),
        ],
      ),
    ).animate(delay: (50 * index).ms).fadeIn().slideY(begin: 0.05);
  }

  Widget _buildRichAnswer(String answer) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (final match in regex.allMatches(answer)) {
      // Add normal text before the match
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: answer.substring(lastIndex, match.start),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
              height: 1.6,
            ),
          ),
        );
      }

      // Add bold text
      spans.add(
        TextSpan(
          text: match.group(1),
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade900,
            fontWeight: FontWeight.bold,
            height: 1.6,
          ),
        ),
      );

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < answer.length) {
      spans.add(
        TextSpan(
          text: answer.substring(lastIndex),
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade800,
            height: 1.6,
          ),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }
}
