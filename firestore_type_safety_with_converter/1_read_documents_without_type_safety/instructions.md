# Read Firestore documents without type-safety

> 💡 If you get stuck, click on the **“Show Solution”** button below, then run the code to see the final result in this step.

In this step, we will read a Firestore **collection** named `poll`, which contains a list of Polls.

## Create `poll` collection in Firestore

At this stage, we don't have such a collection on our Firebase project yet, so let's go and create it with some dummy data. 

On the Firebase console, navigate to Firestore. Click on **"Create database"**, then choose **"Test mode"**. 
> ⚠️ The test mode will make our database open for reads and writes without any security rules. If you're working in a real project, make sure to switch to **production mode** once you're done testing.

![Create Firestore database](https://github.com/pr-Mais/dartpad_workshops/blob/main/firestore_type_safety_with_converter/assets/create-firestore-database.gif?raw=true)

Next, create a new collection named `poll`. It will look like this:

![Poll collection in Firestore](https://github.com/pr-Mais/dartpad_workshops/blob/main/firestore_type_safety_with_converter/assets/poll-collection.png?raw=true)

You can create as many documents as you like.

## Reference the polls collection

It's time to ask Firestore for the list of polls! 

> You can see a number of new lines of code added for you in this step. As our focus is on effect querying and type-safety in this workshop, we won't write much UI code.

Let's scroll down to `TODO(1)`, in line `233`. The first step in reading or writing to Firestore, is to have a reference to what collection we want.

```dart
CollectionReference<Map<String, dynamic>> get _pollsRef =>
      _firestore.collection('poll');
```

## Listen to polls from the collection reference

In `TODO(2)`, we will listen to all the documents in `_pollsRef`. The listener will be attached in the constructor of `PollsState`.

```dart
_pollsRef.snapshots().listen((event) {
  _polls = event.docs;
  notifyListeners();
});
```

## Display the polls

In `TODO(3)`, we will finally see the polls and answers in a `ListView`.

```dart
Expanded(
  child: Consumer<PollsState>(
    builder: (_, pollsState, __) => ListView.builder(
      padding: const EdgeInsets.all(30),
      itemCount: pollsState.polls.length,
      itemBuilder: (_, index) {
        final pollDoc = pollsState.polls[index];

        return PollListItem(
          poll: pollDoc,
          onVote: (i) {},
        );
      },
    ),
  ),
)
```

## What's the problem with using `Map<String, dynamic>` as the reference type

The type assigned to the collection reference is `CollectionReference<Map<String, dynamic>>`, this means the data inside each document that we will get from this reference will be of type `Map<String, dynamic>`. For example, to get the question text of a single poll:

```dart
final question = polls[0]?.data()?['question'];
```

The type of `question` isn't known. Firestore is NoSQL, and each field could have several types, so `question` could be a `null` in one document, and a `int` in another document, therefore we would never be able to set any type rules from the database side! 

This requires us to code defensively. Type-safety is a very crucial part of using a NoSQL database in our projects.