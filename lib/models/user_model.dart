class UserModel {
  final String? id;
  final String state;
  final String educationLevel;
  final String preferredLanguage;
  final int totalScore;
  final int casesCompleted;
  final List<String> badges;
  final String rank;
  final DateTime? createdAt;
  // New fields for better personalization
  final int? age;
  final String? category; // General, SC, ST, OBC, EWS
  final String? gender; // Male, Female, Other
  final double? annualIncome; // For legal aid eligibility
  final bool? hasDisability; // PWD status

  UserModel({
    this.id,
    required this.state,
    required this.educationLevel,
    this.preferredLanguage = 'en',
    this.totalScore = 0,
    this.casesCompleted = 0,
    this.badges = const [],
    this.rank = 'Trainee',
    this.createdAt,
    this.age,
    this.category,
    this.gender,
    this.annualIncome,
    this.hasDisability,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      state: json['state'] ?? '',
      educationLevel: json['education_level'] ?? '',
      preferredLanguage: json['preferred_language'] ?? 'en',
      totalScore: json['total_score'] ?? 0,
      casesCompleted: json['cases_completed'] ?? 0,
      badges: List<String>.from(json['badges'] ?? []),
      rank: json['rank'] ?? 'Trainee',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      age: json['age'],
      category: json['category'],
      gender: json['gender'],
      annualIncome: (json['annual_income'] as num?)?.toDouble(),
      hasDisability: json['has_disability'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'state': state,
      'education_level': educationLevel,
      'preferred_language': preferredLanguage,
      'total_score': totalScore,
      'cases_completed': casesCompleted,
      'badges': badges,
      'rank': rank,
      if (age != null) 'age': age,
      if (category != null) 'category': category,
      if (gender != null) 'gender': gender,
      if (annualIncome != null) 'annual_income': annualIncome,
      if (hasDisability != null) 'has_disability': hasDisability,
    };
  }

  UserModel copyWith({
    String? id,
    String? state,
    String? educationLevel,
    String? preferredLanguage,
    int? totalScore,
    int? casesCompleted,
    List<String>? badges,
    String? rank,
    int? age,
    String? category,
    String? gender,
    double? annualIncome,
    bool? hasDisability,
  }) {
    return UserModel(
      id: id ?? this.id,
      state: state ?? this.state,
      educationLevel: educationLevel ?? this.educationLevel,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      totalScore: totalScore ?? this.totalScore,
      casesCompleted: casesCompleted ?? this.casesCompleted,
      badges: badges ?? this.badges,
      rank: rank ?? this.rank,
      createdAt: createdAt,
      age: age ?? this.age,
      category: category ?? this.category,
      gender: gender ?? this.gender,
      annualIncome: annualIncome ?? this.annualIncome,
      hasDisability: hasDisability ?? this.hasDisability,
    );
  }

  // Get rank title based on score (aligned with dossier)
  static String getRankTitle(int score) {
    if (score >= 750) return 'High Court Judge';
    if (score >= 500) return 'District Judge';
    if (score >= 300) return 'Civil Judge';
    if (score >= 150) return 'Junior Advocate';
    if (score >= 50) return 'Legal Intern';
    return 'Trainee';
  }
}
