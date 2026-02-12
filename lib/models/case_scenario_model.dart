class JudgmentOption {
  final String id;
  final String text;
  final int fairnessScore;
  final int evidenceScore;
  final int biasScore;

  JudgmentOption({
    required this.id,
    required this.text,
    required this.fairnessScore,
    required this.evidenceScore,
    required this.biasScore,
  });

  int get totalScore => fairnessScore + evidenceScore + biasScore;

  factory JudgmentOption.fromJson(Map<String, dynamic> json) {
    final score = json['score'] as Map<String, dynamic>? ?? {};
    return JudgmentOption(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      fairnessScore: score['fairness'] ?? 0,
      evidenceScore: score['evidence'] ?? 0,
      biasScore: score['bias'] ?? 0,
    );
  }
}

class CaseScenario {
  final String id;
  final String title;
  final String titleHi;
  final String category;
  final String difficulty;
  final String facts;
  final String factsHi;
  final List<String> evidence;
  final List<String> evidenceHi;
  final List<JudgmentOption> options;
  final List<JudgmentOption> optionsHi;
  final String explanation;
  final String explanationHi;
  final String bestOptionId;

  CaseScenario({
    required this.id,
    required this.title,
    required this.titleHi,
    required this.category,
    required this.difficulty,
    required this.facts,
    required this.factsHi,
    required this.evidence,
    required this.evidenceHi,
    required this.options,
    required this.optionsHi,
    required this.explanation,
    required this.explanationHi,
    required this.bestOptionId,
  });

  factory CaseScenario.fromJson(Map<String, dynamic> json) {
    return CaseScenario(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      titleHi: json['title_hi'] ?? json['title'] ?? '',
      category: json['category'] ?? '',
      difficulty: json['difficulty'] ?? 'easy',
      facts: json['facts'] ?? '',
      factsHi: json['facts_hi'] ?? json['facts'] ?? '',
      evidence: List<String>.from(json['evidence'] ?? []),
      evidenceHi: List<String>.from(json['evidence_hi'] ?? json['evidence'] ?? []),
      options: (json['options'] as List?)
          ?.map((e) => JudgmentOption.fromJson(e))
          .toList() ?? [],
      optionsHi: (json['options_hi'] as List?)
          ?.map((e) => JudgmentOption.fromJson(e))
          .toList() ?? 
          (json['options'] as List?)
              ?.map((e) => JudgmentOption.fromJson(e))
              .toList() ?? [],
      explanation: json['explanation'] ?? '',
      explanationHi: json['explanation_hi'] ?? json['explanation'] ?? '',
      bestOptionId: json['best_option_id'] ?? '',
    );
  }

  String getTitle(String locale) => locale == 'hi' ? titleHi : title;
  String getFacts(String locale) => locale == 'hi' ? factsHi : facts;
  List<String> getEvidence(String locale) => locale == 'hi' ? evidenceHi : evidence;
  List<JudgmentOption> getOptions(String locale) => locale == 'hi' ? optionsHi : options;
  String getExplanation(String locale) => locale == 'hi' ? explanationHi : explanation;

  String get difficultyLabel {
    switch (difficulty) {
      case 'easy':
        return '⭐ Easy';
      case 'medium':
        return '⭐⭐ Medium';
      case 'hard':
        return '⭐⭐⭐ Hard';
      default:
        return '⭐ Easy';
    }
  }

  String get categoryIcon {
    switch (category) {
      case 'theft':
        return '🔒';
      case 'civil':
        return '📋';
      case 'property':
        return '🏠';
      case 'contract':
        return '📝';
      case 'family':
        return '👨‍👩‍👧';
      case 'consumer':
        return '🛍️';
      case 'workplace':
        return '🏢';
      case 'medical':
        return '🏥';
      case 'financial':
        return '💳';
      case 'accident':
        return '🚗';
      case 'cyber':
        return '💻';
      case 'agriculture':
        return '🌾';
      default:
        return '⚖️';
    }
  }
}

