import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:japaniwp/colors.dart';

class UpdateUser extends StatefulWidget {
  const UpdateUser({Key? key}) : super(key: key);

  @override
  _UpdateUserState createState() => _UpdateUserState();
}

class _UpdateUserState extends State<UpdateUser> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Update Customer'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
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
                  title: Text('${snapshot.data!.docs[index]['name']}'),
                  subtitle: Text(
                      'Amount Remaining: ₹${snapshot.data!.docs[index]['remain']}'),
                  trailing: IconButton(
                      icon: Icon(Icons.edit, color: accentThemeColor),
                      onPressed: () {
                        var oldName = snapshot.data!.docs[index]['name'];
                        var oldLocation =
                            snapshot.data!.docs[index]['location'];
                        var docID = snapshot.data!.docs[index].id;
                        setState(() {
                          nameController.text = oldName;
                          locationController.text = oldLocation;
                        });
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (c) {
                              return AlertDialog(
                                title: Text(
                                    '${snapshot.data!.docs[index]['name']}'),
                                actions: <Widget>[
                                  MaterialButton(
                                    onPressed: () {
                                      var newName = nameController.text;
                                      var newLocation = locationController.text;
                                      FirebaseFirestore.instance
                                          .collection('Users')
                                          .doc(docID)
                                          .update({
                                        'name': newName,
                                        'location': newLocation
                                      }).then((onValue) {
                                        nameController.text = '';
                                        locationController.text = '';
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text('Data Updated')));
                                        Navigator.pop(context);
                                      });
                                    },
                                    child: const Text('Update'),
                                  ),
                                  MaterialButton(
                                      shape: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: accentThemeColor)),
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'))
                                ],
                                content: Form(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      //TextField(), Date
                                      TextField(
                                        controller: nameController,
                                        decoration: const InputDecoration(
                                          labelText: 'Enter new name',
                                        ),
                                      ),
                                      TextField(
                                        controller: locationController,
                                        decoration: const InputDecoration(
                                            labelText: 'Enter new location'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            });
                      }),
                );
              });
        });
  }
}
