// ignore_for_file: public_member_api_docs, sort_constructors_first
class ErrorModel {
  final int status;
  final String msgAr;
  final String msgEn;
  ErrorModel({
    required this.status,
    required this.msgAr,
    required this.msgEn,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'status': status,
      'msgAr': msgAr,
      'msgEn': msgEn,
    };
  }

  factory ErrorModel.fromJson(Map<String, dynamic> map) {
    return ErrorModel(
      status: map['status'] ?? 0,
      msgAr: map['msgAr'] ?? '',
      msgEn: map['msgEn'] ?? '',
    );
  }
}
