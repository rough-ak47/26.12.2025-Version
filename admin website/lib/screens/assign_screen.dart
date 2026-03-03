import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../models/user_model.dart';
import '../models/user_request_model.dart';

class AssignScreen extends StatelessWidget {
  const AssignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: provider.users.length,
                  itemBuilder: (context, index) {
                    return _buildUserCard(provider.users[index], context);
                  },
                ),
              ),
              const SizedBox(height: 16),
              _buildPagination(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserCard(User user, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Picture
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Role: ${user.role}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Assigned: ${user.assignedRequestIds.length} requests',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          // Assign Button
          ElevatedButton(
            onPressed: () {
              _openAssignDialog(context, user);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {},
        ),
        _buildPageNumber(1, true),
        _buildPageNumber(2, false),
        _buildPageNumber(3, false),
        const Text('...'),
        _buildPageNumber(8, false),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildPageNumber(int number, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? Colors.green : Colors.grey.shade300,
        ),
      ),
      child: Center(
        child: Text(
          number.toString(),
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade700,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Future<void> _openAssignDialog(BuildContext context, User volunteer) async {
    final provider = Provider.of<AdminProvider>(context, listen: false);
    final pending = provider.getPendingRequests();
    String? selectedRequestId = pending.isNotEmpty ? pending.first.id : null;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Assign to ${volunteer.name}'),
          content: pending.isEmpty
              ? const Text('No pending customer requests.')
              : StatefulBuilder(
                  builder: (context, setState) {
                    return ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 420,
                        minWidth: 280,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DropdownButton<String>(
                              value: selectedRequestId,
                              isExpanded: true,
                              items: pending
                                  .map(
                                    (req) => DropdownMenuItem<String>(
                                      value: req.id,
                                      child: _requestRow(req),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedRequestId = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedRequestId == null
                  ? null
                  : () {
                      provider.assignRequestToVolunteer(
                        selectedRequestId!,
                        volunteer.id,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Assigned request #$selectedRequestId to ${volunteer.name}',
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Widget _requestRow(UserRequest req) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(req.requestType, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(
          req.userName,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        if (req.location != null)
          Text(
            req.location!,
            style: const TextStyle(fontSize: 11, color: Colors.black45),
          ),
      ],
    );
  }
}

