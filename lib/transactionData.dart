import 'package:uuid/uuid.dart';
import 'package:flutter_money_book/main.dart';
class TransactionData{
  String m_id;
  DateTime m_transDate;
  String m_method;
  String m_usage;
  int m_value;
  String m_note;


  TransactionData(this.m_id,this.m_transDate,this.m_method,this.m_usage,this.m_value,this.m_note){}

  Map<String,dynamic> toMap() {
    return {
      "id":m_id,
      "transactionDate":m_transDate.millisecondsSinceEpoch,
      "method":m_method,
      "usage":m_usage,
      "value":m_value,
      "note":m_note
    };
  }

  @override
  String toString(){
    return "${this.m_transDate.year}/${this.m_transDate.month}/${this.m_transDate.day} ${this.m_transDate.hour}:${this.m_transDate.minute} ${MyApp.globalPriceFormatter.format(m_value)} ${m_note}";
  }

  String toCSVString(){
    return "${this.m_id},${this.m_transDate.year}/${this.m_transDate.month}/${this.m_transDate.day} ${this.m_transDate.hour}:${this.m_transDate.minute},${this.m_method},${this.m_usage},${this.m_value},${this.m_note}";

  }

  TransactionData clone(){
    return TransactionData(this.m_id,this.m_transDate,this.m_method,this.m_usage,this.m_value,this.m_note);
  }
  static TransactionData create(){

    return TransactionData("", DateTime.now(), "", "", 0, "");
  }
}