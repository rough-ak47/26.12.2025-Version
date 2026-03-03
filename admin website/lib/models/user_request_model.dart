class UserRequest {
  final String id;
  final String userName;
  final String requestType;
  final DateTime date;
  final String status; // 'pending', 'approved', 'declined', 'assigned'
  final String? location;
  final String? details;
  final String? volunteerId;
  final String? volunteerName;

  UserRequest({
    required this.id,
    required this.userName,
    required this.requestType,
    required this.date,
    this.status = 'pending',
    this.location,
    this.details,
    this.volunteerId,
    this.volunteerName,
  });
}

