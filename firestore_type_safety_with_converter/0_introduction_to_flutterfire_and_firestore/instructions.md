# Introduction to FlutterFire and Firestore

> 💡 if you get stuck, click on **show solution** button below then run the code to see the final result in this step.

FlutterFire stands for **Flutter + Firebase**. It's a collection of plugins and packages to integrate and use Firebase in Flutter applications.

**Firestore** is one of Firebase's popular products, it's a NoSQL real-time database. There's another database option in Firebase, which is the **Real-time Database**. To understand the difference between them, [this's a nice guide](https://firebase.google.com/docs/database/rtdb-vs-firestore) to help you decide which one is suitable for your use case.

In this workshop, we will talk about Firestore only. We will learn how to write effective and type-safe Firestore queries in Flutter, with techniques to parse the data from and back to Firestore.

## Add required packages

To use Firestore in Flutter, we need 2 packages:
1. [`firebase_core`](https://pub.dev/packages/firebase_core)
2. [`cloud_firestore`](https://pub.dev/packages/cloud_firestore)

The **core package** helps us configure Firebase project with our credentials.

To use these packages in this workshop, import them on `TODO(1)`.

Additionally, you will notice 2 packages are added for you:
1. [`firebase_auth`](https://pub.dev/packages/firebase_auth): to help us identify each user as we will use that in building the app.
2. [`provider`](https://pub.dev/packages/provider): to help in state management and decoupling database logic from the UI.

## Create a Firebase project

To link any app with Firebase, we need to get project configurations. 
But first, we need to have a Firebase project. 
To create a Firebase project, follow these steps:

1. You need to have a Gmail account.
2. Go to [console.firebase.google.com](https://console.firebase.google.com/), and click on **Add project**.
3. Once you get into the project, you can create various apps. In this workshop we will create a web app.
![Create web app in the Firebase Console](http://localhost:8080/assets/create-app.gif)
4. Once you copied the configurations, paste them in `TODO(2)`.

> 💡 You will have to repeat this step for all the upcoming steps in the workshop to be able to run the code successfully.

## Initialize Firebase in Flutter

Now that we have the configurations ready, the initialization should happen before any call to any other FlutterFire plugin, including Firestore.
It's usually better to do that before calling `runApp()` in `main()`.

### `TODO(3)`

Mark the `main()` method as `async`, since the initialization method has the return type of `Future<viod>`.

Then call the initialization method:
```dart
// It's important to call this line before initializing Firebase,
// since we need to make sure Flutter binding to be initialized first.
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(options: firebaseOptions);
```

**A common concern here is:** if the initialization is an asynchronous method, it might cause the app to take more time before calling `runApp()`, so a black screen will show for few seconds.

**The simple answer:** it wouldn't be a concern. The reason it's marked as `Future` because it's calling platform channels on native platforms, and similarly on web it's injecting the configurations to the Firebase JS SDK. Therefore, it's not a network call and won't ever take more than few milliseconds.