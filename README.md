# Expense Tracker

A simple Flutter app to track your personal expenses, set monthly budgets, and visualize spending with charts.

## Features

* Add, edit, and delete expenses
* Categorize expenses
* Set monthly budgets and track remaining budget
* View expenses by category
* Visual charts for insights (pie chart by category)
* Filter expenses by category
* Local storage with Hive for offline persistence

## Screens

* **Home:** Overview of expenses and quick access to actions
* **Add Expense:** Form to create or edit an expense
* **Budget:** Set and view monthly budgets
* **Charts:** Visualize expenses using pie charts

## Technologies & Packages

* **Flutter**: Cross-platform UI framework
* **Riverpod**: State management
* **Hive**: Local NoSQL storage
* **http**: Fetch categories from API
* **intl**: Date formatting

## Installation

1. Clone the repository:

   ```
   git clone <repository-url>
   ```
2. Navigate to the project directory:

   ```
   cd expense_tracker
   ```
3. Install dependencies:

   ```
   flutter pub get
   ```
4. Run the app:

   ```
   flutter run
   ```

## Usage

* Open the app and add your first expense.
* Set a monthly budget via the budget screen.
* View your spending trends in the charts screen.
* Filter expenses by category using the filter button on the home screen.

## Folder Structure

```
lib/
├── common/          # App-wide utilities, routes
├── models/          # Data models (Expense, Category, Budget)
├── providers/       # Riverpod state providers
├── services/        # API and storage services
├── views/
│   ├── screens/     # Screens: Home, AddExpense, Budget, Charts
│   └── widgets/     # Reusable widgets: BalanceCard, ExpenseList
└── main.dart        # App entry point
```

## Future Enhancements

1. Currency: Extract currency into a class.
2. Exchange Rate: Track spending among different currencies and convert it to a default selected currency.
3. Profile: Create a profile with the ability to import/export spendings in CSV/PDF formats.
4. Online: Invite others to join a group expense.
