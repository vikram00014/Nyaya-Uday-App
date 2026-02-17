import 'state_catalog.dart';

class RoadmapStep {
  final String title;
  final String? titleHi;
  final String description;
  final String? descriptionHi;
  final String duration;
  final String? durationHi;
  final int order;
  final bool isCompleted;
  final List<String> details;
  final List<String>? detailsHi;

  RoadmapStep({
    required this.title,
    this.titleHi,
    required this.description,
    this.descriptionHi,
    required this.duration,
    this.durationHi,
    required this.order,
    this.isCompleted = false,
    this.details = const [],
    this.detailsHi,
  });

  String getTitle(String locale) =>
      (locale == 'hi' && titleHi != null) ? titleHi! : title;
  String getDescription(String locale) =>
      (locale == 'hi' && descriptionHi != null) ? descriptionHi! : description;
  String getDuration(String locale) =>
      (locale == 'hi' && durationHi != null) ? durationHi! : duration;
  List<String> getLocalizedDetails(String locale) =>
      (locale == 'hi' && detailsHi != null) ? detailsHi! : details;

  factory RoadmapStep.fromJson(Map<String, dynamic> json) {
    return RoadmapStep(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? '',
      order: json['order'] ?? 0,
      isCompleted: json['is_completed'] ?? false,
      details: List<String>.from(json['details'] ?? []),
    );
  }
}

enum VerificationLevel { verified, advisory }

// State-specific eligibility criteria (verifiable)
class StateEligibilityCriteria {
  final String state;
  final int? minAge;
  final int? maxAge;
  final int? maxAttempts;
  final String practiceRequirement;
  final List<String> languageRequirements;
  final String sourceUrl;
  final String sourceLabel;
  final String lastVerified; // DD-MM-YYYY
  final VerificationLevel verificationLevel;
  final String verificationNote;

  StateEligibilityCriteria({
    required this.state,
    required this.minAge,
    required this.maxAge,
    required this.maxAttempts,
    required this.practiceRequirement,
    required this.languageRequirements,
    required this.sourceUrl,
    required this.sourceLabel,
    required this.lastVerified,
    required this.verificationLevel,
    required this.verificationNote,
  });
}

class RoadmapModel {
  final String state;
  final String educationLevel;
  final List<RoadmapStep> steps;
  final String totalDuration;
  final List<String> entranceExams;
  final String eligibilityNotes;
  final StateEligibilityCriteria? eligibilityCriteria;

  RoadmapModel({
    required this.state,
    required this.educationLevel,
    required this.steps,
    required this.totalDuration,
    required this.entranceExams,
    this.eligibilityNotes = '',
    this.eligibilityCriteria,
  });

  factory RoadmapModel.fromJson(Map<String, dynamic> json) {
    return RoadmapModel(
      state: json['state'] ?? '',
      educationLevel: json['education_level'] ?? '',
      steps:
          (json['steps'] as List?)
              ?.map((e) => RoadmapStep.fromJson(e))
              .toList() ??
          [],
      totalDuration: json['total_duration'] ?? '',
      entranceExams: List<String>.from(json['entrance_exams'] ?? []),
      eligibilityNotes: json['eligibility_notes'] ?? '',
    );
  }
}

// Default roadmap data for different education levels
class RoadmapData {
  static const String _judicialUpdateNote =
      'Policy update (20-05-2025): Supreme Court restored a 3-year legal practice requirement prospectively for entry-level judicial service. '
      'Some state rules/notifications may still be in transition, so verify the latest official advertisement before applying.';

  static RoadmapModel getDefaultRoadmap(String state, String educationLevel) {
    final stateCode = StateCatalog.normalizeCode(state);
    final stateName = StateCatalog.displayName(state);

    switch (educationLevel) {
      case 'class_10':
        return _getRoadmapAfter10th(stateCode, stateName);
      case 'class_12':
        return _getRoadmapAfter12th(stateCode, stateName);
      case 'graduate':
        return _getRoadmapAfterGraduation(stateCode, stateName);
      default:
        return _getRoadmapAfter12th(stateCode, stateName);
    }
  }

  // Get state-specific eligibility criteria (verifiable)
  static StateEligibilityCriteria getEligibilityCriteria(String state) {
    final stateCode = StateCatalog.normalizeCode(state);
    final criteria = _stateEligibilityMap[stateCode];
    return criteria ?? _getDefaultCriteria(stateCode);
  }

