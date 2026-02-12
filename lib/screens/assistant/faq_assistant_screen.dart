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
    if (!_speechAvailable) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isHindi
                ? 'वॉइस इनपुट इस डिवाइस पर उपलब्ध नहीं है'
                : 'Voice input is not available on this device',
          ),
        ),
      );
      return;
    }

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
      _searchQuery = query.trim().toLowerCase();

      // Voice Intent Detection (3 hardcoded intents)
      final intentDetected = _detectVoiceIntent(_searchQuery, isHindi);
      if (intentDetected != null) {
        _searchQuery = intentDetected;
      }

      if (_searchQuery.isEmpty) {
        _filteredFaqs = [];
      } else {
        final allFaqs = _getFaqs(isHindi);
        _filteredFaqs = allFaqs
            .where((faq) => _matchesFaq(faq, _searchQuery))
            .toList();
      }
    });
  }

  // Voice Intent Detection - 3 hardcoded common intents
  String? _detectVoiceIntent(String query, bool isHindi) {
    final q = query.toLowerCase().trim();

    // Intent 1: "After 12th/graduation judge" → Convert to eligibility query
    if ((q.contains('12') || q.contains('बारहवीं') || q.contains('12th')) &&
        (q.contains('judge') || q.contains('जज'))) {
      return '12th';
    }

    if ((q.contains('graduation') ||
            q.contains('graduate') ||
            q.contains('ग्रेजुएशन')) &&
        (q.contains('judge') || q.contains('जज'))) {
      return 'graduation';
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
      return 'eligibility';
    }

    return null;
  }

  bool _matchesFaq(Map<String, dynamic> faq, String query) {
    final question = (faq['question'] as String? ?? '').toLowerCase();
    final answer = (faq['answer'] as String? ?? '').toLowerCase();
    final keywords = (faq['keywords'] as List<dynamic>? ?? const [])
        .map((k) => k.toString().toLowerCase())
        .toList();

    if (question.contains(query) || answer.contains(query)) {
      return true;
    }
    if (keywords.any((k) => k.contains(query) || query.contains(k))) {
      return true;
    }

    final tokens = _tokenize(query);
    if (tokens.isEmpty) {
      return false;
    }

    final searchable = '$question ${keywords.join(' ')} $answer';
    return tokens.every(searchable.contains);
  }

  List<String> _tokenize(String value) {
    return value
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .map((token) => token.trim())
        .where((token) => token.length >= 2)
        .toList();
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
        'category': isHindi ? 'वेतन और करियर' : 'Career',
        'icon': '💰',
        'question': isHindi
            ? 'जज की सैलरी कितनी होती है?'
            : 'What is the salary of a judge?',
        'answer': isHindi
            ? '''**वेतन राज्य कैडर और नवीनतम वेतन संशोधनों पर निर्भर करता है।**

सामान्य तौर पर:
• प्रवेश स्तर के सिविल जज को सरकारी वेतन + भत्ते मिलते हैं
• वरिष्ठता और पदोन्नति के साथ वेतन बढ़ता है
• आवास/चिकित्सा और संबंधित लाभ राज्य नियमों के अनुसार

सटीक आंकड़ों के लिए, अपने राज्य का नवीनतम आधिकारिक न्यायिक भर्ती अधिसूचना देखें।'''
            : '''**Salary depends on state cadre and latest pay revisions.**

In general:
• Entry-level civil judges receive structured government pay + allowances
• Pay increases with seniority and promotion
• Housing/medical and related benefits vary by state rules

For exact figures, check the latest official judicial recruitment notification for your state.''',
        'keywords': ['salary', 'pay', 'सैलरी', 'वेतन', 'income'],
      },
      {
        'category': isHindi ? 'वेतन और करियर' : 'Career',
        'icon': '📈',
        'question': isHindi
            ? 'जज का करियर ग्रोथ कैसा होता है?'
            : 'What is the career growth of a judge?',
        'answer': isHindi
            ? '''**न्यायिक करियर पदानुक्रम:**

1. Civil Judge (Junior Division)
        ↓ (5-7 वर्ष)
2. Civil Judge (Senior Division)
        ↓ (5-7 वर्ष)
3. District & Sessions Judge
        ↓ (प्रमोशन/चयन के आधार पर)
4. High Court Judge
        ↓ (कॉलेजियम नियुक्ति)
5. Supreme Court Judge

**विशेष अवसर:**
• Tribunal सदस्य
• Law Commission सदस्य
• Legal Advisor पद'''
            : '''**Judicial Career Hierarchy:**

1. Civil Judge (Junior Division)
        ↓ (5-7 years)
2. Civil Judge (Senior Division)
        ↓ (5-7 years)
3. District & Sessions Judge
        ↓ (Based on promotion/selection)
4. High Court Judge
        ↓ (Collegium appointment)
5. Supreme Court Judge

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
            : 'How many types of courts are there in India?',
        'answer': isHindi
            ? '''**भारतीय न्यायालय पदानुक्रम:**

1. **सर्वोच्च न्यायालय** (Supreme Court)
   • मुख्य न्यायाधीश + अन्य न्यायाधीश
   • संविधान का अंतिम व्याख्याकार

2. **उच्च न्यायालय** (High Courts)
   • प्रत्येक राज्य/UT के लिए
   • 25 High Courts

3. **जिला न्यायालय** (District Courts)
   • जिला और सत्र न्यायाधीश

4. **अधीनस्थ न्यायालय** (Subordinate Courts)
   • सिविल जज (Junior/Senior Division)
   • मजिस्ट्रेट कोर्ट

5. **विशेष न्यायालय**
   • Family Courts, Consumer Courts, NCLT
   • Fast Track Courts, Lok Adalat'''
            : '''**Indian Court Hierarchy:**

1. **Supreme Court**
   • Chief Justice + other Judges
   • Final interpreter of Constitution

2. **High Courts**
   • One for each state/UT
   • 25 High Courts

3. **District Courts**
   • District & Sessions Judges

4. **Subordinate Courts**
   • Civil Judge (Junior/Senior Division)
   • Magistrate Courts

5. **Special Courts**
   • Family Courts, Consumer Courts, NCLT
   • Fast Track Courts, Lok Adalat''',
        'keywords': [
          'court',
          'types',
          'hierarchy',
          'न्यायालय',
          'प्रकार',
          'कोर्ट',
        ],
      },
      // Preparation Tips
      {
        'category': isHindi ? 'तैयारी सुझाव' : 'Preparation Tips',
        'icon': '💡',
        'question': isHindi
            ? 'न्यायिक परीक्षा की तैयारी कैसे करें?'
            : 'How to prepare for judicial exams?',
        'answer': isHindi
            ? '''**न्यायिक परीक्षा तैयारी गाइड:**

**1. मूल विषय:**
• भारतीय संविधान
• CPC (सिविल प्रक्रिया संहिता)
• CrPC (दंड प्रक्रिया संहिता)
• IPC / भारतीय न्याय संहिता (BNS)
• Evidence Act / भारतीय साक्ष्य अधिनियम (BSA)

**2. तैयारी रणनीति:**
• Bare Acts का नियमित अध्ययन
• पिछले वर्षों के प्रश्न पत्र हल करें
• मॉक टेस्ट नियमित रूप से दें
• उत्तर लेखन अभ्यास करें

**3. महत्वपूर्ण संसाधन:**
• Bare Acts और कमेंट्री
• SC/HC के प्रमुख निर्णय
• कानूनी पत्रिकाएं
• ऑनलाइन कोर्सेज'''
            : '''**Judicial Exam Preparation Guide:**

**1. Core Subjects:**
• Indian Constitution
• CPC (Civil Procedure Code)
• CrPC (Criminal Procedure Code)
• IPC / Bharatiya Nyaya Sanhita (BNS)
• Evidence Act / Bharatiya Sakshya Adhiniyam (BSA)

**2. Preparation Strategy:**
• Regular study of Bare Acts
• Solve previous year question papers
• Take mock tests regularly
• Practice answer writing

**3. Important Resources:**
• Bare Acts and Commentaries
• Landmark SC/HC Judgments
• Legal journals
• Online courses''',
        'keywords': [
          'prepare',
          'preparation',
          'tips',
          'strategy',
          'तैयारी',
          'सुझाव',
          'रणनीति',
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _getQuickQuestions(bool isHindi) {
    return [
      {
        'text': isHindi
            ? '12वीं के बाद जज कैसे बनें?'
            : 'How to become judge after 12th?',
        'query': '12th',
      },
      {
        'text': isHindi ? 'आयु सीमा क्या है?' : 'What is the age limit?',
        'query': 'eligibility',
      },
      {
        'text': isHindi ? 'वेतन कितनी है?' : 'What is the salary?',
        'query': 'salary',
      },
      {
        'text': isHindi ? 'कौन सी परीक्षा देनी होगी?' : 'Which exam to give?',
        'query': 'exam',
      },
      {
        'text': isHindi ? 'तैयारी कैसे करें?' : 'How to prepare?',
        'query': 'prepare',
      },
      {'text': isHindi ? 'CLAT क्या है?' : 'What is CLAT?', 'query': 'CLAT'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final isHindi = localeProvider.locale.languageCode == 'hi';

    final displayFaqs = _searchQuery.isEmpty
        ? _getFaqs(isHindi)
        : _filteredFaqs;

    return Scaffold(
      appBar: AppBar(
        title: Text(isHindi ? 'न्यायिक सहायक' : 'Judicial Assistant'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Column(
        children: [
          // Voice Banner
          if (_speechAvailable)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withAlpha(20),
                    AppTheme.accentColor.withAlpha(20),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening ? Colors.red : AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isListening
                          ? (isHindi
                                ? '🎙️ सुन रहा हूं... बोलें'
                                : '🎙️ Listening... Speak now')
                          : (isHindi
                                ? '🎙️ माइक बटन दबाकर सवाल पूछें'
                                : '🎙️ Tap mic button to ask a question'),
                      style: TextStyle(
                        fontSize: 13,
                        color: _isListening
                            ? Colors.red.shade700
                            : AppTheme.textSecondary,
                        fontWeight: _isListening
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => _onSearch(value, isHindi),
                    decoration: InputDecoration(
                      hintText: isHindi
                          ? '🔍 अपना सवाल टाइप करें...'
                          : '🔍 Type your question...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppTheme.primaryColor,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _onSearch('', isHindi);
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppTheme.primaryColor,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                if (_speechAvailable) ...[
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isListening ? Colors.red : AppTheme.primaryColor,
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isListening ? Icons.stop : Icons.mic,
                        color: Colors.white,
                      ),
                      onPressed: _isListening
                          ? _stopListening
                          : () => _startListening(isHindi),
                    ),
                  ),
                ],
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.1, end: 0),

          // Quick Questions
          if (_searchQuery.isEmpty)
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _getQuickQuestions(isHindi).map((q) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(
                        q['text'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      backgroundColor: AppTheme.primaryColor.withAlpha(20),
                      side: BorderSide(
                        color: AppTheme.primaryColor.withAlpha(50),
                      ),
                      onPressed: () {
                        _searchController.text = q['text'] as String;
                        _onSearch(q['query'] as String, isHindi);
                      },
                    ),
                  );
                }).toList(),
              ),
            ).animate(delay: 100.ms).fadeIn(),

          const SizedBox(height: 8),

          // FAQ Results
          Expanded(
            child: displayFaqs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('⚖️', style: TextStyle(fontSize: 64)),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? (isHindi
                                    ? 'कोई परिणाम नहीं मिला'
                                    : 'No results found')
                              : (isHindi
                                    ? 'अपना सवाल पूछें या खोजें'
                                    : 'Ask or search your question'),
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        if (_searchQuery.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            isHindi
                                ? 'अलग शब्दों से खोजने का प्रयास करें'
                                : 'Try searching with different words',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary.withAlpha(150),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: displayFaqs.length,
                    itemBuilder: (context, index) {
                      final faq = displayFaqs[index];
                      return _FaqCard(
                        faq: faq,
                        isHindi: isHindi,
                        delay: index * 50,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FaqCard extends StatefulWidget {
  final Map<String, dynamic> faq;
  final bool isHindi;
  final int delay;

  const _FaqCard({required this.faq, required this.isHindi, this.delay = 0});

  @override
  State<_FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<_FaqCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final faq = widget.faq;

    return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _isExpanded
                  ? AppTheme.primaryColor.withAlpha(100)
                  : Colors.grey.shade200,
            ),
          ),
          child: InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        faq['icon'] as String? ?? '❓',
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              faq['category'] as String? ?? '',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              faq['question'] as String? ?? '',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
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
                    const Divider(height: 24),
                    _buildRichAnswer(faq['answer'] as String? ?? ''),
                  ],
                ],
              ),
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: widget.delay))
        .fadeIn()
        .slideY(begin: 0.05, end: 0);
  }

  Widget _buildRichAnswer(String answer) {
    final lines = answer.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) return const SizedBox(height: 8);

        // Bold text: **text**
        if (trimmed.contains('**')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _buildBoldText(trimmed),
          );
        }

        // Bullet points
        if (trimmed.startsWith('•') || trimmed.startsWith('✅')) {
          return Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trimmed.startsWith('✅') ? '✅ ' : '• ',
                  style: TextStyle(color: AppTheme.primaryColor, fontSize: 14),
                ),
                Expanded(
                  child: _buildBoldText(
                    trimmed.startsWith('✅')
                        ? trimmed.substring(2).trim()
                        : trimmed.substring(1).trim(),
                  ),
                ),
              ],
            ),
          );
        }

        // Numbered items
        if (RegExp(r'^\d+\.').hasMatch(trimmed)) {
          return Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: _buildBoldText(trimmed),
          );
        }

        // Arrow/hierarchy lines
        if (trimmed.contains('↓') || trimmed.contains('→')) {
          return Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 2),
            child: Text(
              trimmed,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            trimmed,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBoldText(String text) {
    final parts = text.split('**');
    if (parts.length <= 1) {
      return Text(text, style: const TextStyle(fontSize: 14, height: 1.5));
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: AppTheme.textPrimary,
        ),
        children: parts.asMap().entries.map((entry) {
          final isBold = entry.key % 2 == 1;
          return TextSpan(
            text: entry.value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          );
        }).toList(),
      ),
    );
  }
}
