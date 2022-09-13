import 'package:flutter/material.dart';
import 'screen/home_screen.dart';
import 'screen/login_screen.dart';

void main() async {
  runApp(MyApp());
}

enum Status {
  Disconnected,
  Connected,
  Loading,
  FailedLogin,
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  static ValueNotifier<Status> telegramStatus = ValueNotifier<Status>(Status.Disconnected);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.grey,
        ),
        home: Scaffold(
            body: ValueListenableBuilder<Status>(
              builder: (BuildContext context, Status status, Widget? child) {
                print(telegramStatus.value);
                print(status);
                print('\n');
                if (telegramStatus.value == Status.Loading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (telegramStatus.value == Status.Connected) {
                  return const HomeScreen();
                } else {
                  return const LoginScreen();
                  //child: Text('State: ${snapshot.connectionState}'),
                }
              },
              valueListenable: telegramStatus,
            ),
        )
    );
  }
}
