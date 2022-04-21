# Data models and Firestore converters

> 💡 If you get stuck, click on the **“Show Solution”** button below, then run the code to see the final result in this step.

In the previous step, you have seen how dynamic access to properties in a document could be risky.
Let us now add a layer of type-safety!

## Create `Poll` and `Answer` models

Scroll down to `TODO(1)` and follow the instructions in this section.

The poll document has the following structure:

```
pollId
|___ question (String)
|___ answers (List)
|___ users (Map)
```

To represent it as a data model in Dart, you will create a class named `Poll`. This class will have a property matching each field in the Firestore document.

```dart
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
}
```

Note how each field has a clear type. It's important to not leave lists and maps without specifying the type of object inside it. In this case, you already know that the `users` map has `String` keys and `int` values. Similarly, each answer could be represented with a new model, as each answer in the list is a map with its own fields.

```dart
class Answer {
  final int id;
  final String text;
  final int votes;

  Answer({
    required this.text,
    required this.id,
    this.votes = 0,
  });
}
```

The `votes` property is not one of the fields stored in the database. Remember where you calculated votes for each answer?
This transformation code can now be included as a property in each answer as well.

## `fromJson` factory constructor

Let us add another constructor to each model.

```dart
// Add it inside `Poll` class.
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

// Add it inside `Answer` class.
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
```

The `votes` is now calculated on the fly for each answer, therefore no need for the extra logic in `PollListItem` 😄

## `toJson()` instance method

The constructor above instantiates a new object from a Map. This is helpful when reading documents from Firestore, but you also need to write to Firestore, in which case you need to get back a Map representation of each model.

```dart
// Add inside `Poll` class.
Map<String, dynamic> toJson() {
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

// Add inside `Answer` class.
Map<String, dynamic> toJson() {
  return {
    'text': text,
    'id': id,
  };
}
```

## Put it all together

You're now ready to use the models. In `TODO(2)` & `TODO(3)`, change the list type from `Map<String, dynamic>` to `Poll`.

Next, you will use the magical `withConvereter()` method on the collection reference, scroll back to `TODO(4)`, and change it to the following:

```dart
CollectionReference<Poll> get _pollsRef =>
    _firestore.collection('poll').withConverter<Poll>(
          fromFirestore: (snapshot, _) => Poll.fromJson(snapshot.data()),
          toFirestore: (Poll poll, _) => poll.toJson(),
        );
```

Let us talk a bit about what's happening here. The data received from Firestore is a JSON-like, key-value pairs. The method `withConverter()` will take 2 arguments, a fromJson and toJson methods. It will handle transformation of data for you on all the operations done on this reference. For reads, you will get `Poll` instead of `Map`. In writes, you can pass a `Poll` directly without doing any manual pre-processing to convert it to `Map` back again.

So if you want to add a new poll, you would simply do:

```dart
Poll poll = Poll({...});
_pollsRef.add(poll);
```

## Cleaning up `PollListItem`

In the last step on `TODO(5)`, you will go to `PollListItem`, and remove `votes()` method, now that it's a property of `Answer`.
Then read the votes from answer object in `TODO(6)`.

```dart
trailing: Text('Votes: ${answer.votes}'),
```
