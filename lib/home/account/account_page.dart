import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/common_widgets/show_alert_dialog.dart';
import 'package:time_tracker/services/auth.dart';

class AccountPage extends StatelessWidget {
  Future<void> _signOut(BuildContext context) async {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      await auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final didRequestSignOut = await showAlertDialog(
      context,
      title: 'Logout',
      content: 'Are you sure that you want to logout?',
      cancelActionText: 'Cancel',
      defaultActionText: 'Logout',
    );
    if (didRequestSignOut == true) {
      _signOut(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        leading: (auth.currentUser!.photoURL != null)
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  // height: 10,
                  // width: 10,
                  clipBehavior: Clip.antiAlias,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(50)),
                  child: Image.network('${auth.currentUser!.photoURL}'),
                ),
              )
            : SizedBox(),
        title: Text('Account'),
        centerTitle: true,
        actions: <Widget>[
          ElevatedButton(
            child: Text(
              'Logout',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.white,
              ),
            ),
            onPressed: () => _confirmSignOut(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            (auth.currentUser!.displayName != null)
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('User Name: ${auth.currentUser!.displayName}'),
                  )
                : SizedBox(),
            (auth.currentUser!.email != null &&
                    auth.currentUser!.email!.isNotEmpty)
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Email: ${auth.currentUser!.email}'),
                  )
                : SizedBox(),
            (auth.currentUser!.photoURL != null)
                ? Container(
                    height: 100,
                    width: 100,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        border: Border(),
                        borderRadius: BorderRadius.circular(10)),
                    child: Image.network(
                      '${auth.currentUser!.photoURL}',
                      scale: 0.6,
                    ),
                  )
                : Icon(
                    Icons.image,
                    size: 100,
                    color: Colors.grey[400],
                  ),
          ],
        ),
      ),
    );
  }
}
