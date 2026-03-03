import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/request_model.dart';
import '../providers/home_provider.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track My E-Waste'),
        backgroundColor: const Color(0xFFE8F5E8),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFFAFAFA),
      body: Consumer<HomeProvider>(
        builder: (context, homeProvider, child) {
          if (homeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (homeProvider.recentRequests.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.track_changes,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No requests to track yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Submit your first e-waste request to start tracking',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: homeProvider.recentRequests.length,
            itemBuilder: (context, index) {
              final request = homeProvider.recentRequests[index];
              return _buildTrackingCard(context, request);
            },
          );
        },
      ),
    );
  }

  Widget _buildTrackingCard(BuildContext context, RequestModel request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E7D32),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.recycling,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Request #${request.id}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        request.itemType,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color:
                        _getStatusColor(request.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    request.status,
                    style: TextStyle(
                      color: _getStatusColor(request.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Status Timeline
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status Timeline',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                _buildStatusTimeline(request),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Address', request.address),
                const SizedBox(height: 8),
                _buildDetailRow('Location', request.location),
                const SizedBox(height: 8),
                _buildDetailRow('Created', _formatDate(request.createdAt)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(RequestModel request) {
    final statuses = ['Pending', 'Picked', 'Hub', 'Recycled'];
    final currentStatusIndex = statuses.indexOf(request.status);

    return Row(
      children: statuses.asMap().entries.map((entry) {
        final index = entry.key;
        final status = entry.value;
        final isCompleted = index <= currentStatusIndex;
        final isCurrent = index == currentStatusIndex;

        return Expanded(
          child: Column(
            children: [
              // Status Circle
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color:
                      isCompleted ? const Color(0xFF2E7D32) : Colors.grey[300],
                  shape: BoxShape.circle,
                  border: isCurrent
                      ? Border.all(
                          color: const Color(0xFF2E7D32),
                          width: 3,
                        )
                      : null,
                ),
                child: isCompleted
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
              const SizedBox(height: 8),

              // Status Text
              Text(
                status,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color:
                      isCompleted ? const Color(0xFF2E7D32) : Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),

              // Connector Line
              if (index < statuses.length - 1)
                Container(
                  height: 2,
                  color: index < currentStatusIndex
                      ? const Color(0xFF2E7D32)
                      : Colors.grey[300],
                  margin: const EdgeInsets.only(top: 8),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
      case 'recycled':
        return const Color(0xFF2E7D32);
      case 'cancelled':
        return Colors.red;
      case 'picked':
        return Colors.blue;
      case 'hub':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
