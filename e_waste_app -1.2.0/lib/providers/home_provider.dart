import 'package:flutter/foundation.dart';
import '../models/request_model.dart';
import '../models/statistics_model.dart';
import '../models/news_model.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeProvider with ChangeNotifier {
  UserModel? _currentUser;
  StatisticsModel? _statistics;
  List<RequestModel> _recentRequests = [];
  List<NewsModel> _newsArticles = [];
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  UserModel? get currentUser => _currentUser;
  StatisticsModel? get statistics => _statistics;
  List<RequestModel> get recentRequests => _recentRequests;
  List<NewsModel> get newsArticles => _newsArticles;
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get unreadNotificationsCount =>
      _notifications.where((n) => !n.isRead).length;

  final ApiService _apiService = ApiService();

  Future<void> loadData() async {
    _setLoading(true);
    _clearError();

    try {
      if (Supabase.instance.client.auth.currentUser == null) {
        _currentUser = null;
        _statistics = null;
        _recentRequests = [];
        _newsArticles = [];
        _notifications = [];
        _setLoading(false);
        return;
      }

      await Future.wait([
        _loadUserData(),
        _loadStatistics(),
        _loadRecentRequests(),
        _loadNewsArticles(),
        _loadNotifications(),
      ]);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadUserData() async {
    try {
      _currentUser = await _apiService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      _currentUser = null;
      _setError(e.toString());
    }
  }

  Future<void> _loadStatistics() async {
    try {
      _statistics = await _apiService.getStatistics();
      notifyListeners();
    } catch (e) {
      _statistics = StatisticsModel(
        totalWasteCollected: 0,
        requestsCompleted: 0,
        activeRequests: 0,
        totalUsers: 0,
      );
      _setError(e.toString());
    }
  }

  Future<void> _loadRecentRequests() async {
    try {
      _recentRequests = await _apiService.getRecentRequests();
      notifyListeners();
    } catch (e) {
      _recentRequests = [];
      _setError(e.toString());
    }
  }

  Future<void> _loadNewsArticles() async {
    try {
      _newsArticles = await _apiService.getNewsArticles();
      notifyListeners();
    } catch (e) {
      _newsArticles = [];
      _setError(e.toString());
    }
  }

  Future<void> _loadNotifications() async {
    try {
      _notifications = await _apiService.getNotifications();
      notifyListeners();
    } catch (e) {
      _notifications = [];
      _setError(e.toString());
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _apiService.markNotificationAsRead(notificationId);
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          title: _notifications[index].title,
          message: _notifications[index].message,
          createdAt: _notifications[index].createdAt,
          isRead: true,
          type: _notifications[index].type,
        );
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadRecentRequests() async {
    _setLoading(true);
    _clearError();

    try {
      if (Supabase.instance.client.auth.currentUser == null) {
        _recentRequests = [];
        _setLoading(false);
        return;
      }

      await _loadRecentRequests();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
}
