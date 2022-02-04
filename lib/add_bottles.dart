import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:japaniwp/add_bottle_page.dart';

class AddBottles extends StatefulWidget {
  const AddBottles({Key? key}) : super(key: key);

  @override
  _AddBottlesState createState() => _AddBottlesState();
}

class _AddBottlesState extends State<AddBottles> {
  // final _formKey = GlobalKey<FormState>();
  final TextEditingController bottleCountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController lastUpdatedController = TextEditingController();
  final TextEditingController paidController = TextEditingController();
  final TextEditingController remainController = TextEditingController();

  var dropValue = 15;

  final formats = {
    DateFormat.YEAR_MONTH_DAY: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
    DateFormat.DAY: DateFormat('yyyy-MM-dd'),
    DateFormat.HOUR_MINUTE: DateFormat("HH:mm"),
  };

  bool editable = true;
  late DateTime date;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Add Bottle'),
      ),
      body: _buildList(),
    );
  }

  Widget _buildList() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .orderBy('name')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data!.docs[index]['name']),
                  onTap: () {
                    var documentID = snapshot.data!.docs[index];
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddBottlePage(
                                  documentID: documentID.id,
                                )));
                  },
                );
              });
        });
  }
}
