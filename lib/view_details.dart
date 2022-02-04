import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:japaniwp/colors.dart';
import 'package:japaniwp/update_bottle.dart';

class ViewDetails extends StatefulWidget {
  final dynamic docID;

  const ViewDetails({Key? key, this.docID}) : super(key: key);

  @override
  _ViewDetailsState createState() => _ViewDetailsState();
}

class _ViewDetailsState extends State<ViewDetails> {
  var name = '';
  var itemID = '';
  late int oldBottle;
  late int oldPaid;
  late int oldRemain;
  late int calcBottle;
  late int calcPaid;
  late int calcRemain;

  Future<void> getUserProfile() async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.docID)
        .get()
        .then((onData) {
      setState(() {
        name = onData['name'];
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryThemeColor,
      appBar: AppBar(
        centerTitle: true,
        title: name.isEmpty ? const Text('Users') : Text(name),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .doc(widget.docID)
              .collection('monthly')
              .orderBy('date')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  DateTime date = snapshot.data!.docs[index]['date'].toDate();
                  var formatDate =
                      DateFormat("EEEE, MMMM d, yyyy 'at' h:mma").format(date);
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Card(
                      elevation: 4.0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              formatDate,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w300),
                            ),
                            Text(
                              'Bottle: ${snapshot.data!.docs[index]['bottle_count']}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w400),
                            ),
                            Text(
                              'Paid: ${snapshot.data!.docs[index]['paid']}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w400),
                            ),
                            Text(
                              'Remain: ${snapshot.data!.docs[index]['remain']}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w400),
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                IconButton(
                                  icon: const Icon(Icons.delete_forever),
                                  onPressed: () async {
                                    await onDeleteButtonPressed(
                                        snapshot, index, context);
                                  },
                                ),
                                IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      itemID = snapshot.data!.docs[index].id;
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UpdateBottle(
                                            docID: widget.docID,
                                            itemID: itemID,
                                          ),
                                        ),
                                      );
                                    }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                });
          }),
    );
  }

  Future<void> onDeleteButtonPressed(
      AsyncSnapshot<QuerySnapshot<Object?>> snapshot,
      int index,
      BuildContext context) async {
    FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.docID)
        .get()
        .then((onData) {
      oldBottle = onData['total_bottle'];
      oldPaid = onData['paid'];
      oldRemain = onData['remain'];

      int bottleCount = snapshot.data!.docs[index]['bottle_count'];
      int paid = snapshot.data!.docs[index]['paid'];
      int remain = snapshot.data!.docs[index]['remain'];
      calcBottle = oldBottle - bottleCount;
      calcPaid = oldPaid - paid;
      calcRemain = oldRemain - remain;

      FirebaseFirestore.instance.runTransaction((trans) async {
        DocumentReference ref =
            FirebaseFirestore.instance.collection('Users').doc(widget.docID);
        trans.update(ref, {
          'total_bottle': calcBottle,
          'paid': calcPaid,
          'remain': calcRemain
        });
      }).then((onSuccess) {
        setState(() {
          itemID = snapshot.data!.docs[index].id;
        });
      });
    });
  }
}
