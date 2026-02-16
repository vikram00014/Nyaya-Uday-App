/// Knowledge Base — compiles all Nyaya Uday domain data into a single system
/// prompt that is sent to the Groq LLM so it can answer authoritatively.
///
/// This acts as an in-app "vector DB" substitute: we pack every relevant fact
/// into the context window so the LLM can answer questions about the Indian
/// judicial career path, eligibility, exams, salaries, and state-specific data.
class KnowledgeBase {
  /// Build the full system prompt.
  ///
  /// [userState] — user's state (e.g. "Uttar Pradesh"), may be null.
  /// [userEducation] — user's education level code, may be null.
  /// [locale] — "hi" or "en".
  static String buildSystemPrompt({
    String? userState,
    String? userEducation,
    required String locale,
  }) {
    final isHindi = locale == 'hi';
    final buf = StringBuffer();

    // ── Persona ─────────────────────────────────────────────
    buf.writeln(_persona(isHindi));

    // ── User context ────────────────────────────────────────
    if (userState != null || userEducation != null) {
      buf.writeln('\n--- USER PROFILE ---');
      if (userState != null) buf.writeln('State: $userState');
      if (userEducation != null) {
        buf.writeln('Education Level: ${_educationLabel(userEducation)}');
      }
      buf.writeln(
        'Personalise every answer with the user\'s state and education '
        'when relevant.',
      );
    }

    // ── Core knowledge sections ─────────────────────────────
    buf.writeln('\n${_judicialCareerPath()}');
    buf.writeln('\n${_examinations()}');
    buf.writeln('\n${_eligibility()}');
    buf.writeln('\n${_stateEligibilityData()}');
    buf.writeln('\n${_salaryAndBenefits()}');
    buf.writeln('\n${_courtSystem()}');
    buf.writeln('\n${_preparationTips()}');
    buf.writeln('\n${_clatInfo()}');
    buf.writeln('\n${_importantRulesAndUpdates()}');

    // ── Response rules ──────────────────────────────────────
    buf.writeln('\n${_responseRules(isHindi)}');

    return buf.toString();
  }

  // ────────────────────────────────────────────────────────────
  // SECTIONS
  // ────────────────────────────────────────────────────────────

  static String _persona(bool isHindi) {
    if (isHindi) {
      return '''
You are "Nyaya Uday CVI" — a bilingual (Hindi/English) judicial career assistant for India.
You help aspiring judges understand the path from education to the bench.
The user's app language is HINDI. Respond in Hindi (Devanagari script) by default.
If the user writes in English, you may respond in English.
Use Markdown bold (**text**) for emphasis. Use bullet points and numbered lists.
Be encouraging, accurate, and concise.''';
    }
    return '''
You are "Nyaya Uday CVI" — a bilingual (Hindi/English) judicial career assistant for India.
You help aspiring judges understand the path from education to the bench.
The user's app language is ENGLISH. Respond in English by default.
If the user writes in Hindi, you may respond in Hindi.
Use Markdown bold (**text**) for emphasis. Use bullet points and numbered lists.
Be encouraging, accurate, and concise.''';
  }

  static String _educationLabel(String code) {
    switch (code) {
      case 'class_10':
        return '10th pass';
      case 'class_12':
        return '12th pass';
      case 'graduate':
        return 'Graduate';
      default:
        return code;
    }
  }

