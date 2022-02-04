import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UpdateBottle extends StatefulWidget {
  final dynamic docID;
  final dynamic itemID;

  const UpdateBottle({Key? key, this.docID, this.itemID}) : super(key: key);

  @override
  _UpdateBottleState createState() => _UpdateBottleState();
}

class _UpdateBottleState extends State<UpdateBottle> {
  final TextEditingController bottleController = TextEditingController();
  final TextEditingController paidController = TextEditingController();
  final TextEditingController remainController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int dropValue = 15;
  late int rate;
  late int freshPaid;
  late int freshRemain;
  late int freshBottle;
  late int total;
  var currentDate = '';
  //
  // final formats = {
  //   InputType.both: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
  //   InputType.date: DateFormat('yyyy-MM-dd'),
  //   InputType.time: DateFormat("HH:mm"),
  // };

  // InputType inputType = InputType.both;
  // bool editable = true;
  // DateTime date;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Update Bottle'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
        child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Users')
                .doc(widget.docID)
                .collection('monthly')
                .doc(widget.itemID)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              // DateTime oldDate = snapshot.data['date'].toDate();

              // int oldRate = snapshot.data['rate'];
              // int oldBottleCount = snapshot.data['bottle_count'];
              // int oldPaidData = snapshot.data['paid'];
              // int oldRemainData = snapshot.data['remain'];
              // dropValue = oldRate;
              // rate = oldRate;
              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(),
                      // child: DateTimePickerFormField(
                      //   inputType: inputType,
                      //   format: formats[inputType],
                      //   editable: editable,
                      //   decoration: const InputDecoration(
                      //       labelText: 'Date/Time',
                      //       floatingLabelBehavior: FloatingLabelBehavior.never),
                      //   onChanged: (dt) => setState(() {
                      //     date = dt;
                      //     currentDate = dt;
                      //     oldDate = dt;
                      //   }),
                      //   initialValue: oldDate,
                      // ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        textInputAction: TextInputAction.next,
                        controller: bottleController,
                        decoration:
                            const InputDecoration(labelText: 'Bottle Count'),
                        // initialValue: oldBottleCount.toString(),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButton<int>(
                          isExpanded: true,
                          // value: oldRate,
                          onChanged: (newValue) {
                            setState(() {
                              dropValue = newValue!;
                              rate = dropValue;
                            });
                          },
                          items: <int>[15, 16, 17, 18, 19, 20]
                              .map<DropdownMenuItem<int>>((int value) {
                            return DropdownMenuItem<int>(
                                value: value, child: Text('$value'));
                          }).toList(),
                        )),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        controller: paidController,
                        onChanged: (paidValue) {
                          if (paidValue.isEmpty == true) {
                            paidController.text = 0.toString();
                          }
                          _calculate();
                        },
                        decoration: const InputDecoration(labelText: 'Paid'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        keyboardType: const TextInputType.numberWithOptions(),
                        controller: remainController,
                        decoration: const InputDecoration(labelText: 'Remain'),
                      ),
                    ),
                    MaterialButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Processing...')));
                          var docID = widget.docID;
                          int bottleCount = int.parse(bottleController.text);
                          int paidAmt = int.parse(paidController.text);
                          int remainAmt = int.parse(remainController.text);
                          FirebaseFirestore.instance
                              .collection('Users')
                              .doc(docID)
                              .collection('monthly')
                              .doc(widget.itemID)
                              .update({
                            'bottle_count': bottleCount,
                            'date': currentDate,
                            'paid': paidAmt,
                            'rate': rate,
                            'remain': remainAmt
                          }).then((onSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Updated')));
                          });
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              );
            }));
  }

  void _calculate() {
    int one = int.parse(bottleController.text);
    if (kDebugMode) {
      print('bottle: $one');
    }
    int two = rate;
    if (kDebugMode) {
      print('rate: $rate');
    }
    int calc = one * two;
    total = calc;
    if (kDebugMode) {
      print('Total: $total');
    }
    int remain = total - int.parse(paidController.text);
    if (kDebugMode) {
      print('Remain: $remain');
    }
    setState(() {
      remainController.text = remain.toString();
    });
  }
}
