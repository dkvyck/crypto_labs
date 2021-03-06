import 'package:flutter/material.dart';
import 'package:lab1/logic/linear_random_algorithm.dart';
import 'package:lab1/logic/series_helper.dart';
import 'package:math_expressions/math_expressions.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late GlobalKey<FormState> _formKey;
  late SeriesGenerator generator;
  bool inProgress = false;

  late Parser parser = Parser();

  TextEditingController outputController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController fileAmountController = TextEditingController();
  TextEditingController periodController = TextEditingController();
  TextEditingController moduleController = TextEditingController();
  TextEditingController multiplierController = TextEditingController();
  TextEditingController increaseController = TextEditingController();
  TextEditingController initialValueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    generator = SeriesGenerator();
  }

  @override
  Widget build(BuildContext context) {
    var mQuery = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Card(
          elevation: 10,
          margin: EdgeInsets.all(10),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: mQuery.width * 0.2,
                            child: TextFormField(
                              controller: amountController,
                              decoration: InputDecoration(
                                  helperText: 'Enter amount',
                                  labelText: 'UI Amount'),
                              validator: (value) {
                                if (value != null) {
                                  int? number = int.tryParse(value);

                                  return number != null
                                      ? null
                                      : 'Enter a valid amount';
                                } else
                                  return 'Enter an amount';
                              },
                            ),
                          ),
                          Container(
                            width: mQuery.width * 0.2,
                            child: TextFormField(
                              controller: fileAmountController,
                              decoration: InputDecoration(
                                  helperText: 'Enter amount',
                                  labelText: 'File Amount'),
                              validator: (value) {
                                if (value != null) {
                                  int? number = int.tryParse(value);

                                  return number != null
                                      ? null
                                      : 'Enter a valid amount';
                                } else
                                  return 'Enter an amount';
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        width: mQuery.width * 0.10,
                        child: TextFormField(
                          validator: (value) {
                            if (value != null) {
                              try {
                                num? number = parser.parse(value).evaluate(
                                    EvaluationType.REAL, ContextModel());
                              } catch (_) {
                                return 'Enter a valid module';
                              }

                              return null;
                            } else
                              return 'Enter an module';
                          },
                          controller: moduleController,
                          decoration: InputDecoration(
                              labelText: 'Module',
                              contentPadding: EdgeInsets.all(10)),
                        ),
                      ),
                      SizedBox(
                        width: mQuery.width * 0.005,
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        width: mQuery.width * 0.10,
                        child: TextFormField(
                          validator: (value) {
                            if (value != null) {
                              try {
                                num? number = parser.parse(value).evaluate(
                                    EvaluationType.REAL, ContextModel());
                              } catch (_) {
                                return 'Enter a valid multiplier';
                              }
                              return null;
                            } else
                              return 'Enter an multiplier';
                          },
                          controller: multiplierController,
                          decoration: InputDecoration(
                              labelText: 'Multiplier',
                              contentPadding: EdgeInsets.all(10)),
                        ),
                      ),
                      SizedBox(
                        width: mQuery.width * 0.005,
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        width: mQuery.width * 0.10,
                        child: TextFormField(
                          validator: (value) {
                            if (value != null) {
                              int? number = int.tryParse(value);

                              return number != null
                                  ? null
                                  : 'Enter a valid growth';
                            } else
                              return 'Enter an growth';
                          },
                          controller: increaseController,
                          decoration: InputDecoration(
                              labelText: 'Growth',
                              contentPadding: EdgeInsets.all(10)),
                        ),
                      ),
                      SizedBox(
                        width: mQuery.width * 0.005,
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        width: mQuery.width * 0.10,
                        child: TextFormField(
                          controller: initialValueController,
                          validator: (value) {
                            if (value != null) {
                              int? number = int.tryParse(value);

                              return number != null
                                  ? null
                                  : 'Enter a valid initial value';
                            } else
                              return 'Enter an initial value';
                          },
                          decoration: InputDecoration(
                              labelText: 'InitialValue',
                              contentPadding: EdgeInsets.all(10)),
                        ),
                      ),
                      SizedBox(
                        width: mQuery.width * 0.005,
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        width: mQuery.width * 0.15,
                        child: TextField(
                          controller: periodController,
                          decoration: InputDecoration(
                              labelText: 'Period',
                              contentPadding: EdgeInsets.all(10)),
                          readOnly: true,
                        ),
                      ),
                      SizedBox(
                        width: mQuery.width * 0.005,
                      ),
                      ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  inProgress
                                      ? Colors.grey
                                      : Theme.of(context).primaryColor)),
                          onPressed: inProgress ? null : () => _evaluate(),
                          child: Text('Generate')),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  color: Colors.grey.shade100,
                  child: TextField(
                    controller: outputController,
                    maxLines: null,
                    readOnly: true,
                    decoration:
                        InputDecoration(contentPadding: EdgeInsets.all(10)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _evaluate() async {
    if (_formKey.currentState!.validate()) {
      var m = parser
          .parse(moduleController.text)
          .evaluate(EvaluationType.REAL, ContextModel());
      var a = parser
          .parse(multiplierController.text)
          .evaluate(EvaluationType.REAL, ContextModel());
      var c = int.parse(increaseController.text);
      var x0 = int.parse(initialValueController.text);
      var amount = int.parse(amountController.text);
      var fileAmount = int.parse(fileAmountController.text);

      outputController.clear();
      periodController.clear();

      if (!generator.subject.hasListener)
        generator.subject.listen((state) {
          if (state is ValueGeneratorState) {
            if (!inProgress) inProgress = true;
            outputController.text += ' ${state.value.toStringAsFixed(0)} ';
          } else if (state is PeriodGeneratorState) {
            periodController.text = state.period.toString();
          } else if (state is FinishedGeneratorState) {
            inProgress = false;
          }
        });

      generator.generate(amount, x0, c, a, m, fileAmount: fileAmount);
    }
  }
}
