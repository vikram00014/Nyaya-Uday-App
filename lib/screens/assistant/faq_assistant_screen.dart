import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_theme.dart';
import '../../providers/locale_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/state_catalog.dart';
import '../../services/groq_service.dart';
import '../../services/knowledge_base.dart';

// ─────────────────────────────────────────────────────────────
// Civic Voice Interface (CVI) — Chat-based Judicial Assistant
//
// CVI Feature 1: Interaction History & Reference Recall
// CVI Feature 2: Structured Decision Checkpoint
// CVI Feature 3: Alternative Path Suggestion
// CVI Feature 4: Conversation Time Awareness
// CVI Feature 5: Graceful Failure & Safe Exit
// ─────────────────────────────────────────────────────────────

// ── Chat message model ──────────────────────────────────────
enum MessageType { bot, user, checkpoint, summary, alternatives, safeExit }

class _ChatMessage {
  final String text;
  final MessageType type;
  final List<Map<String, dynamic>>? faqResults;
  final List<String>? alternativeQueries;
  final DateTime timestamp;

  _ChatMessage({
    required this.text,
    required this.type,
    this.faqResults,
    this.alternativeQueries,
  }) : timestamp = DateTime.now();
}

// ── Session context (Feature 1) ─────────────────────────────
class _SessionContext {
  String? userName;
  String? userState;
  String? userStateDisplay;
  String? userEducation;
  int? userAge;
  String? userCategory;
  String? userGender;
  double? userIncome;
  bool? userDisability;
  final List<String> topicsDiscussed = [];
  int interactionCount = 0;
  final DateTime sessionStart = DateTime.now();

  Duration get elapsed => DateTime.now().difference(sessionStart);
}

// ── Screen ──────────────────────────────────────────────────
class FaqAssistantScreen extends StatefulWidget {
  const FaqAssistantScreen({super.key});

  @override
  State<FaqAssistantScreen> createState() => _FaqAssistantScreenState();
}

