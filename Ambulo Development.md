
# Ambulo Development

## Table of Contents
- [Development Environment Setup with FVM](#development-environment-setup-with-fvm)
- [Organizing and Running Tests](#organizing-and-running-tests)
- [Running Tests in GitHub Actions](#running-tests-in-github-actions)
- [Useful Git Commands](#useful-git-commands)
- [Github Workflow](#github-workflow)

---

## Development Environment Setup with FVM

#### Overview
This guide explains how to set up a consistent development environment for our Flutter project. We will use **FVM (Flutter Version Management)** to manage Flutter SDK versions across all team members' machines. FVM is a tool that allows us to install and switch between multiple Flutter versions easily, ensuring everyone works with the same setup.

---

#### Part 1: Installing FVM and Setting Up Flutter

1. **Install Prerequisites**
   - **Chocolatey**: Install Chocolatey if not already installed. Follow the official guide: [https://chocolatey.org/install](https://chocolatey.org/install).
   - **Android Studio**: Download and install Android Studio (version 2024.1 recommended) from [https://developer.android.com/studio](https://developer.android.com/studio). This is required for the Android toolchain.

2. **Install FVM Using Chocolatey**
   - Open PowerShell or Command Prompt **as Administrator** and run:
     ```
     choco install fvm
     ```
   - *Note*: If you encounter an error related to Python dependencies (e.g., `python312`) and Python is already installed, use this instead:
     ```
     choco install fvm --ignore-dependencies
     ```
   - After installation, verify that FVM is installed by running:
     ```
     fvm
     ```
     You should see a list of available FVM commands. You can also check installed Flutter versions with:
     ```
     fvm list
     ```

3. **Clone the Project from GitHub**
   - To get the project on your machine, run the following commands in your preferred directory:
     ```
     git clone https://github.com/Danielbet21/Ambulo.git
     cd Ambulo
     ```
   - From this point, manage the project as usual with Git (e.g., `git pull`, `git add`, `git commit`, `git push`) to collaborate with the team.

4. **Set Up the Flutter Version**
   - We will use Flutter version `3.29.0` for this project. Install it with FVM:
     ```
     fvm install 3.29.0
     ```
   - Navigate to the project directory (if not already there) and set the project to use this version:
     ```
     cd path_to_project\Ambulo
     fvm use 3.29.0
     ```
   - After running this command, a `.fvm` folder will be created in the project directory, locking the Flutter version for this project.
   - Verify the version inside the project folder:
     ```
     flutter --version
     ```
     This should output `Flutter 3.29.0`. Outside the project folder, 
     running `flutter --version` will show the global Flutter version (if any).
   - To confirm that the project is using the FVM-managed Flutter version, run:
     ```
     Get-Command flutter
     ```
     The output should point to a path inside the `.fvm` folder (e.g., `...\Flutter-Map-Demo\.fvm\versions\3.29.0\bin\flutter.ps1`), ensuring the project runs with the configured version.

5. **Install Project Dependencies**
   - Open the project in **VS Code**.
   - Navigate to the `pubspec.yaml` file, make any small edit (e.g., add a space), and press **Ctrl + S** (or File > Save).
   - This will trigger `flutter pub get` to download all the libraries defined in `pubspec.yaml`.

---

## Organizing and Running Tests

### Overview
In our project, we aim to cover all non-UI functions and UI components with automated tests. We will organize our tests into two main categories:
- **Unit Tests**: These tests cover the logic and backend functions, stored in the `test/Unit Tests/` directory.
- **Widget Tests**: These tests cover UI components, stored in the `test/Widget Tests/` directory.

*Note*: The terms "Unit Tests" and "Widget Tests" are the standard terminology in Flutter. Unit Tests verify the logic of individual functions or classes, while Widget Tests verify the behavior and rendering of UI components.

### Test Structure
For every file in the `lib/` directory, there should be a corresponding test file in the `test/` directory. For example:
- If you have a file `lib/calculator.dart` containing backend logic, create a test file named `test/Unit Tests/calculator_test.dart`.
- If you have a file `lib/screens/home_screen.dart` containing UI components, create a test file named `test/Widget Tests/home_screen_test.dart`.

#### Example of a Unit Test
Suppose you have a file `lib/calculator.dart`:

```dart
class  Calculator {
	double  add(double a, double b) => a + b;
	double  subtract(double a, double b) => a - b;
	double  multiply(double a, double b) => a * b;
	double  divide(double a, double b) => b !=  0  ? a / b :  0;
}
```

The corresponding test file `test/Unit Tests/calculator_test.dart` would look like this:

```dart
import 'package:flutter_application_1/calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Calculator', () {
    final calculator = Calculator();

    test('addition of two numbers', () {
      expect(calculator.add(2, 3), 5);
      expect(calculator.add(-2, -3), -5);
      expect(calculator.add(2, -3), -1);
    });

    test('subtraction of two numbers', () {
      expect(calculator.subtract(5, 3), 2);
      expect(calculator.subtract(-5, -3), -2);
      expect(calculator.subtract(5, -3), 8);
    });

    test('multiplication of two numbers', () {
      expect(calculator.multiply(2, 3), 6);
      expect(calculator.multiply(-2, -3), 6);
      expect(calculator.multiply(2, -3), -6);
    });

    test('division of two numbers', () {
      expect(calculator.divide(6, 3), 2);
      expect(calculator.divide(-6, -3), 2);
      expect(calculator.divide(6, -3), -2);
      expect(calculator.divide(6, 0), 0); // Division by zero should return 0
    });
  });
}

```

#### Example of a Widget Test
Suppose you have a file `lib/screens/home_screen.dart` with a simple widget. The corresponding test file `test/Widget Tests/home_screen_test.dart` would look like this:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // This is a basic Flutter widget test.

    void main() {
      testWidgets('Calculator UI elements are displayed',
          (WidgetTester tester) async {
        // Build our app and trigger a frame
        await tester.pumpWidget(const MyApp());

        // Verify the app title is displayed
        expect(find.text('Simple Calculator'), findsOneWidget);

        // Check for input fields
        expect(find.text('First Number'), findsOneWidget);
        expect(find.text('Second Number'), findsOneWidget);

        // Check for operation buttons
        expect(find.text('+'), findsOneWidget);
        expect(find.text('-'), findsOneWidget);
        expect(find.text('×'), findsOneWidget);
        expect(find.text('÷'), findsOneWidget);

        // Result section should be visible with initial value
        expect(find.text('Result'), findsOneWidget);
        expect(find.text('0'), findsOneWidget);
      });

      testWidgets('Addition operation works correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());

        // Enter values in text fields
        await tester.enterText(find.byType(TextField).at(0), '5');
        await tester.enterText(find.byType(TextField).at(1), '3');

        // Tap the addition button
        await tester.tap(find.text('+'));
        await tester.pump();

        // Check result
        expect(find.text('8'), findsOneWidget);
      });

      testWidgets('Subtraction operation works correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());

        // Enter values in text fields
        await tester.enterText(find.byType(TextField).at(0), '10');
        await tester.enterText(find.byType(TextField).at(1), '4');

        // Tap the subtraction button
        await tester.tap(find.text('-'));
        await tester.pump();

        // Check result
        expect(find.text('6'), findsOneWidget);
      });

      testWidgets('Multiplication operation works correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());

        // Enter values in text fields
        await tester.enterText(find.byType(TextField).at(0), '5');
        await tester.enterText(find.byType(TextField).at(1), '3');

        // Tap the multiplication button
        await tester.tap(find.text('×'));
        await tester.pump();

        // Check result
        expect(find.text('15'), findsOneWidget);
      });

      testWidgets('Division operation works correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());

        // Enter values in text fields
        await tester.enterText(find.byType(TextField).at(0), '10');
        await tester.enterText(find.byType(TextField).at(1), '2');

        // Tap the division button
        await tester.tap(find.text('÷'));
        await tester.pump();

        // Check result
        expect(find.text('5'), findsOneWidget);
      });
    }
  });
}

