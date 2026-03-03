class RequestModel {
  final String id;
  final String itemType;
  final String status;
  final DateTime createdAt;
  final String? imageUrl;
  final String address;
  final String location;
  final List<StatusUpdate> statusUpdates;

  RequestModel({
    required this.id,
    required this.itemType,
    required this.status,
    required this.createdAt,
    this.imageUrl,
    required this.address,
    required this.location,
    this.statusUpdates = const [],
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: json['id'],
      itemType: json['itemType'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      imageUrl: json['imageUrl'],
      address: json['address'],
      location: json['location'],
      statusUpdates: (json['statusUpdates'] as List?)
          ?.map((update) => StatusUpdate.fromJson(update))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemType': itemType,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'imageUrl': imageUrl,
      'address': address,
      'location': location,
      'statusUpdates': statusUpdates.map((update) => update.toJson()).toList(),
    };
  }
}

class StatusUpdate {
  final String status;
  final DateTime timestamp;
  final String? description;

  StatusUpdate({
    required this.status,
    required this.timestamp,
    this.description,
  });

  factory StatusUpdate.fromJson(Map<String, dynamic> json) {
    return StatusUpdate(
      status: json['status'],
      timestamp: DateTime.parse(json['timestamp']),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
    };
  }
}
