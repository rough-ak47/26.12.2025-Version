import 'package:flutter/foundation.dart';
import '../models/user_request_model.dart';
import '../models/user_model.dart';
import '../models/news_item.dart';
import '../services/admin_api_service.dart';

class AdminProvider extends ChangeNotifier {
  final AdminApiService _api = AdminApiService();

  bool _isLoading = false;
  String? _error;

  final int _totalActiveUsers = 12403;
  int _pendingRequests = 87;
  final double _systemUptime = 99.98;
  String _selectedTimeRange = 'Last 30 Days';

  // User Requests
  List<UserRequest> _userRequests = [];

  // Users for Assign Screen
  final List<User> _users = [
    User(
      id: '1',
      name: 'Drew Cano',
      email: 'd.cano@email.com',
      role: 'Volunteer',
      status: 'active',
      comments: 12,
      reviews: 5,
      reports: 2,
      assignedRequestIds: [],
    ),
    User(
      id: '2',
      name: 'Olivia Rhye',
      email: 'olivia@email.com',
      role: 'Volunteer',
      status: 'active',
      comments: 34,
      reviews: 15,
      reports: 0,
      assignedRequestIds: [],
    ),
    User(
      id: '3',
      name: 'Phoenix Baker',
      email: 'p.baker@email.com',
      role: 'Volunteer',
      status: 'suspended',
      comments: 5,
      reviews: 1,
      reports: 8,
      assignedRequestIds: [],
    ),
    User(
      id: '4',
      name: 'Lana Steiner',
      email: 'lana.s@email.com',
      role: 'Volunteer',
      status: 'active',
      comments: 88,
      reviews: 23,
      reports: 1,
      assignedRequestIds: [],
    ),
    User(
      id: '5',
      name: 'Candice Wu',
      email: 'candice@email.com',
      role: 'Volunteer',
      status: 'banned',
      comments: 1,
      reviews: 0,
      reports: 15,
      assignedRequestIds: [],
    ),
  ];

  // Report Data
  final int _completedWork = 1254;
  final int _pendingWork = 86;
  final int _cancelledWork = 12;

  // News & Updates
  final List<NewsItem> _news = [];

  // UI state
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalActiveUsers => _totalActiveUsers;
  int get pendingRequests => _pendingRequests;
  double get systemUptime => _systemUptime;
  String get selectedTimeRange => _selectedTimeRange;
  List<UserRequest> get userRequests => _userRequests;
  List<User> get users => _users;
  int get completedWork => _completedWork;
  int get pendingWork => _pendingWork;
  int get cancelledWork => _cancelledWork;
  List<NewsItem> get news => _news;

  // Filtered requests
  List<UserRequest> getRequestsByStatus(String status) {
    if (status == 'all') return _userRequests;
    return _userRequests.where((r) => r.status == status).toList();
  }

  List<UserRequest> getPendingRequests() {
    return _userRequests.where((r) => r.status == 'pending').toList();
  }

  // Actions
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  Future<void> loadNews() async {
    _setLoading(true);
    _setError(null);
    try {
      final items = await _api.fetchNews();
      _news
        ..clear()
        ..addAll(items);
    } catch (e) {
      _setError('Failed to load news: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadData() async {
    await loadRequests();
    await loadNews();
  }

  Future<void> loadRequests() async {
    _setLoading(true);
    _clearError();
    try {
      final requests = await _api.fetchUserRequests();
      _userRequests = requests;
      _pendingRequests = requests.where((r) => r.status == 'pending').length;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load requests: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Actions
  void setTimeRange(String range) {
    _selectedTimeRange = range;
    notifyListeners();
  }

  Future<void> acceptRequest(String requestId) async {
    _setLoading(true);
    _clearError();
    try {
      await _api.updateRequestStatus(requestId, 'approved');
      final index = _userRequests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        _userRequests[index] = UserRequest(
          id: _userRequests[index].id,
          userName: _userRequests[index].userName,
          requestType: _userRequests[index].requestType,
          date: _userRequests[index].date,
          status: 'approved',
          location: _userRequests[index].location,
          details: _userRequests[index].details,
        );
        _pendingRequests--;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to accept request: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> declineRequest(String requestId) async {
    _setLoading(true);
    _clearError();
    try {
      await _api.updateRequestStatus(requestId, 'declined');
      final index = _userRequests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        _userRequests[index] = UserRequest(
          id: _userRequests[index].id,
          userName: _userRequests[index].userName,
          requestType: _userRequests[index].requestType,
          date: _userRequests[index].date,
          status: 'declined',
          location: _userRequests[index].location,
          details: _userRequests[index].details,
        );
        _pendingRequests--;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to decline request: $e');
    } finally {
      _setLoading(false);
    }
  }

  void assignRequestToVolunteer(String requestId, String volunteerId) {
    final requestIndex = _userRequests.indexWhere((r) => r.id == requestId);
    final volunteerIndex = _users.indexWhere((u) => u.id == volunteerId);
    if (requestIndex == -1 || volunteerIndex == -1) return;

    final volunteer = _users[volunteerIndex];
    final request = _userRequests[requestIndex];

    final updatedVolunteer = User(
      id: volunteer.id,
      name: volunteer.name,
      email: volunteer.email,
      role: volunteer.role,
      status: volunteer.status,
      comments: volunteer.comments,
      reviews: volunteer.reviews,
      reports: volunteer.reports,
      profileImageUrl: volunteer.profileImageUrl,
      assignedRequestIds: [
        ...volunteer.assignedRequestIds,
        request.id,
      ],
    );

    final updatedRequest = UserRequest(
      id: request.id,
      userName: request.userName,
      requestType: request.requestType,
      date: request.date,
      status: 'assigned',
      location: request.location,
      details: request.details,
      volunteerId: volunteer.id,
      volunteerName: volunteer.name,
    );

    _users[volunteerIndex] = updatedVolunteer;
    _userRequests[requestIndex] = updatedRequest;
    if (request.status == 'pending' && _pendingRequests > 0) {
      _pendingRequests--;
    }
    notifyListeners();
  }

  Future<void> createNews({
    required String title,
    required String body,
    String audience = 'all',
  }) async {
    _setError(null);
    try {
      final item = await _api.createNews(
        title: title,
        body: body,
        audience: audience,
      );
      _news.insert(0, item);
      notifyListeners();
    } catch (e) {
      _setError('Failed to publish news: $e');
      rethrow;
    }
  }
}