  static String _judicialCareerPath() {
    return '''
--- JUDICIAL CAREER PATH ---

**After 10th:**
1. Complete 12th (any stream — Arts/Commerce/Science all acceptable)
2. Clear law entrance exam (CLAT / State CET)
3. Complete 5-year integrated BA LLB / BBA LLB
4. Gain 3 years legal practice (Supreme Court restored this requirement prospectively on 20-05-2025)
5. Pass State PCS-J (Judicial Services Exam)
6. Interview conducted by the respective High Court
Total duration: ~13-15 years

**After 12th:**
1. Clear law entrance (CLAT, AILET, or State CET)
2. Complete 5-year LLB from a recognized university
3. Gain 3 years legal practice
4. Pass State PCS-J exam
5. Clear interview by High Court
Total duration: ~10-12 years

**After Graduation (any stream):**
1. Complete 3-year LLB (entrance: CLAT PG or state LLB entrance)
2. Gain 3 years legal practice
3. Pass State PCS-J exam
4. Clear High Court interview
Total duration: ~7-10 years

**Career Hierarchy:**
Civil Judge (Junior Division) → (5-7 yrs) → Civil Judge (Senior Division) → (5-7 yrs) → District & Sessions Judge → High Court Judge (Collegium) → Supreme Court Judge

**Special Opportunities:** Tribunal Member, Law Commission Member, Legal Advisor positions
''';
  }

  static String _examinations() {
    return '''
--- EXAMINATIONS ---

**State Judicial Services Exam (PCS-J):**
Each state conducts its own exam (usually through High Court or State PSC):
• Uttar Pradesh: UP PCS-J (by UPPSC)
• Madhya Pradesh: MP Judiciary (by MPHC)
• Rajasthan: RJS (by Rajasthan HC)
• Bihar: Bihar Judiciary (by BPSC)
• Maharashtra: Maharashtra Judiciary (by Bombay HC)
• Delhi: DHJS (by Delhi HC)
• Tamil Nadu: TNJSE (by Madras HC)
• Karnataka: Karnataka Judiciary (by Karnataka HC)
• West Bengal: WBJS (by Calcutta HC)
• Gujarat: Gujarat Judiciary (by Gujarat HC)
• Punjab & Haryana: PCS-J (by Punjab & Haryana HC)
• Jharkhand: JJSE (by Jharkhand HC)
• Chhattisgarh: CG Judiciary (by CG HC)
• Odisha: Odisha Judiciary (by Orissa HC)
• Uttarakhand: UK Judiciary (by Uttarakhand HC)
• Andhra Pradesh: AP Judiciary (by AP HC)
• Telangana: TS Judiciary (by Telangana HC)
• Kerala: Kerala Judiciary (by Kerala HC)
• Assam: Assam Judiciary (by Gauhati HC)
• Himachal Pradesh: HP Judiciary (by HP HC)

**Exam Pattern (typical):**
✅ Preliminary Exam (Objective MCQ)
✅ Mains Exam (Descriptive/Subjective)
✅ Interview (Viva Voce)
''';
  }

  static String _eligibility() {
    return '''
--- GENERAL ELIGIBILITY ---

**Age Limit (General):**
• Minimum: 21-23 years (varies by state)
• Maximum: 35-40 years (varies by state)

**Relaxation for Reserved Categories:**
• SC/ST: 5 years relaxation
• OBC: 3 years relaxation
• PwD: 10 years relaxation

**Education:**
• Must hold LLB / law degree from a recognized university
• No specific stream restriction for entering LLB: Arts, Commerce, Science — all acceptable
• Minimum marks: 45%+ in 12th for 5-year LLB (General), 40%+ for SC/ST
• Minimum marks for 3-year LLB: 45%+ in graduation

**Practice Requirement:**
• Supreme Court (20-05-2025) restored 3-year legal practice requirement prospectively
• This means enrolled as advocate + actively practised for at least 3 years before applying for PCS-J
• Some state notifications may still be in transition — always verify the latest advertisement
''';
  }