```

### Running Tests Locally in VS Code
To make running tests convenient in VS Code, we will set up a keyboard shortcut to run all tests with a single key press.

#### Setting Up F6 Shortcut in VS Code
1. Open VS Code.
2. Press **Ctrl + Shift + P** to open the command palette.
3. Type `Preferences: Open Keyboard Shortcuts` and select this option.
4. Search for `Test: Run All Tests`
5. Change the keybinding to `Ctrl+F6`

From now on, pressing **Ctrl + F6** will run all tests in the `test/` directory. You can view the results in the Terminal or the Test Explorer in VS Code.

#### Manual Test Execution
If you prefer running tests manually, you can use the following command in the terminal:
```
flutter test
```

---

## Running Tests in GitHub Actions

### Overview
Our project uses GitHub Actions to automatically run tests on every push or pull request to the `main` branch. The GitHub Actions workflow performs the following steps:
1. Runs all tests in the `test/` directory.
2. Verifies that an APK can be built.
3. Verifies that a Web build can be completed.

This process is fully automated, ensuring that every commit is thoroughly tested.

### GitHub Actions Configuration
Our GitHub Actions workflow is defined in `.github/workflows/main.yml` and looks like this:

```yaml
name: Flutter CI

# Trigger the workflow on push or pull request to the main branch
on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  build:
    name: Build and Test
    runs-on: ubuntu-latest

    steps:
      # Step 1: Checkout the repository code
      - uses: actions/checkout@v4

      # Step 2: Set up Java (required for building APK)
      - uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin' # Specify the Java distribution

      # Step 3: Set up Flutter
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.29.0' # Use your specific Flutter version
          channel: 'stable'

      # Step 4: Install dependencies
      - run: flutter pub get

      # Step 5: Run all tests
      - run: flutter test
        name: Run All Tests

      # Step 6: Build APK
      - run: flutter build apk --release
        name: Build APK

      # Step 7: Build Web
      - run: flutter build web --release
        name: Build Web
