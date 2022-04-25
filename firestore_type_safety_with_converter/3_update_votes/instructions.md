# Update votes

> 💡 If you get stuck, click on the **“Show Solution”** button below, then run the code to see the final result in this step.

Now that you have the power of type-safety to read Firestore collections, what about updating existing documents?

In this step, you will add a voting method to each poll, which includes updating existing polls to reflect the new votes.

## Voting logic

Each user is authenticated anonymously and has a unique ID. When a user clicks on an answer in a poll to vote for it, you need to make sure that any user can vote once for any poll. Therefore, on each poll, you will store a map of users, linking each user to an answer by its ID.

![Users map in a poll document](https://github.com/pr-Mais/dartpad_workshops/blob/main/firestore_type_safety_with_converter/assets/poll-votes.png?raw=true)

## Update nested fields in Firestore

In order to update `users` map, you need to update a field inside a map inside a document, this's a "nested field".

In Firestore, nested fields can be updated easily by using the `update` method. Go to `TODO(1)`, and add the following method to the `PollsState` class which updates the answer ID for a specific user:

```dart
Future<void> vote(String pollId, int answerId) async {
  final user = FirebaseAuth.instance.currentUser;
  await _pollsRef.doc(pollId).update({'users.${user!.uid}': answerId});
}
```

Note how you used the same `_pollsRef` without any additional code to transform the poll object.

For more information about updating data, [see FlutterFire Firestore documentation](https://firebase.flutter.dev/docs/firestore/usage#updating-documents).

## Call `vote` from the UI

In `TODO(2)`, you will simply call `vote()` and pass it the poll ID and answer ID. If you try to vote on any poll now, you can see the text color changing to amber, indicating that this is the answer you voted for. Additionally, the votes count dynamically increases since your vote adds up to the users' collection.

```dart
return PollListItem(
  poll: pollDoc,
  //TODO(2): call `vote` and pass it the current answer id.
  onVote: (answerId) => pollsState.vote(pollDoc.id, answerId),
);
```