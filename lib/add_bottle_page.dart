import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddBottlePage extends StatefulWidget {
  const AddBottlePage({Key? key, @required this.documentID}) : super(key: key);

  final dynamic documentID;

  @override
  _AddBottlePageState createState() => _AddBottlePageState();
}

class _AddBottlePageState extends State<AddBottlePage> {
  final TextEditingController bottleController = TextEditingController();
  final TextEditingController paidController = TextEditingController();
  final TextEditingController remainController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var dropValue = 15;
  var rate = '';
  late int currentPaid;
  late int currentRemain;
  late int currentBottle;
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
  //
  // InputType inputType = InputType.both;
  // bool editable = true;
  // DateTime date;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Add Bottle'),
      ),
      body: SingleChildScrollView(
        child: Builder(
          builder: (context) {
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
                    //       hasFloatingPlaceholder: false),
                    //   onChanged: (dt) => setState(() {
                    //     date = dt;
                    //     currentDate = dt;
                    //   }),
                    // ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      controller: bottleController,
                      decoration:
                          const InputDecoration(labelText: 'Bottle Count'),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: dropValue,
                        onChanged: (newValue) {
                          setState(() {
                            dropValue = newValue!;
                            rate = newValue as String;
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
                      keyboardType: TextInputType.number,
                      controller: remainController,
                      decoration: const InputDecoration(labelText: 'Remain'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Processing...')));
                        var docID = widget.documentID;
                        int bottleCount = int.parse(bottleController.text);
                        int paidAmt = int.parse(paidController.text);
                        int remainAmt = int.parse(remainController.text);

                        FirebaseFirestore.instance
                            .collection('Users')
                            .doc(docID)
                            .collection('monthly')
                            .add({
                          'bottle_count': bottleCount,
                          'date': currentDate,
                          'rate': rate,
                          'paid': paidAmt,
                          'remain': remainAmt
                        }).then((onSuccess) {
                          onSuccess.get().then((newValue) {
                            freshPaid = newValue['paid'];
                            freshRemain = newValue['remain'];
                            freshBottle = newValue['bottle_count'];

                            FirebaseFirestore.instance
                                .collection('Users')
                                .doc(docID)
                                .get()
                                .then((onValue) {
                              currentPaid = onValue['paid'];
                              currentRemain = onValue['remain'];
                              currentBottle = onValue['total_bottle'];
                              if (currentPaid == 0 &&
                                  currentRemain == 0 &&
                                  currentBottle == 0) {
                                FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(docID)
                                    .update({
                                  'paid': freshPaid,
                                  'remain': freshRemain,
                                  'total_bottle': freshBottle
                                });
                              } else {
                                int calcPaid = currentPaid + freshPaid;
                                int calcRemain = currentRemain + freshRemain;
                                int calcBottle = currentBottle + freshBottle;

                                FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(docID)
                                    .update({
                                  'paid': calcPaid,
                                  'remain': calcRemain,
                                  'total_bottle': calcBottle
                                });
                              }
                            });
                          });
                          Navigator.pop(context);
                        });
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _calculate() {
    int one = int.parse(bottleController.text);
    int two = rate as int;
    int calc = one * two;
    total = calc;
    var remain = (total - int.parse(paidController.text));
    setState(() {
      remainController.text = remain.toString();
    });
  }
}
