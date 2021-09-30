import 'package:flutter/material.dart';
import 'package:flutter_money_book/transactionData.dart';
import 'package:flutter_money_book/dataManagerFactory.dart';
import 'package:flutter_money_book/main.dart';

class ReportData {
  var _curInValue = 0;
  var _curOutValue = 0;
}

class Report extends StatefulWidget {
  DateTime _beginCurMonth = DateTime.now(), _endCurMonth = DateTime.now();
  DateTime _beginPrevMonth = DateTime.now(), _endPrevMonth = DateTime.now();
  Report(DateTime targetDate) : super() {
    _calcDate(targetDate);
  }

  void _calcDate(DateTime d) {
    _beginCurMonth = DateTime(d.year, d.month, 1);
    if (12 == _beginCurMonth.month) {
      _endCurMonth = DateTime(_beginCurMonth.year + 1, 1, 1);
      _beginPrevMonth =
          DateTime(_beginCurMonth.year, _beginCurMonth.month - 1, 1);
      _endPrevMonth = _beginCurMonth;
    } else if (1 == _beginCurMonth.month) {
      _endCurMonth = DateTime(_beginCurMonth.year, _beginCurMonth.month + 1, 1);
      _beginPrevMonth = DateTime(_beginCurMonth.year - 1, 12, 1);
      _endPrevMonth = _beginCurMonth;
    } else {
      _endCurMonth = DateTime(_beginCurMonth.year, _beginCurMonth.month + 1, 1);
      _beginPrevMonth =
          DateTime(_beginCurMonth.year, _beginCurMonth.month - 1, 1);
      _endPrevMonth = _beginCurMonth;
    }
  }

  @override
  ReportState createState() => ReportState();
}

class ReportState extends State<Report> {
  ReportState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(""),
        ),
        body: SingleChildScrollView(
            child: FutureBuilder(
                future: _calcMonthlyData(),
                builder:
                    (BuildContext context, AsyncSnapshot<ReportData> snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            ElevatedButton(
                              child: const Text('PREV'),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.blueAccent,
                                onPrimary: Colors.white,
                              ),
                              onPressed: () {
                                _showPrevMonth();
                              },
                            ),
                            ElevatedButton(
                              child: const Text('NEXT'),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.blueAccent,
                                onPrimary: Colors.white,
                              ),
                              onPressed: () {
                                _showNextMonth();
                              },
                            )
                          ],
                        ),
                        Text(
                          "${MyApp.globalDateFormatter.format(this.widget._beginCurMonth)}-${MyApp.globalDateFormatter.format(this.widget._endCurMonth.add(Duration(days: -1)))}",
                          style: MyApp.globalTextStyle,
                        ),
                        Text(
                          "Income ${snapshot.data!._curInValue}",
                          style: MyApp.globalTextStyle,
                        ),
                        Text("Spends ${snapshot.data!._curOutValue}",
                            style: MyApp.globalTextStyle),
                        Text(
                          "Delta ${snapshot.data!._curInValue - snapshot.data!._curOutValue}",
                          style: MyApp.globalTextStyle,
                        )
                      ],
                    );
                  } else {
                    return Column(children: []);
                  }
                })));
  }

  Future<ReportData> _calcMonthlyData() async {
    final dm = DataManagerFactory.getManager();
    List<TransactionData> l = await dm.getTransactionByDateRange(
        this.widget._beginCurMonth, this.widget._endCurMonth);
    ReportData rd = ReportData();
    for (var t in l) {
      if (0 < t.m_value) {
        rd._curInValue += t.m_value;
      } else {
        rd._curOutValue += -t.m_value;
      }
    }
    return rd;
  }

  void _showPrevMonth() {
    setState(() {
      var dt = this.widget._beginCurMonth;
      if (1 == dt.month) {
        dt = DateTime(dt.year - 1, 12, 1);
      } else {
        dt = DateTime(dt.year, dt.month - 1, 1);
      }
      this.widget._calcDate(dt);
    });
  }

  void _showNextMonth() {
    setState(() {
      var dt = this.widget._beginCurMonth;
      if (12 == dt.month) {
        dt = DateTime(dt.year + 1, 1, 1);
      } else {
        dt = DateTime(dt.year, dt.month + 1, 1);
      }
      this.widget._calcDate(dt);
    });
  }
}
