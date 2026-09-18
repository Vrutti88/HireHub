import '../core/utils/safe_parsers.dart';

class ReviewModel {
  final String id;
  final String companyId;
  final String authorTitle;
  final double rating;
  final String reviewText;
  final String pros;
  final String cons;
  final DateTime date;

  const ReviewModel({
    required this.id,
    required this.companyId,
    required this.authorTitle,
    required this.rating,
    required this.reviewText,
    required this.pros,
    required this.cons,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'companyId': companyId,
      'authorTitle': authorTitle,
      'rating': rating,
      'reviewText': reviewText,
      'pros': pros,
      'cons': cons,
      'date': date.toIso8601String(),
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return ReviewModel(
      id: id ?? SafeParsers.string(map['id']),
      companyId: SafeParsers.string(map['companyId']),
      authorTitle: SafeParsers.string(map['authorTitle'], 'Employee'),
      rating: SafeParsers.doubleVal(map['rating'], 4.0),
      reviewText: SafeParsers.string(map['reviewText']),
      pros: SafeParsers.string(map['pros']),
      cons: SafeParsers.string(map['cons']),
      date: SafeParsers.dateTime(map['date']),
    );
  }
}
