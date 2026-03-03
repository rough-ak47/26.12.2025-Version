# E-Waste Collector Mobile App

A Flutter mobile application for responsible e-waste disposal and management.

## Features

### 🏠 Home Screen
- **Welcome Section**: Personalized greeting with user's name
- **Quick Actions**: Send Request, Track E-Waste, News & Updates
- **Live Statistics**: Real-time data on waste collected and requests completed
- **Recent Activities**: List of user's recent e-waste requests
- **News Highlights**: Preview of latest news and updates
- **Notification Bell**: Shows unread notification count with badge

### 📱 Core Screens

#### 1. Send Request Screen
- Photo upload for e-waste items
- Form with item type, address, location details
- Request submission with ID generation
- Camera integration for photo capture

#### 2. Track My E-Waste Screen
- Timeline view of request status
- Status updates: Pending → Picked → Hub → Recycled
- Visual progress indicators
- Request details and history

#### 3. My Requests Screen
- Complete list of user's requests
- Status tracking for each request
- Detailed view with status updates
- Quick access to tracking

#### 4. News & Updates Screen
- List of news articles
- Article previews with images
- Full article view in modal
- Author and publish date information

#### 5. Notifications Screen
- List of all notifications
- Unread notification indicators
- Different notification types (request updates, reminders, awareness)
- Mark as read functionality

#### 6. Profile Screen
- User profile information
- Edit profile options
- User statistics and impact
- Settings and logout

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── request_model.dart
│   ├── notification_model.dart
│   ├── news_model.dart
│   ├── statistics_model.dart
│   └── user_model.dart
├── providers/                # State management
│   └── home_provider.dart
├── screens/                  # UI screens
│   ├── home_screen.dart
│   ├── send_request_screen.dart
│   ├── tracking_screen.dart
│   ├── my_requests_screen.dart
│   ├── news_screen.dart
│   ├── notification_screen.dart
│   └── profile_screen.dart
├── services/                 # API services
│   └── api_service.dart
└── widgets/                  # Reusable widgets
    ├── quick_action_card.dart
    ├── statistics_card.dart
    ├── recent_activity_card.dart
    └── news_preview_card.dart
```

## Setup Instructions

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / VS Code
- Android device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd ewaste_collector
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Dependencies

The app uses the following key dependencies:

- **provider**: State management
- **http**: API calls
- **image_picker**: Camera functionality
- **path_provider**: File system access
- **shared_preferences**: Local storage
- **intl**: Date formatting

## API Integration

The app is designed to work with a backend API. Currently, it uses mock data for demonstration purposes. To integrate with a real API:

1. Update the `baseUrl` in `lib/services/api_service.dart`
2. Implement the actual HTTP calls in each method
3. Update error handling for network requests
4. Add authentication if required

## Key Features Implementation

### State Management
- Uses Provider pattern for state management
- `HomeProvider` manages all app state
- Reactive UI updates based on state changes

### Navigation
- Bottom navigation bar for main screens
- Modal sheets for detailed views
- Proper navigation stack management

### Data Models
- Comprehensive models for all data types
- JSON serialization/deserialization
- Type-safe data handling

### UI/UX
- Material Design principles
- Consistent color scheme (green theme)
- Responsive design
- Loading states and error handling

## Customization

### Colors
The app uses a green color scheme:
- Primary: `#2E7D32`
- Light: `#81C784`
- Background: `#E8F5E8`

### Fonts
- Primary font: Roboto
- Consistent typography hierarchy

## Future Enhancements

1. **Real API Integration**: Replace mock data with actual backend
2. **Push Notifications**: Real-time notification system
3. **Offline Support**: Cache data for offline usage
4. **Maps Integration**: Location services for pickup scheduling
5. **Payment Integration**: Reward system for users
6. **Social Features**: Community impact sharing
7. **Analytics**: User behavior tracking
8. **Multi-language Support**: Internationalization

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please contact the development team or create an issue in the repository.
