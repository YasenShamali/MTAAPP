class RequestMedia {
  final String id;
  final String offerId;
  final String uploadedBy;
  final String stage;
  final String imageUrl;
  final String note;
  final DateTime createdAt;

  RequestMedia({
    required this.id,
    required this.offerId,
    required this.uploadedBy,
    required this.stage,
    required this.imageUrl,
    required this.note,
    required this.createdAt,
  });

  factory RequestMedia.fromJson(Map<String, dynamic> json) {
    return RequestMedia(
      id: json['id'] as String,
      offerId: json['offer_id'] as String,
      uploadedBy: json['uploaded_by'] as String,
      stage: json['stage'] as String,
      imageUrl: json['image_url'] as String,
      note: json['note'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
