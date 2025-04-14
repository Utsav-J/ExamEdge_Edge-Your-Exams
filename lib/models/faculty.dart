class Faculty {
  final String id;
  final String name;
  final String title;
  final String department;
  final List<String> expertise;
  final int experienceYears;
  final double rating;
  final String satisfactionRate;
  final double sessionPrice;
  final List<DateTime> freeSessionsAvailable;
  final String contactEmail;
  final String image;

  Faculty({
    required this.id,
    required this.name,
    required this.title,
    required this.department,
    required this.expertise,
    required this.experienceYears,
    required this.rating,
    required this.satisfactionRate,
    required this.sessionPrice,
    required this.freeSessionsAvailable,
    required this.contactEmail,
    required this.image,
  });

  factory Faculty.fromJson(Map<String, dynamic> json) {
    return Faculty(
      id: json['id'] as String,
      name: json['name'] as String,
      title: json['title'] as String,
      department: json['department'] as String,
      expertise: List<String>.from(json['expertise']),
      experienceYears: json['experience_years'] as int,
      rating: json['rating'] as double,
      satisfactionRate: json['satisfaction_rate'] as String,
      sessionPrice: json['session_price'] as double,
      freeSessionsAvailable: (json['free_sessions_available'] as List)
          .map((date) => DateTime.parse(date as String))
          .toList(),
      contactEmail: json['contact_email'] as String,
      image: json['image'] as String,
    );
  }
}
