# VaporFirebaseDemo
A sample project showing how to connect server-side Swift Vapor to Firebase's Cloud Firestore database. This repository is the demo project for the [Medium article](https://medium.com/rocket-fuel/getting-started-with-firebase-for-server-side-swift-93c11098702a) that I wrote on this subject.

# What Does It Do?
This Vapor server publishes a random number to a Firebase Cloud Firestore database every 60 seconds. The idea is to pair this with something like the [iOS Client Demo App](https://github.com/tylermilner/VaporFirebaseDemo-ClientApp) to show how server-side Swift code can send realtime updates to client devices via Firebase.

# Getting started
If you'd like to run this server yourself, here's what you need to do:
## Create a Firebase App
Create a new app in [Firebase](https://firebase.google.com/). I called mine "VaporFirebaseDemo".

## Install Vapor
Check out the official installation instructions at [vapor.codes](https://vapor.codes) or use Homebrew:
```bash
brew tap vapor/homebrew-tap
brew update
brew install vapor
```

## Clone the repository
```bash
git clone https://github.com/tylermilner/VaporFirebaseDemo.git
```

## Generate the Xcode project
Run the following command to generate an Xcode project from the `Package.swift` file:
```bash
vapor xcode
```

# Running the Server
By default, this server will crash on launch until you've setup your environment variables. Specifically, you need to set the value of the `GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY` environment variable to the RSA private key for your Google Service Account.

## Obtaining the RSA Private Key
Refer to the [Medium article](https://medium.com/rocket-fuel/getting-started-with-firebase-for-server-side-swift-93c11098702a) for help on how to download and massage your Google Service Account's private key into a format suitable for Vapor's `JWTProvider`.

## Setting the Environment Variable
These instructions are also in the article, but the gist of it goes something like:
* Select the "Run" scheme and then choose "Edit Scheme".
* Create an environment variable called `GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY`.
* Set the value of `GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY` to the RSA private key that you generated.

As an alternative to using the environment variable, you can also move the `Config/jwt.json` file into the "secrets" folder (final path would be `Config/secrets/jwt.json`) and then replace `$GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY` with your RSA private key directly in the configuration file. This assumes that your `.gitignore` is already setup to ignore the `Config/secrets` directory. If it's not, **don't do this**!

## Configuring the Server
The only other configuration options you need to modify are in `Config/app.json`:
* `googleServiceAccountEmail` - replace the value for this key with the email address for your Google Service Account.
* `firebaseProjectId` - replace the value for this key with the project identifier for your Firebase app.

## Build and Run
After you've configured the server with your Google Service Account private key, email, and Firebase project ID, you should be able to run the server. Select the `Run` scheme and hit `CMD + R` to build and run the server.

The server in its current form will start publishing random numbers to Firebase as soon as it's started. If you want to manually publish an update to Firebase through the server, you can hit the `/nextRandom` endpoint at anytime by issuing a HTTP `POST` request to `http://0.0.0.0:8080/nextRandom`. The server will then publish a new random number to Firebase and then return the Firebase response to you. This will give you a peek into how Firebase Cloud Firestore structures the document insertion/update.
