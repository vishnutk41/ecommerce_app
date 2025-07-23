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
  - `src/screens/` - App screens (splash, login, products, profile, etc.)
  - `src/services/` - Service classes (e.g., authentication)
  - `viewmodels/` - ViewModel classes
  - `assets/images/` - App images (e.g., logo)

## Packages Used
- [provider](https://pub.dev/packages/provider)
- [flutter_staggered_grid_view](https://pub.dev/packages/flutter_staggered_grid_view)
- [http](https://pub.dev/packages/http)
- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)

## Customization
- Update the logo in `assets/images/logo.png`.
- Change theme colors in `lib/src/theme/`.

## License
This project is for educational and challenge purposes.
