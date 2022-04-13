# Introduction to FlutterFire and Firestore

> 💡 If you get stuck, click on the **“Show Solution”** button below, then run the code to see the final result in this step.

FlutterFire stands for **Flutter + Firebase**. It's a collection of plugins and packages to integrate and use Firebase in Flutter applications.

**Firestore** is one of Firebase's popular products, it's a NoSQL real-time database. There's another database option in Firebase, which is the **Real-time Database**. To understand the difference between them, [this is a nice guide](https://firebase.google.com/docs/database/rtdb-vs-firestore) to help you decide which one is suitable for your use case.

In this workshop, you will learn how to write effective and type-safe Firestore queries in Flutter, with techniques to serialize the data from and back to Firestore.

## Add required packages

To use Firestore in Flutter, you need 2 packages:
1. [`firebase_core`](https://pub.dev/packages/firebase_core)
2. [`cloud_firestore`](https://pub.dev/packages/cloud_firestore)

The **core package** allows you to configure a Firebase project with your credentials.

In order to use these packages in this workshop, import them on `TODO(1)`.

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
```

Additionally, you will notice 2 packages are added for you:
1. [`firebase_auth`](https://pub.dev/packages/firebase_auth): to help you uniquely identify each user as you will use that in building the app.
2. [`provider`](https://pub.dev/packages/provider): to help in state management and decoupling database logic from the UI.

## Create a Firebase project

To link any app with Firebase, you need to get project configurations. 
But first, you need to have a Firebase project. 
To create a Firebase project, follow these steps:

1. You need to have a Gmail account.
2. Go to [console.firebase.google.com](https://console.firebase.google.com/), and click on **Add project**.
3. Once you get into the project, you can create various apps. In this workshop you will create a web app.
![Create web app in the Firebase Console](https://github.com/pr-Mais/dartpad_workshops/blob/main/firestore_type_safety_with_converter/assets/create-app.gif?raw=true)
4. Once you copied the configurations, paste them in `TODO(2)`.

> 💡 You will have to repeat this step for all the upcoming steps in the workshop to be able to run the code successfully.

## Anonymous sign-in method

[Firebase Auth] is used in this project to uniquely identify each user. It provides various options for sign-in methods, like Email and Password, Google, and the one which is used in this workshop, **anonymous sign-in**.

Before you can use any sign-in provider, you have to enable it explicitly in the Firebase console.
![Enable Firebase Auth in the Firebase Console](https://github.com/pr-Mais/dartpad_workshops/blob/main/firestore_type_safety_with_converter/assets/enable-auth.gif?raw=true)
## Initialize Firebase in Flutter

Now that you have the configurations ready, the initialization should happen before any call to any other FlutterFire plugin, including Firestore.
It's usually better to do that before calling `runApp()` in `main()`.

### `TODO(3)`

Mark the `main()` method as `async`, since the initialization method has the return type of `Future<void>`.

Then call the initialization method:
```dart
// It's important to call this line before initializing Firebase,
// since Flutter binding needs to be initialized first.
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(options: firebaseOptions);
```

**A common concern here is:** if the initialization is an asynchronous method, it might cause the app to take more time before calling `runApp()`, so a black screen will show for a few seconds.

**The simple answer:** it wouldn't be a concern. The reason it's marked as `Future` is that it's calling platform channels on native platforms, and similarly on web it's injecting the configurations to the Firebase JS SDK. Therefore, it's not a network call and won't ever take more than a few milliseconds.