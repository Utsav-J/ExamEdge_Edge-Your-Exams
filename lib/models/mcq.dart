class MCQ {
  final String question;
  final List<String> options;
  final String answer;

  MCQ({
    required this.question,
    required this.options,
    required this.answer,
  });

  factory MCQ.fromJson(Map<String, dynamic> json) {
    return MCQ(
      question: json['question'] as String,
      options: List<String>.from(json['options']),
      answer: json['answer'] as String,
    );
  }
}
