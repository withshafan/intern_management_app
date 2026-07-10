<div align="center">
  <!-- Replace with actual logo if available, or keep a nice placeholder -->
  <img src="assets/icon/app_icon.jpg" width="150" height="150" alt="Intern Management App Logo"/>
  <h1>Intern Management App</h1>
  <p>A modern, premium, and highly interactive Flutter application for streamlined intern management, task tracking, and analytics.</p>

  [![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
  [![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)
  [![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
</div>

<br/>

## 📖 Overview

**Intern Management App** is a meticulously designed task and progress management system built to streamline the workflow between administrators and interns. Re-engineered with a focus on **UI/UX excellence**, it features a beautiful custom-designed glassmorphic theme, seamless light & dark mode support, smooth micro-interactions, real-time data sync, and intelligent interactive analytics.

## ✨ Key Features

### 🛡️ Core Management
- **Centralized Dashboard:** Get a bird's-eye view of all interns, task distribution (pending, in-progress, completed), and individual progress metrics.
- **Intern Profiles:** Detailed profiles for every intern tracking their department, exact progress percentages, and start dates using native Date Pickers.
- **Complete CRUD Operations:** Easily add new interns, edit existing profiles, or remove them entirely from the system.

### ⚡ Real-Time Task Tracking
- **Assign & Monitor:** Create, assign, and track tasks instantly using **Firebase Cloud Firestore**.
- **Deadline Management:** Assign due dates using native calendar interfaces and visually highlight overdue and due-today tasks on the dashboard.
- **Intelligent Cascading Deletes:** Securely erase an intern and automatically trigger a batch deletion of all their assigned tasks, leaving no orphaned data behind.

### 🎨 Premium UI/UX & Animations
- **Modern Glassmorphic Aesthetic:** Beautifully crafted frosted glass cards, dynamic backgrounds, and soft shadows that adapt perfectly to both Light and Dark themes.
- **Micro-Interactions:** Staggered list animations, smooth hero transitions for avatars, and highly polished shimmer loading effects.
- **Form Validation & UX:** Auto-validating forms, custom animated text fields, and premium tactile feedback across all interactive elements.

### 📊 Interactive Analytics & Progress
- **Live Dashboards:** Dynamic **Pie Charts** and **Animated Progress Rings** (powered by `fl_chart`) to instantly visualize task completion rates and statuses.
- **Attention System:** Automatically flags tasks that are overdue or due today directly on the dashboard.

## 🛠️ Technology Stack

- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **Backend & Database:** [Firebase](https://firebase.google.com/) (Auth & Cloud Firestore)
- **State Management:** Reactive Architecture (`StatefulWidget`, `StreamBuilder` for real-time Firestore sync)
- **UI Components:** 
  - `fl_chart` (Analytics & Pie Charts)
  - `flutter_animate` (Staggered UI & Micro-interactions)

## 📁 Project Structure

```text
lib/
├── main.dart                 # App entry point & Theme Configuration
├── models/                   # Data structures
│   ├── intern.dart           # Intern model definition
│   └── task.dart             # Task model definition
├── screens/                  # Application UI Screens
│   ├── splash_screen.dart    # Animated loading screen
│   ├── login_screen.dart     # Secure authentication screen
│   ├── home_screen.dart      # Main bottom navigation host
│   ├── dashboard_screen.dart # Analytics & Overview Dashboard
│   ├── interns_list_screen.dart # Directory of all interns
│   ├── intern_detail_screen.dart # Detailed profile & task list
│   ├── add_intern_screen.dart # Form to onboard new interns
│   ├── edit_intern_screen.dart # Form to update existing interns
│   ├── add_task_screen.dart  # Form to assign tasks to interns
│   ├── task_detail_screen.dart # Task status management
│   └── profile_screen.dart   # Current user profile & settings
├── services/                 # API & Firebase logic
│   ├── auth_service.dart     # Firebase Authentication wrappers
│   ├── intern_service.dart   # Firestore CRUD for Interns
│   └── task_service.dart     # Firestore CRUD for Tasks
├── theme/                    # Design System
│   └── app_colors.dart       # Centralized color tokens for themes
└── widgets/                  # Reusable UI components
    ├── custom_text_field.dart # Glassmorphic input fields
    ├── glass_card.dart       # Frosted glass containers
    ├── animated_progress_ring.dart # Circular progress indicators
    └── shimmer_loading.dart  # Skeleton loading placeholders
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.10.0 or higher)
- Dart SDK
- Android Studio / VS Code
- A configured Firebase project (Firestore and Authentication enabled)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/withshafan/intern_management_app.git
   cd intern_management_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   Ensure you have your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) in their respective directories if you are setting up a new Firebase backend, or configure it via the FlutterFire CLI.

4. **Run the app:**
   ```bash
   flutter run
   ```

## 🤝 Contributing
Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/withshafan/intern_management_app/issues).

## 📄 License
This project is licensed under the MIT License.
