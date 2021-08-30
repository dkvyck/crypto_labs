import 'package:flutter/material.dart';
import 'package:lab1/logic/linear_random_algorithm.dart';
import 'package:lab1/logic/series_helper.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late GlobalKey<FormState> _formKey;
  late SeriesGenerator generator;
  late SeriesHelper seriesHelper;
  TextEditingController outputController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController periodController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _formKey = GlobalKey<FormState>();
    generator = SeriesGenerator();
    seriesHelper = SeriesHelper();
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
                      Container(
                        width: mQuery.width * 0.2,
                        child: TextFormField(
                          controller: amountController,
                          decoration: InputDecoration(
                              helperText: 'Enter amount', labelText: 'Amount'),
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
                      SizedBox(
                        width: 20,
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              var series = (await generator
                                  .generate(int.parse(amountController.text)));
                              outputController.text = series.join(" ");
                              periodController.text =
                                  seriesHelper.findPeriod(series).toString();
                              seriesHelper.writeToFile(series);
                            }
                          },
                          child: Text('Generate')),
                      SizedBox(
                        width: mQuery.width * 0.3,
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
                      )
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
}
