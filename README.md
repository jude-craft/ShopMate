# ShopMate

ShopMate is a modern Flutter application designed to help shop owners efficiently manage their inventory, record sales, track profits, and receive timely alerts for low or out-of-stock items. With a clean interface and insightful analytics, ShopMate empowers you to make smarter business decisions.

![ShopMate Icon](assets/images/icon.png)

---

## Features

- **Welcome & Onboarding**
  - Beautiful animated welcome screen for a smooth first-time experience.

- **Home Dashboard**
  - At-a-glance stats: today’s sales, product count, low/out-of-stock alerts.
  - Quick actions for adding sales or products.

- **Stock Management**
  - Add, edit, and delete products with details like category, supplier, pricing, and expiry.
  - Real-time low stock and out-of-stock alerts.
  - Track total investment, current stock value, and profit per product.
  - Search, sort, and filter products.

- **Sales Management**
  - Record new sales with product, quantity, price, and payment method (Cash/M-Pesa).
  - View all sales and filter by date, product, or payment method.
  - Automatic stock deduction and profit calculation on each sale.

- **Reports & Analytics**
  - Visual sales trends (line/bar charts) for different periods (Today, Week, Month, Year).
  - Top products and product performance analytics.
  - Quick stats: total sales, profit, transactions, items sold, and more.
  - Export report feature (coming soon).

- **Settings**
  - Theme switching (light/dark mode).
  - App customization and preferences.

---

## Tech Stack

- **Frontend:** Flutter (Dart)
- **State Management:** Provider
- **Database:** SQLite (local, via `sqflite` package)
- **Charts:** fl_chart
- **Animations:** lottie, flutter_animate

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Dart SDK (comes with Flutter)
- Android Studio, VS Code, or your preferred IDE

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Jude254-programmer/shop_mate.git
   cd shop_mate
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

---

## Project Structure

```
lib/
  main.dart                # App entry point
  src/
    features/
      screens/
        home/              # Home dashboard
        stock/             # Stock management
        sales/             # Sales management
        reports/           # Reports & analytics
        welcome/           # Welcome/onboarding
      providers/           # App-wide providers
      models/              # Data models
      theme/               # App theming
      widgets/             # Shared widgets
assets/
  images/                  # App icons and images
```

---

## Screenshots

>

---

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

---

## License

This project is licensed under the MIT License.

---

**ShopMate** – _Your smart shop assistant!_

