import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/admin_provider.dart';
import '../models/user_request_model.dart';

class UserRequestsScreen extends StatefulWidget {
  const UserRequestsScreen({super.key});

  @override
  State<UserRequestsScreen> createState() => _UserRequestsScreenState();
}

class _UserRequestsScreenState extends State<UserRequestsScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, child) {
        final requests = provider.getRequestsByStatus(_selectedFilter);

        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Tabs
              Row(
                children: [
                  _buildFilterTab('All Requests', 'all'),
                  const SizedBox(width: 12),
                  _buildFilterTab('Pending', 'pending'),
                  const SizedBox(width: 12),
                  _buildFilterTab('Approved', 'approved'),
                  const SizedBox(width: 12),
                  _buildFilterTab('Declined', 'declined'),
                ],
              ),
              const SizedBox(height: 24),
              // Requests List
              Expanded(
                child: ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    return _buildRequestCard(requests[index], provider);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterTab(String label, String value) {
    final isSelected = _selectedFilter == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(UserRequest request, AdminProvider provider) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  request.requestType,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (request.location != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    request.location!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  dateFormat.format(request.date),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                if (request.volunteerName != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Assigned to: ${request.volunteerName}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (request.status == 'pending')
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    provider.declineRequest(request.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${request.userName}\'s request declined')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Decline'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    provider.acceptRequest(request.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${request.userName}\'s request accepted')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Accept'),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: request.status == 'approved'
                    ? Colors.green.shade50
                    : request.status == 'assigned'
                        ? Colors.blue.shade50
                        : Colors.red.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                request.status.toUpperCase(),
                style: TextStyle(
                  color: request.status == 'approved'
                      ? Colors.green
                      : request.status == 'assigned'
                          ? Colors.blue
                          : Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

