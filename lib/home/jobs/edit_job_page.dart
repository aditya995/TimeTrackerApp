import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/common_widgets/show_alert_dialog.dart';
import 'package:time_tracker/common_widgets/show_exception_alert_dialog.dart';
import 'package:time_tracker/home/models/job.dart';
import 'package:time_tracker/services/database.dart';

class EditJobPage extends StatefulWidget {
  EditJobPage({Key? key, this.database, this.job}) : super(key: key);

  bool isLoading = false;
  final Database? database;
  final Job? job;

  static Future<void> show(BuildContext context,
      {required Database database, Job? job}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditJobPage(
          database: database,
          job: job,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  _EditJobPageState createState() => _EditJobPageState();
}

class _EditJobPageState extends State<EditJobPage> {
  final _formKey = GlobalKey<FormState>();

  String? _name;
  int? _ratePerHour;

  @override
  void initState() {
    super.initState();
    if (widget.job != null) {
      _name = widget.job!.name;
      _ratePerHour = widget.job!.ratePerHour;
    }
  }

  bool _validateAndSaveForm() {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> _submit() async {
    if (_validateAndSaveForm()) {
      setState(() {
        widget.isLoading = true;
      });
      try {
        final jobs = await widget.database!.jobsStream().first;
        final allNames = jobs.map((job) => job.name).toList();
        if (widget.job != null) {
          allNames.remove(widget.job!.name);
        }
        if (allNames.contains(_name)) {
          showAlertDialog(context,
              title: 'Name already used',
              content: 'Please choose another name',
              defaultActionText: 'OK');
        } else {
          final id = widget.job?.id ?? documentIdFromCurrentDate();
          final job = Job(id: id, name: _name!, ratePerHour: _ratePerHour!);
          await widget.database!.setJob(job);
          Navigator.of(context).pop();
        }
      } on FirebaseException catch (e) {
        showExceptionAlertDialog(context,
            title: 'Operation failed', exception: e);
      } finally {
        setState(() {
          widget.isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: Text(widget.job == null ? 'New Job' : 'Edit job'),
        centerTitle: true,
        actions: <Widget>[
          TextButton(
              onPressed: (!widget.isLoading) ? _submit : null,
              child: Text(
                'Save',
                style: TextStyle(
                  fontSize: 18,
                  color: (!widget.isLoading) ? Colors.white : Colors.black38,
                ),
              )),
        ],
      ),
      body: _buildContent(),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: _buildFromChildren(),
      ),
    );
  }

  List<Widget> _buildFromChildren() {
    return [
      (widget.isLoading) ? CircularProgressIndicator() : SizedBox(),
      TextFormField(
        enabled: !widget.isLoading,
        decoration: InputDecoration(
          labelText: 'Job name',
        ),
        initialValue: _name,
        textInputAction: TextInputAction.next,
        onSaved: (value) => _name = (value != null) ? value : '',
        validator: (value) => value!.isNotEmpty ? null : 'Name can\'t be empty',
      ),
      TextFormField(
        enabled: !widget.isLoading,
        decoration: InputDecoration(
          labelText: 'Rate per hour',
        ),
        initialValue: _ratePerHour != null ? _ratePerHour.toString() : null,
        keyboardType: TextInputType.numberWithOptions(
          signed: false,
          decimal: false,
        ),
        validator: (value) => (value!.isNotEmpty)
            ? (int.tryParse(value) != null && int.tryParse(value)! > 0)
                ? null
                : 'Give a valid positive Integer value'
            : 'Rate per hour can\'t be empty',
        onSaved: (value) => _ratePerHour = int.tryParse(value!) ?? null,
      ),
    ];
  }
}
