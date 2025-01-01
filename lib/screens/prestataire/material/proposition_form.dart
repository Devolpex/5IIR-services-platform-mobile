import 'package:flutter/material.dart';

class PropositionForm extends StatefulWidget {
  final Function(double tarif, String description, DateTime dateDispo, int demandeId) onSubmit;
  final int demandeId;

  const PropositionForm({Key? key, required this.onSubmit, required this.demandeId}) : super(key: key);

  @override
  _PropositionFormState createState() => _PropositionFormState();
}

class _PropositionFormState extends State<PropositionForm> {
  final _formKey = GlobalKey<FormState>();
  String? _description;
  double? _tarif;
  DateTime? _dateDispo;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onSubmit(_tarif!, _description!, _dateDispo!, widget.demandeId);
      Navigator.of(context).pop(); // Close the dialog
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateDispo ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dateDispo)
      setState(() {
        _dateDispo = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Add Proposition',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(labelText: 'Tarif'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                }
                return null;
              },
              onSaved: (value) {
                _tarif = double.tryParse(value!);
              },
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Description'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
              onSaved: (value) {
                _description = value;
              },
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _dateDispo == null
                        ? 'No date selected!'
                        : 'Selected Date: ${_dateDispo!.toLocal()}'.split(' ')[0],
                  ),
                ),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Select date'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: Text('Submit'),
          onPressed: _submitForm,
        ),
      ],
    );
  }
}