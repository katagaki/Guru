# Guru
Intelligent password manager for iOS

## Compiling

To compile Guru, open the project in Guru, you will need to prepare:

- A Have I Been Pwned API key: get it from the [Have I Been Pwned website](https://haveibeenpwned.com). The API key should be placed in an APIKeys.plist file in the Guru folder within the project, and should contain a key-value pair where the key is 'hibp', and the value is your API key.
- Apple Developer account, or Apple ID for signing.
- Xcode 13 with iOS 15 support.

You may need to update the packages in the Swift Package Manager as well before you can build.

## To-Do

- Implement Online Sources feature.
- Implement adding of new logins from AutoFill.
- Make import progress stick on all views.
- Make breach detection report progress.
