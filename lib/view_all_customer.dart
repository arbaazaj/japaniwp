import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:japaniwp/colors.dart';
import 'package:japaniwp/view_details.dart';

class ViewAllCustomer extends StatefulWidget {
  const ViewAllCustomer({Key? key}) : super(key: key);

  @override
  _ViewAllCustomerState createState() => _ViewAllCustomerState();
}

class _ViewAllCustomerState extends State<ViewAllCustomer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('All Customers'),
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
                    var docID = snapshot.data!.docs[index].id;
                    showDialog(
                        context: context,
                        builder: (c) => AlertDialog(
                              contentPadding: const EdgeInsets.all(16.0),
                              title: Text(
                                snapshot.data!.docs[index]['name'],
                              ),
                              titlePadding:
                                  const EdgeInsets.only(left: 16.0, top: 16.0),
                              actions: <Widget>[
                                TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ViewDetails(
                                                    docID: docID,
                                                  )));
                                    },
                                    child: const Text('View Details')),
                                MaterialButton(
                                    shape: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: accentThemeColor)),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Cancel')),
                              ],
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                      'Name: ${snapshot.data!.docs[index]['name']}'),
                                  Text(
                                      'Location: ${snapshot.data!.docs[index]['location']}'),
                                  Text(
                                      'Total Bottles: ${snapshot.data!.docs[index]['total_bottle']}'),
                                  Text(
                                      'Paid: ${snapshot.data!.docs[index]['paid']}'),
                                  Text(
                                      'Remain: ${snapshot.data!.docs[index]['remain']}'),
                                ],
                              ),
                            ));
                  });
            },
          );
        });
  }
}