class _FaqAssistantScreenState extends State<FaqAssistantScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  final _SessionContext _session = _SessionContext();

  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechAvailable = false;

  // Feature 2: Checkpoint state
  bool _awaitingCheckpoint = false;
  String _pendingQuery = '';

  // Feature 4: Time awareness flags
  bool _summaryOffered = false;
  bool _timeWarningShown = false;

  // LLM (Groq) state
  bool _isOnline = false;
  bool _isLlmTyping = false;
  final List<Map<String, String>> _conversationHistory = [];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
    _checkConnectivity();

    // Feature 1: Load session context from user profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSessionContext();
    });
  }

  Future<void> _checkConnectivity() async {
    final online = await GroqService.isOnline();
    final hasKey = await GroqService.hasApiKey();
    if (mounted) setState(() => _isOnline = online && hasKey);
  }

  // Feature 1: Read user's state and education from provider
  void _loadSessionContext() {
    final userProvider = context.read<UserProvider>();
    final user = userProvider.user;
    if (user != null) {
      _session.userName = userProvider.displayName;
      _session.userState = user.state;
      _session.userEducation = user.educationLevel;
      _session.userAge = user.age;
      _session.userCategory = user.category;
      _session.userGender = user.gender;
      _session.userIncome = user.annualIncome;
      _session.userDisability = user.hasDisability;
      final stateInfo = StateCatalog.tryResolve(user.state);
      if (stateInfo != null) {
        final localeProvider = context.read<LocaleProvider>();
        final isHindi = localeProvider.locale.languageCode == 'hi';
        _session.userStateDisplay = isHindi ? stateInfo.nameHi : stateInfo.name;
      } else {
        _session.userStateDisplay = user.state;
      }
    }
    _addWelcomeMessage();
  }

  // Feature 1: Welcome message with session context
  void _addWelcomeMessage() {
    final isHindi = context.read<LocaleProvider>().locale.languageCode == 'hi';
    String welcome;

    final modeNote = _isOnline
        ? (isHindi
              ? '\n\n✨ **AI मोड सक्रिय** — कोई भी सवाल स्वतंत्र रूप से पूछें!'
              : '\n\n✨ **AI mode active** — ask any question freely!')
        : (isHindi
              ? '\n\n📴 **ऑफ़लाइन मोड** — पूर्व-निर्धारित FAQ से उत्तर मिलेंगे।'
              : '\n\n📴 **Offline mode** — answers from pre-built FAQ.');

    if (_session.userState != null && _session.userEducation != null) {
      final edu = _session.userEducation!;
      final state = _session.userStateDisplay ?? _session.userState!;
      final extraInfo = <String>[];
      if (_session.userAge != null) {
        extraInfo.add(
          isHindi ? 'आयु: ${_session.userAge}' : 'Age: ${_session.userAge}',
        );
      }
      if (_session.userCategory != null) {
        extraInfo.add(
          isHindi
              ? 'श्रेणी: ${_session.userCategory}'
              : 'Category: ${_session.userCategory}',
        );
      }
      if (_session.userIncome != null) {
        extraInfo.add(
          isHindi
              ? 'आय: ₹${_session.userIncome} लाख'
              : 'Income: ₹${_session.userIncome}L',
        );
      }
      final extraStr = extraInfo.isNotEmpty ? ' (${extraInfo.join(', ')})' : '';
      final nameGreet = _session.userName != null
          ? ', ${_session.userName}'
          : '';
      if (isHindi) {
        welcome =
            'नमस्ते$nameGreet! 🙏 मैं आपका न्यायिक सहायक हूं।\n\n'
            'मुझे पता है कि आप **$state** से हैं '
            'और आपकी शिक्षा स्तर **$edu** है।$extraStr\n\n'
            'आप न्यायिक करियर के बारे में कोई भी सवाल पूछ सकते हैं। '
            'टाइप करें या माइक बटन दबाकर बोलें।$modeNote';
      } else {
        welcome =
            'Hello$nameGreet! 🙏 I am your Judicial Career Assistant.\n\n'
            'I see that you are from **$state** '
            'and your education level is **$edu**.$extraStr\n\n'
            'You can ask me any question about the judicial career path. '
            'Type or tap the mic to speak.$modeNote';
      }
    } else {
      welcome = isHindi
          ? 'नमस्ते! 🙏 मैं आपका न्यायिक सहायक हूं।\n\n'
                'न्यायिक करियर के बारे में कोई भी सवाल पूछें।$modeNote'
          : 'Hello! 🙏 I am your Judicial Career Assistant.\n\n'
                'Ask me any question about the judicial career path.$modeNote';
    }

    setState(() {
      _messages.add(_ChatMessage(text: welcome, type: MessageType.bot));
    });
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
    _inputController.dispose();
    _scrollController.dispose();
    _speech.stop();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Voice ──────────────────────────────────────────────────
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
        if (result.finalResult) {
          _inputController.text = result.recognizedWords;
          _handleUserInput(result.recognizedWords);
        } else {
          _inputController.text = result.recognizedWords;
        }
      },
      localeId: isHindi ? 'hi_IN' : 'en_US',
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  // ── Main input handler ────────────────────────────────────
  void _handleUserInput(String rawInput) {
    final query = rawInput.trim();
    if (query.isEmpty) return;

    final isHindi = context.read<LocaleProvider>().locale.languageCode == 'hi';

    // Add user message
    setState(() {
      _messages.add(_ChatMessage(text: query, type: MessageType.user));
      _inputController.clear();
    });
    _scrollToBottom();

    _session.interactionCount++;

    if (_isOnline) {
      // Online mode: send directly to LLM — no checkpoint needed.
      // The LLM has the full knowledge base and can answer any question.
      _processQuery(query, isHindi);
    } else {
      // Offline mode: Process rule-based FAQ directly.
      // Checkpoint only shown in the response when results are found.
      _processQuery(query, isHindi);
    }

    // Feature 4: Time awareness — never blocks or drops user input
    if (!_summaryOffered && _session.interactionCount >= 5) {
      _summaryOffered = true;
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _offerSummary(isHindi);
      });
    } else if (!_timeWarningShown && _session.interactionCount >= 8) {
      _timeWarningShown = true;
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _offerTimeCheck(isHindi);
      });
    }
  }

  // ── Feature 2: Topic detection (used for session tracking) ─

  String _detectTopic(String query, bool isHindi) {
    if (query.contains('12') || query.contains('बारहवीं')) {
      return isHindi
          ? '12वीं के बाद न्यायिक करियर'
          : 'judicial career after 12th';
    }
    if (query.contains('graduat') || query.contains('ग्रेजुएशन')) {
      return isHindi
          ? 'ग्रेजुएशन के बाद न्यायिक करियर'
          : 'judicial career after graduation';
    }
    if (query.contains('salary') ||
        query.contains('pay') ||
        query.contains('सैलरी') ||
        query.contains('वेतन')) {
      return isHindi ? 'जज का वेतन' : 'judge salary';
    }
    if (query.contains('age') ||
        query.contains('eligib') ||
        query.contains('आयु') ||
        query.contains('पात्रता')) {
      return isHindi ? 'आयु सीमा और पात्रता' : 'age limit and eligibility';
    }
    if (query.contains('exam') ||
        query.contains('परीक्षा') ||
        query.contains('pcs')) {
      return isHindi ? 'न्यायिक परीक्षा' : 'judicial examination';
    }
    if (query.contains('clat') || query.contains('क्लैट')) {
      return 'CLAT';
    }
    if (query.contains('court') || query.contains('न्यायालय')) {
      return isHindi ? 'न्यायालय प्रणाली' : 'court system';
    }
    if (query.contains('career') ||
        query.contains('growth') ||
        query.contains('करियर')) {
      return isHindi ? 'करियर ग्रोथ' : 'career growth';
    }
    if (query.contains('prepar') ||
        query.contains('तैयारी') ||
        query.contains('tips')) {
      return isHindi ? 'तैयारी के सुझाव' : 'preparation tips';
    }
    if (query.contains('stream') || query.contains('स्ट्रीम')) {
      return isHindi ? 'LLB के लिए स्ट्रीम' : 'stream for LLB';
    }
    // Fallback
    return isHindi ? 'न्यायिक करियर' : 'judicial career';
  }

  // User confirms or continues from checkpoint
  void _onCheckpointConfirm(bool confirmed) {
    final isHindi = context.read<LocaleProvider>().locale.languageCode == 'hi';

    setState(() {
      _awaitingCheckpoint = false;
      _messages.add(
        _ChatMessage(
          text: confirmed
              ? (isHindi ? '👍 धन्यवाद!' : '👍 Thanks!')
              : (isHindi ? '🔄 और जानकारी चाहिए' : '🔄 Need more info'),
          type: MessageType.user,
        ),
      );
    });

    if (confirmed) {
      // User found the answer helpful — offer to continue
      setState(() {
        _messages.add(
          _ChatMessage(
            text: isHindi
                ? 'बहुत अच्छा! कोई और सवाल पूछें या ऊपर दिए विषयों में से चुनें।'
                : 'Great! Feel free to ask another question or pick from the topics above.',
            type: MessageType.bot,
          ),
        );
      });
    } else {
      // User needs more — show alternatives
      setState(() {
        _messages.add(
          _ChatMessage(
            text: isHindi
                ? 'कोई बात नहीं! कृपया अपना सवाल दूसरे तरीके से पूछें, या इन विकल्पों को आज़माएं:'
                : 'No problem! Try rephrasing your question, or try these alternatives:',
            type: MessageType.bot,
          ),
        );
      });
      _handleNoResults(_pendingQuery, isHindi);
    }
    _scrollToBottom();
  }

  // ── Process query ─────────────────────────────────────────
  void _processQuery(String query, bool isHindi) {
    final lowerQ = query.toLowerCase();

    // Feature 1: Track topic in session
    final topic = _detectTopic(lowerQ, isHindi);
    if (!_session.topicsDiscussed.contains(topic)) {
      _session.topicsDiscussed.add(topic);
    }

    // ── LLM path (online) — handles any question freely ────
    if (_isOnline) {
      _processWithLlm(query, isHindi);
      return;
    }

    // ── Rule-based path (offline fallback) ──────────────────
    final intentQuery = _detectVoiceIntent(lowerQ, isHindi);
    final searchQ = intentQuery ?? lowerQ;
    _processRuleBased(searchQ, lowerQ, isHindi);
  }

  /// Send the query to the Groq LLM with full knowledge context.
  Future<void> _processWithLlm(String query, bool isHindi) async {
    setState(() => _isLlmTyping = true);
    _scrollToBottom();

    final locale = isHindi ? 'hi' : 'en';
    final systemPrompt = KnowledgeBase.buildSystemPrompt(
      userName: _session.userName,
      userState: _session.userStateDisplay ?? _session.userState,
      userEducation: _session.userEducation,
      userAge: _session.userAge,
      userCategory: _session.userCategory,
      userGender: _session.userGender,
      userIncome: _session.userIncome,
      userDisability: _session.userDisability,
      locale: locale,
    );

    // Feature 1: Add rich context for personalized LLM responses
    String enrichedQuery = query;
    final contextParts = <String>[];
    if (_session.topicsDiscussed.length > 1) {
      final prevTopics = _session.topicsDiscussed
          .sublist(0, _session.topicsDiscussed.length - 1)
          .join(', ');
      contextParts.add('Previously discussed: $prevTopics');
    }
    if (_session.userAge != null) {
      contextParts.add('User age: ${_session.userAge}');
    }
    if (_session.userCategory != null) {
      contextParts.add('User category: ${_session.userCategory}');
    }
    if (_session.userGender != null) {
      contextParts.add('User gender: ${_session.userGender}');
    }
    if (contextParts.isNotEmpty) {
      enrichedQuery = '(${contextParts.join(' | ')})';
      if (_session.userIncome != null) {
        enrichedQuery += ' | Income: ₹${_session.userIncome} Lakh';
      }
      enrichedQuery += '\n\nQuestion: $query';
    }

    final reply = await GroqService.chat(
      systemPrompt: systemPrompt,
      conversationHistory: _conversationHistory,
      userMessage: enrichedQuery,
    );

    // Track in conversation history (keep last 10 exchanges = 20 messages)
    _conversationHistory.add({'role': 'user', 'content': query});

    if (reply != null) {
      _conversationHistory.add({'role': 'assistant', 'content': reply});
      if (_conversationHistory.length > 20) {
        _conversationHistory.removeRange(0, 2);
      }

      setState(() {
        _isLlmTyping = false;
        _messages.add(_ChatMessage(text: reply, type: MessageType.bot));
      });
    } else {
      // LLM failed — fall back to rule-based for this query
      setState(() {
        _isLlmTyping = false;
        _isOnline = false; // mark offline for subsequent queries
        _messages.add(
          _ChatMessage(
            text: isHindi
                ? '⚠️ AI सेवा अभी उपलब्ध नहीं है। ऑफ़लाइन मोड पर स्विच किया गया।'
                : '⚠️ AI service unavailable. Switched to offline mode.',
            type: MessageType.bot,
          ),
        );
      });
      final lowerQ = query.toLowerCase();
      final intentQuery = _detectVoiceIntent(lowerQ, isHindi);
      final searchQ = intentQuery ?? lowerQ;
      _processRuleBased(searchQ, lowerQ, isHindi);
    }
    _scrollToBottom();
  }

  /// Original rule-based FAQ matching (offline fallback).
  /// Checkpoint confirmation is shown alongside the answer (not before query).
  void _processRuleBased(String searchQ, String lowerQ, bool isHindi) {
    final allFaqs = _getFaqs(isHindi);
    final results = allFaqs.where((faq) => _matchesFaq(faq, searchQ)).toList();

    if (results.isNotEmpty) {
      // Feature 1: Reference earlier context
      String contextRef = '';
      if (_session.topicsDiscussed.length > 1 &&
          _session.userStateDisplay != null) {
        final prevTopic =
            _session.topicsDiscussed[_session.topicsDiscussed.length - 2];
        if (isHindi) {
          contextRef =
              'पहले आपने **$prevTopic** के बारे में पूछा था। अब इस विषय पर:\n\n';
        } else {
          contextRef =
              'Earlier you asked about **$prevTopic**. Now on this topic:\n\n';
        }
      }

      setState(() {
        _messages.add(
          _ChatMessage(
            text:
                contextRef +
                (isHindi
                    ? 'मुझे ${results.length} उत्तर मिले। यहां देखें:'
                    : 'I found ${results.length} answer${results.length > 1 ? 's' : ''}. Here you go:'),
            type: MessageType.bot,
            faqResults: results,
          ),
        );

        // Feature 2: Show confirmation checkpoint AFTER presenting the answer
        _messages.add(
          _ChatMessage(
            text: isHindi
                ? '✅ क्या यह जानकारी आपके लिए उपयोगी थी? कुछ और पूछना है?'
                : '✅ Was this information helpful? Want to ask anything else?',
            type: MessageType.checkpoint,
          ),
        );
        _pendingQuery = searchQ;
        _awaitingCheckpoint = true;
      });
    } else {
      // Feature 3 + 5: No results → Alternatives + Graceful failure
      _handleNoResults(lowerQ, isHindi);
    }
    _scrollToBottom();
  }

  // ── Feature 3: Alternative Path Suggestion ────────────────
  void _handleNoResults(String query, bool isHindi) {
    // Suggest related alternatives
    final alternatives = <String>[];
    if (isHindi) {
      alternatives.addAll([
        '12वीं के बाद जज कैसे बनें?',
        'आयु सीमा क्या है?',
        'वेतन कितनी है?',
        'कौन सी परीक्षा देनी होगी?',
      ]);
    } else {
      alternatives.addAll([
        'How to become judge after 12th?',
        'What is the age limit?',
        'What is the salary?',
        'Which exam to give?',
      ]);
    }

    setState(() {
      _messages.add(
        _ChatMessage(
          text: isHindi
              ? '🤔 मुझे "$query" के लिए सटीक उत्तर नहीं मिला।\n\n'
                    'शायद यह एक ऐसा विषय है जिसकी जानकारी अभी उपलब्ध नहीं है, '
                    'या नियम अस्पष्ट हो सकते हैं।\n\n'
                    '**आप ये विकल्प आज़मा सकते हैं:**'
              : '🤔 I could not find an exact answer for "$query".\n\n'
                    'This may be a topic where information is not yet available, '
                    'or the rules may be unclear.\n\n'
                    '**You can try these alternatives:**',
          type: MessageType.alternatives,
          alternativeQueries: alternatives,
        ),
      );

      // Feature 5: Safe exit guidance
      _messages.add(
        _ChatMessage(
          text: isHindi
              ? '🏛️ **अगला कदम:**\n'
                    '• अपने राज्य के **High Court** की वेबसाइट देखें\n'
                    '• **State PSC** की भर्ती अधिसूचना जांचें\n'
                    '• जिला न्यायालय में **Legal Aid Centre** से संपर्क करें\n\n'
                    'ये आधिकारिक स्रोत सबसे विश्वसनीय हैं।'
              : '🏛️ **Suggested next steps:**\n'
                    '• Visit your state **High Court** website\n'
                    '• Check **State PSC** recruitment notifications\n'
                    '• Contact the **Legal Aid Centre** at your district court\n\n'
                    'These official sources are the most reliable.',
          type: MessageType.safeExit,
        ),
      );
    });
    _scrollToBottom();
  }

  // ── Feature 4: Conversation Time Awareness ────────────────
  void _offerSummary(bool isHindi) {
    if (_session.topicsDiscussed.isEmpty) return;

    final topics = _session.topicsDiscussed.join(', ');
    setState(() {
      _messages.add(
        _ChatMessage(
          text: isHindi
              ? '📝 आपने अब तक **${_session.interactionCount} सवाल** पूछे हैं '
                    'और इन विषयों पर बात की: **$topics**।\n\n'
                    'क्या आप अब तक की चर्चा का सारांश चाहते हैं?'
              : '📝 You have asked **${_session.interactionCount} questions** so far, '
                    'covering: **$topics**.\n\n'
                    'Would you like a quick summary of our conversation?',
          type: MessageType.summary,
        ),
      );
    });
    _scrollToBottom();
  }

  void _offerTimeCheck(bool isHindi) {
    final mins = _session.elapsed.inMinutes;
    setState(() {
      _messages.add(
        _ChatMessage(
          text: isHindi
              ? '⏰ आप **$mins+ मिनट** से यहां हैं और **${_session.interactionCount} सवाल** पूछ चुके हैं।\n\n'
                    'क्या आप जारी रखना चाहते हैं, या सारांश के साथ समाप्त करें?'
              : '⏰ You have been here for **$mins+ minutes** and asked **${_session.interactionCount} questions**.\n\n'
                    'Would you like to continue, or wrap up with a summary?',
          type: MessageType.summary,
        ),
      );
    });
    _scrollToBottom();
  }

  void _generateSummary() {
    final isHindi = context.read<LocaleProvider>().locale.languageCode == 'hi';
    final topics = _session.topicsDiscussed;
    final state = _session.userStateDisplay ?? '';

    final income = _session.userIncome;
    final hasDisability = _session.userDisability;

    String summary;
    if (isHindi) {
      summary = '📋 **आज की चर्चा का सारांश:**\n\n';
      if (state.isNotEmpty) summary += '• आपका राज्य: **$state**\n';
      if (_session.userEducation != null) {
        summary += '• शिक्षा स्तर: **${_session.userEducation}**\n';
      }
      if (income != null) {
        summary += '• वार्षिक आय: **₹${income.toStringAsFixed(1)} लाख**\n';
      }
      if (hasDisability == true) {
        summary += '• PwD श्रेणी: **हाँ** (आयु/प्रयास में छूट लागू)\n';
      }
      summary += '• कुल सवाल: **${_session.interactionCount}**\n';
      if (topics.isNotEmpty) {
        summary += '• चर्चित विषय: **${topics.join(", ")}**\n';
      }
      if (income != null && income < 3) {
        summary +=
            '\n💡 **NALSA मुफ्त कानूनी सहायता:** आपकी आय ₹3 लाख से कम है — '
            'आप NALSA के तहत मुफ्त कानूनी सहायता के पात्र हो सकते हैं।\n';
      }
      summary +=
          '\n🏛️ आगे के लिए अपने राज्य की **आधिकारिक भर्ती अधिसूचना** '
          'अवश्य देखें। शुभकामनाएं! ⚖️';
    } else {
      summary = '📋 **Summary of today\'s conversation:**\n\n';
      if (state.isNotEmpty) summary += '• Your state: **$state**\n';
      if (_session.userEducation != null) {
        summary += '• Education level: **${_session.userEducation}**\n';
      }
      if (income != null) {
        summary += '• Annual income: **₹${income.toStringAsFixed(1)} Lakhs**\n';
      }
      if (hasDisability == true) {
        summary +=
            '• PwD category: **Yes** (age/attempt relaxations may apply)\n';
      }
      summary += '• Total questions: **${_session.interactionCount}**\n';
      if (topics.isNotEmpty) {
        summary += '• Topics covered: **${topics.join(", ")}**\n';
      }
      if (income != null && income < 3) {
        summary +=
            '\n💡 **NALSA Free Legal Aid:** Your income is under ₹3 Lakhs — '
            'you may be eligible for free legal aid under NALSA.\n';
      }
      summary +=
          '\n🏛️ Be sure to check the **official recruitment notification** '
          'for your state. Best of luck! ⚖️';
    }

    setState(() {
      _messages.add(_ChatMessage(text: summary, type: MessageType.bot));
    });
    _scrollToBottom();
  }

  // ── Feature 5: Graceful exit ──────────────────────────────
  void _handleGracefulExit() {
    final isHindi = context.read<LocaleProvider>().locale.languageCode == 'hi';

    // Generate summary + safe exit
    _generateSummary();

    setState(() {
      _messages.add(
        _ChatMessage(
          text: isHindi
              ? '👋 यदि आपके और सवाल हैं, तो कभी भी वापस आएं। '
                    'आपकी न्यायिक यात्रा की शुभकामनाएं!'
              : '👋 If you have more questions, come back anytime. '
                    'Best wishes on your judicial journey!',
          type: MessageType.safeExit,
        ),
      );
    });
    _scrollToBottom();
  }

  // ── Voice intent detection ────────────────────────────────
  String? _detectVoiceIntent(String query, bool isHindi) {
    final q = query.toLowerCase().trim();

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
    if (q.contains('salary') ||
        q.contains('pay') ||
        q.contains('सैलरी') ||
        q.contains('वेतन') ||
        q.contains('income')) {
      return 'salary';
    }
    if ((q.contains('age') || q.contains('आयु') || q.contains('उम्र')) ||
        (q.contains('eligibility') || q.contains('पात्रता'))) {
      return 'eligibility';
    }
    return null;
  }

  // ── FAQ matching logic ────────────────────────────────────
  bool _matchesFaq(Map<String, dynamic> faq, String query) {
    final question = (faq['question'] as String? ?? '').toLowerCase();
    final answer = (faq['answer'] as String? ?? '').toLowerCase();
    final keywords = (faq['keywords'] as List<dynamic>? ?? const [])
        .map((k) => k.toString().toLowerCase())
        .toList();

    if (question.contains(query) || answer.contains(query)) return true;
    if (keywords.any((k) => k.contains(query) || query.contains(k))) {
      return true;
    }

    final tokens = query
        .split(RegExp(r'\s+'))
        .map((t) => t.trim())
        .where((t) => t.length >= 2)
        .toList();
    if (tokens.isEmpty) return false;

    final searchable = '$question ${keywords.join(' ')} $answer';
    return tokens.every(searchable.contains);
  }

  // ── FAQ data ──────────────────────────────────────────────
  List<Map<String, dynamic>> _getFaqs(bool isHindi) {
    return [
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

  // ── Quick questions — mode-aware suggestions ──────────────
  List<Map<String, String>> _getQuickQuestions(bool isHindi) {
    if (_isOnline) {
      // Online: More open-ended questions that LLM can answer deeply
      return [
        {
          'text': isHindi
              ? 'मेरे राज्य में जज कैसे बनें?'
              : 'How to become judge in my state?',
        },
        {'text': isHindi ? 'मेरी पात्रता क्या है?' : 'Am I eligible?'},
        {
          'text': isHindi
              ? 'तैयारी की पूरी रणनीति बताएं'
              : 'Full preparation strategy?',
        },
        {
          'text': isHindi
              ? 'वेतन और सुविधाएं क्या हैं?'
              : 'Salary and benefits?',
        },
        {
          'text': isHindi
              ? 'मुफ्त कानूनी सहायता कैसे मिले?'
              : 'How to get free legal aid?',
        },
        {'text': isHindi ? 'CLAT vs राज्य परीक्षा?' : 'CLAT vs State exam?'},
      ];
    } else {
      // Offline: FAQ-matching friendly questions
      return [
        {'text': isHindi ? '12वीं के बाद जज कैसे बनें?' : 'Judge after 12th?'},
        {'text': isHindi ? 'आयु सीमा क्या है?' : 'Age limit?'},
        {'text': isHindi ? 'वेतन कितनी है?' : 'Salary?'},
        {'text': isHindi ? 'कौन सी परीक्षा?' : 'Which exam?'},
        {'text': isHindi ? 'तैयारी कैसे करें?' : 'How to prepare?'},
        {'text': isHindi ? 'CLAT क्या है?' : 'What is CLAT?'},
      ];
    }
  }

  // ── Build UI ──────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final isHindi = localeProvider.locale.languageCode == 'hi';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                isHindi ? 'न्यायिक सहायक' : 'Judicial Assistant',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _isOnline
                    ? Colors.green.shade400.withAlpha(60)
                    : Colors.orange.shade400.withAlpha(60),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isOnline ? Icons.auto_awesome : Icons.wifi_off,
                    size: 12,
                    color: _isOnline ? Colors.greenAccent : Colors.orangeAccent,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    _isOnline ? 'AI' : 'Offline',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _isOnline
                          ? Colors.greenAccent
                          : Colors.orangeAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          // Refresh connectivity
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            tooltip: isHindi ? 'कनेक्शन जांचें' : 'Check connection',
            onPressed: _checkConnectivity,
          ),
          // Feature 5: Graceful exit button
          IconButton(
            icon: const Icon(Icons.summarize_outlined),
            tooltip: isHindi ? 'सारांश और समाप्त' : 'Summary & Exit',
            onPressed: _handleGracefulExit,
          ),
        ],
      ),
      body: Column(
        children: [
          // Voice status banner
          if (_speechAvailable)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isListening
                        ? (isHindi ? '🎙️ सुन रहा हूं...' : '🎙️ Listening...')
                        : (isHindi
                              ? '🎙️ माइक दबाकर बोलें'
                              : '🎙️ Tap mic to speak'),
                    style: TextStyle(
                      fontSize: 12,
                      color: _isListening
                          ? Colors.red.shade700
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

          // Quick question chips (only at start)
          if (_messages.length <= 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _getQuickQuestions(isHindi).map((q) {
                  return ActionChip(
                    label: Text(
                      q['text']!,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: AppTheme.primaryColor.withAlpha(20),
                    side: BorderSide(
                      color: AppTheme.primaryColor.withAlpha(50),
                    ),
                    onPressed: () {
                      _inputController.text = q['text']!;
                      _handleUserInput(q['text']!);
                    },
                  );
                }).toList(),
              ),
            ).animate().fadeIn(),

          // ── Chat messages ─────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index], isHindi);
              },
            ),
          ),

          // ── LLM thinking indicator ──────────────────────────
          if (_isLlmTyping)
            Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            AppTheme.accentColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isHindi ? 'AI सोच रहा है...' : 'AI is thinking...',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                )
                .animate(onPlay: (c) => c.repeat())
                .shimmer(
                  duration: 1200.ms,
                  color: AppTheme.accentColor.withAlpha(40),
                ),

          // ── Input bar ─────────────────────────────────────
          if (_awaitingCheckpoint)
            _buildCheckpointButtons(isHindi)
          else
            _buildInputBar(isHindi),
        ],
      ),
    );
  }

  // ── Chat message builder ──────────────────────────────────
  Widget _buildMessage(_ChatMessage message, bool isHindi) {
    final isUser = message.type == MessageType.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Message bubble
          Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.82,
                ),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isUser
                      ? AppTheme.primaryColor
                      : _bubbleColor(message.type),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isUser ? 16 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type label for special messages
                    if (message.type == MessageType.checkpoint)
                      _typeLabel(
                        isHindi ? '🔍 पुष्टि' : '🔍 Confirmation',
                        Colors.orange,
                      )
                    else if (message.type == MessageType.summary)
                      _typeLabel(
                        isHindi ? '⏰ समय जागरूकता' : '⏰ Time Check',
                        Colors.blue,
                      )
                    else if (message.type == MessageType.alternatives)
                      _typeLabel(
                        isHindi ? '💡 विकल्प' : '💡 Alternatives',
                        Colors.purple,
                      )
                    else if (message.type == MessageType.safeExit)
                      _typeLabel(
                        isHindi ? '🏛️ मार्गदर्शन' : '🏛️ Guidance',
                        Colors.teal,
                      ),

                    // Message text
                    _buildRichText(
                      message.text,
                      isUser ? Colors.white : AppTheme.textPrimary,
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 200.ms)
              .slideX(begin: isUser ? 0.05 : -0.05, end: 0),

          // FAQ result cards embedded in bot message
          if (message.faqResults != null && message.faqResults!.isNotEmpty)
            ...message.faqResults!.asMap().entries.map((entry) {
              return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: _EmbeddedFaqCard(faq: entry.value, isHindi: isHindi),
                  )
                  .animate(delay: Duration(milliseconds: 100 * entry.key))
                  .fadeIn()
                  .slideY(begin: 0.05, end: 0);
            }),

          // Alternative suggestion chips (Feature 3)
          if (message.alternativeQueries != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: message.alternativeQueries!.map((q) {
                  return ActionChip(
                    label: Text(q, style: const TextStyle(fontSize: 12)),
                    backgroundColor: Colors.purple.shade50,
                    side: BorderSide(color: Colors.purple.shade200),
                    onPressed: () {
                      _inputController.text = q;
                      _handleUserInput(q);
                    },
                  );
                }).toList(),
              ),
            ).animate().fadeIn(delay: 300.ms),

          // Feature 4: Summary action buttons
          if (message.type == MessageType.summary)
            _buildSummaryActions(isHindi),
        ],
      ),
    );
  }

  Color _bubbleColor(MessageType type) {
    switch (type) {
      case MessageType.checkpoint:
        return Colors.orange.shade50;
      case MessageType.summary:
        return Colors.blue.shade50;
      case MessageType.alternatives:
        return Colors.purple.shade50;
      case MessageType.safeExit:
        return Colors.teal.shade50;
      default:
        return Colors.grey.shade100;
    }
  }

  Widget _typeLabel(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }

  // Feature 2: Post-answer feedback buttons (offline only)
  Widget _buildCheckpointButtons(bool isHindi) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border(top: BorderSide(color: Colors.green.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _onCheckpointConfirm(false),
              icon: const Icon(Icons.help_outline, size: 18),
              label: Text(isHindi ? 'और जानें' : 'Need more'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange.shade700,
                side: BorderSide(color: Colors.orange.shade300),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _onCheckpointConfirm(true),
              icon: const Icon(Icons.thumb_up_alt_outlined, size: 18),
              label: Text(isHindi ? 'उपयोगी था!' : 'Helpful!'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  // Feature 4: Summary action buttons within chat
  Widget _buildSummaryActions(bool isHindi) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButton(
            onPressed: () {
              setState(() {
                _messages.add(
                  _ChatMessage(
                    text: isHindi ? 'जारी रखें' : 'Continue',
                    type: MessageType.user,
                  ),
                );
              });
              _scrollToBottom();
            },
            child: Text(isHindi ? 'जारी रखें' : 'Continue'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _generateSummary,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(isHindi ? 'सारांश दें' : 'Show Summary'),
          ),
        ],
      ),
    );
  }

  // Input bar at bottom
  Widget _buildInputBar(bool isHindi) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                onSubmitted: _handleUserInput,
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  hintText: isHindi
                      ? 'अपना सवाल टाइप करें...'
                      : 'Type your question...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  isDense: true,
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
                    size: 22,
                  ),
                  onPressed: _isListening
                      ? _stopListening
                      : () => _startListening(isHindi),
                ),
              ),
            ],
            const SizedBox(width: 6),
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentColor,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: () => _handleUserInput(_inputController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Rich text (bold + clickable URL support) ─────────────

  static final _urlRegex = RegExp(
    r'(https?://[^\s,)]+|www\.[^\s,)]+|[a-zA-Z0-9-]+\.[a-z]{2,}(?:/[^\s,)]*)?)',
    caseSensitive: false,
  );

  Widget _buildRichText(String text, Color baseColor) {
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) return const SizedBox(height: 6);

        if (trimmed.contains('**')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: _buildBoldLine(trimmed, baseColor),
          );
        }

        if (trimmed.startsWith('•') || trimmed.startsWith('✅')) {
          return Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trimmed.startsWith('✅') ? '✅ ' : '• ',
                  style: TextStyle(color: baseColor, fontSize: 14),
                ),
                Expanded(
                  child: _buildBoldLine(
                    trimmed.substring(trimmed.startsWith('✅') ? 2 : 1).trim(),
                    baseColor,
                  ),
                ),
              ],
            ),
          );
        }

        if (RegExp(r'^\d+\.').hasMatch(trimmed)) {
          return Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 2),
            child: _buildBoldLine(trimmed, baseColor),
          );
        }

        if (trimmed.contains('↓') || trimmed.contains('→')) {
          return Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 1),
            child: _buildClickableText(
              trimmed,
              TextStyle(color: baseColor.withAlpha(180), fontSize: 13),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: _buildClickableText(
            trimmed,
            TextStyle(fontSize: 14, height: 1.4, color: baseColor),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBoldLine(String text, Color baseColor) {
    final parts = text.split('**');
    if (parts.length <= 1) {
      return _buildClickableText(
        text,
        TextStyle(fontSize: 14, height: 1.4, color: baseColor),
      );
    }
    // Build spans with bold + URL detection
    final spans = <InlineSpan>[];
    for (final entry in parts.asMap().entries) {
      final isBold = entry.key % 2 == 1;
      final partStyle = TextStyle(
        fontSize: 14,
        height: 1.4,
        color: baseColor,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      );
      final urlMatches = _urlRegex.allMatches(entry.value).toList();
      if (urlMatches.isEmpty) {
        spans.add(TextSpan(text: entry.value, style: partStyle));
      } else {
        int lastEnd = 0;
        for (final match in urlMatches) {
          if (match.start > lastEnd) {
            spans.add(
              TextSpan(
                text: entry.value.substring(lastEnd, match.start),
                style: partStyle,
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
                  style: partStyle.copyWith(
                    color: Colors.blue.shade700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          );
          lastEnd = match.end;
        }
        if (lastEnd < entry.value.length) {
          spans.add(
            TextSpan(text: entry.value.substring(lastEnd), style: partStyle),
          );
        }
      }
    }
    return RichText(text: TextSpan(children: spans));
  }

  /// Renders plain text with auto-detected clickable URLs.
  Widget _buildClickableText(String text, TextStyle style) {
    final matches = _urlRegex.allMatches(text).toList();
    if (matches.isEmpty) {
      return Text(text, style: style);
    }

    final spans = <InlineSpan>[];
    int lastEnd = 0;

    for (final match in matches) {
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(text: text.substring(lastEnd, match.start), style: style),
        );
      }
      final urlText = match.group(0)!;
      final fullUrl = urlText.startsWith('http') ? urlText : 'https://$urlText';
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

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd), style: style));
    }

    return RichText(text: TextSpan(children: spans));
  }
}

