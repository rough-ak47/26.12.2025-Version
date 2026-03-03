import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/request_model.dart';
import '../models/statistics_model.dart';
import '../models/news_model.dart';
import '../models/user_model.dart';
import '../providers/home_provider.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/statistics_card.dart';
import '../widgets/recent_activity_card.dart';
import '../widgets/news_preview_card.dart';
import 'notification_screen.dart';
import 'send_request_screen.dart';
import 'tracking_screen.dart';
import 'news_screen.dart';
import 'my_requests_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const MyRequestsScreen(),
    const NewsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'My Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFE8F5E8),
            elevation: 0,
            title: const Text(
              'E-Waste Collector',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.black),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                        ),
                      );
                    },
                  ),
                  if (homeProvider.unreadNotificationsCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${homeProvider.unreadNotificationsCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          backgroundColor: const Color(0xFFFAFAFA),
          body: RefreshIndicator(
            onRefresh: () async {
              await homeProvider.loadData();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  _buildWelcomeSection(homeProvider.currentUser),
                  const SizedBox(height: 24),

                  // Quick Actions
                  _buildQuickActions(context),
                  const SizedBox(height: 24),

                  // Live Statistics
                  _buildStatisticsSection(homeProvider.statistics),
                  const SizedBox(height: 24),

                  // Recent Activities
                  _buildRecentActivitiesSection(homeProvider.recentRequests),
                  const SizedBox(height: 24),

                  // News Highlights
                  _buildNewsSection(homeProvider.newsArticles),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection(UserModel? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome, ${user?.name ?? 'User'}',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Let's make a difference today!",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Send Request - Main Action
        QuickActionCard(
          title: 'Send Request',
          icon: Icons.send,
          color: const Color(0xFF2E7D32),
          isMainAction: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SendRequestScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // Secondary Actions
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                title: 'Track My E-Waste',
                icon: Icons.track_changes,
                color: const Color(0xFF81C784),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TrackingScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: QuickActionCard(
                title: 'News & Updates',
                icon: Icons.article,
                color: const Color(0xFF81C784),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewsScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatisticsSection(StatisticsModel? statistics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Live Statistics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatisticsCard(
                title: 'Total Waste Collected',
                value:
                    '${statistics?.totalWasteCollected.toStringAsFixed(0) ?? '0'} kg',
                color: const Color(0xFF81C784),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatisticsCard(
                title: 'Requests Completed',
                value: '${statistics?.requestsCompleted ?? 0}',
                color: const Color(0xFF81C784),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivitiesSection(List<RequestModel> recentRequests) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Activities',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to My Requests screen
              },
              child: const Text(
                'View All',
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...recentRequests.take(3).map(
              (request) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: RecentActivityCard(request: request),
              ),
            ),
      ],
    );
  }

  Widget _buildNewsSection(List<NewsModel> newsArticles) {
    if (newsArticles.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'News Highlights',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: newsArticles.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index < newsArticles.length - 1 ? 16 : 0,
                ),
                child: NewsPreviewCard(news: newsArticles[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}
