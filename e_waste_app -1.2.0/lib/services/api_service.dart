import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/request_model.dart';
import '../models/statistics_model.dart';
import '../models/news_model.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';

class ApiService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<UserModel> getCurrentUser() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      throw Exception('Not authenticated');
    }
    final profile =
        await _client.from('profiles').select().eq('id', authUser.id).single();
    return UserModel.fromProfile(authUser, profile);
  }

  Future<StatisticsModel> getStatistics() async {
    final pickups = await _client.from('pickup_requests').select();
    final profiles = await _client.from('profiles').select();

    final completed =
        pickups.where((p) => (p['status'] ?? '') == 'completed').length;
    final active =
        pickups.where((p) => (p['status'] ?? '') != 'completed').length;

    return StatisticsModel(
      totalWasteCollected: 0, // no weight field available yet
      requestsCompleted: completed,
      activeRequests: active,
      totalUsers: profiles.length,
    );
  }

  Future<List<RequestModel>> getRecentRequests() async {
    final data = await _client
        .from('pickup_requests')
        .select()
        .order('created_at', ascending: false)
        .limit(20);

    return data
        .map<RequestModel>((row) => RequestModel(
              id: row['id'].toString(),
              itemType: row['item_id']?.toString() ?? 'Item',
              status: row['status'] ?? '',
              createdAt:
                  DateTime.tryParse(row['created_at'] ?? '') ?? DateTime.now(),
              imageUrl: null,
              address: row['pickup_address'] ?? '',
              location: '',
              statusUpdates: const [],
            ))
        .toList();
  }

  Future<List<NewsModel>> getNewsArticles() async {
    final data = await _client
        .from('news')
        .select()
        .order('published_at', ascending: false);

    return data
        .map<NewsModel>((row) => NewsModel(
              id: row['id'].toString(),
              title: row['title'] ?? '',
              summary: row['summary'] ?? '',
              content: row['content'] ?? '',
              imageUrl: row['image_url'] ?? '',
              publishedAt: DateTime.tryParse(row['published_at'] ?? '') ??
                  DateTime.now(),
              author: row['author'] ?? '',
            ))
        .toList();
  }

  Future<List<NotificationModel>> getNotifications() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await _client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return data
        .map<NotificationModel>((row) => NotificationModel(
              id: row['id'].toString(),
              title: row['title'] ?? '',
              message: row['message'] ?? '',
              createdAt:
                  DateTime.tryParse(row['created_at'] ?? '') ?? DateTime.now(),
              isRead: row['is_read'] ?? false,
              type: _mapNotificationType(row['type']?.toString()),
            ))
        .toList();
  }

  Future<RequestModel> submitRequest({
    required String itemType,
    required String address,
    required String location,
    required String imagePath,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final res = await _client
        .from('pickup_requests')
        .insert({
          'item_id': itemType,
          'requested_by': userId,
          'pickup_address': '$address | $location',
          'status': 'pending',
        })
        .select()
        .single();

    return RequestModel(
      id: res['id'].toString(),
      itemType: res['item_id']?.toString() ?? itemType,
      status: res['status'] ?? 'pending',
      createdAt: DateTime.tryParse(res['created_at'] ?? '') ?? DateTime.now(),
      imageUrl: imagePath,
      address: res['pickup_address'] ?? address,
      location: location,
      statusUpdates: const [],
    );
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _client
        .from('notifications')
        .update({'is_read': true}).eq('id', notificationId);
  }

  Future<List<RequestModel>> getAllRequests() async {
    return getRecentRequests();
  }

  Future<List<NewsModel>> getAllNews() async {
    return getNewsArticles();
  }

  Future<UserModel> updateUserProfile(Map<String, dynamic> updates) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) throw Exception('Not authenticated');

    final profile = await _client
        .from('profiles')
        .update(updates)
        .eq('id', authUser.id)
        .select()
        .single();

    return UserModel.fromProfile(authUser, profile);
  }

  NotificationType _mapNotificationType(String? raw) {
    if (raw == null || raw.isEmpty) {
      return NotificationType.general;
    }

    switch (raw) {
      case 'requestUpdate':
        return NotificationType.requestUpdate;
      case 'reminder':
        return NotificationType.reminder;
      case 'awareness':
        return NotificationType.awareness;
      case 'general':
        return NotificationType.general;
      default:
        return NotificationType.general;
    }
  }
}