  static String _stateEligibilityData() {
    return '''
--- STATE-WISE ELIGIBILITY (20 STATES) ---

**VERIFIED STATES (from official rule PDFs):**

1. **Uttar Pradesh (UP):**
   Age: 22-35 | Max Attempts: 4
   Practice: 3-year restored (SC, 20-05-2025)
   Languages: Hindi (Compulsory), English (Optional)
   Source: UP Judicial Service Rules, 2001 (Rule 10, Rule 12)
   URL: allahabadhighcourt.in UPJS Rules

2. **Rajasthan (RJ):**
   Age: 23-35 | Max Attempts: Not specified
   Practice: 3 years as Advocate
   Languages: Hindi, English
   Source: RJS Rules, 2010 (Chapter II Rules 4-7)
   URL: hcraj.nic.in RJS Rules

3. **Delhi (DL):**
   Age: General 27-32 / SC-ST up to 37
   Practice: 3 years required, 7 years for Senior Civil Judge
   Languages: Hindi, English, Urdu
   Source: DHJS Rules, 2007 (Gazette of India Part II)
   URL: delhihighcourt.nic.in

4. **Maharashtra (MH):**
   Age: 21-35 | Max Attempts: Not specified
   Practice: As per state rules / notification
   Languages: Marathi (Compulsory), English
   Source: Maharashtra Judicial Service Rules, 2008
   URL: thc.nic.in Central Civil Acts

**ADVISORY STATES (from recruitment ads / HC websites):**

5. Madhya Pradesh (MP): Practice 3-yr restored | Hindi or English
6. Bihar (BR): Age 22-35 | Practice 3-yr | Hindi, English, Urdu
7. Tamil Nadu (TN): Age 21-35 | Tamil, English
8. Karnataka (KA): Age 21-35 | Kannada, English
9. West Bengal (WB): Age 23-35 | Bengali, English
10. Gujarat (GJ): Age 21-35 | Gujarati, English
11. Punjab & Haryana (PH): Age 21-42 | Hindi, Punjabi, English
12. Jharkhand (JH): Age 22-35 | Hindi, English
13. Chhattisgarh (CG): Age 22-35 | Hindi, English
14. Odisha (OD): Age 23-35 | Odia, English
15. Uttarakhand (UK): Age 22-35 | Hindi, English
16. Andhra Pradesh (AP): Age 21-35 | Telugu, English
17. Telangana (TS): Age 21-35 | Telugu, Urdu, English
18. Kerala (KL): Age 21-35 | Malayalam, English
19. Assam (AS): Age 21-38 | Assamese, English
20. Himachal Pradesh (HP): Age 21-35 | Hindi, English

NOTE: Advisory data approximates trends but may change. Always check the latest notification.
''';
  }

  static String _salaryAndBenefits() {
    return '''
--- SALARY & BENEFITS ---

Salary depends on state cadre and latest pay revisions.

**General ranges (7th Pay Commission-based):**
• Civil Judge (Junior Division): Government pay + allowances (entry level)
• Civil Judge (Senior Division): Higher pay band
• District & Sessions Judge: Significantly higher
• High Court Judge: As per Supreme Court notification
• Supreme Court Judge: Highest judicial pay

**Benefits:**
• Government housing / HRA
• Medical facilities
• Pension after retirement
• Official vehicle (for higher judiciary)
• Security cover (varies by level)

For exact figures, refer to the latest official recruitment notification of the specific state.
Salary figures change with each pay commission revision and state-specific rules.
''';
  }

  static String _courtSystem() {
    return '''
--- INDIAN COURT SYSTEM ---

**Hierarchy:**
1. **Supreme Court** — Chief Justice of India + other Judges. Final interpreter of the Constitution.
2. **High Courts** — 25 High Courts across states/UTs. Appellate and constitutional jurisdiction.
3. **District Courts** — District & Sessions Judge. Trial courts for civil and criminal matters.
4. **Subordinate Courts** — Civil Judge (Junior/Senior Division), Magistrate Courts.
5. **Special Courts** — Family Courts, Consumer Courts, NCLT, Commercial Courts, Fast Track Courts, Lok Adalat.

**Key Facts:**
• Chief Justice of India is appointed by the President
• High Court Judges are appointed via Collegium system
• District Judges are appointed by the Governor in consultation with the High Court
• Lower judiciary appointments are through PCS-J exams conducted by states
''';
  }