// ── Embedded FAQ card inside chat ───────────────────────────
class _EmbeddedFaqCard extends StatefulWidget {
  final Map<String, dynamic> faq;
  final bool isHindi;

  const _EmbeddedFaqCard({required this.faq, required this.isHindi});

  @override
  State<_EmbeddedFaqCard> createState() => _EmbeddedFaqCardState();
}

class _EmbeddedFaqCardState extends State<_EmbeddedFaqCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final faq = widget.faq;
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.82,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _expanded
              ? AppTheme.primaryColor.withAlpha(100)
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    faq['icon'] as String? ?? '❓',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          faq['category'] as String? ?? '',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          faq['question'] as String? ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
              if (_expanded) ...[
                const Divider(height: 16),
                _buildAnswer(faq['answer'] as String? ?? ''),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static final _faqUrlRegex = RegExp(
    r'(https?://[^\s,)]+|www\.[^\s,)]+|[a-zA-Z0-9-]+\.[a-z]{2,}(?:/[^\s,)]*)?)',
    caseSensitive: false,
  );

  Widget _buildAnswer(String answer) {
    final lines = answer.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) return const SizedBox(height: 6);

        if (trimmed.contains('**')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: _boldLine(trimmed),
          );
        }

        if (trimmed.startsWith('•') || trimmed.startsWith('✅')) {
          return Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trimmed.startsWith('✅') ? '✅ ' : '• ',
                  style: TextStyle(color: AppTheme.primaryColor, fontSize: 13),
                ),
                Expanded(
                  child: _boldLine(
                    trimmed.substring(trimmed.startsWith('✅') ? 2 : 1).trim(),
                  ),
                ),
              ],
            ),
          );
        }

        if (RegExp(r'^\d+\.').hasMatch(trimmed)) {
          return Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 2),
            child: _boldLine(trimmed),
          );
        }

        if (trimmed.contains('↓') || trimmed.contains('→')) {
          return Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 1),
            child: _faqClickableText(
              trimmed,
              TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: _faqClickableText(
            trimmed,
            const TextStyle(fontSize: 13, height: 1.4),
          ),
        );
      }).toList(),
    );
  }

  Widget _boldLine(String text) {
    final parts = text.split('**');
    if (parts.length <= 1) {
      return _faqClickableText(
        text,
        const TextStyle(fontSize: 13, height: 1.4),
      );
    }
    final spans = <InlineSpan>[];
    for (final entry in parts.asMap().entries) {
      final isBold = entry.key % 2 == 1;
      final partStyle = TextStyle(
        fontSize: 13,
        height: 1.4,
        color: AppTheme.textPrimary,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      );
      final urlMatches = _faqUrlRegex.allMatches(entry.value).toList();
      if (urlMatches.isEmpty) {
        spans.add(TextSpan(text: entry.value, style: partStyle));
      } else {
        int lastEnd = 0;
        for (final match in urlMatches) {
          if (match.start > lastEnd) {
            spans.add(
              TextSpan(
                text: entry.value.substring(lastEnd, match.start),
                style: partStyle,
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
                  style: partStyle.copyWith(
                    color: Colors.blue.shade700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          );
          lastEnd = match.end;
        }
        if (lastEnd < entry.value.length) {
          spans.add(
            TextSpan(text: entry.value.substring(lastEnd), style: partStyle),
          );
        }
      }
    }
    return RichText(text: TextSpan(children: spans));
  }

  /// Renders text with auto-detected clickable URLs.
  Widget _faqClickableText(String text, TextStyle style) {
    final matches = _faqUrlRegex.allMatches(text).toList();
    if (matches.isEmpty) {
      return Text(text, style: style);
    }

    final spans = <InlineSpan>[];
    int lastEnd = 0;

    for (final match in matches) {
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(text: text.substring(lastEnd, match.start), style: style),
        );
      }
      final urlText = match.group(0)!;
      final fullUrl = urlText.startsWith('http') ? urlText : 'https://$urlText';
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

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd), style: style));
    }

    return RichText(text: TextSpan(children: spans));
  }
}
