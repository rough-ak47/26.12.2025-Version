class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String status; // 'active', 'suspended', 'banned'
  final int comments;
  final int reviews;
  final int reports;
  final String? profileImageUrl;
  final List<String> assignedRequestIds;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.comments,
    required this.reviews,
    required this.reports,
    this.profileImageUrl,
    this.assignedRequestIds = const [],
  });
}

