import 'package:flutter/material.dart';
import 'package:time_tracker/sign_in/email_sign_in_form_change_notifier.dart';

class EmailSignInPage extends StatelessWidget {
  const EmailSignInPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In with Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: EmailSignInFormChangeNotifier.create(context),
        ),
      ),
      backgroundColor: Colors.grey[200],
    );
  }
}
