# Emoticon
An Emoticon Keyboard offering a curated list of emoticons.

Preview
---
![keyboard](Previews/keyboard.gif)

Requirement
---
- iOS 8.3 (realmSwift)
- Xcode 6.3
- Apple iOS developer account

Build with Xcode
---
- install Pod packages
- setup App Groups

Emoticons
---
The emoticons are scraped from http://japaneseemoticons.me/ using the casper.js script.

Usage
---
1. Install the hosting app.
2. Tap the app icon to open it. (This step is required to initialize the in-app emoticon database)
3. Then, go to your iOS Settings.
4. Then go to General > Keyboards > Add New Keyboard.
5. Just below the suggested keyboards section is where you'll find a list of installed third-party keyboards. Select EmoticonKeyboard.
6. Select the EmoticonKeyboard you just added, turn on **Allow Full Access**. (This step is required to grant the keyboard extension access to the emoticon database).

Feedback
---
Please submit an issue at https://github.com/zhxnlai/Emoticon/issues/new
