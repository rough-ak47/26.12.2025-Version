import 'dart:io' show File;
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class ItemsRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> listMyItems() async {
    return _client.from('items').select().order('created_at', ascending: false);
  }

  Future<String> createItem({
    required String ownerId,
    required String category,
    String? brand,
    String? model,
    List<String> photos = const [],
    String status = 'listed',
  }) async {
    final res = await _client
        .from('items')
        .insert({
          'owner_id': ownerId,
          'category': category,
          'brand': brand,
          'model': model,
          'status': status,
          'photos': photos,
        })
        .select('id')
        .single();
    return res['id'].toString();
  }

  Future<void> updateItem(String id, Map<String, dynamic> payload) async {
    await _client.from('items').update(payload).eq('id', id);
  }

  Future<void> updatePhotos(String id, List<String> photos) async {
    await _client.from('items').update({'photos': photos}).eq('id', id);
  }

  Future<void> deleteItem(String id) async {
    await _client.from('items').delete().eq('id', id);
  }
}

class PickupRequestsRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> listRequests() async {
    return _client
        .from('pickup_requests')
        .select()
        .order('created_at', ascending: false);
  }

  Future<String> createPickupRequest({
    required String itemId,
    required String requestedBy,
    String? collectorId,
    required String pickupAddress,
    String status = 'pending',
  }) async {
    final res = await _client
        .from('pickup_requests')
        .insert({
          'item_id': itemId,
          'requested_by': requestedBy,
          'collector_id': collectorId,
          'pickup_address': pickupAddress,
          'status': status,
        })
        .select('id')
        .single();
    return res['id'].toString();
  }

  Future<void> updatePickup(String id, Map<String, dynamic> payload) async {
    await _client.from('pickup_requests').update(payload).eq('id', id);
  }

  Future<void> deletePickup(String id) async {
    await _client.from('pickup_requests').delete().eq('id', id);
  }
}

class StorageRepository {
  final SupabaseClient _client = Supabase.instance.client;
  final String bucket = 'item-photos';

  Future<String> uploadItemPhoto({
    required dynamic file, // File (mobile/desktop) or Uint8List (web)
    required String itemId,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final fileName = file is File
        ? file.uri.pathSegments.last
        : 'upload-${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = '$userId/$itemId/$fileName';
    
    if (file is Uint8List) {
      await _client.storage.from(bucket).uploadBinary(path, file);
    } else {
      await _client.storage.from(bucket).upload(path, file);
    }
    return path;
  }

  Future<String> getSignedUrl(String path,
      {int expiresInSeconds = 3600}) async {
    return _client.storage.from(bucket).createSignedUrl(path, expiresInSeconds);
  }

  Future<String> uploadProfilePhoto({
    required dynamic file, // File (mobile/desktop) or Uint8List (web)
    required String userId,
  }) async {
    final fileName = 'profile-${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = '$userId/$fileName';
    const profileBucket = 'user_photos';
    
    if (file is Uint8List) {
      await _client.storage.from(profileBucket).uploadBinary(
        path, 
        file, 
        fileOptions: const FileOptions(upsert: true),
      );
    } else {
      await _client.storage.from(profileBucket).upload(
        path, 
        file, 
        fileOptions: const FileOptions(upsert: true),
      );
    }
    
    final publicUrl = _client.storage.from(profileBucket).getPublicUrl(path);
    return publicUrl;
  }

  Future<void> deletePhoto(String path) async {
    await _client.storage.from(bucket).remove([path]);
  }
}
