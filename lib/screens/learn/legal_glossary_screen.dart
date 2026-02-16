import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../providers/locale_provider.dart';

/// Searchable A-Z Legal Glossary with bilingual definitions.
class LegalGlossaryScreen extends StatefulWidget {
  const LegalGlossaryScreen({super.key});

  @override
  State<LegalGlossaryScreen> createState() => _LegalGlossaryScreenState();
}

class _LegalGlossaryScreenState extends State<LegalGlossaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = context.watch<LocaleProvider>().locale.languageCode == 'hi';
    final allTerms = _getGlossaryTerms(isHindi);
    final filtered = _searchQuery.isEmpty
        ? allTerms
        : allTerms
              .where(
                (t) =>
                    t['term']!.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    t['definition']!.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();

    // Group by first letter
    final grouped = <String, List<Map<String, String>>>{};
    for (final term in filtered) {
      final letter = term['term']![0].toUpperCase();
      grouped.putIfAbsent(letter, () => []).add(term);
    }
    final sortedLetters = grouped.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: Text(isHindi ? '📖 कानूनी शब्दकोश' : '📖 Legal Glossary'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.primaryColor.withAlpha(15),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: isHindi ? 'शब्द खोजें...' : 'Search terms...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppTheme.primaryColor,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AppTheme.primaryColor.withAlpha(40),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AppTheme.primaryColor.withAlpha(40),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.primaryColor),
                ),
              ),
            ),
          ),
          // Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  isHindi
                      ? '${filtered.length} शब्द मिले'
                      : '${filtered.length} terms found',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          // Terms list
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔍', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(
                          isHindi ? 'कोई शब्द नहीं मिला' : 'No terms found',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: sortedLetters.length,
                    itemBuilder: (context, sectionIndex) {
                      final letter = sortedLetters[sectionIndex];
                      final terms = grouped[letter]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                letter,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          ...terms.asMap().entries.map((entry) {
                            final term = entry.value;
                            return _GlossaryCard(
                                  term: term['term']!,
                                  definition: term['definition']!,
                                  example: term['example'],
                                  category: term['category']!,
                                )
                                .animate(
                                  delay: Duration(milliseconds: 50 * entry.key),
                                )
                                .fadeIn()
                                .slideX(begin: 0.05, end: 0);
                          }),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  static List<Map<String, String>> _getGlossaryTerms(bool isHindi) {
    if (isHindi) {
      return [
        {
          'term': 'अधिवक्ता (Advocate)',
          'definition':
              'एक व्यक्ति जो कानूनी पेशे में योग्य है और न्यायालय में पक्ष का प्रतिनिधित्व करता है। अधिवक्ता अधिनियम 1961 के तहत पंजीकृत।',
          'category': 'पेशा',
          'example':
              'वरिष्ठ अधिवक्ता को सर्वोच्च न्यायालय द्वारा नामित किया जाता है।',
        },
        {
          'term': 'अपील (Appeal)',
          'definition':
              'निचली अदालत के फैसले को उच्च न्यायालय में चुनौती देने की प्रक्रिया।',
          'category': 'प्रक्रिया',
          'example':
              'जिला न्यायालय के निर्णय के विरुद्ध उच्च न्यायालय में अपील।',
        },
        {
          'term': 'अग्रिम जमानत (Anticipatory Bail)',
          'definition':
              'गिरफ्तारी से पहले जमानत प्राप्त करना — CrPC धारा 438 (अब BNSS धारा 482)।',
          'category': 'आपराधिक',
          'example': 'आरोपी ने गिरफ्तारी की आशंका में अग्रिम जमानत ली।',
        },
        {
          'term': 'जमानत (Bail)',
          'definition':
              'गिरफ्तारी के बाद अभियुक्त को मुक्त करने का आदेश, शर्तों के साथ।',
          'category': 'आपराधिक',
        },
        {
          'term': 'बेंच (Bench)',
          'definition':
              'एक या अधिक न्यायाधीशों का समूह जो मामले की सुनवाई करता है। डिवीजन बेंच (2 न्यायाधीश), फुल बेंच (3+)।',
          'category': 'न्यायालय',
        },
        {
          'term': 'भारतीय न्याय संहिता (BNS)',
          'definition':
              'भारतीय दंड संहिता (IPC) का प्रतिस्थापन — 1 जुलाई 2024 से लागू। 358 धाराएं।',
          'category': 'कानून',
        },
        {
          'term': 'सिविल वाद (Civil Suit)',
          'definition':
              'संपत्ति, अनुबंध, या अधिकार से संबंधित विवाद जो दीवानी अदालत में दायर किया जाता है।',
          'category': 'सिविल',
        },
        {
          'term': 'CLAT',
          'definition':
              'कॉमन लॉ एडमिशन टेस्ट — 22 राष्ट्रीय विधि विश्वविद्यालयों में प्रवेश के लिए परीक्षा।',
          'category': 'परीक्षा',
        },
        {
          'term': 'संविधान (Constitution)',
          'definition':
              'भारत का सर्वोच्च कानून — 395 अनुच्छेद, 12 अनुसूचियां (मूल रूप से)। 26 जनवरी 1950 से लागू।',
          'category': 'कानून',
        },
        {
          'term': 'दहेज (Dowry)',
          'definition':
              'विवाह के समय लड़की पक्ष से मांगी गई सम्पत्ति। दहेज निषेध अधिनियम 1961 के तहत अपराध।',
          'category': 'आपराधिक',
        },
        {
          'term': 'FIR',
          'definition':
              'प्रथम सूचना रिपोर्ट — पुलिस में अपराध की पहली शिकायत। BNSS धारा 173 (पूर्व CrPC 154)।',
          'category': 'आपराधिक',
        },
        {
          'term': 'मूल अधिकार (Fundamental Rights)',
          'definition':
              'संविधान भाग III (अनुच्छेद 12-35) — समता, स्वतंत्रता, शोषण से रक्षा, धार्मिक स्वतंत्रता, सांस्कृतिक अधिकार, संवैधानिक उपचार।',
          'category': 'कानून',
        },
        {
          'term': 'हैबियस कॉर्पस (Habeas Corpus)',
          'definition':
              'अनुच्छेद 226/32 — गैरकानूनी हिरासत के विरुद्ध रिट। "शरीर को प्रस्तुत करो।"',
          'category': 'कानून',
          'example':
              'गैरकानूनी गिरफ्तारी पर उच्च न्यायालय में हैबियस कॉर्पस याचिका।',
        },
        {
          'term': 'उच्च न्यायालय (High Court)',
          'definition':
              'राज्य स्तर का सर्वोच्च न्यायालय। संविधान अनुच्छेद 214-231। भारत में 25 उच्च न्यायालय।',
          'category': 'न्यायालय',
        },
        {
          'term': 'IPC (अब BNS)',
          'definition':
              'भारतीय दंड संहिता 1860 — 1 जुलाई 2024 से BNS द्वारा प्रतिस्थापित।',
          'category': 'कानून',
        },
        {
          'term': 'न्यायाधीश (Judge)',
          'definition':
              'न्यायालय में न्याय प्रदान करने वाला अधिकारी। सिविल जज, जिला जज, HC/SC जज।',
          'category': 'पेशा',
        },
        {
          'term': 'न्यायिक सेवा परीक्षा',
          'definition':
              'राज्य उच्च न्यायालय द्वारा आयोजित सिविल जज भर्ती परीक्षा — PCS(J)।',
          'category': 'परीक्षा',
        },
        {
          'term': 'अधिकार क्षेत्र (Jurisdiction)',
          'definition':
              'किसी न्यायालय की मामले सुनने की शक्ति — मूल, अपीलीय, या पुनरीक्षण।',
          'category': 'न्यायालय',
        },
        {
          'term': 'लोक अदालत (Lok Adalat)',
          'definition':
              'विधिक सेवा प्राधिकरण अधिनियम 1987 के तहत वैकल्पिक विवाद समाधान मंच। कोई कोर्ट फीस नहीं।',
          'category': 'न्यायालय',
        },
        {
          'term': 'मध्यस्थता (Mediation)',
          'definition':
              'तटस्थ तृतीय पक्ष द्वारा विवाद समाधान। मध्यस्थता अधिनियम 2023 लागू।',
          'category': 'प्रक्रिया',
        },
        {
          'term': 'NALSA',
          'definition':
              'राष्ट्रीय विधिक सेवा प्राधिकरण — अनुच्छेद 39A के तहत मुफ्त कानूनी सहायता। हेल्पलाइन: 15100।',
          'category': 'संस्था',
        },
        {
          'term': 'PCS(J)',
          'definition':
              'प्रांतीय सिविल सेवा (न्यायिक) — सिविल जज/न्यायिक मजिस्ट्रेट भर्ती परीक्षा।',
          'category': 'परीक्षा',
        },
        {
          'term': 'PIL (जनहित याचिका)',
          'definition':
              'जनहित में न्यायालय में दायर याचिका। जनता के अधिकारों की रक्षा हेतु।',
          'category': 'प्रक्रिया',
          'example': 'पर्यावरण प्रदूषण के विरुद्ध PIL।',
        },
        {
          'term': 'रिट (Writ)',
          'definition':
              'उच्च न्यायालय/सर्वोच्च न्यायालय द्वारा जारी आदेश — हैबियस कॉर्पस, मैंडेमस, प्रोहिबिशन, सर्टिओरारी, क्वो-वारंटो।',
          'category': 'कानून',
        },
        {
          'term': 'सर्वोच्च न्यायालय (Supreme Court)',
          'definition':
              'भारत का शीर्ष न्यायालय। अनुच्छेद 124-147। CJI + 33 न्यायाधीश।',
          'category': 'न्यायालय',
        },
        {
          'term': 'शपथ पत्र (Affidavit)',
          'definition':
              'शपथ पर लिखित बयान जो न्यायालय में साक्ष्य के रूप में प्रस्तुत किया जाता है।',
          'category': 'प्रक्रिया',
        },
        {
          'term': 'ज़मानत पत्र (Surety Bond)',
          'definition':
              'जमानत में ज़मानतदार द्वारा दिया गया बंध पत्र कि अभियुक्त न्यायालय में उपस्थित होगा।',
          'category': 'आपराधिक',
        },
        {
          'term': 'विधिक सहायता (Legal Aid)',
          'definition':
              'अनुच्छेद 39A — निर्धन व्यक्तियों को मुफ्त कानूनी सहायता। SC/ST/महिला/बच्चे/दिव्यांग को आय सीमा के बिना।',
          'category': 'कानून',
        },
        {
          'term': 'वकालतनामा (Vakalatnama)',
          'definition':
              'मुवक्किल द्वारा अधिवक्ता को दिया गया प्राधिकार पत्र जो न्यायालय में प्रतिनिधित्व की अनुमति देता है।',
          'category': 'प्रक्रिया',
        },
        {
          'term': 'ज़िला न्यायालय (District Court)',
          'definition':
              'जिला स्तर का न्यायालय — CPC और CrPC के तहत मूल तथा अपीलीय क्षेत्राधिकार।',
          'category': 'न्यायालय',
        },
      ];
    }
    return [
      {
        'term': 'Acquittal',
        'definition':
            'A court verdict declaring the accused not guilty of the charges. The prosecution failed to prove guilt beyond reasonable doubt.',
        'category': 'Criminal',
        'example': 'The accused was acquitted due to insufficient evidence.',
      },
      {
        'term': 'Adjournment',
        'definition':
            'Postponement of a court hearing to a future date. Granted by the judge upon request or suo motu.',
        'category': 'Procedure',
      },
      {
        'term': 'Advocate',
        'definition':
            'A person qualified and enrolled under the Advocates Act 1961, authorized to practice law and represent parties in court.',
        'category': 'Profession',
        'example':
            'Senior Advocates are designated by the Supreme Court or High Courts.',
      },
      {
        'term': 'Affidavit',
        'definition':
            'A written sworn statement of facts submitted as evidence in court proceedings. Must be signed before an oath commissioner.',
        'category': 'Procedure',
      },
      {
        'term': 'Anticipatory Bail',
        'definition':
            'Bail granted before arrest in anticipation of being accused of an offence — CrPC Section 438 (now BNSS Section 482).',
        'category': 'Criminal',
        'example': 'The accused sought anticipatory bail fearing arrest.',
      },
      {
        'term': 'Appeal',
        'definition':
            'The process of challenging a lower court\'s decision in a higher court for reconsideration.',
        'category': 'Procedure',
        'example':
            'Appeal in the High Court against a District Court judgment.',
      },
      {
        'term': 'Bail',
        'definition':
            'Temporary release of an accused person from custody, subject to conditions imposed by the court.',
        'category': 'Criminal',
      },
      {
        'term': 'Bench',
        'definition':
            'A group of one or more judges hearing a case. Division Bench (2 judges), Full Bench (3+), Constitutional Bench (5+).',
        'category': 'Court',
      },
      {
        'term': 'BNS (Bharatiya Nyaya Sanhita)',
        'definition':
            'Replacement of the Indian Penal Code (IPC) — effective 1 July 2024. Contains 358 sections covering criminal offences.',
        'category': 'Law',
      },
      {
        'term': 'BNSS (Bharatiya Nagarik Suraksha Sanhita)',
        'definition':
            'Replacement of CrPC — effective 1 July 2024. Contains 531 sections on criminal procedure.',
        'category': 'Law',
      },
      {
        'term': 'BSA (Bharatiya Sakshya Adhiniyam)',
        'definition':
            'Replacement of the Indian Evidence Act — effective 1 July 2024. Contains 170 sections on evidence law.',
        'category': 'Law',
      },
      {
        'term': 'Civil Suit',
        'definition':
            'A legal dispute related to property, contracts, or rights filed in a civil court under the Code of Civil Procedure (CPC).',
        'category': 'Civil',
      },
      {
        'term': 'CLAT',
        'definition':
            'Common Law Admission Test — national entrance exam for admission to 22 National Law Universities (NLUs) in India.',
        'category': 'Exam',
      },
      {
        'term': 'Cognizable Offence',
        'definition':
            'An offence where police can arrest without warrant and start investigation without Magistrate\'s order. E.g., murder, robbery.',
        'category': 'Criminal',
      },
      {
        'term': 'Constitution',
        'definition':
            'The supreme law of India — originally 395 Articles, 8 Schedules (now 12). Came into force 26 January 1950.',
        'category': 'Law',
      },
      {
        'term': 'Contempt of Court',
        'definition':
            'Willful disobedience of a court order or disrespect to the court. Contempt of Courts Act 1971.',
        'category': 'Law',
      },
      {
        'term': 'District Court',
        'definition':
            'Principal court at the district level with original and appellate jurisdiction under CPC and CrPC.',
        'category': 'Court',
      },
      {
        'term': 'Dowry',
        'definition':
            'Property or money demanded from the bride\'s side at marriage. Prohibited under Dowry Prohibition Act 1961.',
        'category': 'Criminal',
      },
      {
        'term': 'FIR (First Information Report)',
        'definition':
            'The first report of a cognizable offence lodged with police — BNSS Section 173 (formerly CrPC 154).',
        'category': 'Criminal',
      },
      {
        'term': 'Fundamental Rights',
        'definition':
            'Part III of the Constitution (Articles 12-35) — Right to Equality, Freedom, Against Exploitation, Religion, Culture, Constitutional Remedies.',
        'category': 'Law',
      },
      {
        'term': 'Habeas Corpus',
        'definition':
            'Writ under Article 226/32 against unlawful detention. Literally: "produce the body." Courts can order release of illegally detained persons.',
        'category': 'Law',
        'example':
            'Habeas corpus petition filed against illegal police custody.',
      },
      {
        'term': 'High Court',
        'definition':
            'The highest court at state level. Constitution Articles 214-231. India has 25 High Courts.',
        'category': 'Court',
      },
      {
        'term': 'Injunction',
        'definition':
            'A court order directing a party to do or refrain from doing a specific act. Temporary or permanent.',
        'category': 'Civil',
      },
      {
        'term': 'Judge',
        'definition':
            'A judicial officer who presides over court proceedings and delivers judgments. Civil Judge, District Judge, HC/SC Judge.',
        'category': 'Profession',
      },
      {
        'term': 'Judicial Service Exam',
        'definition':
            'State-level examination conducted by High Courts for recruitment of Civil Judges / Judicial Magistrates — also called PCS(J).',
        'category': 'Exam',
      },
      {
        'term': 'Jurisdiction',
        'definition':
            'The authority of a court to hear and decide cases — original, appellate, or revisional.',
        'category': 'Court',
      },
      {
        'term': 'Legal Aid',
        'definition':
            'Free legal assistance to the poor under Article 39A. SC/ST/Women/Children/PwD eligible regardless of income. NALSA Helpline: 15100.',
        'category': 'Law',
      },
      {
        'term': 'Lok Adalat',
        'definition':
            'Alternative dispute resolution forum under Legal Services Authorities Act 1987. No court fee. Decisions are final and binding.',
        'category': 'Court',
      },
      {
        'term': 'Mandamus',
        'definition':
            'Writ commanding a public official/body to perform a statutory duty. "We command." Under Article 226/32.',
        'category': 'Law',
      },
      {
        'term': 'Mediation',
        'definition':
            'Dispute resolution through a neutral third party. Mediation Act 2023 now in effect in India.',
        'category': 'Procedure',
      },
      {
        'term': 'NALSA',
        'definition':
            'National Legal Services Authority — provides free legal aid under Article 39A. Helpline: 15100. Email: nalsa-dla@nic.in.',
        'category': 'Institution',
      },
      {
        'term': 'Non-Cognizable Offence',
        'definition':
            'An offence where police cannot arrest without warrant or investigate without Magistrate\'s order. E.g., defamation, cheating.',
        'category': 'Criminal',
      },
      {
        'term': 'PCS(J)',
        'definition':
            'Provincial Civil Service (Judicial) — the exam for recruitment of Civil Judges/Judicial Magistrates at state level.',
        'category': 'Exam',
      },
      {
        'term': 'PIL (Public Interest Litigation)',
        'definition':
            'A petition filed in court for the protection of public interest. Any citizen can file a PIL.',
        'category': 'Procedure',
        'example': 'PIL against environmental pollution in a locality.',
      },
      {
        'term': 'Plea Bargaining',
        'definition':
            'An accused pleads guilty in exchange for a lesser sentence. Allowed under BNSS for offences with punishment up to 7 years.',
        'category': 'Criminal',
      },
      {
        'term': 'Quasi-Judicial Body',
        'definition':
            'An authority that is not a court but has the power to make binding legal decisions. E.g., Tribunals, Consumer Forums.',
        'category': 'Court',
      },
      {
        'term': 'Remand',
        'definition':
            'Court order sending an accused back to custody (judicial or police) for further investigation.',
        'category': 'Criminal',
      },
      {
        'term': 'Suo Motu',
        'definition':
            'Action taken by a court on its own initiative without any petition or complaint. "On its own motion."',
        'category': 'Procedure',
      },
      {
        'term': 'Supreme Court',
        'definition':
            'The apex court of India. Articles 124-147. Headed by the Chief Justice of India (CJI) + 33 judges.',
        'category': 'Court',
      },
      {
        'term': 'Surety Bond',
        'definition':
            'A bond given by a guarantor (surety) that the accused will appear before the court as required.',
        'category': 'Criminal',
      },
      {
        'term': 'Vakalatnama',
        'definition':
            'Authorization document signed by a client empowering an advocate to represent them in court proceedings.',
        'category': 'Procedure',
      },
      {
        'term': 'Warrant',
        'definition':
            'A written order issued by a court directing the arrest of a person or search of premises.',
        'category': 'Criminal',
      },
      {
        'term': 'Writ',
        'definition':
            'Order issued by the High Court (Art. 226) or Supreme Court (Art. 32) — Habeas Corpus, Mandamus, Prohibition, Certiorari, Quo Warranto.',
        'category': 'Law',
      },
    ];
  }
}

