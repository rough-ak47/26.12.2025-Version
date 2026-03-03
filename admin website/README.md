# Admin Panel Web Application

A Flutter web-based admin panel for managing E-Waste collection requests and users.

## Features

- **Dashboard**: Overview with KPIs and usage graphs
- **User Requests**: Manage and filter user requests (Account Verification, Password Reset, Data Export, Account Deletion)
- **Assign**: Assign user requests to team members
- **User ID Manipulation**: View and manage user accounts with status tracking
- **Reports**: Work report overview with trends and statistics

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK
- Chrome or any modern web browser

### Installation

1. Navigate to the admin website directory:
   ```bash
   cd "admin website"
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the web application:
   ```bash
   flutter run -d chrome
   ```

   Or for web server:
   ```bash
   flutter run -d web-server --web-port=8080
   ```

## Project Structure

```
lib/
├── main.dart                    # Main application entry point
├── models/                      # Data models
│   ├── user_model.dart
│   └── user_request_model.dart
├── providers/                   # State management
│   └── admin_provider.dart
└── screens/                     # UI Screens
    ├── dashboard_screen.dart
    ├── user_requests_screen.dart
    ├── assign_screen.dart
    ├── user_id_manipulation_screen.dart
    └── report_screen.dart
```

## Dependencies

- `provider`: State management
- `fl_chart`: Charts and graphs
- `intl`: Date formatting
- `http`: HTTP requests (for future API integration)

## Screenshots

The application includes 5 main screens:
1. Dashboard with KPIs and usage graphs
2. User Requests management
3. Assign user requests
4. User ID Manipulation
5. Work Report Overview

## Future Enhancements

- API integration for real data
- Authentication system
- Real-time updates
- Export functionality
- Advanced filtering and search

