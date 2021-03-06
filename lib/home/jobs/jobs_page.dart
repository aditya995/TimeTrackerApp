import 'package:time_tracker/home/job_entries/job_entries_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/common_widgets/show_alert_dialog.dart';
import 'package:time_tracker/common_widgets/show_exception_alert_dialog.dart';
import 'package:time_tracker/home/jobs/job_list_tile.dart';
import 'package:time_tracker/home/jobs/list_items_builder.dart';
import 'package:time_tracker/home/models/job.dart';
import 'package:time_tracker/services/auth.dart';
import 'package:time_tracker/services/database.dart';

import 'edit_job_page.dart';

class JobsPage extends StatelessWidget {
  const JobsPage({Key? key}) : super(key: key);

  Future<void> _delete(BuildContext context, Job job) async {
    try {
      final database = Provider.of<Database>(context, listen: false);
      await database.deleteJob(job);
    } on FirebaseException catch (e) {
      showExceptionAlertDialog(context,
          title: 'Operation failed', exception: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppBar appbar = AppBar(
      title: Text('Jobs'),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () => EditJobPage.show(context,
              database: Provider.of<Database>(context, listen: false)),
        ),
      ],
    );
    return Scaffold(
      appBar: appbar,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 48.0),
        child: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => EditJobPage.show(context,
              database: Provider.of<Database>(context, listen: false)),
        ),
      ),
      body: ListView(
        children: [
          Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.black12,
              height: MediaQuery.of(context).size.height -
                  appbar.preferredSize.height,
              child: _buildContents(context)),
        ],
      ),
    );
  }

  Widget _buildContents(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);

    return StreamBuilder<List<Job>>(
      stream: database.jobsStream(),
      builder: (context, snapshot) {
        return ListItemsBuilder<Job>(
          snapshot: snapshot,
          itemBuilder: (context, job) => Dismissible(
            key: Key('job-${job.id}'),
            background: Container(
              color: Colors.red,
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) => _delete(context, job),
            child: JobListTile(
              job: job,
              onTap: () => JobEntriesPage.show(context, job),
            ),
          ),
        );
      },
    );
  }
}
