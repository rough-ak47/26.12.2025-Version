class StatisticsModel {
  final double totalWasteCollected;
  final int requestsCompleted;
  final int activeRequests;
  final int totalUsers;

  StatisticsModel({
    required this.totalWasteCollected,
    required this.requestsCompleted,
    required this.activeRequests,
    required this.totalUsers,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      totalWasteCollected: (json['totalWasteCollected'] ?? 0).toDouble(),
      requestsCompleted: json['requestsCompleted'] ?? 0,
      activeRequests: json['activeRequests'] ?? 0,
      totalUsers: json['totalUsers'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalWasteCollected': totalWasteCollected,
      'requestsCompleted': requestsCompleted,
      'activeRequests': activeRequests,
      'totalUsers': totalUsers,
    };
  }
}
