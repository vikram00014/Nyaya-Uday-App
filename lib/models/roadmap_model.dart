class RoadmapStep {
  final String title;
  final String description;
  final String duration;
  final int order;
  final bool isCompleted;
  final List<String> details;

  RoadmapStep({
    required this.title,
    required this.description,
    required this.duration,
    required this.order,
    this.isCompleted = false,
    this.details = const [],
  });

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

// State-specific eligibility criteria (verifiable)
class StateEligibilityCriteria {
  final String state;
  final int minAge;
  final int maxAge;
  final int maxAttempts;
  final List<String> languageRequirements;
  final String sourceUrl;
  final String lastVerified; // DD-MM-YYYY

  StateEligibilityCriteria({
    required this.state,
    required this.minAge,
    required this.maxAge,
    required this.maxAttempts,
    required this.languageRequirements,
    required this.sourceUrl,
    required this.lastVerified,
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
  static RoadmapModel getDefaultRoadmap(String state, String educationLevel) {
    switch (educationLevel) {
      case 'class_10':
        return _getRoadmapAfter10th(state);
      case 'class_12':
        return _getRoadmapAfter12th(state);
      case 'graduate':
        return _getRoadmapAfterGraduation(state);
      default:
        return _getRoadmapAfter12th(state);
    }
  }

  // Get state-specific eligibility criteria (verifiable)
  static StateEligibilityCriteria getEligibilityCriteria(String state) {
    // Based on official High Court notifications and BCI norms
    final criteria = _stateEligibilityMap[state.toUpperCase()];
    return criteria ?? _getDefaultCriteria(state);
  }

  static final Map<String, StateEligibilityCriteria> _stateEligibilityMap = {
    'UP': StateEligibilityCriteria(
      state: 'Uttar Pradesh',
      minAge: 21,
      maxAge: 35,
      maxAttempts: 0, // No limit
      languageRequirements: [
        'Hindi (Compulsory)',
        'English (Optional for answers)',
      ],
      sourceUrl: 'http://allahabadhighcourt.in',
      lastVerified: '01-02-2026',
    ),
    'MP': StateEligibilityCriteria(
      state: 'Madhya Pradesh',
      minAge: 21,
      maxAge: 35,
      maxAttempts: 0,
      languageRequirements: ['Hindi or English'],
      sourceUrl: 'https://mphc.gov.in',
      lastVerified: '01-02-2026',
    ),
    'MH': StateEligibilityCriteria(
      state: 'Maharashtra',
      minAge: 21,
      maxAge: 35,
      maxAttempts: 0,
      languageRequirements: ['Marathi (Compulsory)', 'English'],
      sourceUrl: 'https://bombayhighcourt.nic.in',
      lastVerified: '01-02-2026',
    ),
    'RJ': StateEligibilityCriteria(
      state: 'Rajasthan',
      minAge: 21,
      maxAge: 35,
      maxAttempts: 0,
      languageRequirements: ['Hindi', 'English'],
      sourceUrl: 'https://hcraj.nic.in',
      lastVerified: '01-02-2026',
    ),
    'DL': StateEligibilityCriteria(
      state: 'Delhi',
      minAge: 21,
      maxAge: 32,
      maxAttempts: 0,
      languageRequirements: ['English', 'Hindi'],
      sourceUrl: 'https://delhihighcourt.nic.in',
      lastVerified: '01-02-2026',
    ),
  };

  static StateEligibilityCriteria _getDefaultCriteria(String state) {
    return StateEligibilityCriteria(
      state: state,
      minAge: 21,
      maxAge: 35,
      maxAttempts: 0,
      languageRequirements: [
        'Hindi or English',
        'Regional language may be required',
      ],
      sourceUrl: 'https://bci.nic.in',
      lastVerified: '01-02-2026',
    );
  }

  static RoadmapModel _getRoadmapAfter10th(String state) {
    return RoadmapModel(
      state: state,
      educationLevel: 'class_10',
      totalDuration: '9-10 years',
      entranceExams: ['CLAT (after 12th)', 'AILET', 'State Law CETs'],
      eligibilityCriteria: getEligibilityCriteria(state),
      steps: [
        RoadmapStep(
          title: 'Complete 12th Standard',
          description: 'Complete your higher secondary education in any stream',
          duration: '2 years',
          order: 1,
          details: [
            'Focus on developing reading and analytical skills',
            'Any stream (Science/Commerce/Arts) is acceptable',
            'Maintain good academic performance',
          ],
        ),
        RoadmapStep(
          title: 'Law Entrance Exam',
          description: 'Appear for law entrance exams like CLAT, AILET',
          duration: '6 months preparation',
          order: 2,
          details: [
            'CLAT - Common Law Admission Test (for NLUs)',
            'AILET - All India Law Entrance Test (NLU Delhi)',
            'State Law CETs for state universities',
          ],
        ),
        RoadmapStep(
          title: '5-Year Integrated LLB',
          description:
              'Complete BA LLB / BBA LLB / BSc LLB from a recognized university',
          duration: '5 years',
          order: 3,
          details: [
            'BCI recognized law degree is mandatory',
            'Focus on Constitutional Law, Criminal Law, Civil Law',
            'Participate in moot courts and legal aid clinics',
          ],
        ),
        RoadmapStep(
          title: 'PCS-J Preparation',
          description:
              'Prepare for State Judicial Services (PCS-J) examination',
          duration: '1-2 years',
          order: 4,
          details: [
            'Prelims: Objective questions on law',
            'Mains: Descriptive papers on various laws',
            'Interview: Personality and legal knowledge test',
          ],
        ),
        RoadmapStep(
          title: 'Become a Judge',
          description: 'Clear PCS-J and join as Civil Judge (Junior Division)',
          duration: 'Ongoing career',
          order: 5,
          details: [
            'Start as Civil Judge (Junior Division)',
            'Progress to Senior Division and District Judge',
            'Continuous judicial training and assessments',
          ],
        ),
      ],
    );
  }

  static RoadmapModel _getRoadmapAfter12th(String state) {
    // State-specific entrance exams and judicial service exams
    final stateExamData = _getStateExamData(state);

    return RoadmapModel(
      state: state,
      educationLevel: 'class_12',
      totalDuration: '7-8 years',
      entranceExams: stateExamData['entranceExams'],
      eligibilityCriteria: getEligibilityCriteria(state),
      steps: [
        RoadmapStep(
          title: 'Law Entrance Exam',
          description:
              'Appear for law entrance exams like CLAT, AILET, or state-specific exams',
          duration: '6 months preparation',
          order: 1,
          details: stateExamData['entranceDetails'],
        ),
        RoadmapStep(
          title: '5-Year Integrated LLB',
          description: 'Complete BA LLB / BBA LLB / BSc LLB',
          duration: '5 years',
          order: 2,
          details: [
            'Get admission in a BCI recognized law college',
            'BA LLB, BBA LLB, or BSc LLB options available',
            'Focus on core subjects and practical training',
          ],
        ),
        RoadmapStep(
          title: 'Internships & Practice',
          description: 'Gain practical experience during and after law school',
          duration: 'During LLB',
          order: 3,
          details: [
            'Intern with District Courts',
            'Intern with High Court advocates',
            'Work on real cases under supervision',
          ],
        ),
        RoadmapStep(
          title: stateExamData['judiciaryExamName'],
          description: 'Appear for ${stateExamData['judiciaryExamFullName']}',
          duration: '1-2 years preparation',
          order: 4,
          details: stateExamData['judiciaryExamDetails'],
        ),
        RoadmapStep(
          title: 'Join as Civil Judge',
          description: 'Start your judicial career',
          duration: 'Lifetime career',
          order: 5,
          details: [
            'Posted as Civil Judge (Junior Division)',
            'Handle civil and criminal cases at district level',
            'Promotion based on experience and performance',
          ],
        ),
      ],
    );
  }

  static RoadmapModel _getRoadmapAfterGraduation(String state) {
    final stateExamData = _getStateExamData(state);

    return RoadmapModel(
      state: state,
      educationLevel: 'graduate',
      totalDuration: '4-5 years',
      entranceExams: ['CLAT (PG)', 'State LLB Entrance', 'University Entrance'],
      eligibilityCriteria: getEligibilityCriteria(state),
      steps: [
        RoadmapStep(
          title: '3-Year LLB Program',
          description: 'Enroll in a 3-year LLB program after graduation',
          duration: '3 years',
          order: 1,
          details: [
            'Must have a graduation degree in any discipline',
            'Appear for CLAT (PG) or state LLB entrance exams',
            'Join a BCI recognized law college',
          ],
        ),
        RoadmapStep(
          title: 'Court Training',
          description: 'Gain hands-on experience in courts',
          duration: 'During LLB',
          order: 2,
          details: [
            'Mandatory internships at courts',
            'Observe court proceedings',
            'Assist in drafting legal documents',
          ],
        ),
        RoadmapStep(
          title: 'PCS-J Preparation',
          description: 'Prepare for ${stateExamData['judiciaryExamFullName']}',
          duration: '1-2 years',
          order: 3,
          details: [
            'Study procedural laws thoroughly',
            'Practice answer writing for Mains',
            'Mock interviews and personality development',
          ],
        ),
        RoadmapStep(
          title: 'Clear ${stateExamData['judiciaryExamName']}',
          description: 'Successfully pass all stages of the examination',
          duration: 'Exam cycles',
          order: 4,
          details: stateExamData['judiciaryExamDetails'],
        ),
        RoadmapStep(
          title: 'Judicial Officer',
          description: 'Begin your journey as a judge',
          duration: 'Career',
          order: 5,
          details: [
            'Initial posting as Civil Judge (Junior Division)',
            'Training at state judicial academy',
            'Gradual elevation to higher positions',
          ],
        ),
      ],
    );
  }

  // State-specific exam data (authentic)
  static Map<String, dynamic> _getStateExamData(String state) {
    final stateData = {
      'Uttar Pradesh': {
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
          'Age: 21-35 years (SC/ST: +5 years, OBC: +3 years)',
          'Prelims: 150 MCQs (2 hours)',
          'Mains: 4 papers (CPC, CrPC, Evidence, Constitutional Law)',
          'Interview: Personality test by High Court panel',
          'Hindi proficiency compulsory',
        ],
      },
      'Maharashtra': {
        'entranceExams': ['CLAT', 'MH-CET Law', 'AILET'],
        'entranceDetails': [
          'CLAT - Common Law Admission Test (for NLUs)',
          'MH-CET Law - Maharashtra State Law Entrance',
          'AILET - All India Law Entrance Test',
        ],
        'judiciaryExamName': 'MPSC Judicial Services',
        'judiciaryExamFullName': 'Maharashtra Judicial Services Examination',
        'judiciaryExamDetails': [
          'Conducted by Maharashtra Public Service Commission (MPSC)',
          'Age: 21-35 years (with relaxations)',
          'Prelims: 200 MCQs on law subjects',
          'Mains: 6 papers (substantive and procedural law)',
          'Marathi language proficiency required',
          'Interview by Bombay High Court judges',
        ],
      },
      'Madhya Pradesh': {
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
          'Age: 21-35 years',
          'Prelims: 100 objective questions',
          'Mains: 4 papers on core legal subjects',
          'Interview: Final selection by HC panel',
          'Hindi or English medium available',
        ],
      },
      'Rajasthan': {
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
          'Age: 21-35 years (with relaxations)',
          'Prelims: 200 MCQs (3 hours)',
          'Mains: 5 papers (substantive law, procedural law)',
          'Interview: Final round',
          'Hindi and English proficiency required',
        ],
      },
      'Delhi': {
        'entranceExams': ['CLAT', 'DU LLB Entrance', 'AILET'],
        'entranceDetails': [
          'CLAT - Common Law Admission Test',
          'DU LLB Entrance - Delhi University Law Entrance',
          'AILET - All India Law Entrance Test (NLU Delhi)',
        ],
        'judiciaryExamName': 'Delhi Judicial Services',
        'judiciaryExamFullName': 'Delhi Higher Judicial Services Examination',
        'judiciaryExamDetails': [
          'Conducted by Delhi Public Service Commission (DSPSC)',
          'Age: 21-32 years',
          'Prelims: 200 MCQs',
          'Mains: 4 papers on law',
          'Interview by Delhi High Court',
          'English and Hindi both important',
        ],
      },
    };

    return stateData[state] ??
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
            'Age: Generally 21-35 years (varies by state)',
            'Prelims: Objective questions on law',
            'Mains: Descriptive papers on various laws',
            'Interview: Personality and legal knowledge test',
          ],
        };
  }
}
