#!/bin/bash

echo "🔍 Checking Google Sign In Configuration..."

GOOGLE_PLIST="ios/Runner/GoogleService-Info.plist"

if [ ! -f "$GOOGLE_PLIST" ]; then
    echo "❌ GoogleService-Info.plist not found!"
    exit 1
fi

CLIENT_ID=$(grep -A 1 "REVERSED_CLIENT_ID" "$GOOGLE_PLIST" | grep string | sed 's/.*<string>//;s/<\/string>.*//' | tr -d '\t')

if [ -z "$CLIENT_ID" ]; then
    echo "❌ REVERSED_CLIENT_ID not found in GoogleService-Info.plist"
    echo "⚠️  This means Google Sign In is not properly configured in Firebase Console"
    echo ""
    echo "Please:"
    echo "1. Enable Google Sign In in Firebase Console (Authentication → Sign-in method)"
    echo "2. Download updated GoogleService-Info.plist"
    echo "3. Replace ios/Runner/GoogleService-Info.plist"
    echo "4. Run this script again"
    exit 1
fi

echo "✅ Found REVERSED_CLIENT_ID: $CLIENT_ID"
echo "📝 Updating Info.plist..."

sed -i '' "s|com.googleusercontent.apps.YOUR-CLIENT-ID|$CLIENT_ID|g" "ios/Runner/Info.plist"

echo "✅ Info.plist updated successfully!"
echo ""
echo "Next steps:"
echo "1. Run: flutter clean"
echo "2. Run: cd ios && pod install"
echo "3. Run: flutter run"
