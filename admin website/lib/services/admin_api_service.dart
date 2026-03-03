import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/news_item.dart';
import '../models/user_request_model.dart';
// import '../models/user_model.dart';

class AdminApiService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<NewsItem>> fetchNews() async {
    final data = await _client
        .from('news')
        .select()
        .order('created_at', ascending: false);

    return data
        .map<NewsItem>((row) => NewsItem(
              id: row['id'].toString(),
              title: row['title'] ?? '',
              body: row['body'] ?? '',
              audience: row['audience'] ?? 'all',
              createdAt:
                  DateTime.tryParse(row['created_at'] ?? '') ?? DateTime.now(),
            ))
        .toList();
  }

  Future<NewsItem> createNews({
    required String title,
    required String body,
    required String audience,
  }) async {
    final res = await _client
        .from('news')
        .insert({
          'title': title,
          'body': body,
          'audience': audience,
        })
        .select()
        .single();

    return NewsItem(
      id: res['id'].toString(),
      title: res['title'] ?? title,
      body: res['body'] ?? body,
      audience: res['audience'] ?? audience,
      createdAt: DateTime.tryParse(res['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Future<List<UserRequest>> fetchUserRequests() async {
    final data = await _client.from('pickup_requests').select('''
          id,
          status,
          pickup_address,
          created_at,
          items!inner (
            category,
            photos
          ),
          profiles!pickup_requests_requested_by_fkey (
            full_name
          )
        ''').order('created_at', ascending: false);

    return data.map<UserRequest>((row) {
      final item = row['items'] as Map<String, dynamic>;
      final profile = row['profiles'] as Map<String, dynamic>;
      return UserRequest(
        id: row['id'].toString(),
        userName: profile['full_name'] ?? 'Unknown User',
        requestType: item['category'] ?? 'Unknown',
        date: DateTime.tryParse(row['created_at'] ?? '') ?? DateTime.now(),
        status: row['status'] ?? 'pending',
        location: row['pickup_address'],
        details: item['photos'] != null && (item['photos'] as List).isNotEmpty
            ? 'Has photos'
            : 'No photos',
      );
    }).toList();
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    await _client
        .from('pickup_requests')
        .update({'status': status}).eq('id', requestId);
  }
}
