import 'package:flutter/material.dart';
import 'package:flutter_money_book/transactionData.dart';
import 'package:flutter_money_book/main.dart';
import 'package:flutter_money_book/editTransactionList.dart';
class TransactionListForm extends StatefulWidget {
  late TransactionList _targetData;
  TransactionListForm(this._targetData) : super();


@override
TransactionListFormState createState() => TransactionListFormState();
}
class TransactionListFormState extends State<TransactionListForm> {
  TransactionListFormState();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(""),
      ),
      body: ListView.builder(
          itemCount: this.widget._targetData.list.length,
          shrinkWrap: true,
          itemBuilder: (context, i) {
            var t=this.widget._targetData.list[i];
            return ListTile(
              onTap: (){
                Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) {
                      return EditTransactionList(t.m_transDate,t);
                    }
                  )).then((value) => setState(() {}));
              },
                title:Text(
                "${this.widget._targetData.list[i].toString()}",
                style: MyApp.globalTextStyle));
          }),
    );
  }
}