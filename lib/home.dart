import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:japaniwp/add_bottles.dart';
import 'package:japaniwp/add_customer.dart';
import 'package:japaniwp/colors.dart';
import 'package:japaniwp/delete_customer.dart';
import 'package:japaniwp/update_user.dart';
import 'package:japaniwp/view_all_customer.dart';

class JapaniHome extends StatefulWidget {
  const JapaniHome({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _JapaniHomeState createState() => _JapaniHomeState();
}

class _JapaniHomeState extends State<JapaniHome> {
  var _totalCustomers = 0;

  Future<void> getNoOfCustomers() async {
    await FirebaseFirestore.instance
        .collection('Users')
        .get()
        .then((onSuccess) {
      setState(() {
        _totalCustomers = onSuccess.docs.length;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getNoOfCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryThemeColor,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: accentThemeColor),
        ),
        centerTitle: true,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('stats')
              .doc('current_stats')
              .snapshots(),
          builder: (context, snapshot) {
            getNoOfCustomers();
            Map<String, dynamic> data =
            snapshot.data!.data() as Map<String, dynamic>;
            if (!snapshot.hasData) return const CircularProgressIndicator();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(top: 6.0),
                  color: primaryThemeColor,
                  width: double.infinity,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Total Customer: $_totalCustomers',
                            style: Theme.of(context).textTheme.subtitle1!.apply(
                              color: Colors.black54,
                            ),
                          ),
                          Text('Paid: ₹${data['total_paid']}',
                              style:
                              Theme.of(context).textTheme.subtitle1!.apply(
                                color: Colors.black54,
                              )),
                          Text('Remaining: ₹${data['total_remain']}',
                              style:
                              Theme.of(context).textTheme.subtitle1!.apply(
                                color: Colors.black54,
                              )),
                          Text('Total Bottle: ${data['total_bottles']}',
                              style:
                              Theme.of(context).textTheme.subtitle1!.apply(
                                color: Colors.black54,
                              )),
                        ],
                      ),
                    ),
                    elevation: 4.0,
                  ),
                ),
                const Padding(padding: EdgeInsets.all(4.0)),
                MaterialButton(
                  color: accentThemeColor,
                  colorBrightness: Brightness.dark,
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddCustomer()));
                  },
                  child: const Text('Add Customer'),
                ),
                MaterialButton(
                    color: accentThemeColor,
                    colorBrightness: Brightness.dark,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddBottles()));
                    },
                    child: const Text('Add Bottles')),
                MaterialButton(
                    color: accentThemeColor,
                    colorBrightness: Brightness.dark,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const UpdateUser()));
                    },
                    child: const Text('Update Customer')),
                MaterialButton(
                    color: accentThemeColor,
                    colorBrightness: Brightness.dark,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DeleteCustomer()));
                    },
                    child: const Text('Delete Customer')),
                MaterialButton(
                    color: accentThemeColor,
                    colorBrightness: Brightness.dark,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ViewAllCustomer()));
                    },
                    child: const Text('View All Customer')),
              ],
            );
          }),
    );
  }
}

