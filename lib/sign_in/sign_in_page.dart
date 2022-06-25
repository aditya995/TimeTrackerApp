import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/common_widgets/show_exception_alert_dialog.dart';
import 'package:time_tracker/services/auth.dart';
import 'package:time_tracker/sign_in/email_sign_in_page.dart';
import 'package:time_tracker/sign_in/sign_in_manager.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({Key? key, required this.manager, required this.isLoading})
      : super(key: key);

  final SignInManager manager;
  final bool isLoading;

  static Widget create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return ChangeNotifierProvider<ValueNotifier<bool>>(
      create: (_) => ValueNotifier<bool>(false),
      child: Consumer<ValueNotifier<bool>>(
        builder: (_, isLoading, __) => Provider<SignInManager>(
          create: (_) => SignInManager(auth: auth, isLoading: isLoading),
          child: Consumer<SignInManager>(
            builder: (_, manager, __) => SignInPage(
              manager: manager,
              isLoading: isLoading.value,
            ),
          ),
        ),
      ),
    );
  }

  void _showSignInError(BuildContext context, Exception exception) {
    if (exception is FirebaseException &&
        exception.code == 'ERROR_ABORTED_BY_USER') {
      return;
    }
    showExceptionAlertDialog(context,
        title: 'Sign in failed', exception: exception);
  }

  Future<void> _signInAnonymously(BuildContext context) async {
    try {
      await manager.signInAnonymously();
    } on Exception catch (e) {
      _showSignInError(context, e);
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      await manager.signInWithGoogle();
    } on Exception catch (e) {
      _showSignInError(context, e);
    }
  }

  Future<void> _signInWithFacebook(BuildContext context) async {
    try {
      await manager.signInWithFacebook();
    } on Exception catch (e) {
      _showSignInError(context, e);
    }
  }

  void _signInWithEmail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => EmailSignInPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign in page'),
        centerTitle: true,
      ),
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: 50, child: _buildHeader()),
          SizedBox(
            height: 48,
          ),
          TextButton(
            onPressed: isLoading ? null : () => _signInWithGoogle(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/google-logo.png'),
                Text('Sign in with Google'),
                Opacity(
                    opacity: 0.0, child: Image.asset('assets/google-logo.png')),
              ],
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              primary: Colors.black,
            ),
          ),
          SizedBox(
            height: 8,
          ),
          // TextButton(
          //   onPressed: isLoading ? null : () => _signInWithFacebook(context),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Image.asset('assets/facebook-logo.png'),
          //       Text('Sign in with Facebook'),
          //       Opacity(
          //           opacity: 0.0,
          //           child: Image.asset('assets/facebook-logo.png')),
          //     ],
          //   ),
          //   style: TextButton.styleFrom(
          //       backgroundColor: Colors.indigo, primary: Colors.white),
          // ),
          TextButton(
            onPressed: isLoading ? null : () => _signInWithEmail(context),
            child: Text('Sign in with Email'),
            style: TextButton.styleFrom(
                backgroundColor: Colors.green[600], primary: Colors.white),
          ),
          Text(
            'or',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
          TextButton(
            onPressed: isLoading ? null : () => _signInAnonymously(context),
            child: Text('Go anonymous'),
            style: TextButton.styleFrom(
                backgroundColor: Colors.amber, primary: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Text(
      'Sign In',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 32),
    );
  }
}
