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
          Expanded(
            child: Consumer<PollsState>(
              builder: (_, pollsState, __) => ListView.builder(
                padding: const EdgeInsets.all(30),
                itemCount: pollsState.polls.length,
                itemBuilder: (_, index) {
                  final pollDoc = pollsState.polls[index];

                  return PollListItem(
                    poll: pollDoc,
                    //TODO(2): call `vote` and pass it the current answer id.
                    onVote: (answerId) {}, // Please give this variable a more helpful name to guide the taker.
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}

class PollListItem extends StatelessWidget {
  const PollListItem({
    Key? key,
    required this.poll,
    required this.onVote,
  }) : super(key: key);

  final QueryDocumentSnapshot<Poll> poll;
  final void Function(int) onVote;

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthState>().user!.uid;
    final pollData = poll.data();
    final answers = pollData.answers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            pollData.question,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        for (var answer in answers)
          ListTile(
            title: Text(answer.text),
            selected: pollData.users[uid] == answer.id,
            trailing: Text('Votes: ${answer.votes}'),
            onTap: () => onVote(answer.id),
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
  List<QueryDocumentSnapshot<Poll>>? _polls;
  List<QueryDocumentSnapshot<Poll>> get polls => _polls ?? [];

  final _firestore = FirebaseFirestore.instance;

  CollectionReference<Poll> get _pollsRef =>
      _firestore.collection('poll').withConverter<Poll>(
            fromFirestore: (snapshot, _) => Poll.fromJson(snapshot.data()),
            toFirestore: (Poll poll, _) => poll.toJson(),
          );

  PollsState() {
    _pollsRef.snapshots().listen((event) {
      _polls = event.docs;
      notifyListeners();
    });
  }

  //TODO(1): add vote() method.
}

class Poll {
  /// represents the `question` field.
  final String question;

  /// represents the `answers` field.
  final List<Answer> answers;

  /// represents the `users` field.
  final Map<String, int> users;

  Poll({
    required this.question,
    required this.answers,
    this.users = const {},
  });

  factory Poll.fromJson(Map<String, dynamic>? data) {
    final users = (data!['users'] ?? {}).cast<String, int>();
    final answers = data['answers']
        .map((answerData) => Answer.fromJson(answerData, users))
        .toList()
        .cast<Answer>();

    return Poll(
      answers: answers,
      question: data['question'],
      users: users,
    );
  }

  toJson() {
    final answersMap = <Map<String, dynamic>>[];

    for (var answer in answers) {
      answersMap.add(answer.toJson());
    }

    return {
      'question': question,
      'answers': answersMap,
      'users': users,
    };
  }
}

class Answer {
  final int id;
  final String text;
  final int votes;

  Answer({
    required this.text,
    required this.id,
    this.votes = 0,
  });

  factory Answer.fromJson(Map<String, dynamic> data, Map<String, int> users) {
    // Votes is the total of users who voted for this answer by its Id.
    // The logic to calculate total votes is now done on the data layer,
    // making the widgets layer clean and separate from logic.
    int votes = 0;

    for (String user in users.keys) {
      if (users[user] == data['id']) {
        votes++;
      }
    }

    return Answer(
      text: data['text'],
      id: data['id'],
      votes: votes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'id': id,
    };
  }
}