  static final Map<String, StateEligibilityCriteria> _stateEligibilityMap = {
    'UP': StateEligibilityCriteria(
      state: 'Uttar Pradesh',
      minAge: 22,
      maxAge: 35,
      maxAttempts: 4,
      practiceRequirement:
          'Must be enrolled advocate under Advocates Act, 1961. Max 4 attempts (2022 amendment). 3-year practice requirement restored prospectively (SC, 20-05-2025).',
      languageRequirements: [
        'Hindi in Devnagri Script (Compulsory)',
        'English (translation paper in Mains)',
      ],
      sourceUrl:
          'https://www.allahabadhighcourt.in/rules/TheUttarPradeshJudicialServiceRules2001.pdf',
      sourceLabel: 'UP Judicial Service Rules, 2001 (as amended)',
      lastVerified: '17-02-2026',
      verificationLevel: VerificationLevel.verified,
      verificationNote:
          'Official PDF from Allahabad HC. Age 22–35. LLB required. 4-attempt cap per 2022 amendment.',
    ),
    'MP': StateEligibilityCriteria(
      state: 'Madhya Pradesh',
      minAge: 21,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'Civil Judge: 3-year continuous practice OR outstanding law graduate (all exams first attempt, 70% Gen/OBC, 50% SC/ST). Per MP JS Rules, 1994 (2023 amendment) & SC ruling 20-05-2025.',
      languageRequirements: ['Hindi (Compulsory)', 'English'],
      sourceUrl: 'https://mphc.gov.in/rules',
      sourceLabel: 'MP Judicial Service Rules, 1994 (amended 2023) / HJS Rules, 2017',
      lastVerified: '17-02-2026',
      verificationLevel: VerificationLevel.verified,
      verificationNote:
          'Official MPHC rules page. CJ age 21–35 (SC/ST/OBC +3 yrs). HJS: 35–48, 7-yr practice.',
    ),
    'MH': StateEligibilityCriteria(
      state: 'Maharashtra',
      minAge: 21,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'Mandatory 3-year practice (SC ruling 20-05-2025). 2025 amendment for faster vacancy filling.',
      languageRequirements: ['Marathi (Compulsory)', 'English'],
      sourceUrl:
          'https://bombayhighcourt.nic.in/writereaddata/latest/PDF/ltupdtbom20170727161616.pdf',
      sourceLabel: 'Maharashtra Judicial Service Rules, 2008 (amended 2025)',
      lastVerified: '17-02-2026',
      verificationLevel: VerificationLevel.verified,
      verificationNote:
          'PDF verified accessible. Age 21-35 from rules. 2025 amendment for faster vacancy filling.',
    ),
    'RJ': StateEligibilityCriteria(
      state: 'Rajasthan',
      minAge: 23,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          '3-year practice as advocate required (SC ruling 20-05-2025). LLB from recognized university. Rules amended up to 20-08-2020.',
      languageRequirements: ['Hindi (Compulsory)', 'English'],
      sourceUrl:
          'https://kota.dcourts.gov.in/document/rajasthan-judicial-service-rules-2010-as-amended-upto-20-08-2020',
      sourceLabel:
          'Rajasthan Judicial Service Rules, 2010 (amended up to 20-08-2020)',
      lastVerified: '17-02-2026',
      verificationLevel: VerificationLevel.verified,
      verificationNote:
          'Official district court page. Age 23–35. SC/ST +5 yrs, OBC +3 yrs relaxation.',
    ),
    'DL': StateEligibilityCriteria(
      state: 'Delhi',
      minAge: null,
      maxAge: 32,
      maxAttempts: null,
      practiceRequirement:
          'Must be enrolled advocate under Advocates Act, 1961. No mandatory prior practice under DJS Rules. 3-year practice requirement restored prospectively (SC, 20-05-2025).',
      languageRequirements: ['Hindi (translation paper)', 'English'],
      sourceUrl: 'https://delhihighcourt.nic.in',
      sourceLabel: 'Delhi Judicial Service Rules, 1970',
      lastVerified: '17-02-2026',
      verificationLevel: VerificationLevel.verified,
      verificationNote:
          'Official Delhi HC. Max age 32 (OBC/SC/ST +5 yrs, PwD +10 yrs). Hindi–English translation tested.',
    ),
    'BR': StateEligibilityCriteria(
      state: 'Bihar',
      minAge: 22,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'LLB from BCI-recognized university. Must be enrolled advocate. 1955 rules required bar certificate; modern practice: 3-year requirement restored (SC, 20-05-2025). OBC +3 yrs, SC/ST/PwD/Women +5 yrs age relaxation.',
      languageRequirements: ['Hindi (Compulsory qualifying paper)', 'English (General English paper)'],
      sourceUrl:
          'https://www.linkinglaws.com/assets/pdf/contents/bihar-recruitment-rules-1955-1509.pdf',
      sourceLabel:
          'Bihar Civil Service (Judicial Branch) Recruitment Rules, 1955 (as amended)',
      lastVerified: '17-02-2026',
      verificationLevel: VerificationLevel.verified,
      verificationNote:
          'Base rules PDF (1955) verified. Modern age 22–35. Hindi departmental exam per 1963 training rules.',
    ),
    'GJ': StateEligibilityCriteria(
      state: 'Gujarat',
      minAge: 21,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'Must be practicing advocate. LLB + AIBE (if degree from 2009-10 onwards). Gujarati language proficiency test mandatory. 3-year practice rule for future vacancies post 20-05-2026 (SC direction). Computer knowledge certificate required.',
      languageRequirements: ['Gujarati (Compulsory proficiency test)', 'English'],
      sourceUrl: 'https://gujarathighcourt.nic.in/servicerules',
      sourceLabel: 'Gujarat State Judicial Service Rules (as amended)',
      lastVerified: '17-02-2026',
      verificationLevel: VerificationLevel.verified,
      verificationNote:
          'Official Gujarat HC page. Age 21–35 (SC/ST/SEBC/EWS +3 yrs to 38). Gujarati test is qualifying.',
    ),
    'KA': StateEligibilityCriteria(
      state: 'Karnataka',
      minAge: 21,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'Mandatory 3-year practice (SC ruling 20-05-2025). Karnataka Judicial Service Rules, 2004.',
      languageRequirements: ['Kannada (Compulsory)', 'English'],
      sourceUrl: 'https://law.karnataka.gov.in/storage/pdf-files/Notifications/JudicialService.pdf',
      sourceLabel: 'Karnataka Judicial Service (Recruitment) Rules, 2004',
      lastVerified: '17-02-2026',
      verificationLevel: VerificationLevel.verified,
      verificationNote:
          'PDF verified accessible. Conducted by KPSC. Kannada mandatory.',
    ),
    'KL': StateEligibilityCriteria(
      state: 'Kerala',
      minAge: 22,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'Mandatory 3-year practice (SC ruling 20-05-2025). 2025 amendment updates syllabus & reservations.',
      languageRequirements: ['Malayalam (Compulsory)', 'English'],
      sourceUrl: 'https://kja.keralacourts.in/kjauploads/media/kerala_state_higher_judicial_serive_amendment_rules_2025_1741677652.pdf',
      sourceLabel: 'Kerala Higher Judicial Service Special Rules (amended 2025)',
      lastVerified: '17-02-2026',
      verificationLevel: VerificationLevel.verified,
      verificationNote:
          'PDF verified accessible (138 KB). 2025 amendment for syllabus & reservations. Kerala PSC conducts exam.',
    ),
    'TN': StateEligibilityCriteria(
      state: 'Tamil Nadu',
      minAge: 21,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'Mandatory 3-year practice (SC ruling 20-05-2025). 2026 syllabus amendment.',
      languageRequirements: ['Tamil (Compulsory)', 'English'],
      sourceUrl: 'https://www.mhc.tn.gov.in/recruitment/docs/TNSJS%202007%2020.01.2026%20(SYLABUSS%20AMENDMENT)%20UPDATED%20ON%2020.01.2026.pdf',
      sourceLabel: 'TN State Judicial Service Rules, 2007 (Syllabus Amendment 2026)',
      lastVerified: '17-02-2026',
      verificationLevel: VerificationLevel.verified,
      verificationNote:
          'PDF verified accessible (1.1 MB). Syllabus updated 20-01-2026. Madras HC conducts exam.',
    ),
    'WB': StateEligibilityCriteria(
      state: 'West Bengal',
      minAge: 23,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'Must be enrolled advocate with any State Bar Council. 3-year practice requirement restored (SC, 20-05-2025). SC/ST +5 yrs, OBC +3 yrs, PwBD up to 45 yrs, Govt servants +2 yrs age relaxation.',
      languageRequirements: ['Bengali (must read/write/speak)', 'English'],
      sourceUrl:
          'https://thc.nic.in/Central%20Governmental%20Rules/West%20Bengal%20Judicial%20(Condition%20of%20Service)%20Rules,%202004.pdf',
      sourceLabel: 'WB Judicial (Conditions of Service) Rules, 2004',
      lastVerified: '17-02-2026',
      verificationLevel: VerificationLevel.verified,
      verificationNote:
          'Official THC PDF. Age 23–35. Bengali proficiency tested at interview. Nepali mother-tongue exempted from Bengali.',
    ),
    'HR': StateEligibilityCriteria(
      state: 'Haryana',
      minAge: 22,
      maxAge: 42,
      maxAttempts: null,
      practiceRequirement:
          'Minimum 3-year practice as advocate. Must be an enrolled advocate of any Bar Council in India.',
      languageRequirements: ['Hindi (Compulsory)', 'English'],
      sourceUrl:
          'https://highcourtchd.gov.in/sub_pages/left_menu/Rules_orders/download_pdf/Rules/HaryanaSuperiorJudicialServiceRules2007.pdf',
      sourceLabel: 'Haryana Superior Judicial Service Rules, 2007',
      lastVerified: '17-02-2026',
      verificationLevel: VerificationLevel.verified,
      verificationNote:
          'PDF verified accessible. Conducted by Punjab & Haryana HC. Age 22-42.',
    ),
    'PB': StateEligibilityCriteria(
      state: 'Punjab',
      minAge: 22,
      maxAge: 42,
      maxAttempts: null,
      practiceRequirement: 'Minimum 3-year practice as advocate required.',
      languageRequirements: ['Punjabi', 'Hindi', 'English'],
      sourceUrl:
          'https://highcourtchd.gov.in/sub_pages/left_menu/Rules_orders/download_pdf/Rules/PunjabSuperiorJudicialServiceRules2007.pdf',
      sourceLabel: 'Punjab Superior Judicial Service Rules, 2007',
      lastVerified: '17-02-2026',
      verificationLevel: VerificationLevel.verified,
      verificationNote:
          'PDF verified accessible. Conducted by Punjab & Haryana High Court. Punjabi knowledge may be required.',
    ),
    'JH': StateEligibilityCriteria(
      state: 'Jharkhand',
      minAge: 22,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'CJ (Jr Div): LLB, enrolled advocate. SJS/HJS (District Judge): 7+ yrs practice, age 35–45 (SC/ST +3 yrs). 3-year practice for CJ restored (SC, 20-05-2025).',
      languageRequirements: ['Hindi (Compulsory)', 'English'],
      sourceUrl:
          'https://thc.nic.in/Central%20Governmental%20Rules/Jharkhand%20Superior%20Judicial%20Service%20(Recruitment,%20Appointment%20&%20Condition%20of%20Service)%20Rules,%202001.pdf',
      sourceLabel: 'Jharkhand Superior Judicial Service Rules, 2001',
      lastVerified: '17-02-2026',
      verificationLevel: VerificationLevel.verified,
      verificationNote:
          'Official THC PDF. SJS: age 35–45, 7-yr practice. CJ: 22–35. Conducted by Jharkhand HC.',
    ),
    'CG': StateEligibilityCriteria(
      state: 'Chhattisgarh',
      minAge: 21,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'Lower JS (CJ Jr Div): LLB + enrolled advocate, age 21–35 (SC/ST/OBC +5, Women +10 yrs). Higher JS (District Judge): 7+ yrs practice, age 35–45 (SC/ST/OBC +3 yrs). Good character & sound health.',
      languageRequirements: ['Hindi (Compulsory)', 'English'],
      sourceUrl: 'https://highcourt.cg.gov.in/information/rule/rule.php',
      sourceLabel: 'CG Higher/Lower Judicial Service Rules, 2006 (amended)',
      lastVerified: '17-02-2026',
      verificationLevel: VerificationLevel.verified,
      verificationNote:
          'Official CG HC rules page. CJ: 21–35 (women +10 yrs). HJS: 35–45, 7-yr practice.',
    ),
    'OD': StateEligibilityCriteria(
      state: 'Odisha',
      minAge: 21,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'Mandatory 3-year practice (SC ruling 20-05-2025). 2026 amendment enhances PwD opportunities.',
      languageRequirements: ['Odia', 'English'],
      sourceUrl: 'https://www.orissahighcourt.nic.in/OSJS-OJS-Rules2007.pdf',
      sourceLabel: 'OSJS/OJS Rules, 2007 (amended 2026: PwD enhancements)',
      lastVerified: '17-02-2026',
      verificationLevel: VerificationLevel.verified,
      verificationNote:
          'PDF verified accessible (1.3 MB). OPSC conducts exam. 2026 amendment for PwD.',
    ),
    'AP': StateEligibilityCriteria(
      state: 'Andhra Pradesh',
      minAge: null,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'LLB from Indian university. CJ: no mandatory minimum practice under 2007 rules; enrolled advocate required. District Judge: 7+ yrs practice. SC/ST/BC/EWS +5 yrs, PwD +10 yrs age relaxation. Mains includes English & Translation paper.',
      languageRequirements: ['Telugu', 'English (Mains translation paper)'],
      sourceUrl:
          'https://gad.ap.gov.in/documents/service-rules/ap-judicial-service-rules.pdf',
      sourceLabel: 'AP State Judicial Service Rules, 2007 (amended up to 2023)',
      lastVerified: '17-02-2026',
      verificationLevel: VerificationLevel.verified,
      verificationNote:
          'Official GAD PDF. CJ max age 35 (no explicit min). DJ age 45, 7-yr practice. AP Judicial Academy training replaces language test.',
    ),
    'TS': StateEligibilityCriteria(
      state: 'Telangana',
      minAge: 22,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'Mandatory 3-year practice (SC ruling 20-05-2025). TS Judicial Service & Cadre Rules, 2023.',
      languageRequirements: ['Telugu (Compulsory)', 'English'],
      sourceUrl: 'https://cdnbbsr.s3waas.gov.in/s3ec019f8684e630c4c30cad7b1f0935cd/uploads/2025/11/2025111883.pdf',
      sourceLabel: 'Telangana State Judicial (Service & Cadre) Rules, 2023',
      lastVerified: '17-02-2026',
      verificationLevel: VerificationLevel.verified,
      verificationNote:
          'PDF verified accessible (1.5 MB). TSPSC/TS HC conducts exam. Telugu mandatory.',
    ),
    'AS': StateEligibilityCriteria(
      state: 'Assam',
      minAge: null,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'LLB from recognized Indian university. 3-year practice restored (SC, 20-05-2025). SC/ST +3 yrs to 38. HJS: 7+ yrs practice, age 35–45. Assamese qualifying paper (35% minimum, not counted in aggregate).',
      languageRequirements: ['Assamese (qualifying paper)', 'English'],
      sourceUrl:
          'https://ghconline.gov.in/General/Assam%20Gazette%20AJS.pdf',
      sourceLabel: 'Assam Judicial Service Rules, 2003 (as amended)',
      lastVerified: '17-02-2026',
      verificationLevel: VerificationLevel.verified,
      verificationNote:
          'Official Gauhati HC Gazette PDF. CJ max age 35 (SC/ST 38). HJS age 35–45. Assamese is qualifying.',
    ),
    'UK': StateEligibilityCriteria(
      state: 'Uttarakhand',
      minAge: 22,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'LLB from recognized university. 3-year practice restored (SC, 20-05-2025). SC/ST +5 yrs, OBC +3 yrs, PwD +10 yrs. Thorough Hindi in Devnagri script required. Computer operation test (MS Office) is mandatory.',
      languageRequirements: ['Hindi in Devnagri Script (Compulsory)', 'English'],
      sourceUrl: 'https://highcourtofuttarakhand.gov.in/service-matter',
      sourceLabel: 'Uttarakhand Judicial Service Rules, 2005 (as amended)',
      lastVerified: '17-02-2026',
      verificationLevel: VerificationLevel.verified,
      verificationNote:
          'Official UK HC service-matter page. Age 22–35. Computer practical test mandatory. Hindi proficiency required.',
    ),
    'AR': StateEligibilityCriteria(
      state: 'Arunachal Pradesh',
      minAge: 21,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'LLB from recognized university + AIBE clearance. Grade-III (CJ): no mandatory prior practice; 2-year practice preferred. Grade-I (DJ): 7+ yrs practice, age 35–45 (APST 48). 3-year practice restored (SC, 20-05-2025).',
      languageRequirements: ['English', 'Local languages (desirable)'],
      sourceUrl:
          'https://ghcitanagar.gov.in/Rules/Subordinatecourt/APJudlSRules.pdf',
      sourceLabel: 'Arunachal Pradesh Judicial Service Rules, 2006',
      lastVerified: '17-02-2026',
      verificationLevel: VerificationLevel.verified,
      verificationNote:
          'Official Gauhati HC (Itanagar) PDF. CJ age 21–35 (APST 38). AIBE + law degree required.',
    ),
    'GA': StateEligibilityCriteria(
      state: 'Goa',
      minAge: 21,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          '3-year practice as advocate OR fresh LLB graduate (first attempt all years, 55%+ final year) OR LLM degree. Advocates: age 21–35. Fresh graduates: age 21–25. Ministerial staff: age 21–45. BC +5 yrs relaxation.',
      languageRequirements: ['Konkani, Marathi, or English (CJ exam medium)', 'English (DJ exam medium)'],
      sourceUrl:
          'https://hcbombayatgoa.nic.in/download/The_Goa_Judicial_Service_Rules_2013.pdf',
      sourceLabel: 'Goa Judicial Service Rules, 2013',
      lastVerified: '17-02-2026',
      verificationLevel: VerificationLevel.verified,
      verificationNote:
          'Official Bombay HC at Goa PDF. CJ exam in Konkani/Marathi/English. Fresh graduate route available.',
    ),
    'HP': StateEligibilityCriteria(
      state: 'Himachal Pradesh',
      minAge: 22,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'LLB from recognized university. 3-year practice as advocate (SC, 20-05-2025). SC/ST/OBC relaxation as per state rules. Conducted by HP High Court.',
      languageRequirements: ['Hindi (Compulsory)', 'English'],
      sourceUrl:
          'https://hphighcourt.nic.in/rules/Himachal_Pradesh_Judicial_Service_Rules_2004.pdf',
      sourceLabel: 'Himachal Pradesh Judicial Service Rules, 2004',
      lastVerified: '17-02-2026',
      verificationLevel: VerificationLevel.verified,
      verificationNote:
          'Official HP HC PDF. Age 22–35. Conducted by HP High Court.',
    ),
    'MN': StateEligibilityCriteria(
      state: 'Manipur',
      minAge: null,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'LLB from recognized university. Grade-III: earlier no mandatory practice; 3-year practice now required (SC, 20-05-2025). Grade-I (DJ): 7+ yrs, age 35–45. OBC +3 yrs (to 48), SC/ST +5 yrs (to 50) age relaxation.',
      languageRequirements: ['Manipuri (knowledge required)', 'English'],
      sourceUrl:
          'https://manipur.gov.in/wp-content/uploads/2013/02/manipur-judicial-service-rule-2005.pdf',
      sourceLabel: 'Manipur Judicial Service Rules, 2005 (as amended)',
      lastVerified: '17-02-2026',
      verificationLevel: VerificationLevel.verified,
      verificationNote:
          'Official Manipur Govt PDF. CJ max 35. Manipuri tested at viva-voce. Conducted by Manipur HC.',
    ),
    'ML': StateEligibilityCriteria(
      state: 'Meghalaya',
      minAge: null,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'LLB from recognized university. 3-year practice as advocate required. Grade-I (DJ): 7+ yrs, age 35–45 (SC/ST 48). Working knowledge of Khasi, Jaintia, or Garo required. Compulsory Khasi/Garo paper (2022 amendment).',
      languageRequirements: ['Khasi or Garo (Compulsory paper)', 'English'],
      sourceUrl:
          'https://meglaw.gov.in/rules/Meghalaya%20Judicial%20Service%20Rules%202006%20with%20Amendment%20Rules%202007,%202009,%202012.pdf',
      sourceLabel: 'Meghalaya Judicial Service Rules, 2006 (amended 2007/2009/2012/2022)',
      lastVerified: '17-02-2026',
      verificationLevel: VerificationLevel.verified,
      verificationNote:
          'Official Meghalaya Law Dept PDF. CJ max 35 (SC/ST 38). Khasi/Garo compulsory paper since 2022.',
    ),
    'MZ': StateEligibilityCriteria(
      state: 'Mizoram',
      minAge: null,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'LLB from recognized university. CJ: no mandatory prior practice under 2006 rules; 3-year practice restored (SC, 20-05-2025). DJ: 7+ yrs, age 35–45 (SC/ST 48). Mizo language knowledge (Middle School standard) required.',
      languageRequirements: ['Mizo (Middle School standard)', 'English'],
      sourceUrl:
          'https://mpsc.mizoram.gov.in/uploads/files/mjs-rules.pdf',
      sourceLabel: 'Mizoram Judicial Service Rules, 2006',
      lastVerified: '17-02-2026',
      verificationLevel: VerificationLevel.verified,
      verificationNote:
          'Official MPSC Mizoram PDF. CJ max 35 (SC/ST 40). Mizo language mandatory.',
    ),
    'NL': StateEligibilityCriteria(
      state: 'Nagaland',
      minAge: null,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'LLB from BCI-recognized university + AIBE clearance + license to practice. Knowledge of local Naga tribal dialect (read & write) and Naga Tribal Customary practices required.',
      languageRequirements: ['English', 'Local Naga tribal dialect'],
      sourceUrl:
          'https://jaa.assam.gov.in/storage/article_pdf/si1686135993Nagaland%20Judicial%20Service%20Rules%202006.pdf',
      sourceLabel: 'Nagaland Judicial Service Rules, 2006',
      lastVerified: '17-02-2026',
      verificationLevel: VerificationLevel.verified,
      verificationNote:
          'Official JAA Assam archive PDF. CJ max 35 (SC/ST 38). AIBE + tribal dialect knowledge required.',
    ),
    'SK': StateEligibilityCriteria(
      state: 'Sikkim',
      minAge: null,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'LLB from recognized Indian university. 3-year practice as advocate (certified). Computer knowledge mandatory (tested at viva-voce). Must communicate in Nepali or any state language.',
      languageRequirements: ['Nepali or State language', 'English'],
      sourceUrl:
          'https://hcs.gov.in/hcs/sites/default/files/rules/Judicial%20Service%20Rules.pdf',
      sourceLabel: 'Sikkim Judicial Service Rules, 1975 (as amended)',
      lastVerified: '17-02-2026',
      verificationLevel: VerificationLevel.verified,
      verificationNote:
          'Official HC Sikkim PDF. Max age 35 (amended from 32). 3-yr practice certified. Computer proficiency tested.',
    ),
    'TR': StateEligibilityCriteria(
      state: 'Tripura',
      minAge: 18,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'LLB from recognized university. Grade-III: enrolled advocate, no mandatory prior practice. Grade-I (DJ): 7+ yrs, age 35–45 (SC/ST 48). Bengali proficiency test within 2 years of joining if not studied in school. Bengali paper in exam (translation & essay).',
      languageRequirements: ['Bengali (Compulsory exam paper)', 'English'],
      sourceUrl:
          'https://thc.nic.in/Tripura%20State%20Lagislation%20Rules/Judicial%20Services%20Rules,Tripura%20,%202003%20(As%20Amended%20upto%2013th%20Amendment%20dt.%2007.11.2025%20and%20Notifications%20upto%20dt.%2009.01.2026).pdf',
      sourceLabel: 'Tripura Judicial Service Rules, 2003 (13th Amendment, 2025)',
      lastVerified: '17-02-2026',
      verificationLevel: VerificationLevel.verified,
      verificationNote:
          'Official THC consolidated PDF (up to 13th Amendment). CJ age 18–35 (SC/ST +3 yrs). Bengali tested.',
    ),
  };

