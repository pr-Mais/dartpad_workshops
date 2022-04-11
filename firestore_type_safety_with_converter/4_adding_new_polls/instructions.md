# Adding new polls

> 💡 if you get stuck, click on **show solution** button below then run the code to see the final result in this step.

Read, write... we're still missing `create`!

Let's add new polls and see how the converters we added previously on `_pollsRef` will make this step easy and clean.

Before we go further, 2 new widgets has been added to help in this step:
- Line `200`: `CreatePollButton` a custom button design with `onTap` callback. 
- Line `236`: `NewPollSheet` a new page designed to create polls, with `onSave` callback that returns a new `Poll` object if all fields are valid.

## Call `add` on `_pollsRef`

Go to `TODO(1)`, and let's add the new poll to the database:

```dart
Future<void> createPoll(Poll poll) async {
  await _pollsRef.add(poll);
}
```

There's no need to call `toJson()` on the poll, we simply pass it to `add`, since `toJson` has already been declared as the `toFirestore` property in `withConverter`, we won't need to call it again.

## Creating new polls

The last step is to construct a new poll object from the data the user enters in `NewPollSheet`, then add it to Firestore. On `TODO(2)`, add the following code:

```dart
void onCreate() {
  if (formKey.currentState!.validate() && answersControllers.isNotEmpty) {
    // ADD FROM HERE
    Poll poll = Poll(
      answers: [
        for (int answerId in answersControllers.keys)
          Answer(
            id: answerId,
            text: answersControllers[answerId]!.text,
          ),
      ],
      question: questionController.text,
    );

    widget.onSave(poll);
    // TO HERE

    Navigator.of(context).pop();
  }
}
```

If you scroll up to `line 133`, we're calling `createPoll` from `PollsState` and giving it the newly constructed poll in the sheet.

## Resources

With this we reach the final step in this workshop. To learn more about the different methods available in the Firestore SDK in Flutter, [visit the documentation](https://firebase.flutter.dev/docs/firestore/usage).

Remember that type-safety should always be your friend in creating Flutter apps. Whether it's Firestore, or any other type of data, make sure you code defensively, and guard against possibly unexpected data types.