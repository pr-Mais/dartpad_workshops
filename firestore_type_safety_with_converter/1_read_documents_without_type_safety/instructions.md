# Read Firestore documents without type-safety

> 💡 If you get stuck, click on the **“Show Solution”** button below, then run the code to see the final result in this step.

In this step, you will read a Firestore **collection** named `poll`, which contains a list of Polls.

## Create `poll` collection in Firestore

At this stage, you don't have such a collection on your Firebase project yet, so let us go and create it with some dummy data. 

On the Firebase console, navigate to Firestore. Click on **"Create database"**, then choose **"Test mode"**. 
> ⚠️ The test mode will make your database open for reads and writes without any security rules. If you're working in a real project, make sure to switch to **production mode** once you're done testing.

![Create Firestore database](https://github.com/pr-Mais/dartpad_workshops/blob/main/firestore_type_safety_with_converter/assets/create-firestore-database.gif?raw=true)

Next, create a new collection named `poll`. You can't create a collection without at least creating one document (note step 2 in the gif). The document ID will be auto generated once you click on the button **"Auto ID"**.

![Create poll collection](https://github.com/pr-Mais/dartpad_workshops/blob/main/firestore_type_safety_with_converter/assets/create-collection.gif?raw=true)

Lastly, fill the first document with the following data structure:

```json
{
  "answers" : [
    0: {
      "id": 0,
      // The value of the answer text could be any of your choice.
      "text": "Yes!"
    },
    1: {
      "id": 1,
      // The value of the answer text could be any of your choice.
      "text": "Absolutely yes!"
    },
  ],
  // The value of the question string could be any of your choice.
  "question": "Are you liking Flutter?",
  // "users"? Missing users here?
}
```

Once the collection is created, it will look like this:

![Poll collection in Firestore with documents](https://github.com/pr-Mais/dartpad_workshops/blob/main/firestore_type_safety_with_converter/assets/poll-collection.png?raw=true)

You can create as many documents as you like.

## Reference the polls collection

It's time to ask Firestore for the list of polls! 

> You can see a number of new lines of code added for you in this step. As the focus is on effect querying and type-safety in this workshop, you won't have to write much UI code, new widgets will be provided for you throughout the workshop.

Scroll down to `TODO(1)`. The first step in reading or writing to Firestore, is to have a reference to the required collection.

```dart
CollectionReference<Map<String, dynamic>> get _pollsRef =>
      _firestore.collection('poll');
```

## Listen to polls from the collection reference

In `TODO(2)`, you will listen to all the documents in `_pollsRef`. The listener will be attached in the constructor of `PollsState`.

```dart
_pollsRef.snapshots().listen((event) {
  _polls = event.docs;
  notifyListeners();
});
```

## Display the polls

In `TODO(3)`, you will finally see the polls and answers in a `ListView`.

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

The type assigned to the collection reference is `CollectionReference<Map<String, dynamic>>`, this means the data inside each document that you will get from this reference will be of type `Map<String, dynamic>`. For example, to get the question text of a single poll:

```dart
final question = polls[0]?.data()?['question'];
```

The type of `question` isn't known. Firestore is NoSQL, and each field could have several types, so `question` could be a `null` in one document, and a `int` in another document, therefore you would never be able to set any type rules from the database side! 

This requires us to code defensively. Type-safety is a very crucial part of using a NoSQL database in our projects.