  static StateEligibilityCriteria _getDefaultCriteria(String state) {
    final stateName = StateCatalog.displayName(state);
    return StateEligibilityCriteria(
      state: stateName.isEmpty ? state : stateName,
      minAge: null,
      maxAge: null,
      maxAttempts: null,
      practiceRequirement:
          'Minimum 3-year practice requirement may apply as per Supreme Court direction dated 20-05-2025 and state notifications.',
      languageRequirements: [
        'Hindi or English',
        'Regional language may be required',
      ],
      sourceUrl: 'https://www.sci.gov.in',
      sourceLabel: 'Check latest State Judicial Service notification',
      lastVerified: '12-02-2026',
      verificationLevel: VerificationLevel.advisory,
      verificationNote:
          'This is a guidance fallback. Use your state High Court/PSC notification before applying.',
    );
  }

  static RoadmapModel _getRoadmapAfter10th(String stateCode, String stateName) {
    return RoadmapModel(
      state: stateName,
      educationLevel: 'class_10',
      totalDuration: '9-10 years',
      entranceExams: ['CLAT (after 12th)', 'AILET', 'State Law CETs'],
      eligibilityCriteria: getEligibilityCriteria(stateCode),
      eligibilityNotes: _judicialUpdateNote,
      steps: [
        RoadmapStep(
          title: 'Complete 12th Standard',
          titleHi: '12वीं कक्षा पूरी करें',
          description: 'Complete your higher secondary education in any stream',
          descriptionHi: 'किसी भी स्ट्रीम में उच्च माध्यमिक शिक्षा पूरी करें',
          duration: '2 years',
          durationHi: '2 वर्ष',
          order: 1,
          details: [
            'Focus on developing reading and analytical skills',
            'Any stream (Science/Commerce/Arts) is acceptable',
            'Maintain good academic performance',
          ],
          detailsHi: [
            'पढ़ने और विश्लेषणात्मक कौशल विकसित करने पर ध्यान दें',
            'कोई भी स्ट्रीम (विज्ञान/वाणिज्य/कला) स्वीकार्य है',
            'अच्छा शैक्षणिक प्रदर्शन बनाए रखें',
          ],
        ),
        RoadmapStep(
          title: 'Law Entrance Exam',
          titleHi: 'लॉ प्रवेश परीक्षा',
          description: 'Appear for law entrance exams like CLAT, AILET',
          descriptionHi: 'CLAT, AILET जैसी लॉ प्रवेश परीक्षाएं दें',
          duration: '6 months preparation',
          durationHi: '6 महीने तैयारी',
          order: 2,
          details: [
            'CLAT - Common Law Admission Test (for NLUs)',
            'AILET - All India Law Entrance Test (NLU Delhi)',
            'State Law CETs for state universities',
          ],
          detailsHi: [
            'CLAT - कॉमन लॉ एडमिशन टेस्ट (NLU के लिए)',
            'AILET - ऑल इंडिया लॉ एंट्रेंस टेस्ट (NLU दिल्ली)',
            'राज्य लॉ CET राज्य विश्वविद्यालयों के लिए',
          ],
        ),
        RoadmapStep(
          title: '5-Year Integrated LLB',
          titleHi: '5 वर्षीय एकीकृत LLB',
          description:
              'Complete BA LLB / BBA LLB / BSc LLB from a recognized university',
          descriptionHi:
              'किसी मान्यता प्राप्त विश्वविद्यालय से BA LLB / BBA LLB / BSc LLB पूरा करें',
          duration: '5 years',
          durationHi: '5 वर्ष',
          order: 3,
          details: [
            'BCI recognized law degree is mandatory',
            'Focus on Constitutional Law, Criminal Law, Civil Law',
            'Participate in moot courts and legal aid clinics',
          ],
          detailsHi: [
            'BCI मान्यता प्राप्त लॉ डिग्री अनिवार्य है',
            'संवैधानिक कानून, आपराधिक कानून, सिविल कानून पर ध्यान दें',
            'मूट कोर्ट और कानूनी सहायता क्लीनिक में भाग लें',
          ],
        ),
        RoadmapStep(
          title: 'PCS-J Preparation',
          titleHi: 'PCS-J की तैयारी',
          description:
              'Prepare for State Judicial Services (PCS-J) examination',
          descriptionHi: 'राज्य न्यायिक सेवा (PCS-J) परीक्षा की तैयारी करें',
          duration: '1-2 years',
          durationHi: '1-2 वर्ष',
          order: 4,
          details: [
            'Prelims: Objective questions on law',
            'Mains: Descriptive papers on various laws',
            'Interview: Personality and legal knowledge test',
          ],
          detailsHi: [
            'प्रारंभिक: कानून पर वस्तुनिष्ठ प्रश्न',
            'मुख्य: विभिन्न कानूनों पर वर्णनात्मक पेपर',
            'साक्षात्कार: व्यक्तित्व और कानूनी ज्ञान परीक्षण',
          ],
        ),
        RoadmapStep(
          title: 'Become a Judge',
          titleHi: 'न्यायाधीश बनें',
          description: 'Clear PCS-J and join as Civil Judge (Junior Division)',
          descriptionHi:
              'PCS-J पास करें और सिविल जज (जूनियर डिवीजन) के रूप में शामिल हों',
          duration: 'Ongoing career',
          durationHi: 'आजीवन करियर',
          order: 5,
          details: [
            'Start as Civil Judge (Junior Division)',
            'Progress to Senior Division and District Judge',
            'Continuous judicial training and assessments',
          ],
          detailsHi: [
            'सिविल जज (जूनियर डिवीजन) के रूप में शुरू करें',
            'सीनियर डिवीजन और जिला न्यायाधीश तक प्रगति',
            'निरंतर न्यायिक प्रशिक्षण और मूल्यांकन',
          ],
        ),
      ],
    );
  }

