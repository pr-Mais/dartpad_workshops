// ignore_for_file: unused_field, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//TODO: paste your Firebase project configurations here.
const firebaseOptions = FirebaseOptions(
  apiKey: "...",
  authDomain: "...",
  projectId: "...",
  storageBucket: "...",
  messagingSenderId: "...",
  appId: "...",
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);

  runApp(
    ChangeNotifierProvider<AuthState>(
      create: (_) => AuthState(),
      child: const FirestoreApp(),
    ),
  );
}

class FirestoreApp extends StatefulWidget {
  const FirestoreApp({Key? key}) : super(key: key);

  @override
  State<FirestoreApp> createState() => _FirestoreAppState();
}

class _FirestoreAppState extends State<FirestoreApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: Consumer<AuthState>(
        builder: (_, auth, __) {
          // If a guest has signed in.
          if (auth._user != null) {
            return ChangeNotifierProvider<PollsState>(
              create: (_) => PollsState(),
              child: const PollsPage(),
            );
          } else {
            // If no guest signed in, we prompt them to sign in.
            return const WelcomePage();
          }
        },
      ),
    );
  }
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get Started with FlutterFire'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to FlutterFire Polls!',
                style: Theme.of(context).textTheme.headline4,
              ),
              const SizedBox(height: 20),
              const Text('To get started, enter your name.'),
              const SizedBox(height: 20),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: nameController,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Consumer<AuthState>(
                builder: (_, auth, __) => ElevatedButton(
                  onPressed: () => auth.signUpNewGuest(nameController.text),
                  child: const Text('Start'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class PollsPage extends StatelessWidget {
  const PollsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = context.watch<AuthState>().user!.displayName;

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome ${name ?? 'User'}'),
      ),
      body: Column(
        children: [
          //TODO(3): consume the `PollsState` to get the list of current polls, then pass them to a `ListView` widget.
        ],
      ),
    );
  }
}

class PollListItem extends StatelessWidget {
  const PollListItem({
    Key? key,
    required this.poll,
    this.onVote,
  }) : super(key: key);

  final QueryDocumentSnapshot<Map<String, dynamic>> poll;
  final void Function(int)? onVote;

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthState>().user!.uid;
    final pollData = poll.data();
    final answers = pollData['answers'];

    /// Votes is the total of users who voted for this answer by its Id.
    int votes(Map<String, dynamic> answer) {
      int votes = 0;

      if (pollData.containsKey('users')) {
        final users = pollData['users'].cast<String, int>();

        for (String userId in users.keys) {
          if (users[userId] == answer['id']) {
            votes++;
          }
        }
      }

      return votes;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            pollData['question'],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        for (var answer in answers)
          ListTile(
            title: Text(answer['text']),
            selected: pollData['users']?[uid] == answer['id'],
            trailing: Text('Votes: ${votes(answer)}'),
            onTap: onVote != null ? () => onVote!(answer['id']) : null,
          ),
        const Divider(),
      ],
    );
  }
}

class AuthState extends ChangeNotifier {
  User? _user;
  User? get user => _user;

  final _auth = FirebaseAuth.instance;

  AuthState() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signUpNewGuest(String name) async {
    try {
      await _auth.signInAnonymously();
      await _auth.currentUser!.updateDisplayName(name);
      await _auth.currentUser!.reload();

      _user = FirebaseAuth.instance.currentUser;
      notifyListeners();
    } on FirebaseAuthException {
      rethrow;
    }
  }
}

class PollsState extends ChangeNotifier {
  List<QueryDocumentSnapshot<Map<String, dynamic>>>? _polls;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> get polls => _polls ?? [];

  final _firestore = FirebaseFirestore.instance;

  //TODO(1): create a collection reference to the collection named `poll`.

  PollsState() {
    //TODO(2): listen to real-time changes in the polls collection using `snapshots`.
  }
}
