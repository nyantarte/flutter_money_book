import 'dart:ffi';
import 'dart:io';

import 'package:flutter_money_book/dataManagerFactory.dart';
import 'package:flutter_money_book/main.dart';
import 'package:flutter_money_book/transactionData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_book/sqliteDataManager.dart';

class EditTransaction extends StatefulWidget {
  final TransactionData m_targetData;

  EditTransaction(this.m_targetData) : super();

  @override
  EditTransactionState createState() => EditTransactionState(this.m_targetData);
}

class EditTransactionState extends State<EditTransaction> {
  TransactionData m_targetData;
  bool m_isValueGreaterZero = false;
  TextEditingController m_noteText = TextEditingController();
  String m_valueText = "";
  int m_methodSelected = -1;
  int m_usageSelected = -1;
  late List<String> m_usages;
  late List<DropdownMenuItem<int>> m_usagesItems;
  late List<String> m_methods;
  late List<DropdownMenuItem<int>> m_methodsItems;

  EditTransactionState(this.m_targetData) {
    m_noteText.text = this.m_targetData.m_note;

    m_isValueGreaterZero=0 < this.m_targetData.m_value;
    m_valueText = this.m_targetData.m_value.abs().toString();

    m_usages = DataManagerFactory.getManager().getUsages();
    m_usagesItems = _createDropDownMenuItems(m_usages);
    m_methods = DataManagerFactory.getManager().getMethods();
    m_methodsItems = _createDropDownMenuItems(m_methods);
  }

  @override
  Widget build(BuildContext context) {
    final dm = DataManagerFactory.getManager();
    var selMethod = 0;
    if (-1 == this.m_methodSelected) {
      if (0 < m_methods.length && 0 < this.m_targetData.m_method.length) {
        this.m_methodSelected =
            this.m_methods.indexOf(this.m_targetData.m_method);
        selMethod = this.m_methodSelected;
      }
    } else {
      selMethod = this.m_methodSelected;
    }

    var selUsage = 0;

    if (-1 == this.m_usageSelected) {
      if (0 < m_usages.length && 0 < this.m_targetData.m_usage.length) {
        this.m_usageSelected = m_usages.indexOf(this.m_targetData.m_usage);
        selUsage = this.m_usageSelected;
      }
    } else {
      selUsage = this.m_usageSelected;
    }
    return Scaffold(
        appBar: AppBar(
          title: Text(""),
        ),
        body: SingleChildScrollView(
          child:Column(
          children: [
            Row(
              children: [
                Text("Type", style: MyApp.globalTextStyle),
                Radio(
                    value: true,
                    groupValue: m_isValueGreaterZero,
                    onChanged: _handleGreaterZero),
                Text("In"),
                Radio(
                    value: false,
                    groupValue: m_isValueGreaterZero,
                    onChanged: _handleGreaterZero),
                Text("Out"),
              ],
            ),
            Row(children: [
              Text("Method", style: MyApp.globalTextStyle),
              DropdownButton<int>(
                  value: selMethod,
                  onChanged: (value) {
                    setState(() {
                      if (null != value) {
                        this.m_methodSelected = value;
                      }
                    });
                  },
                  items: m_methodsItems)
            ]),
            Row(children: [
              Text("Usage", style: MyApp.globalTextStyle),
              DropdownButton<int>(
                  value: selUsage,
                  onChanged: (value) {
                    setState(() {
                      if (null != value) {
                        this.m_usageSelected = value;
                      }
                    });
                  },
                  items: m_usagesItems)
            ]),
            Row(
              children: [
                Text("Note   ", style: MyApp.globalTextStyle),
                Expanded(
                    child: TextField(
                        enabled: true,
                        obscureText: false,
                        controller: m_noteText,
                        onSubmitted: _handleNoteChange))
              ],
            ),
            Row(
              children: [
                Text("Value   ", style: MyApp.globalTextStyle),
                Text(this.m_valueText, style: MyApp.globalTextStyle)
              ],
            ),
            Row(
              children: [
                ElevatedButton(
                  child: const Text('C'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      m_valueText = "0";
                    });
                  },
                ),
                ElevatedButton(
                  child: const Text('+/-'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {},
                ),
                ElevatedButton(
                  child: const Text('%'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {},
                ),
                ElevatedButton(
                  child: const Text('DEL'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      if (0 < m_valueText.length) {
                        if ("0" != m_valueText) {
                          if (1 < m_valueText.length) {
                            m_valueText = m_valueText.substring(
                                0, m_valueText.length - 1);
                          } else {
                            m_valueText = "0";
                          }
                        }
                      }
                    });
                  },
                )
              ],
            ),
            Row(
              children: [
                ElevatedButton(
                  child: const Text('7'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    _addValueChar("7");
                  },
                ),
                ElevatedButton(
                  child: const Text('8'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    _addValueChar("8");
                  },
                ),
                ElevatedButton(
                  child: const Text('9'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    _addValueChar("9");
                  },
                ),
                ElevatedButton(
                  child: const Text('÷'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    _addValueChar("÷");
                  },
                )
              ],
            ),
            Row(
              children: [
                ElevatedButton(
                  child: const Text('4'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    _addValueChar("4");
                  },
                ),
                ElevatedButton(
                  child: const Text('5'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    _addValueChar("5");
                  },
                ),
                ElevatedButton(
                  child: const Text('6'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    _addValueChar("6");
                  },
                ),
                ElevatedButton(
                  child: const Text('×'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    _addValueChar("×");
                  },
                )
              ],
            ),
            Row(
              children: [
                ElevatedButton(
                  child: const Text('1'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    _addValueChar("1");
                  },
                ),
                ElevatedButton(
                  child: const Text('2'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    _addValueChar("2");
                  },
                ),
                ElevatedButton(
                  child: const Text('3'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    _addValueChar("3");
                  },
                ),
                ElevatedButton(
                  child: const Text('-'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    _addValueChar("-");
                  },
                )
              ],
            ),
            Row(
              children: [
                ElevatedButton(
                  child: const Text('0'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    _addValueChar("0");
                  },
                ),
                ElevatedButton(
                  child: const Text('.'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    _addValueChar(".");
                  },
                ),
                ElevatedButton(
                  child: const Text('='),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    _parseExp();
                  },
                ),
                ElevatedButton(
                  child: const Text('+'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    _addValueChar("+");
                  },
                )
              ],
            ),
            Row(
              children: [
                ElevatedButton(
                  child: const Text('OK'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    _parseExp();
                    if (this.m_isValueGreaterZero) {
                      this.m_targetData.m_value =
                          double.parse(this.m_valueText).toInt();
                    } else {
                      this.m_targetData.m_value =
                          -double.parse(this.m_valueText).toInt();
                    }
                    if (-1 == this.m_methodSelected) {
                      this.m_methodSelected=0;
                    }
                    this.m_targetData.m_method =
                    this.m_methods[this.m_methodSelected];
                    if (-1 ==this.m_usageSelected) {
                      this.m_usageSelected=0;
                    }
                    this.m_targetData.m_usage =
                    this.m_usages[this.m_usageSelected];
                    this.m_targetData.m_note = this.m_noteText.text;
                    Navigator.of(context).pop(this.m_targetData);
                  },
                ),
                ElevatedButton(
                  child: const Text('CANCEL'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            )
          ],
        )));
  }