```

### Important Note: Managing Test Files
It’s critical to understand that `flutter test` automatically runs every file in the `test/` directory  and expects to find a `main()` function in each file. If a file is empty or entirely commented out, GitHub Actions will fail with an error like "Undefined name 'main'".

To avoid this:
- If you want to disable a test file temporarily, **delete it** from the `test/` directory or rename it so it doesn’t end with `_test.dart` (e.g., `widget_test.dart.bak`).
- Do not leave fully commented-out files in the `test/` directory, as this can lead to confusion, making you think there are tests when there aren’t.

---

## Useful Git Commands

### Overview
To work smoothly with Git and keep the team in sync, we’ll follow a structured workflow. Each team member will work on their own branch, merge changes into the `main` branch frequently (Agile style), and ensure their branch stays updated with `main`.

### Basic Git Workflow
1. **Create Your Own Branch**:
   - When starting a new task, create a branch with a descriptive name:
     ```
     git checkout -b my-feature-branch
     ```
     For example, if you’re working on a login screen feature, name your branch `login-screen`.

2. **Make Changes and Save Them**:
   - After making changes to the code, stage them:
     ```
     git add .
     ```
   - Commit with a clear message:
     ```
     git commit -m "Add login screen UI"
     ```
   - Push your changes to your branch on GitHub:
     ```
     git push origin my-feature-branch
     ```

3. **Merge into `main` via GitHub**:
   - Go to GitHub and click "Create Pull Request" for your branch.
   - Describe your changes, get approval from a team member (if required), and click "Merge Pull Request".
   - Merge frequently (e.g., daily or after each small task) to stay up-to-date and avoid conflicts.

4. **Update Your Branch with `main`**:
   - After your changes are merged into `main`, ensure your branch is updated with the latest changes from `main`:
     ```
     git checkout main
     git pull origin main
     git checkout my-feature-branch
     git merge main
     ```
   - If there are conflicts, resolve them manually, then commit and push again:
     ```
     git add .
     git commit -m "Resolve merge conflicts"
     git push origin my-feature-branch
     ```

### Handling Git Mistakes

#### Undo `git add`
If you added files to staging with `git add` but don’t want to include them in the commit:
- Undo `git add` for a specific file:
  ```
  git restore --staged path/to/file
  ```
- Undo all `git add`:
  ```
  git restore --staged .
  ```

#### Undo a Local Commit (Before Push)
If you made a commit but haven’t pushed it to GitHub:
- Undo the last commit while keeping the changes in staging:
  ```
  git reset --soft HEAD^1
  ```
- Undo the commit and discard all changes:
  ```
  git reset --hard HEAD^1
  ```

#### Undo a Commit After Push
If you pushed a commit to GitHub but want to undo it:
- Undo the last commit and update the remote:
  ```
  git reset --hard HEAD^1
  git push origin my-feature-branch --force
  ```
  *Warning*: Using `--force` can be dangerous if others are working on the same branch. Always notify your team before using this command.

#### Revert to a Previous Version
If you want to revert to a specific commit:
1. Find the commit hash you want to revert to:
   ```
   git log --oneline
   ```
   This lists commits with their hashes (e.g., `a1b2c3d`).
2. Revert to that commit:
   ```
   git reset --hard a1b2c3d
   ```
3. If you’ve already pushed to GitHub, update the remote:
   ```
   git push origin my-feature-branch --force
   ```

#### Additional Useful Commands
- **Check Project Status**:
  ```
  git status
  ```
  This shows which files have been modified, staged, or are ready to commit.

- **View Commit History**:
  ```
  git log --oneline --graph --all
  ```
  This displays the commit history in a visual format.

- **View Changes Before Committing**:
  ```
  git diff
  ```
  This shows the changes you’ve made to files before staging them.

---

## Github Workflow

### Assumptions
- Initially, there is only the `main` branch.
- We will create 3 additional branches: `alpha`, `shai`, `daniel`.
- Shai works on `shai`, Daniel works on `daniel`.
- We work on different files to avoid conflicts.
- Shai works on two computers (laptop and desktop) and syncs between them.
- We merge into `alpha` and `main` together using the GitHub UI.

---

### Keybindings

#### Run all Tests (APK not included)
```
Ctrl+F6
```
#### Update branch (Shai/Daniel) - Sync with alpha
```
Ctrl+Alt+1
```
#### Add Commit Push (Shai/Daniel)
```
Ctrl+Alt+2
```
#### Sync alpha and shai with main / Sync Daniel with main
```
Ctrl+Alt+3
```

### Setup
**Note:** Shai should complete the setup first to create `alpha`, then Daniel can proceed. Coordinate this step to avoid overlap.

### Shai
1. **Clone the repository (new project):**
   ```bash
   git clone <repository-url>
   cd <repository-name>
   ```
2. **Create the `alpha` branch from `main` (only once):**
   ```bash
   git checkout main
   git pull origin main
   git checkout -b alpha
   git push origin alpha
   ```
3. **Create and switch to the `shai` branch from `alpha`:**
   ```bash
   git checkout alpha
   git checkout -b shai
   ```
4. **Push the new `shai` branch to GitHub:**
   ```bash
   git push origin shai
   ```

### Daniel
1. **Clone the repository (new project):**
   ```bash
   git clone <repository-url>
   cd <repository-name>
   ```
2. **Pull the latest changes (after Shai creates `alpha`):**
   ```bash
   git pull origin main
   ```
3. **Create and switch to the `daniel` branch from `alpha`:**
   ```bash
   git checkout alpha
   git checkout -b daniel
   ```
4. **Push the new `daniel` branch to GitHub:**
   ```bash
   git push origin daniel
   ```



---

## Shai

### Stage 1: Individual Work
1. **Start of Stage - Sync with `alpha`:**
   ```bash
   git checkout shai
   git pull origin alpha  # Pulls alpha into shai
   git push origin shai   # Updates shai on GitHub
   ```
2. **Work on Changes:**
   - Make changes to your files.
   ```bash
   git add .
   git commit -m "Description of change (e.g., Added function X)"
   ```
3. **End of Work on One Computer (Before Switching):**
   ```bash
   git push origin shai
   ```
4. **Start Work on the Other Computer:**
   ```bash
   git checkout shai
   git pull origin shai
   ```

### Example Daily Workflow
- Laptop:
  ```bash
  git checkout shai
  git pull origin alpha
  git add . && git commit -m "Update X"
  git push origin shai
  ```
- Desktop:
  ```bash
  git checkout shai
  git pull origin shai
  git add . && git commit -m "Update Y"
  git push origin shai
  ```

---

## Daniel

### Stage 1: Individual Work
1. **Start of Stage - Sync with `alpha`:**
   ```bash
   git checkout daniel
   git pull origin alpha  # Pulls alpha into daniel
   git push origin daniel # Updates daniel on GitHub
   ```
2. **Work on Changes:**
   - Make changes to your files.
   ```bash
   git add .
   git commit -m "Description of change (e.g., Fixed bug Z)"
   git push origin daniel
   ```

### Example Daily Workflow
```bash
git checkout daniel
git pull origin alpha
git add . && git commit -m "Update Z"
git push origin daniel
```

---
## Collaborative

### Stage 2: Merge into `alpha`
1. **Manual Merge via GitHub UI:**
   - Sit together.
   - Create a Pull Request  to `alpha` **(base)** from `shai` **(compare)**   in GitHub, review changes, and merge.
   - Create a Pull Request to `alpha`**(base)** from `daniel` **(compare)**  , review, and merge.
2. **Testing:**
   - Pull `alpha` to your computer:
     ```bash
     git checkout alpha
     git pull origin alpha
     ```
   - Test everything (manually or automatically).
3. **Next Steps:** If all tests pass, proceed to Stage 3. If not, fix in `shai` or `daniel` and repeat from Step 1.

### Stage 3: Merge into `main`
1. **Manual Merge via GitHub UI:**
   - Create a Pull Request to `main`**(base)** from `alpha`**(compare)** , review, and merge.
2. **Testing:**
   - Pull `main` to your computer:
     ```bash
     git checkout main
     git pull origin main
     ```
   - Test everything.
3. **Sync Branches with `main`:**
   - **Shai**:
     ```bash
     git checkout shai
     git pull origin main  # Pulls main into shai
     git push origin shai  # Updates on GitHub
     ```
     
   - Update `alpha`: only 1 user update alpha 
     ```bash
     git checkout alpha
     git pull origin main  # Pulls main into alpha
     git push origin alpha
     git checkout shai
     ```
   - **Daniel**:
     ```bash
     git checkout daniel
     git pull origin main  # Pulls main into daniel
     git push origin daniel
     ```

4. **Result:** All branches (`main`, `alpha`, `shai`, `daniel`) are identical.
5. **Return to Stage 1:** Start individual work again.

---

### Summary
This guide covers everything you need to set up your development environment, organize and run tests, use GitHub Actions, manage Git, and keep branches in sync. If you have any questions or want to add more details, let me know, and I’ll be happy to help! 😊