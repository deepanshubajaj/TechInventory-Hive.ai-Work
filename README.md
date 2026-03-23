# Hive (Tech Inventory)

An iOS UIKit app that demonstrates a simple, scrollable photo grid with pagination.

The app fetches images from the public Lorem Picsum API and displays them in a `UICollectionView`. Tapping an item opens the image’s source URL in an in-app Safari view.

## Features

- 3-column grid layout with responsive cell sizing
- Infinite scroll pagination (loads the next page when you reach the bottom)
- Tap-to-open details using `SFSafariViewController`
- Basic loading indicator

## Tech Stack

- Swift 5
- UIKit + Storyboards
- `URLSession` for networking

## Requirements

- Xcode 16.4+ (project created with Tools Version 16.4)
- iOS deployment target is set to **18.5** in `Hive.xcodeproj` (adjust in Xcode if needed)

## Getting Started

1. Clone the repo.
2. Open `Hive.xcodeproj` in Xcode.
3. Select the `Hive` scheme.
4. Run on an iOS Simulator or a device.

## Running Tests (Optional)

From Xcode: Product → Test

From the command line:

```sh
xcodebuild test -project Hive.xcodeproj -scheme Hive -destination 'platform=iOS Simulator,name=iPhone 16'
```

If the destination name doesn’t exist on your machine, list available simulators and pick one:

```sh
xcrun simctl list devices
```

## API

- Image list: `https://picsum.photos/v2/list?page={page}&limit=10`
- No API key required

## License

Licensed under the Apache License 2.0. See `LICENSE`.