  static RoadmapModel _getRoadmapAfter12th(String stateCode, String stateName) {
    // State-specific entrance exams and judicial service exams
    final stateExamData = _getStateExamData(stateCode);

    return RoadmapModel(
      state: stateName,
      educationLevel: 'class_12',
      totalDuration: '7-8 years',
      entranceExams: stateExamData['entranceExams'],
      eligibilityCriteria: getEligibilityCriteria(stateCode),
      eligibilityNotes: _judicialUpdateNote,
      steps: [
        RoadmapStep(
          title: 'Law Entrance Exam',
          titleHi: 'लॉ प्रवेश परीक्षा',
          description:
              'Appear for law entrance exams like CLAT, AILET, or state-specific exams',
          descriptionHi:
              'CLAT, AILET, या राज्य-विशिष्ट परीक्षाओं जैसी लॉ प्रवेश परीक्षाएं दें',
          duration: '6 months preparation',
          durationHi: '6 महीने तैयारी',
          order: 1,
          details: stateExamData['entranceDetails'],
        ),
        RoadmapStep(
          title: '5-Year Integrated LLB',
          titleHi: '5 वर्षीय एकीकृत LLB',
          description: 'Complete BA LLB / BBA LLB / BSc LLB',
          descriptionHi: 'BA LLB / BBA LLB / BSc LLB पूरा करें',
          duration: '5 years',
          durationHi: '5 वर्ष',
          order: 2,
          details: [
            'Get admission in a BCI recognized law college',
            'BA LLB, BBA LLB, or BSc LLB options available',
            'Focus on core subjects and practical training',
          ],
          detailsHi: [
            'BCI मान्यता प्राप्त लॉ कॉलेज में प्रवेश लें',
            'BA LLB, BBA LLB, या BSc LLB विकल्प उपलब्ध',
            'मुख्य विषयों और व्यावहारिक प्रशिक्षण पर ध्यान दें',
          ],
        ),
        RoadmapStep(
          title: 'Internships & Practice',
          titleHi: 'इंटर्नशिप और अभ्यास',
          description: 'Gain practical experience during and after law school',
          descriptionHi:
              'लॉ स्कूल के दौरान और बाद में व्यावहारिक अनुभव प्राप्त करें',
          duration: 'During LLB',
          durationHi: 'LLB के दौरान',
          order: 3,
          details: [
            'Intern with District Courts',
            'Intern with High Court advocates',
            'Work on real cases under supervision',
          ],
          detailsHi: [
            'जिला अदालतों में इंटर्नशिप करें',
            'हाई कोर्ट के वकीलों के साथ इंटर्नशिप',
            'पर्यवेक्षण में वास्तविक मामलों पर काम करें',
          ],
        ),
        RoadmapStep(
          title: stateExamData['judiciaryExamName'],
          titleHi: '${stateExamData['judiciaryExamName']} परीक्षा',
          description: 'Appear for ${stateExamData['judiciaryExamFullName']}',
          descriptionHi:
              '${stateExamData['judiciaryExamFullName']} के लिए उपस्थित हों',
          duration: '1-2 years preparation',
          durationHi: '1-2 वर्ष तैयारी',
          order: 4,
          details: stateExamData['judiciaryExamDetails'],
        ),
        RoadmapStep(
          title: 'Join as Civil Judge',
          titleHi: 'सिविल जज के रूप में शामिल हों',
          description: 'Start your judicial career',
          descriptionHi: 'अपना न्यायिक करियर शुरू करें',
          duration: 'Lifetime career',
          durationHi: 'आजीवन करियर',
          order: 5,
          details: [
            'Posted as Civil Judge (Junior Division)',
            'Handle civil and criminal cases at district level',
            'Promotion based on experience and performance',
          ],
          detailsHi: [
            'सिविल जज (जूनियर डिवीजन) के रूप में पदस्थापित',
            'जिला स्तर पर सिविल और आपराधिक मामलों का संचालन',
            'अनुभव और प्रदर्शन के आधार पर पदोन्नति',
          ],
        ),
      ],
    );
  }

