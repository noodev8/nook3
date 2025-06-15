#!/bin/bash
set -e

# Update system packages
sudo apt-get update

# Install required dependencies for Flutter
sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa

# Remove any existing Flutter installation
sudo rm -rf /opt/flutter

# Install Flutter SDK (latest stable version that includes Dart 3.7.2+)
cd /tmp
wget -q https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.32.4-stable.tar.xz
tar xf flutter_linux_3.32.4-stable.tar.xz
sudo mv flutter /opt/flutter

# Add Flutter to PATH in user profile
echo 'export PATH="/opt/flutter/bin:$PATH"' >> $HOME/.profile
export PATH="/opt/flutter/bin:$PATH"

# Disable analytics to avoid prompts
flutter config --no-analytics

# Verify Flutter installation
flutter --version

# Navigate to Flutter project directory
cd /mnt/persist/workspace/nook3_flutter

# Get Flutter dependencies
flutter pub get

# Enable web support (in case needed)
flutter config --enable-web

# Fix the test file to use the correct app class name
cat > test/widget_test.dart << 'EOF'
// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nook3_flutter/main.dart';

void main() {
  testWidgets('NookApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NookApp());

    // Verify that the welcome screen loads
    expect(find.text('The Nook of Welshpool'), findsOneWidget);
    expect(find.text('Fresh Buffets & Share Boxes'), findsOneWidget);
  });
}
EOF

# Run Flutter doctor to check setup
flutter doctor