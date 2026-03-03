import 'package:flutter_test/flutter_test.dart';
import 'package:admin_website/providers/admin_provider.dart';

void main() {
  group('AdminProvider', () {
    test('setTimeRange updates selectedTimeRange', () {
      final provider = AdminProvider();

      expect(provider.selectedTimeRange, 'Last 30 Days');

      provider.setTimeRange('Last 7 Days');

      expect(provider.selectedTimeRange, 'Last 7 Days');
    });

    test('acceptRequest updates status and pending count', () {
      final provider = AdminProvider();
      final initialPending = provider.pendingRequests;
      final requestId = provider.userRequests.first.id;

      provider.acceptRequest(requestId);

      final updated =
          provider.userRequests.firstWhere((r) => r.id == requestId);
      expect(updated.status, 'approved');
      expect(provider.pendingRequests, initialPending - 1);
    });
  });
}
