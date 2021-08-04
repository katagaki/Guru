# Guru
Intelligent password manager for iOS

## About

You can learn more about Guru on [the Guru website](https://mypwd.guru). The website also contains links to TestFlight, and a list of changes and known issues.

## Compiling

To compile Guru, open the project in Guru, you will need to prepare:

- A Have I Been Pwned API key: get it from the [Have I Been Pwned website](https://haveibeenpwned.com). The API key should be placed in an APIKeys.plist file in the Guru folder within the project, and should contain a key-value pair where the key is 'hibp', and the value is your API key.
- Apple Developer account, or Apple ID for signing.
- Xcode 13 with iOS 15 support: currently in beta.

You may need to update the packages in the Swift Package Manager as well before you can build.

## To-Do

- Implement Basic and Enhanced password transformation features.
- Implement adding of new logins from AutoFill.
- Implement password questionnaire during onboarding.
- Change Automatically Learned Knowledge to Online Sources.
- Make import progress stick on all views.
- Make breach detection report progress.
