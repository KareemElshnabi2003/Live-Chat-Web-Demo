💬 Live Chat Web Demo

A Flutter Web chat application focused on real-time communication, responsive UI, scalable architecture, and efficient state management.

The project was refactored from a legacy controller-based implementation into a feature-based architecture using Cubit, GetIt, Dio, Repository Pattern, and Pusher.

Note: The application consumes an existing backend API. Because browser requests are subject to CORS restrictions, the Web client uses a same-origin proxy layer where required.

🌐 Web Deployment & API Proxy

Cloudflare Worker Proxy:
https://live-chat-web-demo.kelsayed2012003.workers.dev

The Cloudflare Worker acts as a proxy between the Flutter Web client and the external backend API, allowing browser requests to be handled without disabling browser security.

Live Demo: The Flutter Web application is not currently published as a standalone public demo URL. The Worker URL above is the API proxy, not the application itself.

✨ Features

Authentication

Guest authentication

Phone number login and OTP flow

Login / registration / logout flows

Authentication state handling with Cubit

Real-Time Chat

Real-time messaging using Pusher Channels

Send text messages

Send image/file attachments

Reply and react to messages

Message deduplication using message IDs

Optimistic message updates for immediate UI feedback

Paginated chat history

Chat members management

Create, update, delete, block and unblock chat-related actions

UI & UX

Responsive Web layout for desktop and smaller screens

Light / Dark theme

Arabic / English localization

Loading, error and empty states

Lazy rendering for message lists

Audio message playback

Automatic cleanup of listeners and media resources

Additional Modules

Friends and friend requests

Suggested friends

Notifications

Chat themes

Audio / Radio content

Settings and account management

Market features

🏗️ Architecture

The project follows a feature-based Clean Architecture approach, separating Data, Domain, and Presentation responsibilities.

lib/
├── core/
│   ├── api/
│   ├── di/
│   ├── errors/
│   ├── function/
│   ├── helper/
│   ├── network/
│   ├── routing/
│   ├── services/
│   │   ├── audio/
│   │   ├── notify/
│   │   └── pusher/
│   ├── theme/
│   ├── utils/
│   └── widgets/
│
└── features/
    ├── auth/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │
    ├── chat/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │
    ├── friends/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │
    ├── home/
    ├── market/
    ├── notifications/
    └── settings/

Request Flow

UI
 ↓
Cubit
 ↓
Use Case
 ↓
Repository
 ↓
Remote Data Source
 ↓
Dio
 ↓
REST API

Real-Time Flow

Pusher
 ↓
PusherService
 ↓
ChatCubit
 ↓
Chat State
 ↓
UI

🧰 Tech Stack

Technology

Purpose

Flutter / Dart

Application framework

flutter_bloc / Cubit

State management

GetIt

Dependency injection

Dio

HTTP client and REST communication

Pusher Channels

Real-time messaging

GoRouter

Navigation and routing

just_audio

Audio playback

Cached Network Image

Network image caching

SharedPreferences

Local storage and preferences

Connectivity Plus

Network awareness

Firebase Core / Messaging

Firebase integration used by the application

Screen Go

Responsive layout utilities

intl / Flutter Localizations

Arabic and English localization

⚡ Performance Considerations

The project includes several optimizations aimed at keeping the Web client responsive during chat usage:

Message IDs are tracked using a Set<String> for average O(1) membership checks.

Chat history is paginated rather than loaded indefinitely in one request.

Message lists use lazy rendering with ListView.separated.

Message widgets use stable keys based on message IDs.

Independent Home API requests are started concurrently where possible.

Audio loading is lazy and starts only when playback is requested.

Audio progress updates use narrow rebuilds with ValueNotifier / ValueListenableBuilder.

Stream subscriptions, Pusher listeners, controllers, and audio players are explicitly cleaned up during lifecycle disposal.

The Web image cache has an explicit memory limit.

🔐 Web / CORS Deployment

The backend API is an external service and cannot be modified for Web CORS configuration.

For local Web development, the browser may block cross-origin API requests depending on the backend's CORS configuration. The production Web setup therefore uses a same-origin proxy between the Flutter Web application and the external API.

Flutter Web
    ↓
Same-Origin Proxy (Cloudflare Worker)
    ↓
External REST API

This avoids relying on browser launches with disabled Web security.

✅ Verification

The current build has been verified successfully with:

flutter analyze
flutter test
flutter build web --release

Results:

flutter analyze → No issues found

flutter test → All tests passed

flutter build web --release → Build succeeded

📦 Getting Started

Prerequisites

Flutter SDK

Dart SDK compatible with the project environment

Chrome or another supported Web browser

Access to the required backend API and services

Installation

git clone https://github.com/KareemElshnabi2003/Live-Chat-Web-Demo.git
cd Live-Chat-Web-Demo
flutter pub get

Run on Web

flutter run -d chrome

Build Release Web

flutter build web --release

The production build is generated in:

build/web

📁 Main Project Structure

lib/
├── core/
│   ├── api/
│   ├── di/
│   ├── errors/
│   ├── network/
│   ├── routing/
│   ├── services/
│   ├── theme/
│   ├── utils/
│   └── widgets/
│
└── features/
    ├── auth/
    ├── chat/
    ├── friends/
    ├── home/
    ├── market/
    ├── notifications/
    └── settings/

🧪 Testing

The project currently includes a Flutter smoke test and has been verified with:

flutter test

All existing tests pass in the current verified build.

📌 Development Notes

The project is a Web-focused demo derived from an existing chat application codebase.

The refactor replaced the previous GetX/controller-oriented implementation with Cubit and a feature-based architecture.

Pusher is isolated behind a dedicated service to keep real-time transport concerns separate from UI state.

Data models are kept in the Data layer while Domain logic works with entities and repository abstractions.

The Web deployment uses a Cloudflare Worker proxy because the external backend cannot currently be changed to provide the required browser CORS configuration.

👨‍💻 Author

Kareem Elshnabi

GitHub: https://github.com/KareemElshnabi2003

LinkedIn: https://www.linkedin.com/in/kareem-elshnabi-087624258