// Sample case scenarios
class CaseData {
  static List<CaseScenario> getSampleCases() {
    return [
      CaseScenario(
        id: 'case_001',
        title: 'The Missing Bicycle',
        titleHi: 'गायब साइकिल',
        category: 'theft',
        difficulty: 'easy',
        facts: 'Ravi claims that Suresh stole his bicycle from outside the grocery shop yesterday. Ravi says he saw Suresh riding a similar bicycle later that day. Suresh says he bought a new bicycle from the market last week and has a receipt.',
        factsHi: 'रवि का दावा है कि सुरेश ने कल किराना दुकान के बाहर से उसकी साइकिल चुराई। रवि कहता है कि उसने उस दिन बाद में सुरेश को एक समान साइकिल चलाते हुए देखा। सुरेश का कहना है कि उसने पिछले हफ्ते बाजार से नई साइकिल खरीदी थी और उसके पास रसीद है।',
        evidence: [
          'Ravi\'s statement about seeing similar bicycle',
          'Suresh\'s purchase receipt dated last week',
          'No CCTV footage available',
          'The bicycles are of the same brand and color',
        ],
        evidenceHi: [
          'रवि का बयान कि उसने समान साइकिल देखी',
          'सुरेश की खरीद रसीद पिछले हफ्ते की',
          'कोई सीसीटीवी फुटेज उपलब्ध नहीं',
          'दोनों साइकिलें एक ही ब्रांड और रंग की हैं',
        ],
        options: [
          JudgmentOption(
            id: 'a',
            text: 'Suresh is guilty of theft',
            fairnessScore: 1,
            evidenceScore: 0,
            biasScore: 1,
          ),
          JudgmentOption(
            id: 'b',
            text: 'More investigation is needed before deciding',
            fairnessScore: 5,
            evidenceScore: 5,
            biasScore: 5,
          ),
          JudgmentOption(
            id: 'c',
            text: 'Suresh is innocent as he has proof of purchase',
            fairnessScore: 3,
            evidenceScore: 4,
            biasScore: 3,
          ),
        ],
        optionsHi: [
          JudgmentOption(
            id: 'a',
            text: 'सुरेश चोरी का दोषी है',
            fairnessScore: 1,
            evidenceScore: 0,
            biasScore: 1,
          ),
          JudgmentOption(
            id: 'b',
            text: 'निर्णय लेने से पहले और जांच की जरूरत है',
            fairnessScore: 5,
            evidenceScore: 5,
            biasScore: 5,
          ),
          JudgmentOption(
            id: 'c',
            text: 'सुरेश निर्दोष है क्योंकि उसके पास खरीद का प्रमाण है',
            fairnessScore: 3,
            evidenceScore: 4,
            biasScore: 3,
          ),
        ],
        explanation: 'The best approach is to order more investigation. While Suresh has a receipt, the bicycles look similar, and there\'s no conclusive evidence either way. A good judge gathers all facts before deciding. Jumping to conclusions without solid evidence can lead to injustice.',
        explanationHi: 'सबसे अच्छा तरीका है और जांच का आदेश देना। जबकि सुरेश के पास रसीद है, साइकिलें समान दिखती हैं, और किसी भी तरफ कोई निर्णायक सबूत नहीं है। एक अच्छा न्यायाधीश निर्णय लेने से पहले सभी तथ्य इकट्ठा करता है। ठोस सबूतों के बिना निष्कर्ष पर पहुंचना अन्याय का कारण बन सकता है।',
        bestOptionId: 'b',
      ),
      CaseScenario(
        id: 'case_002',
        title: 'The Rent Dispute',
        titleHi: 'किराये का विवाद',
        category: 'civil',
        difficulty: 'easy',
        facts: 'Landlord Mr. Sharma claims tenant Ms. Gupta has not paid rent for 3 months. Ms. Gupta says she paid in cash but Mr. Sharma refuses to acknowledge it. She does not have receipts. Mr. Sharma has bank statements showing no deposits from her.',
        factsHi: 'मकान मालिक श्री शर्मा का दावा है कि किरायेदार सुश्री गुप्ता ने 3 महीने का किराया नहीं दिया। सुश्री गुप्ता कहती हैं कि उन्होंने नकद में भुगतान किया लेकिन श्री शर्मा स्वीकार नहीं करते। उनके पास रसीद नहीं है। श्री शर्मा के बैंक स्टेटमेंट में उनकी ओर से कोई जमा नहीं दिखता।',
        evidence: [
          'Landlord\'s bank statements (no deposits)',
          'Rent agreement signed by both parties',
          'Tenant claims cash payment without receipt',
          'No witnesses to the alleged cash payments',
        ],
        evidenceHi: [
          'मकान मालिक के बैंक स्टेटमेंट (कोई जमा नहीं)',
          'दोनों पक्षों द्वारा हस्ताक्षरित किराया समझौता',
          'किरायेदार का दावा बिना रसीद के नकद भुगतान',
          'कथित नकद भुगतान का कोई गवाह नहीं',
        ],
        options: [
          JudgmentOption(
            id: 'a',
            text: 'Ms. Gupta must pay the pending rent as she has no proof',
            fairnessScore: 4,
            evidenceScore: 5,
            biasScore: 4,
          ),
          JudgmentOption(
            id: 'b',
            text: 'Mr. Sharma is lying and trying to collect rent twice',
            fairnessScore: 1,
            evidenceScore: 0,
            biasScore: 0,
          ),
          JudgmentOption(
            id: 'c',
            text: 'Both should split the disputed amount equally',
            fairnessScore: 2,
            evidenceScore: 1,
            biasScore: 3,
          ),
        ],
        optionsHi: [
          JudgmentOption(
            id: 'a',
            text: 'सुश्री गुप्ता को बकाया किराया देना होगा क्योंकि उनके पास कोई प्रमाण नहीं है',
            fairnessScore: 4,
            evidenceScore: 5,
            biasScore: 4,
          ),
          JudgmentOption(
            id: 'b',
            text: 'श्री शर्मा झूठ बोल रहे हैं और दोबारा किराया वसूलने की कोशिश कर रहे हैं',
            fairnessScore: 1,
            evidenceScore: 0,
            biasScore: 0,
          ),
          JudgmentOption(
            id: 'c',
            text: 'दोनों को विवादित राशि बराबर बांटनी चाहिए',
            fairnessScore: 2,
            evidenceScore: 1,
            biasScore: 3,
          ),
        ],
        explanation: 'In legal disputes, the burden of proof lies with the person making a claim. Ms. Gupta claims she paid but has no receipt, no witness, and no bank transfer record. Mr. Sharma has documented evidence. While this may seem harsh, proper documentation is essential. The lesson: Always get receipts!',
        explanationHi: 'कानूनी विवादों में, सबूत का भार दावा करने वाले व्यक्ति पर होता है। सुश्री गुप्ता का दावा है कि उन्होंने भुगतान किया लेकिन उनके पास कोई रसीद, गवाह या बैंक ट्रांसफर रिकॉर्ड नहीं है। श्री शर्मा के पास दस्तावेजी सबूत हैं। यह कठोर लग सकता है, लेकिन उचित दस्तावेज़ीकरण आवश्यक है। सबक: हमेशा रसीद लें!',
        bestOptionId: 'a',
      ),
      CaseScenario(
        id: 'case_003',
        title: 'The Broken Promise',
        titleHi: 'टूटा हुआ वादा',
        category: 'contract',
        difficulty: 'medium',
        facts: 'Amit agreed to sell his old laptop to Priya for ₹15,000. They shook hands on the deal. Before the exchange, Amit received a better offer of ₹20,000 from someone else. Amit now refuses to sell to Priya. Priya demands he honor the original agreement.',
        factsHi: 'अमित ने प्रिया को अपना पुराना लैपटॉप ₹15,000 में बेचने की सहमति दी। उन्होंने हाथ मिलाकर सौदा किया। आदान-प्रदान से पहले, अमित को किसी और से ₹20,000 का बेहतर प्रस्ताव मिला। अमित अब प्रिया को बेचने से इनकार करता है। प्रिया की मांग है कि वह मूल समझौते का पालन करे।',
        evidence: [
          'Verbal agreement between Amit and Priya',
          'WhatsApp messages discussing the deal',
          'No written contract or advance payment',
          'Witness (common friend) who heard the agreement',
        ],
        evidenceHi: [
          'अमित और प्रिया के बीच मौखिक समझौता',
          'सौदे पर चर्चा करते व्हाट्सएप संदेश',
          'कोई लिखित अनुबंध या अग्रिम भुगतान नहीं',
          'गवाह (आम मित्र) जिसने समझौता सुना',
        ],
        options: [
          JudgmentOption(
            id: 'a',
            text: 'Amit must sell to Priya as he made a promise',
            fairnessScore: 3,
            evidenceScore: 3,
            biasScore: 3,
          ),
          JudgmentOption(
            id: 'b',
            text: 'Amit can sell to anyone since there was no written contract',
            fairnessScore: 4,
            evidenceScore: 4,
            biasScore: 4,
          ),
          JudgmentOption(
            id: 'c',
            text: 'Priya should get the laptop for ₹17,500 as a compromise',
            fairnessScore: 2,
            evidenceScore: 1,
            biasScore: 2,
          ),
        ],
        optionsHi: [
          JudgmentOption(
            id: 'a',
            text: 'अमित को प्रिया को बेचना होगा क्योंकि उसने वादा किया था',
            fairnessScore: 3,
            evidenceScore: 3,
            biasScore: 3,
          ),
          JudgmentOption(
            id: 'b',
            text: 'अमित किसी को भी बेच सकता है क्योंकि कोई लिखित अनुबंध नहीं था',
            fairnessScore: 4,
            evidenceScore: 4,
            biasScore: 4,
          ),
          JudgmentOption(
            id: 'c',
            text: 'समझौते के रूप में प्रिया को ₹17,500 में लैपटॉप मिलना चाहिए',
            fairnessScore: 2,
            evidenceScore: 1,
            biasScore: 2,
          ),
        ],
        explanation: 'Under Indian Contract Act, a valid contract requires offer, acceptance, consideration, and intention. While WhatsApp messages show intent, without exchange of consideration (payment/advance), either party can back out. Morally, Amit should honor his word, but legally, without a formal agreement, enforceability is weak.',
        explanationHi: 'भारतीय अनुबंध अधिनियम के तहत, एक वैध अनुबंध के लिए प्रस्ताव, स्वीकृति, प्रतिफल और इरादा आवश्यक है। जबकि व्हाट्सएप संदेश इरादा दिखाते हैं, प्रतिफल (भुगतान/अग्रिम) के आदान-प्रदान के बिना, कोई भी पक्ष पीछे हट सकता है। नैतिक रूप से, अमित को अपना वचन निभाना चाहिए, लेकिन कानूनी रूप से, औपचारिक समझौते के बिना, प्रवर्तनीयता कमजोर है।',
        bestOptionId: 'b',
      ),
      CaseScenario(
        id: 'case_004',
        title: 'The Noisy Neighbor',
        titleHi: 'शोरगुल करने वाला पड़ोसी',
        category: 'civil',
        difficulty: 'easy',
        facts: 'Mrs. Verma complains that her neighbor Mr. Patel plays loud music every night until 11 PM. Mr. Patel says it\'s his house and he can do what he wants. Mrs. Verma has recordings of the noise and says she cannot sleep peacefully.',
        factsHi: 'श्रीमती वर्मा की शिकायत है कि उनके पड़ोसी श्री पटेल हर रात 11 बजे तक तेज संगीत बजाते हैं। श्री पटेल का कहना है कि यह उनका घर है और वे जो चाहें कर सकते हैं। श्रीमती वर्मा के पास शोर की रिकॉर्डिंग है और कहती हैं कि वे शांति से सो नहीं पातीं।',
        evidence: [
          'Audio recordings of loud music',
          'Noise pollution norms (limit after 10 PM)',
          'Both are long-time residents',
          'No prior complaints filed officially',
        ],
        evidenceHi: [
          'तेज संगीत की ऑडियो रिकॉर्डिंग',
          'ध्वनि प्रदूषण मानदंड (10 बजे के बाद सीमा)',
          'दोनों लंबे समय से रहने वाले हैं',
          'पहले कोई आधिकारिक शिकायत नहीं',
        ],
        options: [
          JudgmentOption(
            id: 'a',
            text: 'Mr. Patel must stop playing music completely',
            fairnessScore: 1,
            evidenceScore: 2,
            biasScore: 2,
          ),
          JudgmentOption(
            id: 'b',
            text: 'Mr. Patel should lower volume after 10 PM as per noise rules',
            fairnessScore: 5,
            evidenceScore: 5,
            biasScore: 5,
          ),
          JudgmentOption(
            id: 'c',
            text: 'Mrs. Verma should adjust as Mr. Patel has rights in his home',
            fairnessScore: 1,
            evidenceScore: 1,
            biasScore: 0,
          ),
        ],
        optionsHi: [
          JudgmentOption(
            id: 'a',
            text: 'श्री पटेल को संगीत बजाना पूरी तरह बंद करना होगा',
            fairnessScore: 1,
            evidenceScore: 2,
            biasScore: 2,
          ),
          JudgmentOption(
            id: 'b',
            text: 'श्री पटेल को शोर नियमों के अनुसार 10 बजे के बाद आवाज कम करनी चाहिए',
            fairnessScore: 5,
            evidenceScore: 5,
            biasScore: 5,
          ),
          JudgmentOption(
            id: 'c',
            text: 'श्रीमती वर्मा को समायोजित करना चाहिए क्योंकि श्री पटेल के अपने घर में अधिकार हैं',
            fairnessScore: 1,
            evidenceScore: 1,
            biasScore: 0,
          ),
        ],
        explanation: 'Rights come with responsibilities. Under noise pollution rules, loud sounds are restricted after 10 PM. Mr. Patel can enjoy music but must respect his neighbor\'s right to peace. A balanced judgment considers both - his freedom and her right to quiet. The solution is reasonable limits, not total prohibition.',
        explanationHi: 'अधिकारों के साथ जिम्मेदारियां आती हैं। ध्वनि प्रदूषण नियमों के तहत, 10 बजे के बाद तेज आवाज प्रतिबंधित है। श्री पटेल संगीत का आनंद ले सकते हैं लेकिन उन्हें अपने पड़ोसी के शांति के अधिकार का सम्मान करना चाहिए। एक संतुलित निर्णय दोनों पर विचार करता है - उनकी स्वतंत्रता और उनका शांति का अधिकार। समाधान उचित सीमाएं हैं, पूर्ण निषेध नहीं।',
        bestOptionId: 'b',
      ),
      CaseScenario(
        id: 'case_005',
        title: 'The School Fee Refund',
        titleHi: 'स्कूल फीस वापसी',
        category: 'civil',
        difficulty: 'medium',
        facts: 'Parents paid full year fees in April. In July, they shifted to another city due to job transfer. They want a refund of remaining 8 months fees. The school says their policy is "no refund" once fees are paid. The admission form has this clause.',
        factsHi: 'अभिभावकों ने अप्रैल में पूरे साल की फीस जमा की। जुलाई में, नौकरी स्थानांतरण के कारण वे दूसरे शहर चले गए। वे शेष 8 महीने की फीस वापसी चाहते हैं। स्कूल का कहना है कि उनकी नीति है "एक बार फीस जमा होने के बाद कोई वापसी नहीं"। प्रवेश फॉर्म में यह खंड है।',
        evidence: [
          'Admission form with no-refund clause signed by parents',
          'Job transfer letter showing genuine reason',
          'Fee receipt for full year payment',
          'Supreme Court guidelines on school fee refunds',
        ],
        evidenceHi: [
          'अभिभावकों द्वारा हस्ताक्षरित नो-रिफंड क्लॉज वाला प्रवेश फॉर्म',
          'वास्तविक कारण दिखाने वाला नौकरी स्थानांतरण पत्र',
          'पूरे साल के भुगतान की फीस रसीद',
          'स्कूल फीस वापसी पर सुप्रीम कोर्ट के दिशानिर्देश',
        ],
        options: [
          JudgmentOption(
            id: 'a',
            text: 'No refund as parents signed the no-refund clause',
            fairnessScore: 2,
            evidenceScore: 3,
            biasScore: 2,
          ),
          JudgmentOption(
            id: 'b',
            text: 'Full refund of 8 months as child did not study',
            fairnessScore: 2,
            evidenceScore: 2,
            biasScore: 3,
          ),
          JudgmentOption(
            id: 'c',
            text: 'Partial refund considering genuine reason and some admin costs',
            fairnessScore: 5,
            evidenceScore: 4,
            biasScore: 5,
          ),
        ],
        optionsHi: [
          JudgmentOption(
            id: 'a',
            text: 'कोई वापसी नहीं क्योंकि अभिभावकों ने नो-रिफंड क्लॉज पर हस्ताक्षर किए',
            fairnessScore: 2,
            evidenceScore: 3,
            biasScore: 2,
          ),
          JudgmentOption(
            id: 'b',
            text: '8 महीने की पूरी वापसी क्योंकि बच्चे ने पढ़ाई नहीं की',
            fairnessScore: 2,
            evidenceScore: 2,
            biasScore: 3,
          ),
          JudgmentOption(
            id: 'c',
            text: 'वास्तविक कारण और कुछ प्रशासनिक लागत को देखते हुए आंशिक वापसी',
            fairnessScore: 5,
            evidenceScore: 4,
            biasScore: 5,
          ),
        ],
        explanation: 'Courts have held that blanket no-refund policies can be unfair. While schools incur admin costs, keeping fees for services not rendered is unjust enrichment. A balanced approach: School can deduct reasonable admin fees (1-2 months) and refund the rest. This respects both the contract and natural justice.',
        explanationHi: 'अदालतों ने माना है कि व्यापक नो-रिफंड नीतियां अनुचित हो सकती हैं। जबकि स्कूलों को प्रशासनिक लागत आती है, न दी गई सेवाओं की फीस रखना अनुचित लाभ है। संतुलित दृष्टिकोण: स्कूल उचित प्रशासनिक शुल्क (1-2 महीने) काट सकता है और बाकी वापस कर सकता है। यह अनुबंध और प्राकृतिक न्याय दोनों का सम्मान करता है।',
        bestOptionId: 'c',
      ),
      
      // Case 6: Property Dispute
      CaseScenario(
        id: 'case_006',
        title: 'The Ancestral Land',
        titleHi: 'पैतृक ज़मीन',
        category: 'property',
        difficulty: 'hard',
        facts: 'Three brothers inherited ancestral land from their father. The eldest brother has been farming the land for 20 years. Now the younger brothers claim their one-third share each. The eldest says he alone developed the land and paid all taxes.',
        factsHi: 'तीन भाइयों को पिता से पैतृक ज़मीन विरासत में मिली। बड़े भाई 20 साल से ज़मीन पर खेती कर रहे हैं। अब छोटे भाई अपना एक-तिहाई हिस्सा मांग रहे हैं। बड़े भाई का कहना है कि उन्होंने अकेले ज़मीन विकसित की और सारे टैक्स भरे।',
        evidence: [
          'Father\'s will mentioning equal division among sons',
          'Tax receipts in eldest brother\'s name for 20 years',
          'Land development receipts paid by eldest brother',
          'Younger brothers living in different cities',
        ],
        evidenceHi: [
          'पिता की वसीयत जिसमें बेटों में बराबर बंटवारे का उल्लेख है',
          '20 साल के बड़े भाई के नाम टैक्स रसीद',
          'बड़े भाई द्वारा भुगतान की गई भूमि विकास रसीदें',
          'छोटे भाई दूसरे शहरों में रह रहे हैं',
        ],
        options: [
          JudgmentOption(
            id: 'a',
            text: 'Land belongs only to eldest brother due to 20 years of possession',
            fairnessScore: 1,
            evidenceScore: 2,
            biasScore: 1,
          ),
          JudgmentOption(
            id: 'b',
            text: 'Equal division as per will, but reimburse elder for development costs',
            fairnessScore: 5,
            evidenceScore: 5,
            biasScore: 5,
          ),
          JudgmentOption(
            id: 'c',
            text: 'Give 50% to elder and 25% each to younger brothers',
            fairnessScore: 3,
            evidenceScore: 3,
            biasScore: 3,
          ),
        ],
        optionsHi: [
          JudgmentOption(
            id: 'a',
            text: '20 साल के कब्जे के कारण ज़मीन केवल बड़े भाई की है',
            fairnessScore: 1,
            evidenceScore: 2,
            biasScore: 1,
          ),
          JudgmentOption(
            id: 'b',
            text: 'वसीयत के अनुसार बराबर बंटवारा, लेकिन बड़े भाई को विकास लागत की भरपाई',
            fairnessScore: 5,
            evidenceScore: 5,
            biasScore: 5,
          ),
          JudgmentOption(
            id: 'c',
            text: 'बड़े को 50% और छोटे भाइयों को 25%-25%',
            fairnessScore: 3,
            evidenceScore: 3,
            biasScore: 3,
          ),
        ],
        explanation: 'A will is a legally binding document. All three sons have equal legal rights to the ancestral property. However, equity demands that the elder brother who invested time and money in developing the land should be compensated. The fair solution: divide equally but account for development costs.',
        explanationHi: 'वसीयत एक कानूनी रूप से बाध्यकारी दस्तावेज़ है। तीनों बेटों का पैतृक संपत्ति पर समान कानूनी अधिकार है। हालाँकि, न्याय की मांग है कि बड़े भाई को जिन्होंने ज़मीन के विकास में समय और पैसा लगाया, उन्हें मुआवज़ा मिले। उचित समाधान: बराबर बांटें लेकिन विकास लागत का हिसाब रखें।',
        bestOptionId: 'b',
      ),

      // Case 7: Consumer Complaint
      CaseScenario(
        id: 'case_007',
        title: 'The Defective Phone',
        titleHi: 'खराब फोन',
        category: 'consumer',
        difficulty: 'easy',
        facts: 'Ramesh bought a smartphone for ₹25,000 with 1-year warranty. After 3 months, the phone stopped charging. The company says water damage caused the issue and refuses free repair. Ramesh claims he never exposed it to water.',
        factsHi: 'रमेश ने 1 साल की वारंटी के साथ ₹25,000 का स्मार्टफोन खरीदा। 3 महीने बाद फोन चार्ज होना बंद हो गया। कंपनी का कहना है कि पानी के नुकसान से समस्या हुई और मुफ्त मरम्मत से इनकार किया। रमेश का दावा है कि उसने कभी पानी के संपर्क में नहीं आने दिया।',
        evidence: [
          'Purchase bill and warranty card',
          'Service center report mentioning water damage indicators',
          'Ramesh\'s affidavit denying water exposure',
          'Phone was working fine for 3 months (no immediate issue)',
        ],
        evidenceHi: [
          'खरीद बिल और वारंटी कार्ड',
          'सर्विस सेंटर रिपोर्ट जिसमें पानी के नुकसान के संकेत',
          'रमेश का हलफनामा पानी के संपर्क से इनकार करते हुए',
          'फोन 3 महीने ठीक काम करता रहा (तुरंत कोई समस्या नहीं)',
        ],
        options: [
          JudgmentOption(
            id: 'a',
            text: 'Company must repair for free as it\'s within warranty',
            fairnessScore: 3,
            evidenceScore: 2,
            biasScore: 3,
          ),
          JudgmentOption(
            id: 'b',
            text: 'Ramesh must pay for repair as company found water damage',
            fairnessScore: 2,
            evidenceScore: 2,
            biasScore: 2,
          ),
          JudgmentOption(
            id: 'c',
            text: 'Independent expert should examine phone, then decide',
            fairnessScore: 5,
            evidenceScore: 5,
            biasScore: 5,
          ),
        ],
        optionsHi: [
          JudgmentOption(
            id: 'a',
            text: 'कंपनी को मुफ्त मरम्मत करनी होगी क्योंकि वारंटी में है',
            fairnessScore: 3,
            evidenceScore: 2,
            biasScore: 3,
          ),
          JudgmentOption(
            id: 'b',
            text: 'रमेश को मरम्मत का भुगतान करना होगा क्योंकि कंपनी ने पानी का नुकसान पाया',
            fairnessScore: 2,
            evidenceScore: 2,
            biasScore: 2,
          ),
          JudgmentOption(
            id: 'c',
            text: 'स्वतंत्र विशेषज्ञ फोन की जांच करे, फिर निर्णय हो',
            fairnessScore: 5,
            evidenceScore: 5,
            biasScore: 5,
          ),
        ],
        explanation: 'When there\'s a dispute about the cause of defect, an independent expert opinion is the fairest approach. Company\'s own service center report may be biased. Consumer courts often appoint independent experts. This ensures justice based on objective evidence, not just one party\'s claim.',
        explanationHi: 'जब दोष के कारण पर विवाद हो, तो स्वतंत्र विशेषज्ञ राय सबसे उचित तरीका है। कंपनी की अपनी सर्विस सेंटर रिपोर्ट पक्षपाती हो सकती है। उपभोक्ता अदालतें अक्सर स्वतंत्र विशेषज्ञ नियुक्त करती हैं। यह वस्तुनिष्ठ साक्ष्य पर आधारित न्याय सुनिश्चित करता है, न कि केवल एक पक्ष के दावे पर।',
        bestOptionId: 'c',
      ),

      // Case 8: Workplace Harassment
      CaseScenario(
        id: 'case_008',
        title: 'The Workplace Complaint',
        titleHi: 'कार्यस्थल की शिकायत',
        category: 'workplace',
        difficulty: 'hard',
        facts: 'Priya, an office employee, complains that her male colleague Arun makes inappropriate comments about her appearance daily. Arun says he was just being friendly and complimenting her. The HR department has received the complaint.',
        factsHi: 'प्रिया, एक कार्यालय कर्मचारी, शिकायत करती है कि उसका पुरुष सहकर्मी अरुण रोज़ाना उसकी शक्ल-सूरत पर अनुचित टिप्पणियां करता है। अरुण का कहना है कि वह बस मित्रवत था और तारीफ कर रहा था। HR विभाग को शिकायत मिली है।',
        evidence: [
          'Priya\'s written complaint with dates and specific comments',
          'Another female colleague witnessed some incidents',
          'Arun denies any wrong intention',
          'Company has a sexual harassment policy (POSH Act)',
        ],
        evidenceHi: [
          'प्रिया की लिखित शिकायत तारीखों और विशिष्ट टिप्पणियों के साथ',
          'एक अन्य महिला सहकर्मी ने कुछ घटनाएं देखीं',
          'अरुण किसी गलत इरादे से इनकार करता है',
          'कंपनी की यौन उत्पीड़न नीति है (POSH Act)',
        ],
        options: [
          JudgmentOption(
            id: 'a',
            text: 'Immediately terminate Arun\'s employment',
            fairnessScore: 1,
            evidenceScore: 2,
            biasScore: 2,
          ),
          JudgmentOption(
            id: 'b',
            text: 'Dismiss the complaint as it was just compliments',
            fairnessScore: 0,
            evidenceScore: 1,
            biasScore: 0,
          ),
          JudgmentOption(
            id: 'c',
            text: 'Conduct ICC inquiry, counsel Arun, warn him, and monitor',
            fairnessScore: 5,
            evidenceScore: 5,
            biasScore: 5,
          ),
        ],
        optionsHi: [
          JudgmentOption(
            id: 'a',
            text: 'तुरंत अरुण की नौकरी समाप्त करें',
            fairnessScore: 1,
            evidenceScore: 2,
            biasScore: 2,
          ),
          JudgmentOption(
            id: 'b',
            text: 'शिकायत खारिज करें क्योंकि यह सिर्फ तारीफ थी',
            fairnessScore: 0,
            evidenceScore: 1,
            biasScore: 0,
          ),
          JudgmentOption(
            id: 'c',
            text: 'ICC जांच करें, अरुण को परामर्श दें, चेतावनी दें और निगरानी करें',
            fairnessScore: 5,
            evidenceScore: 5,
            biasScore: 5,
          ),
        ],
        explanation: 'Under POSH Act, unwelcome behavior that makes someone uncomfortable at workplace is harassment - regardless of intent. However, due process requires proper inquiry by Internal Complaints Committee (ICC). First-time offenses often warrant warning and counseling rather than immediate termination. The key is: take the complaint seriously but follow fair process.',
        explanationHi: 'POSH अधिनियम के तहत, कार्यस्थल पर किसी को असहज करने वाला अवांछित व्यवहार उत्पीड़न है - इरादे की परवाह किए बिना। हालाँकि, उचित प्रक्रिया के लिए आंतरिक शिकायत समिति (ICC) द्वारा उचित जांच आवश्यक है। पहली बार के अपराधों में अक्सर तत्काल बर्खास्तगी के बजाय चेतावनी और परामर्श उचित होता है। मुख्य बात: शिकायत को गंभीरता से लें लेकिन उचित प्रक्रिया का पालन करें।',
        bestOptionId: 'c',
      ),

      // Case 9: Domestic Dispute
      CaseScenario(
        id: 'case_009',
        title: 'The Maintenance Case',
        titleHi: 'गुजारा भत्ता का मामला',
        category: 'family',
        difficulty: 'medium',
        facts: 'After 8 years of marriage, Meena filed for divorce and maintenance from husband Rajesh who earns ₹80,000/month. Rajesh says Meena is educated (B.Com) and can work. Meena says she sacrificed her career to raise their 2 children aged 5 and 7.',
        factsHi: '8 साल की शादी के बाद, मीना ने पति राजेश से तलाक और गुजारा भत्ता की अर्जी दी जो ₹80,000/माह कमाते हैं। राजेश का कहना है कि मीना पढ़ी-लिखी है (B.Com) और काम कर सकती है। मीना का कहना है कि उसने अपने 2 बच्चों (उम्र 5 और 7) को पालने के लिए अपना करियर छोड़ा।',
        evidence: [
          'Marriage certificate and children\'s birth certificates',
          'Rajesh\'s salary slip showing ₹80,000/month',
          'Meena\'s B.Com degree certificate',
          'Meena was not employed during 8 years of marriage',
        ],
        evidenceHi: [
          'विवाह प्रमाण पत्र और बच्चों के जन्म प्रमाण पत्र',
          'राजेश की वेतन पर्ची ₹80,000/माह दिखाती है',
          'मीना का B.Com डिग्री प्रमाण पत्र',
          'मीना 8 साल की शादी के दौरान काम नहीं कर रही थी',
        ],
        options: [
          JudgmentOption(
            id: 'a',
            text: 'No maintenance as Meena is educated and can earn',
            fairnessScore: 1,
            evidenceScore: 2,
            biasScore: 1,
          ),
          JudgmentOption(
            id: 'b',
            text: 'Reasonable maintenance considering lifestyle, children, and her sacrifice',
            fairnessScore: 5,
            evidenceScore: 5,
            biasScore: 5,
          ),
          JudgmentOption(
            id: 'c',
            text: 'Give 50% of Rajesh\'s salary as maintenance',
            fairnessScore: 2,
            evidenceScore: 2,
            biasScore: 3,
          ),
        ],
        optionsHi: [
          JudgmentOption(
            id: 'a',
            text: 'कोई भत्ता नहीं क्योंकि मीना पढ़ी-लिखी है और कमा सकती है',
            fairnessScore: 1,
            evidenceScore: 2,
            biasScore: 1,
          ),
          JudgmentOption(
            id: 'b',
            text: 'जीवनशैली, बच्चों और उसके त्याग को देखते हुए उचित भत्ता',
            fairnessScore: 5,
            evidenceScore: 5,
            biasScore: 5,
          ),
          JudgmentOption(
            id: 'c',
            text: 'राजेश के वेतन का 50% भत्ता दें',
            fairnessScore: 2,
            evidenceScore: 2,
            biasScore: 3,
          ),
        ],
        explanation: 'Education alone doesn\'t mean someone can immediately earn. Courts consider: years spent as homemaker, sacrifice of career opportunities, children\'s needs, and standard of living during marriage. Reasonable maintenance balances both parties\' situations. It\'s neither zero nor an unfair large amount.',
        explanationHi: 'सिर्फ शिक्षा का मतलब यह नहीं कि कोई तुरंत कमा सकता है। अदालतें विचार करती हैं: गृहिणी के रूप में बिताए वर्ष, करियर के अवसरों का त्याग, बच्चों की जरूरतें, और शादी के दौरान जीवन स्तर। उचित भत्ता दोनों पक्षों की स्थिति को संतुलित करता है। यह न शून्य है और न अनुचित बड़ी राशि।',
        bestOptionId: 'b',
      ),

      // Case 10: Medical Negligence
      CaseScenario(
        id: 'case_010',
        title: 'The Hospital Treatment',
        titleHi: 'अस्पताल का इलाज',
        category: 'medical',
        difficulty: 'hard',
        facts: 'Patient Sunil, 45, was admitted for appendix surgery. After surgery, he developed infection and stayed 20 extra days in hospital. He claims negligence by doctors. Hospital says infections can happen even with proper care and they treated him promptly.',
        factsHi: 'मरीज़ सुनील, 45 वर्ष, को अपेंडिक्स सर्जरी के लिए भर्ती किया गया। सर्जरी के बाद उन्हें संक्रमण हो गया और अस्पताल में 20 अतिरिक्त दिन रहना पड़ा। वे डॉक्टरों की लापरवाही का दावा करते हैं। अस्पताल का कहना है कि उचित देखभाल के बावजूद संक्रमण हो सकता है और उन्होंने तुरंत इलाज किया।',
        evidence: [
          'Surgery was performed by qualified surgeon',
          'Medical records show infection developed 3 days post-surgery',
          'Hospital treated infection immediately when detected',
          'No evidence that sterilization protocols were violated',
        ],
        evidenceHi: [
          'सर्जरी योग्य सर्जन द्वारा की गई',
          'मेडिकल रिकॉर्ड दिखाते हैं कि सर्जरी के 3 दिन बाद संक्रमण हुआ',
          'अस्पताल ने पता चलते ही तुरंत संक्रमण का इलाज किया',
          'कोई सबूत नहीं कि स्टेरलाइज़ेशन प्रोटोकॉल का उल्लंघन हुआ',
        ],
        options: [
          JudgmentOption(
            id: 'a',
            text: 'Hospital is negligent and must compensate for all extra costs',
            fairnessScore: 2,
            evidenceScore: 1,
            biasScore: 2,
          ),
          JudgmentOption(
            id: 'b',
            text: 'No negligence proven, infection is a known surgical risk',
            fairnessScore: 5,
            evidenceScore: 5,
            biasScore: 5,
          ),
          JudgmentOption(
            id: 'c',
            text: 'Split the extra costs 50-50 between patient and hospital',
            fairnessScore: 2,
            evidenceScore: 2,
            biasScore: 3,
          ),
        ],
        optionsHi: [
          JudgmentOption(
            id: 'a',
            text: 'अस्पताल लापरवाह है और सभी अतिरिक्त लागत की भरपाई करनी होगी',
            fairnessScore: 2,
            evidenceScore: 1,
            biasScore: 2,
          ),
          JudgmentOption(
            id: 'b',
            text: 'कोई लापरवाही साबित नहीं, संक्रमण सर्जरी का ज्ञात जोखिम है',
            fairnessScore: 5,
            evidenceScore: 5,
            biasScore: 5,
          ),
          JudgmentOption(
            id: 'c',
            text: 'अतिरिक्त लागत मरीज़ और अस्पताल में 50-50 बांटें',
            fairnessScore: 2,
            evidenceScore: 2,
            biasScore: 3,
          ),
        ],
        explanation: 'Medical negligence requires proving breach of duty and causation. Post-surgical infections can occur despite best practices. If hospital followed protocols and responded promptly to the infection, they cannot be held negligent. Bad outcome alone doesn\'t establish negligence - there must be evidence of substandard care.',
        explanationHi: 'चिकित्सा लापरवाही के लिए कर्तव्य के उल्लंघन और कारण का प्रमाण आवश्यक है। सर्वोत्तम प्रथाओं के बावजूद पोस्ट-सर्जिकल संक्रमण हो सकता है। यदि अस्पताल ने प्रोटोकॉल का पालन किया और संक्रमण पर तुरंत प्रतिक्रिया दी, तो उन्हें लापरवाह नहीं ठहराया जा सकता। खराब परिणाम अकेले लापरवाही स्थापित नहीं करता - निम्न-मानक देखभाल का सबूत होना चाहिए।',
        bestOptionId: 'b',
      ),

      // Case 11: Cheque Bounce
      CaseScenario(
        id: 'case_011',
        title: 'The Bounced Cheque',
        titleHi: 'बाउंस चेक',
        category: 'financial',
        difficulty: 'easy',
        facts: 'Vendor Mohan gave goods worth ₹2 lakh to shopkeeper Kishan on credit. Kishan issued a cheque that bounced due to insufficient funds. Mohan sent legal notice, but Kishan says the goods were defective and he won\'t pay.',
        factsHi: 'विक्रेता मोहन ने दुकानदार किशन को ₹2 लाख का माल उधार दिया। किशन ने चेक दिया जो अपर्याप्त राशि के कारण बाउंस हो गया। मोहन ने कानूनी नोटिस भेजा, लेकिन किशन का कहना है कि माल खराब था और वह भुगतान नहीं करेगा।',
        evidence: [
          'Delivery receipt signed by Kishan for ₹2 lakh goods',
          'Bounced cheque with bank memo (insufficient funds)',
          'Legal notice sent within 30 days of bounce',
          'No written complaint about defective goods before bounce',
        ],
        evidenceHi: [
          'किशन द्वारा हस्ताक्षरित ₹2 लाख माल की डिलीवरी रसीद',
          'बैंक मेमो के साथ बाउंस चेक (अपर्याप्त राशि)',
          'बाउंस के 30 दिनों के भीतर कानूनी नोटिस भेजा गया',
          'बाउंस से पहले खराब माल की कोई लिखित शिकायत नहीं',
        ],
        options: [
          JudgmentOption(
            id: 'a',
            text: 'Kishan must pay ₹2 lakh plus compensation under Sec 138 NI Act',
            fairnessScore: 5,
            evidenceScore: 5,
            biasScore: 5,
          ),
          JudgmentOption(
            id: 'b',
            text: 'Case dismissed as Kishan claims goods were defective',
            fairnessScore: 1,
            evidenceScore: 1,
            biasScore: 1,
          ),
          JudgmentOption(
            id: 'c',
            text: 'Reduce the amount as both parties may be partially at fault',
            fairnessScore: 2,
            evidenceScore: 2,
            biasScore: 3,
          ),
        ],
        optionsHi: [
          JudgmentOption(
            id: 'a',
            text: 'किशन को धारा 138 NI Act के तहत ₹2 लाख + मुआवज़ा देना होगा',
            fairnessScore: 5,
            evidenceScore: 5,
            biasScore: 5,
          ),
          JudgmentOption(
            id: 'b',
            text: 'मामला खारिज क्योंकि किशन का दावा है माल खराब था',
            fairnessScore: 1,
            evidenceScore: 1,
            biasScore: 1,
          ),
          JudgmentOption(
            id: 'c',
            text: 'राशि कम करें क्योंकि दोनों पक्ष आंशिक रूप से गलत हो सकते हैं',
            fairnessScore: 2,
            evidenceScore: 2,
            biasScore: 3,
          ),
        ],
        explanation: 'Under Section 138 of Negotiable Instruments Act, cheque bounce is a criminal offense. The defense of "defective goods" should have been raised before issuing cheque or immediately after receiving goods - not after cheque bounced. Since Kishan signed delivery receipt and raised no prior complaint, the cheque liability stands.',
        explanationHi: 'परक्राम्य लिखत अधिनियम की धारा 138 के तहत, चेक बाउंस एक आपराधिक अपराध है। "खराब माल" का बचाव चेक जारी करने से पहले या माल प्राप्त करने के तुरंत बाद उठाया जाना चाहिए था - चेक बाउंस होने के बाद नहीं। चूंकि किशन ने डिलीवरी रसीद पर हस्ताक्षर किए और पहले कोई शिकायत नहीं की, चेक की देनदारी बनी रहती है।',
        bestOptionId: 'a',
      ),

      // Case 12: Traffic Accident
      CaseScenario(
        id: 'case_012',
        title: 'The Road Accident',
        titleHi: 'सड़क दुर्घटना',
        category: 'accident',
        difficulty: 'medium',
        facts: 'A car hit a motorcyclist at a signal. Driver Vikram says the biker jumped the red light. Biker Sanjay (now injured) says the car was speeding. CCTV footage is blurry and inconclusive. Sanjay wants ₹5 lakh compensation for medical expenses.',
        factsHi: 'एक कार ने सिग्नल पर एक मोटरसाइकिल चालक को टक्कर मार दी। ड्राइवर विक्रम का कहना है कि बाइकर ने लाल बत्ती तोड़ी। बाइकर संजय (अब घायल) का कहना है कि कार तेज़ गति से थी। CCTV फुटेज धुंधली और अनिर्णायक है। संजय चिकित्सा खर्च के लिए ₹5 लाख मुआवज़ा चाहते हैं।',
        evidence: [
          'Police FIR registered by both parties',
          'Medical bills totaling ₹3.5 lakh',
          'Blurry CCTV footage (cannot determine who was at fault)',
          'Vikram has valid license and insurance',
        ],
        evidenceHi: [
          'दोनों पक्षों द्वारा पुलिस FIR दर्ज',
          'कुल ₹3.5 लाख के मेडिकल बिल',
          'धुंधली CCTV फुटेज (गलती निर्धारित नहीं हो सकती)',
          'विक्रम के पास वैध लाइसेंस और बीमा है',
        ],
        options: [
          JudgmentOption(
            id: 'a',
            text: 'Vikram must pay full ₹5 lakh as he was driving the bigger vehicle',
            fairnessScore: 1,
            evidenceScore: 1,
            biasScore: 1,
          ),
          JudgmentOption(
            id: 'b',
            text: 'Case dismissed as fault cannot be proven',
            fairnessScore: 2,
            evidenceScore: 2,
            biasScore: 2,
          ),
          JudgmentOption(
            id: 'c',
            text: 'Insurance company pays actual medical costs (₹3.5L) under no-fault liability',
            fairnessScore: 5,
            evidenceScore: 5,
            biasScore: 5,
          ),
        ],
        optionsHi: [
          JudgmentOption(
            id: 'a',
            text: 'विक्रम को पूरे ₹5 लाख देने होंगे क्योंकि वह बड़ी गाड़ी चला रहा था',
            fairnessScore: 1,
            evidenceScore: 1,
            biasScore: 1,
          ),
          JudgmentOption(
            id: 'b',
            text: 'मामला खारिज क्योंकि गलती साबित नहीं हो सकती',
            fairnessScore: 2,
            evidenceScore: 2,
            biasScore: 2,
          ),
          JudgmentOption(
            id: 'c',
            text: 'बीमा कंपनी नो-फॉल्ट देयता के तहत वास्तविक चिकित्सा लागत (₹3.5L) भुगतान करे',
            fairnessScore: 5,
            evidenceScore: 5,
            biasScore: 5,
          ),
        ],
        explanation: 'Under Motor Vehicles Act, accident victims can claim from insurance even when fault is unclear (no-fault liability for up to ₹5 lakh). This ensures victim gets treatment. Actual medical costs (₹3.5L) should be compensated. The insurance is meant for such situations - to help accident victims regardless of who was at fault.',
        explanationHi: 'मोटर वाहन अधिनियम के तहत, दुर्घटना पीड़ित बीमा से दावा कर सकते हैं भले ही गलती स्पष्ट न हो (₹5 लाख तक नो-फॉल्ट देयता)। यह सुनिश्चित करता है कि पीड़ित को इलाज मिले। वास्तविक चिकित्सा लागत (₹3.5L) की भरपाई होनी चाहिए। बीमा ऐसी स्थितियों के लिए है - दुर्घटना पीड़ितों की मदद करने के लिए चाहे गलती किसी की भी हो।',
        bestOptionId: 'c',
      ),

      // Case 13: Online Fraud
      CaseScenario(
        id: 'case_013',
        title: 'The Online Shopping Fraud',
        titleHi: 'ऑनलाइन शॉपिंग धोखाधड़ी',
        category: 'cyber',
        difficulty: 'medium',
        facts: 'Anita ordered a ₹15,000 saree online. She received a cheap saree worth ₹500. The seller says she is lying and sent the original product. The website is registered but has no clear return policy. Anita paid via debit card.',
        factsHi: 'अनीता ने ऑनलाइन ₹15,000 की साड़ी ऑर्डर की। उसे ₹500 की सस्ती साड़ी मिली। विक्रेता का कहना है कि वह झूठ बोल रही है और उसने असली प्रोडक्ट भेजा। वेबसाइट पंजीकृत है लेकिन स्पष्ट रिटर्न पॉलिसी नहीं है। अनीता ने डेबिट कार्ड से भुगतान किया।',
        evidence: [
          'Order confirmation showing ₹15,000 product',
          'Photo of received saree (clearly cheap material)',
          'Delivery was signed by security guard, not Anita',
          'Seller has 3 other similar complaints online',
        ],
        evidenceHi: [
          'ऑर्डर कन्फर्मेशन जिसमें ₹15,000 का प्रोडक्ट दिखाया गया',
          'प्राप्त साड़ी की फोटो (स्पष्ट रूप से सस्ता कपड़ा)',
          'डिलीवरी पर सिक्योरिटी गार्ड ने साइन किया, अनीता ने नहीं',
          'विक्रेता के खिलाफ ऑनलाइन 3 अन्य समान शिकायतें',
        ],
        options: [
          JudgmentOption(
            id: 'a',
            text: 'Dismiss case as Anita cannot prove what was in the package',
            fairnessScore: 1,
            evidenceScore: 2,
            biasScore: 1,
          ),
          JudgmentOption(
            id: 'b',
            text: 'Full refund to Anita plus compensation for mental harassment',
            fairnessScore: 5,
            evidenceScore: 5,
            biasScore: 5,
          ),
          JudgmentOption(
            id: 'c',
            text: 'Give 50% refund as both parties have some valid points',
            fairnessScore: 2,
            evidenceScore: 2,
            biasScore: 3,
          ),
        ],
        optionsHi: [
          JudgmentOption(
            id: 'a',
            text: 'मामला खारिज क्योंकि अनीता पैकेज में क्या था यह साबित नहीं कर सकती',
            fairnessScore: 1,
            evidenceScore: 2,
            biasScore: 1,
          ),
          JudgmentOption(
            id: 'b',
            text: 'अनीता को पूर्ण रिफंड और मानसिक उत्पीड़न के लिए मुआवज़ा',
            fairnessScore: 5,
            evidenceScore: 5,
            biasScore: 5,
          ),
          JudgmentOption(
            id: 'c',
            text: '50% रिफंड दें क्योंकि दोनों पक्षों की कुछ वैध बातें हैं',
            fairnessScore: 2,
            evidenceScore: 2,
            biasScore: 3,
          ),
        ],
        explanation: 'Pattern of similar complaints is strong evidence against seller. Consumer Protection Act favors the consumer when seller has no proper process (delivery not signed by buyer, no return policy). The seller\'s business practices show bad faith. Consumer deserves full refund plus compensation for deficiency in service.',
        explanationHi: 'समान शिकायतों का पैटर्न विक्रेता के खिलाफ मजबूत सबूत है। उपभोक्ता संरक्षण अधिनियम उपभोक्ता के पक्ष में है जब विक्रेता के पास उचित प्रक्रिया नहीं है (खरीदार ने डिलीवरी पर साइन नहीं किया, कोई रिटर्न पॉलिसी नहीं)। विक्रेता की व्यावसायिक प्रथाएं बुरी नीयत दिखाती हैं। उपभोक्ता को पूर्ण रिफंड और सेवा में कमी के लिए मुआवज़ा मिलना चाहिए।',
        bestOptionId: 'b',
      ),

      // Case 14: Domestic Violence
      CaseScenario(
        id: 'case_014',
        title: 'The Protection Order',
        titleHi: 'सुरक्षा आदेश',
        category: 'family',
        difficulty: 'hard',
        facts: 'Wife Sunita seeks protection order against husband Mahesh claiming daily verbal abuse and one incident of slapping. Mahesh says they only have normal arguments and denies hitting her. Sunita\'s mother witnessed the slapping incident.',
        factsHi: 'पत्नी सुनीता पति महेश के खिलाफ सुरक्षा आदेश मांगती है, दैनिक मौखिक दुर्व्यवहार और एक बार थप्पड़ मारने का दावा करते हुए। महेश का कहना है कि उनके बीच सामान्य बहस होती है और मारने से इनकार करता है। सुनीता की मां ने थप्पड़ की घटना देखी।',
        evidence: [
          'Sunita\'s complaint under DV Act',
          'Mother\'s witness statement about slapping',
          'No medical report (no visible injury)',
          'Couple has been married for 5 years with one child',
        ],
        evidenceHi: [
          'DV Act के तहत सुनीता की शिकायत',
          'थप्पड़ के बारे में मां का गवाह बयान',
          'कोई मेडिकल रिपोर्ट नहीं (कोई दिखाई देने वाली चोट नहीं)',
          'दंपति 5 साल से शादीशुदा हैं और एक बच्चा है',
        ],
        options: [
          JudgmentOption(
            id: 'a',
            text: 'Dismiss case as there is no medical evidence of injury',
            fairnessScore: 1,
            evidenceScore: 1,
            biasScore: 0,
          ),
          JudgmentOption(
            id: 'b',
            text: 'Grant protection order immediately and jail Mahesh',
            fairnessScore: 2,
            evidenceScore: 2,
            biasScore: 2,
          ),
          JudgmentOption(
            id: 'c',
            text: 'Grant protection order with counseling for both parties',
            fairnessScore: 5,
            evidenceScore: 5,
            biasScore: 5,
          ),
        ],
        optionsHi: [
          JudgmentOption(
            id: 'a',
            text: 'मामला खारिज क्योंकि चोट का कोई मेडिकल सबूत नहीं',
            fairnessScore: 1,
            evidenceScore: 1,
            biasScore: 0,
          ),
          JudgmentOption(
            id: 'b',
            text: 'तुरंत सुरक्षा आदेश दें और महेश को जेल भेजें',
            fairnessScore: 2,
            evidenceScore: 2,
            biasScore: 2,
          ),
          JudgmentOption(
            id: 'c',
            text: 'दोनों पक्षों के लिए परामर्श के साथ सुरक्षा आदेश प्रदान करें',
            fairnessScore: 5,
            evidenceScore: 5,
            biasScore: 5,
          ),
        ],
        explanation: 'Domestic Violence Act covers verbal abuse too - not just physical. Witness testimony from mother is valid evidence. Protection order is preventive, not punitive. However, imprisonment as first step is extreme when there\'s no history of severe violence. Counseling can help if marriage is salvageable while protecting the wife.',
        explanationHi: 'घरेलू हिंसा अधिनियम मौखिक दुर्व्यवहार को भी कवर करता है - केवल शारीरिक नहीं। मां की गवाही वैध सबूत है। सुरक्षा आदेश निवारक है, दंडात्मक नहीं। हालांकि, जब गंभीर हिंसा का कोई इतिहास नहीं है तो पहले कदम के रूप में कैद चरम है। परामर्श मदद कर सकता है यदि पत्नी की रक्षा करते हुए विवाह बचाया जा सकता है।',
        bestOptionId: 'c',
      ),

      // Case 15: Agricultural Dispute
      CaseScenario(
        id: 'case_015',
        title: 'The Crop Damage',
        titleHi: 'फसल का नुकसान',
        category: 'agriculture',
        difficulty: 'medium',
        facts: 'Farmer Ramu claims his entire wheat crop worth ₹2 lakh was destroyed when factory nearby released chemical waste into the irrigation canal. Factory says they have proper permissions and the crop failed due to pest attack, not chemicals.',
        factsHi: 'किसान रामू का दावा है कि जब पास की फैक्ट्री ने सिंचाई नहर में रासायनिक कचरा छोड़ा तो उनकी ₹2 लाख की पूरी गेहूं की फसल नष्ट हो गई। फैक्ट्री का कहना है कि उनके पास उचित अनुमति है और फसल कीट हमले से खराब हुई, रसायनों से नहीं।',
        evidence: [
          'Photos of damaged crop with discoloration',
          'Soil sample report showing chemical contamination',
          'Factory has valid pollution control board permit',
          'Three other farmers in same area also reported crop damage',
        ],
        evidenceHi: [
          'मलिनकिरण के साथ क्षतिग्रस्त फसल की तस्वीरें',
          'रासायनिक दूषण दिखाने वाली मिट्टी की नमूना रिपोर्ट',
          'फैक्ट्री के पास वैध प्रदूषण नियंत्रण बोर्ड परमिट है',
          'उसी क्षेत्र के तीन अन्य किसानों ने भी फसल नुकसान की सूचना दी',
        ],
        options: [
          JudgmentOption(
            id: 'a',
            text: 'Factory is not liable as it has valid permit',
            fairnessScore: 1,
            evidenceScore: 2,
            biasScore: 1,
          ),
          JudgmentOption(
            id: 'b',
            text: 'Factory must compensate Ramu based on contamination evidence',
            fairnessScore: 5,
            evidenceScore: 5,
            biasScore: 5,
          ),
          JudgmentOption(
            id: 'c',
            text: 'Share compensation 50-50 between factory and government',
            fairnessScore: 2,
            evidenceScore: 2,
            biasScore: 3,
          ),
        ],
        optionsHi: [
          JudgmentOption(
            id: 'a',
            text: 'फैक्ट्री उत्तरदायी नहीं क्योंकि उसके पास वैध परमिट है',
            fairnessScore: 1,
            evidenceScore: 2,
            biasScore: 1,
          ),
          JudgmentOption(
            id: 'b',
            text: 'दूषण सबूत के आधार पर फैक्ट्री को रामू को मुआवज़ा देना होगा',
            fairnessScore: 5,
            evidenceScore: 5,
            biasScore: 5,
          ),
          JudgmentOption(
            id: 'c',
            text: 'मुआवज़ा फैक्ट्री और सरकार के बीच 50-50 बांटें',
            fairnessScore: 2,
            evidenceScore: 2,
            biasScore: 3,
          ),
        ],
        explanation: 'Having a permit doesn\'t absolve liability for causing harm. Soil report shows chemical contamination. Multiple farmers affected strengthens the case. Under "Polluter Pays Principle" (Environmental Law), whoever causes pollution must compensate victims. Permit is for operations, not for causing damage.',
        explanationHi: 'परमिट होने से नुकसान पहुंचाने की जिम्मेदारी समाप्त नहीं होती। मिट्टी रिपोर्ट रासायनिक दूषण दिखाती है। कई किसान प्रभावित होने से मामला मजबूत होता है। "प्रदूषक भुगतान सिद्धांत" (पर्यावरण कानून) के तहत, जो प्रदूषण करता है उसे पीड़ितों को मुआवज़ा देना होगा। परमिट संचालन के लिए है, नुकसान पहुंचाने के लिए नहीं।',
        bestOptionId: 'b',
      ),
    ];
  }
}

