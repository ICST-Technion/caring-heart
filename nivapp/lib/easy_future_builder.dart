// TODO change
import 'package:flutter/material.dart';

Widget _waitingBuilder() => Center(
      child:
          Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
        CircularProgressIndicator(),
        Text(
          "טוען נתונים...",
          textDirection: TextDirection.rtl,
        )
      ]),
    );

// TODO change
Widget _errorBuilder(String err) => Center(child: Text(err));

FutureBuilder easyFutureBuilder<T>(
    {required Future<T> future,
    required Widget Function(BuildContext, T) doneBuilder,
    Widget Function() waitingBuilder = _waitingBuilder,
    Widget Function(String err) errorBuilder = _errorBuilder}) {
  return FutureBuilder(
    future: future,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        // throw snapshot.error!;
        return errorBuilder(snapshot.error.toString());
      }
      if (snapshot.connectionState == ConnectionState.done) {
        return doneBuilder(context, snapshot.data);
      }
      return waitingBuilder();
    },
  );
}