  static RoadmapModel _getRoadmapAfterGraduation(
    String stateCode,
    String stateName,
  ) {
    final stateExamData = _getStateExamData(stateCode);

    return RoadmapModel(
      state: stateName,
      educationLevel: 'graduate',
      totalDuration: '4-5 years',
      entranceExams: ['CLAT (PG)', 'State LLB Entrance', 'University Entrance'],
      eligibilityCriteria: getEligibilityCriteria(stateCode),
      eligibilityNotes: _judicialUpdateNote,
      steps: [
        RoadmapStep(
          title: '3-Year LLB Program',
          titleHi: '3 वर्षीय LLB कार्यक्रम',
          description: 'Enroll in a 3-year LLB program after graduation',
          descriptionHi:
              'स्नातक के बाद 3 वर्षीय LLB कार्यक्रम में नामांकन करें',
          duration: '3 years',
          durationHi: '3 वर्ष',
          order: 1,
          details: [
            'Must have a graduation degree in any discipline',
            'Appear for CLAT (PG) or state LLB entrance exams',
            'Join a BCI recognized law college',
          ],
          detailsHi: [
            'किसी भी विषय में स्नातक डिग्री होनी चाहिए',
            'CLAT (PG) या राज्य LLB प्रवेश परीक्षा दें',
            'BCI मान्यता प्राप्त लॉ कॉलेज में शामिल हों',
          ],
        ),
        RoadmapStep(
          title: 'Court Training',
          titleHi: 'न्यायालय प्रशिक्षण',
          description: 'Gain hands-on experience in courts',
          descriptionHi: 'अदालतों में व्यावहारिक अनुभव प्राप्त करें',
          duration: 'During LLB',
          durationHi: 'LLB के दौरान',
          order: 2,
          details: [
            'Mandatory internships at courts',
            'Observe court proceedings',
            'Assist in drafting legal documents',
          ],
          detailsHi: [
            'अदालतों में अनिवार्य इंटर्नशिप',
            'अदालती कार्यवाही का अवलोकन',
            'कानूनी दस्तावेज़ तैयार करने में सहायता',
          ],
        ),
        RoadmapStep(
          title: 'PCS-J Preparation',
          titleHi: 'PCS-J की तैयारी',
          description: 'Prepare for ${stateExamData['judiciaryExamFullName']}',
          descriptionHi:
              '${stateExamData['judiciaryExamFullName']} की तैयारी करें',
          duration: '1-2 years',
          durationHi: '1-2 वर्ष',
          order: 3,
          details: [
            'Study procedural laws thoroughly',
            'Practice answer writing for Mains',
            'Mock interviews and personality development',
          ],
          detailsHi: [
            'प्रक्रिया संबंधी कानूनों का गहन अध्ययन करें',
            'मुख्य परीक्षा के लिए उत्तर लेखन का अभ्यास करें',
            'मॉक इंटरव्यू और व्यक्तित्व विकास',
          ],
        ),
        RoadmapStep(
          title: 'Clear ${stateExamData['judiciaryExamName']}',
          titleHi: '${stateExamData['judiciaryExamName']} पास करें',
          description: 'Successfully pass all stages of the examination',
          descriptionHi: 'परीक्षा के सभी चरण सफलतापूर्वक पास करें',
          duration: 'Exam cycles',
          durationHi: 'परीक्षा चक्र',
          order: 4,
          details: stateExamData['judiciaryExamDetails'],
        ),
        RoadmapStep(
          title: 'Judicial Officer',
          titleHi: 'न्यायिक अधिकारी',
          description: 'Begin your journey as a judge',
          descriptionHi: 'न्यायाधीश के रूप में अपनी यात्रा शुरू करें',
          duration: 'Career',
          durationHi: 'करियर',
          order: 5,
          details: [
            'Initial posting as Civil Judge (Junior Division)',
            'Training at state judicial academy',
            'Gradual elevation to higher positions',
          ],
          detailsHi: [
            'सिविल जज (जूनियर डिवीजन) के रूप में प्रारंभिक पदस्थापना',
            'राज्य न्यायिक अकादमी में प्रशिक्षण',
            'उच्च पदों पर क्रमिक पदोन्नति',
          ],
        ),
      ],
    );
  }

