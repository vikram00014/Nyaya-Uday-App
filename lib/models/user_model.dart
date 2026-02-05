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
    );
  }

  // Get rank title based on score
  static String getRankTitle(int score) {
    if (score >= 500) return 'District Judge';
    if (score >= 300) return 'Senior Magistrate';
    if (score >= 150) return 'Junior Judge';
    if (score >= 50) return 'Trainee Magistrate';
    return 'Trainee';
  }
}
