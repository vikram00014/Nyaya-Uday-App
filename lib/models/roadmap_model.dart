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
          'Minimum 3-year practice requirement has been restored prospectively (Supreme Court, 20-05-2025).',
      languageRequirements: [
        'Hindi (Compulsory)',
        'English (Optional for answers)',
      ],
      sourceUrl:
          'https://www.allahabadhighcourt.in/event/UPJS%20Rules,%202001English.pdf',
      sourceLabel: 'UP Judicial Service Rules, 2001 (Rule 10, Rule 12)',
      lastVerified: '12-02-2026',
      verificationLevel: VerificationLevel.verified,
      verificationNote:
          'Rulebook values are shown. Latest recruitment notification always prevails.',
    ),
    'MP': StateEligibilityCriteria(
      state: 'Madhya Pradesh',
      minAge: null,
      maxAge: null,
      maxAttempts: null,
      practiceRequirement:
          'Minimum 3-year practice requirement has been restored prospectively (Supreme Court, 20-05-2025).',
      languageRequirements: ['Hindi or English'],
      sourceUrl: 'https://mphc.gov.in',
      sourceLabel: 'MP High Court recruitment notifications',
      lastVerified: '12-02-2026',
      verificationLevel: VerificationLevel.advisory,
      verificationNote:
          'Exact limits may vary by latest MPHC advertisement and category relaxations.',
    ),
    'MH': StateEligibilityCriteria(
      state: 'Maharashtra',
      minAge: 21,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'Advocate category generally requires practice as per state rules. Confirm current notification.',
      languageRequirements: ['Marathi (Compulsory)', 'English'],
      sourceUrl:
          'https://thc.nic.in/Central%20Governmental%20Acts/Central%20Civil%20Acts/MAHARASHTRA%20JUDICIAL%20SERVICE%20RULES,%202008.pdf',
      sourceLabel: 'Maharashtra Judicial Service Rules, 2008 (as amended)',
      lastVerified: '12-02-2026',
      verificationLevel: VerificationLevel.verified,
      verificationNote:
          'Age 21-35 from official rule PDF. Category-wise relaxations and recruitment details may vary by latest notification.',
    ),
    'RJ': StateEligibilityCriteria(
      state: 'Rajasthan',
      minAge: 23,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'Minimum 3-year practice requirement has been restored prospectively (Supreme Court, 20-05-2025).',
      languageRequirements: ['Hindi', 'English'],
      sourceUrl: 'https://hcraj.nic.in/hcraj/Allfiles/rjs-rules-2010.pdf',
      sourceLabel:
          'Rajasthan Judicial Service Rules, 2010 (Rule 15, direct recruitment)',
      lastVerified: '12-02-2026',
      verificationLevel: VerificationLevel.verified,
      verificationNote:
          'Base age band from rules; reservation/other relaxations depend on notification.',
    ),
    'DL': StateEligibilityCriteria(
      state: 'Delhi',
      minAge: null,
      maxAge: 32,
      maxAttempts: null,
      practiceRequirement:
          'Minimum 3-year practice requirement has been restored prospectively (Supreme Court, 20-05-2025).',
      languageRequirements: ['English', 'Hindi'],
      sourceUrl:
          'https://session.delhi.gov.in/session/delhi-judicial-service-rules-1970',
      sourceLabel: 'Delhi Judicial Service Rules, 1970 (Rule 14)',
      lastVerified: '12-02-2026',
      verificationLevel: VerificationLevel.verified,
      verificationNote:
          'Max age and advocate qualification come from DJS rules; latest exam notice should be checked.',
    ),
    'BR': StateEligibilityCriteria(
      state: 'Bihar',
      minAge: 22,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'Minimum 3-year practice requirement restored prospectively (Supreme Court, 20-05-2025). LLB degree from recognized university.',
      languageRequirements: ['Hindi (Compulsory)', 'English'],
      sourceUrl: 'https://patnahighcourt.gov.in',
      sourceLabel:
          'Bihar Judicial Service (Recruitment) Rules, 1955 (as amended)',
      lastVerified: '12-02-2026',
      verificationLevel: VerificationLevel.advisory,
      verificationNote:
          'Age band sourced from past BPSC notifications. Always verify latest Bihar HC/BPSC advertisement.',
    ),
    'GJ': StateEligibilityCriteria(
      state: 'Gujarat',
      minAge: 23,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'Minimum 3-year practice requirement restored prospectively (Supreme Court, 20-05-2025). Must be enrolled as advocate.',
      languageRequirements: ['Gujarati (Compulsory)', 'English', 'Hindi'],
      sourceUrl: 'https://gujarathighcourt.nic.in',
      sourceLabel: 'Gujarat State Judicial Service Rules',
      lastVerified: '12-02-2026',
      verificationLevel: VerificationLevel.advisory,
      verificationNote:
          'Age limits from previous notifications. SC/ST: 5 years relaxation, OBC: 3 years. Verify latest Gujarat HC recruitment notice.',
    ),
    'KA': StateEligibilityCriteria(
      state: 'Karnataka',
      minAge: 21,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'Must be enrolled as advocate. Practice requirement may apply per latest notification.',
      languageRequirements: ['Kannada (Compulsory)', 'English'],
      sourceUrl: 'https://karnatakajudiciary.kar.nic.in',
      sourceLabel: 'Karnataka Judicial Service (Recruitment) Rules',
      lastVerified: '12-02-2026',
      verificationLevel: VerificationLevel.advisory,
      verificationNote:
          'Conducted by Karnataka PSC. Kannada knowledge is mandatory. Verify latest KPSC advertisement.',
    ),
    'KL': StateEligibilityCriteria(
      state: 'Kerala',
      minAge: 22,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'Must be enrolled advocate. 3-year practice requirement may apply per Supreme Court direction.',
      languageRequirements: ['Malayalam (Compulsory)', 'English'],
      sourceUrl: 'https://highcourtofkerala.nic.in',
      sourceLabel: 'Kerala Judicial Service Rules',
      lastVerified: '12-02-2026',
      verificationLevel: VerificationLevel.advisory,
      verificationNote:
          'Conducted by Kerala PSC. Age relaxation for reserved categories as per rules. Verify latest notification.',
    ),
    'TN': StateEligibilityCriteria(
      state: 'Tamil Nadu',
      minAge: 21,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'Must be enrolled advocate. Practice requirement per state/SC direction applies.',
      languageRequirements: ['Tamil (Compulsory)', 'English'],
      sourceUrl: 'https://www.mhc.tn.gov.in',
      sourceLabel: 'Tamil Nadu State Judicial Service Rules',
      lastVerified: '12-02-2026',
      verificationLevel: VerificationLevel.advisory,
      verificationNote:
          'Conducted by Madras High Court. Tamil proficiency mandatory. Verify latest HC notification.',
    ),
    'WB': StateEligibilityCriteria(
      state: 'West Bengal',
      minAge: 23,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'Must be enrolled advocate. 3-year practice requirement may apply per Supreme Court direction.',
      languageRequirements: ['Bengali', 'English'],
      sourceUrl: 'https://calcuttahighcourt.gov.in',
      sourceLabel: 'West Bengal Judicial Service Rules',
      lastVerified: '12-02-2026',
      verificationLevel: VerificationLevel.advisory,
      verificationNote:
          'Conducted by West Bengal PSC. Bengali knowledge is important. Verify latest WBPSC/HC advertisement.',
    ),
    'HR': StateEligibilityCriteria(
      state: 'Haryana',
      minAge: 22,
      maxAge: 42,
      maxAttempts: null,
      practiceRequirement:
          'Minimum 3-year practice as advocate. Must be an enrolled advocate of any Bar Council in India.',
      languageRequirements: ['Hindi (Compulsory)', 'English'],
      sourceUrl: 'https://highcourtchd.gov.in',
      sourceLabel: 'Haryana Superior Judicial Service / HCS(J) Rules',
      lastVerified: '12-02-2026',
      verificationLevel: VerificationLevel.advisory,
      verificationNote:
          'Age limits from previous Haryana PSC notifications. Conducted by Punjab & Haryana HC. Verify latest notice.',
    ),
    'PB': StateEligibilityCriteria(
      state: 'Punjab',
      minAge: 22,
      maxAge: 42,
      maxAttempts: null,
      practiceRequirement: 'Minimum 3-year practice as advocate required.',
      languageRequirements: ['Punjabi', 'Hindi', 'English'],
      sourceUrl: 'https://highcourtchd.gov.in',
      sourceLabel: 'Punjab Superior Judicial Service Rules',
      lastVerified: '12-02-2026',
      verificationLevel: VerificationLevel.advisory,
      verificationNote:
          'Conducted by Punjab & Haryana High Court. Punjabi knowledge may be required. Verify latest notification.',
    ),
    'JH': StateEligibilityCriteria(
      state: 'Jharkhand',
      minAge: 22,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'Must be enrolled advocate. Practice requirement per state rules and SC direction.',
      languageRequirements: ['Hindi (Compulsory)', 'English'],
      sourceUrl: 'https://jharkhandhighcourt.nic.in',
      sourceLabel: 'Jharkhand Judicial Service Rules',
      lastVerified: '12-02-2026',
      verificationLevel: VerificationLevel.advisory,
      verificationNote:
          'Conducted by Jharkhand HC/JPSC. Verify latest recruitment advertisement for current rules.',
    ),
    'CG': StateEligibilityCriteria(
      state: 'Chhattisgarh',
      minAge: 22,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'Must be enrolled advocate. 3-year practice requirement may apply.',
      languageRequirements: ['Hindi (Compulsory)', 'English'],
      sourceUrl: 'https://highcourt.cg.gov.in',
      sourceLabel: 'Chhattisgarh Judicial Service Rules',
      lastVerified: '12-02-2026',
      verificationLevel: VerificationLevel.advisory,
      verificationNote:
          'Conducted by Chhattisgarh HC. Verify latest recruitment notification for exact eligibility.',
    ),
    'OD': StateEligibilityCriteria(
      state: 'Odisha',
      minAge: 21,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'Must be enrolled advocate. Practice requirement per state rules applies.',
      languageRequirements: ['Odia', 'English'],
      sourceUrl: 'https://orissahighcourt.nic.in',
      sourceLabel: 'Odisha Judicial Service Rules',
      lastVerified: '12-02-2026',
      verificationLevel: VerificationLevel.advisory,
      verificationNote:
          'Conducted by Odisha PSC. Odia knowledge is generally required. Verify latest OPSC/HC notification.',
    ),
    'AP': StateEligibilityCriteria(
      state: 'Andhra Pradesh',
      minAge: 22,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'Must be enrolled advocate with practice as per state rules.',
      languageRequirements: ['Telugu (Compulsory)', 'English'],
      sourceUrl: 'https://aphc.gov.in',
      sourceLabel: 'AP State Judicial Service Rules',
      lastVerified: '12-02-2026',
      verificationLevel: VerificationLevel.advisory,
      verificationNote:
          'Conducted by APPSC/AP HC. Telugu proficiency is mandatory. Verify latest notification.',
    ),
    'TS': StateEligibilityCriteria(
      state: 'Telangana',
      minAge: 22,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'Must be enrolled advocate. Practice requirement per state rules applies.',
      languageRequirements: ['Telugu (Compulsory)', 'English'],
      sourceUrl: 'https://tshc.gov.in',
      sourceLabel: 'Telangana State Judicial Service Rules',
      lastVerified: '12-02-2026',
      verificationLevel: VerificationLevel.advisory,
      verificationNote:
          'Conducted by TSPSC/Telangana HC. Telugu proficiency mandatory. Verify latest notification.',
    ),
    'AS': StateEligibilityCriteria(
      state: 'Assam',
      minAge: 21,
      maxAge: 38,
      maxAttempts: null,
      practiceRequirement:
          'Must be enrolled advocate. Practice requirement may apply per latest notification.',
      languageRequirements: ['Assamese', 'English'],
      sourceUrl: 'https://ghconline.gov.in',
      sourceLabel: 'Assam Judicial Service Rules',
      lastVerified: '12-02-2026',
      verificationLevel: VerificationLevel.advisory,
      verificationNote:
          'Conducted under Gauhati HC. Covers NE states. Verify latest Assam PSC/HC notification.',
    ),
    'UK': StateEligibilityCriteria(
      state: 'Uttarakhand',
      minAge: 22,
      maxAge: 35,
      maxAttempts: null,
      practiceRequirement:
          'Must be enrolled advocate. 3-year practice requirement may apply per SC direction.',
      languageRequirements: ['Hindi (Compulsory)', 'English'],
      sourceUrl: 'https://highcourtofuttarakhand.gov.in',
      sourceLabel: 'Uttarakhand Judicial Service Rules',
      lastVerified: '12-02-2026',
      verificationLevel: VerificationLevel.advisory,
      verificationNote:
          'Conducted by Uttarakhand HC/UKPSC. Verify latest official notification.',
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