  // State-specific exam data (guidance + source-backed where available)
  static Map<String, dynamic> _getStateExamData(String stateCode) {
    final stateData = {
      'UP': {
        'entranceExams': ['CLAT', 'AILET', 'State Law Entrance'],
        'entranceDetails': [
          'CLAT - Common Law Admission Test (for 22 NLUs)',
          'AILET - All India Law Entrance Test (NLU Delhi)',
          'UP State Law Entrance for state universities',
        ],
        'judiciaryExamName': 'UP PCS-J Exam',
        'judiciaryExamFullName': 'Uttar Pradesh Judicial Services Examination',
        'judiciaryExamDetails': [
          'Conducted by UP Public Service Commission (UPPSC)',
          'Base rules indicate age and attempt limits; category relaxations are notification-based',
          'Prelims + Mains + Interview pattern',
          'Subject mix generally includes civil law, criminal law, constitutional law, language, and GK',
          'Hindi proficiency compulsory',
          'Always verify latest UPPSC/High Court notification before applying',
        ],
      },
      'MH': {
        'entranceExams': ['CLAT', 'MH-CET Law', 'AILET'],
        'entranceDetails': [
          'CLAT - Common Law Admission Test (for NLUs)',
          'MH-CET Law - Maharashtra State Law Entrance',
          'AILET - All India Law Entrance Test',
        ],
        'judiciaryExamName': 'MPSC Judicial Services',
        'judiciaryExamFullName': 'Maharashtra Judicial Services Examination',
        'judiciaryExamDetails': [
          'Conducted under Maharashtra Judicial Service recruitment notifications',
          'Prelims + Mains + Interview pattern',
          'Age/eligibility differs by recruitment category',
          'Marathi language proficiency is generally required',
          'Always verify latest Maharashtra notice before applying',
        ],
      },
      'MP': {
        'entranceExams': ['CLAT', 'MP Law CET', 'AILET'],
        'entranceDetails': [
          'CLAT - Common Law Admission Test',
          'MP Law CET - Madhya Pradesh Law Entrance',
          'AILET for NLU Delhi',
        ],
        'judiciaryExamName': 'MPCJ Exam',
        'judiciaryExamFullName':
            'Madhya Pradesh Civil Judge (Entry Level) Examination',
        'judiciaryExamDetails': [
          'Conducted by MP High Court',
          'Prelims + Mains + Interview pattern',
          'Hindi or English medium available',
          'Exact age and category relaxations should be checked in latest MPHC advertisement',
        ],
      },
      'RJ': {
        'entranceExams': ['CLAT', 'AILET', 'RU-CET'],
        'entranceDetails': [
          'CLAT - Common Law Admission Test',
          'AILET - All India Law Entrance Test',
          'RU-CET - Rajasthan University Law Entrance',
        ],
        'judiciaryExamName': 'RJS (Raj. Judicial Service)',
        'judiciaryExamFullName': 'Rajasthan Judicial Services Examination',
        'judiciaryExamDetails': [
          'Conducted by Rajasthan High Court',
          'Base rules show direct recruitment age at 23-35 (subject to relaxations)',
          'Prelims + Mains + Interview pattern',
          'Hindi and English proficiency required',
          'Always verify latest Rajasthan HC notification before applying',
        ],
      },
      'DL': {
        'entranceExams': ['CLAT', 'DU LLB Entrance', 'AILET'],
        'entranceDetails': [
          'CLAT - Common Law Admission Test',
          'DU LLB Entrance - Delhi University Law Entrance',
          'AILET - All India Law Entrance Test (NLU Delhi)',
        ],
        'judiciaryExamName': 'Delhi Judicial Service (DJS)',
        'judiciaryExamFullName': 'Delhi Judicial Service Examination',
        'judiciaryExamDetails': [
          'Conducted by Delhi High Court',
          'DJS rules specify maximum age of 32 years (subject to relaxations in notification)',
          'Minimum 3 years legal practice (policy restored by Supreme Court on 20-05-2025)',
          'Prelims + Mains + Interview pattern',
          'English and Hindi both important',
          'Always verify latest Delhi HC notification before applying',
        ],
      },
    };

    return stateData[stateCode] ??
        {
          'entranceExams': ['CLAT', 'AILET', 'State Law Entrance'],
          'entranceDetails': [
            'CLAT - Common Law Admission Test (for 22 NLUs)',
            'AILET - All India Law Entrance Test (NLU Delhi)',
            'State Law CETs for state universities',
          ],
          'judiciaryExamName': 'State Judicial Services Exam',
          'judiciaryExamFullName': 'State Judicial Services Examination',
          'judiciaryExamDetails': [
            'Conducted by State Public Service Commission or High Court',
            'Age, attempts, and practice requirement vary by state',
            'Minimum legal practice may apply as per latest state notification',
            'Prelims: Objective questions on law',
            'Mains: Descriptive papers on various laws',
            'Interview: Personality and legal knowledge test',
          ],
        };
  }
}
