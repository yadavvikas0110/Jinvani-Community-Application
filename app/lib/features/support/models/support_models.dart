class SupportTicket {
  final String? id;
  final String? ref;
  final String subject;
  final String description;
  final String status;
  final DateTime? createdAt;

  const SupportTicket({
    this.id,
    this.ref,
    required this.subject,
    required this.description,
    this.status = 'open',
    this.createdAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) => SupportTicket(
        id: json['id'] as String?,
        ref: json['ref'] as String?,
        subject: json['subject'] as String? ?? '',
        description: json['description'] as String? ?? '',
        status: json['status'] as String? ?? 'open',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (ref != null) 'ref': ref,
        'subject': subject,
        'description': description,
        'status': status,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };
}

class FeedbackSubmission {
  final String? id;
  final String subject;
  final String description;
  final DateTime? createdAt;

  const FeedbackSubmission({
    this.id,
    required this.subject,
    required this.description,
    this.createdAt,
  });

  factory FeedbackSubmission.fromJson(Map<String, dynamic> json) =>
      FeedbackSubmission(
        id: json['id'] as String?,
        subject: json['subject'] as String? ?? '',
        description: json['description'] as String? ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'subject': subject,
        'description': description,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };
}