class _GlossaryCard extends StatefulWidget {
  final String term;
  final String definition;
  final String? example;
  final String category;

  const _GlossaryCard({
    required this.term,
    required this.definition,
    this.example,
    required this.category,
  });

  @override
  State<_GlossaryCard> createState() => _GlossaryCardState();
}

class _GlossaryCardState extends State<_GlossaryCard> {
  bool _expanded = false;

  Color get _categoryColor {
    switch (widget.category.toLowerCase()) {
      case 'criminal':
      case 'आपराधिक':
        return Colors.red.shade700;
      case 'civil':
      case 'सिविल':
        return Colors.blue.shade700;
      case 'law':
      case 'कानून':
        return Colors.indigo.shade700;
      case 'court':
      case 'न्यायालय':
        return Colors.purple.shade700;
      case 'procedure':
      case 'प्रक्रिया':
        return Colors.teal.shade700;
      case 'profession':
      case 'पेशा':
        return Colors.orange.shade800;
      case 'exam':
      case 'परीक्षा':
        return Colors.green.shade700;
      case 'institution':
      case 'संस्था':
        return Colors.brown.shade700;
      default:
        return AppTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _expanded
                  ? _categoryColor.withAlpha(80)
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.term,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: _categoryColor,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _categoryColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.category,
                      style: TextStyle(
                        fontSize: 10,
                        color: _categoryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
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
                const SizedBox(height: 10),
                Text(
                  widget.definition,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (widget.example != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _categoryColor.withAlpha(10),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _categoryColor.withAlpha(30)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('💡 ', style: TextStyle(fontSize: 14)),
                        Expanded(
                          child: Text(
                            widget.example!,
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: AppTheme.textSecondary,
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
}
