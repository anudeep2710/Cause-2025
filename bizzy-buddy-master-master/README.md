# BizzyBuddy - Business Management App

BizzyBuddy is a Flutter-based offline-first application designed for retail shopkeepers and medium-scale businesses. It provides essential tools for inventory management, expense tracking, and sales monitoring.

## Features

### 🏪 Business Type Support
- Convenience Store mode
- Medium-scale Business mode

### 📦 Product & Inventory Management
- Add, edit, and delete products
- Track stock levels with visual indicators
- Categorize products
- Set expiry dates
- Search and filter products

### 💰 Sales & Expense Tracking
- Record daily sales and expenses
- View trends with interactive charts
- Filter by date range (7 days/30 days)
- Categorize expenses

### 📊 Dashboard
- Overview of key metrics
- Stock level indicators
- Category distribution charts
- Recent sales list

### ⚙️ Settings
- Theme customization (Light/Dark/System)
- Data export functionality
- Data backup and restore

## Technical Details

### Architecture
- MVVM pattern with Provider/Riverpod
- Offline-first using Hive for local storage
- Material 3 design system
- Modular and scalable codebase

### Dependencies
- State Management: `provider`, `flutter_riverpod`
- Local Storage: `hive`, `hive_flutter`
- Routing: `go_router`
- Charts: `fl_chart`
- UI Components: `flutter_slidable`, `google_fonts`
- Utils: `intl`, `share_plus`

## Getting Started

1. Clone the repository
```bash
git clone https://github.com/yourusername/bizzybuddy.git
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

## Project Structure
```
lib/
├── app/
│   ├── routes/
│   └── theme/
├── models/
├── viewmodels/
├── views/
│   ├── dashboard/
│   ├── products/
│   ├── expenses/
│   └── settings/
├── widgets/
└── services/
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
