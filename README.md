# Ecom App

A modern Flutter e-commerce application challenge project.

## Features
- Splash screen with animated logo
- Login and authentication
- Product listing with search, sort, and category filter
- Masonry grid product display
- Product detail page with image gallery, price, rating, and action buttons
- Add product and update product screens
- Profile page with user info and logout
- **MVVM architecture** with ViewModels for all screens
- Graceful error handling for missing products and network issues

## Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Dart

### Setup
1. Clone this repository:
   ```sh
   git clone <your-repo-url>
   cd ecom_app
   ```
2. Install dependencies:
   ```sh
   flutter pub get
   ```
3. Run the app:
   ```sh
   flutter run
   ```

## Folder Structure
- `lib/` - Main source code
  - `src/models/` - Data models (Product, User)
  - `src/screens/` - App screens (splash, login, products, profile, etc.)
  - `src/services/` - Service classes (e.g., authentication)
  - `viewmodels/` - ViewModel classes for MVVM
  - `assets/images/` - App images (e.g., logo)

## Architecture
This app uses the **MVVM (Model-View-ViewModel)** pattern:
- **Models:** Represent data (e.g., Product, User)
- **ViewModels:** Hold business logic and state for each screen
- **Views (Screens):** Display UI and react to ViewModel state
- **Provider:** Used for dependency injection and state management

## Packages Used
- [provider](https://pub.dev/packages/provider)
- [flutter_staggered_grid_view](https://pub.dev/packages/flutter_staggered_grid_view)
- [http](https://pub.dev/packages/http)
- [dio](https://pub.dev/packages/dio)
- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)

## Error Handling & Troubleshooting
- If a product does not exist, the app will show "Product not found (404)" instead of crashing.
- Common emulator/device warnings (e.g., `E/libEGL ... called unimplemented OpenGL ES API`) are safe to ignore unless you have rendering issues.
- If you see a 404 error, check that the product ID exists in the backend or API.

## Customization
- Update the logo in `assets/images/logo.png`.
- Change theme colors in `lib/src/theme/`.

## License
This project is for educational and challenge purposes.