  void _handleGreaterZero(bool? f) =>
      setState(() => {m_isValueGreaterZero = f ?? false});

  List<DropdownMenuItem<int>> _createDropDownMenuItems(List<String> l) {
    List<DropdownMenuItem<int>> res = [];
    int i = 0;
    for (var t in l) {
      res.add(DropdownMenuItem<int>(
          child: Text(t, style: MyApp.globalTextStyle), value: i++));
    }
    return res;
  }

  void _handleNoteChange(String t) {
    setState(() {
      m_targetData.m_note = t;
    });
  }

  void _parseExp() {
    if ("0" != this.m_valueText) {
      List<String> tokenList = [];
      List<String> opList = [];
      String res = "";
      for (var t in this.m_valueText.characters) {
        if (RegExp(r'^[0-9\.]+').hasMatch(t)) {
          res = res + t;
        } else if ("+" == t || "-" == t || "×" == t || "÷" == t) {
          if (0 < res.length) {
            tokenList.add(res);
            res = "";
            opList.add(t);
          }
        }
      }
      if (0 < res.length) {
        tokenList.add(res);
      }

      double payValue = double.parse(tokenList[0]);
      for (var i = 0; i < opList.length; ++i) {
        var op = opList[i];
        if ("+" == op) {
          payValue += double.parse(tokenList[i + 1]);
        } else if ("-" == op) {
          payValue -= double.parse(tokenList[i + 1]);
        } else if ("×" == op) {
          payValue *= double.parse(tokenList[i + 1]);
        } else if ("÷" == op) {
          payValue /= double.parse(tokenList[i + 1]);
        }
      }
      setState(() {
        this.m_valueText = payValue.toString();
      });
    }
  }

  void _addValueChar(String t) {
    setState(() {
      if ("0" == m_valueText) {
        m_valueText = t;
      } else {
        m_valueText = m_valueText + t;
      }
    });
  }
}