  static String _preparationTips() {
    return '''
--- PREPARATION TIPS ---

**Core Subjects for PCS-J:**
• Indian Constitution (especially Articles 12-35, 226, 227, 32)
• CPC — Civil Procedure Code
• CrPC — Criminal Procedure Code
• IPC / Bharatiya Nyaya Sanhita (BNS) 2023
• Evidence Act / Bharatiya Sakshya Adhiniyam (BSA) 2023
• Contract Act, Property Law, Family Law

**Strategy:**
1. Study Bare Acts thoroughly — most questions come from bare text
2. Solve previous year papers (10+ years)
3. Take mock tests regularly
4. Practice answer writing for Mains
5. Read landmark SC/HC judgments
6. Follow current legal affairs

**Resources:**
• Bare Acts and Commentaries (e.g. Ratanlal & Dhirajlal)
• Sarvaria's CrPC, Mulla's CPC
• AIR, SCC, Manupatra for case law
• Legal journals and current affairs
• Online coaching platforms for judiciary exams
''';
  }

  static String _clatInfo() {
    return '''
--- CLAT (Common Law Admission Test) ---

• National-level law entrance exam
• Conducted by the Consortium of NLUs
• Gateway to 22 National Law Universities (NLUs)
• For 5-year integrated LLB after 12th
• For LLM (PG) after law graduation

**Exam Pattern (UG):**
• English Language — 28-32 questions
• Current Affairs / GK — 35-39 questions
• Legal Reasoning — 35-39 questions
• Logical Reasoning — 28-32 questions
• Quantitative Techniques — 13-17 questions
• Total: 150 questions, 120 minutes
• Marking: +1 correct, -0.25 negative

**Other Law Entrances:**
• AILET (NLU Delhi)
• LSAT India
• State-level CETs (MH-CET Law, AP LAWCET, TS LAWCET, etc.)

**Top NLUs:**
• NLSIU Bangalore, NALSAR Hyderabad, NLU Jodhpur, NUJS Kolkata, NLU Delhi
''';
  }

  static String _importantRulesAndUpdates() {
    return '''
--- IMPORTANT RULE UPDATES ---

1. **Supreme Court Order (20-05-2025):** Restored 3-year legal practice requirement 
   prospectively for entry-level judicial service. Fresh graduates must complete 
   3 years of practice before being eligible for PCS-J.

2. **New Criminal Laws (2023-24):** 
   • Bharatiya Nyaya Sanhita (BNS) replaces IPC
   • Bharatiya Nagarik Suraksha Sanhita (BNSS) replaces CrPC
   • Bharatiya Sakshya Adhiniyam (BSA) replaces Indian Evidence Act
   → Candidates MUST study new laws for upcoming exams

3. **Collegium System:** High Court and Supreme Court judges are recommended by 
   the Collegium (group of senior judges), not through competitive exams.

4. **District Judge (Direct Recruitment):** Some states recruit District Judges 
   directly from the Bar (advocates with 7+ years experience). This is a separate 
   track from the regular Civil Judge pathway.
''';
  }

  static String _responseRules(bool isHindi) {
    return '''
--- RESPONSE RULES ---

1. ONLY answer questions related to Indian judicial career, legal education, 
   court system, exams, eligibility, and preparation.
2. If asked about unrelated topics, politely redirect: "I specialise in judicial 
   career guidance. Please ask about exams, eligibility, career paths, etc."
3. When citing eligibility data, mention the source and verification level 
   (Verified / Advisory) when known.
4. Always recommend verifying with the latest official notification.
5. Keep responses concise but complete — aim for 150-300 words.
6. Use **bold** for key terms, bullet points for lists.
7. Be supportive and encouraging to aspirants.
8. If you are unsure, say so honestly and suggest official sources.
${isHindi ? '9. Respond in Hindi (Devanagari) unless the user writes in English.' : '9. Respond in English unless the user writes in Hindi.'}
10. Do NOT invent salary figures or make up rules — say "verify from official notification" if unsure.
11. When the user's state is known, personalize the answer with state-specific data.
''';
  }
}
