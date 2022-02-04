import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DeleteCustomer extends StatefulWidget {
  const DeleteCustomer({Key? key}) : super(key: key);

  @override
  _DeleteCustomerState createState() => _DeleteCustomerState();
}

class _DeleteCustomerState extends State<DeleteCustomer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Delete Customer'),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${snapshot.data!.docs[index]['name']}'),
                  subtitle: Text('${snapshot.data!.docs[index]['location']}'),
                  trailing: IconButton(
                      icon: const Icon(Icons.delete_forever),
                      onPressed: () {
                        var docId = snapshot.data!.docs[index].id;
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Deleting')));
                        FirebaseFirestore.instance
                            .runTransaction((trans) async {
                          CollectionReference deleteCustomer =
                              FirebaseFirestore.instance.collection('Users');
                          await deleteCustomer
                              .doc(docId)
                              .delete()
                              .then((value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Deleted')));
                          }).catchError((onError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Failed to delete customer!')));
                          });
                        });
                      }),
                );
              });
        });
  }
}
