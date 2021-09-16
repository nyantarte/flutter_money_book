import 'dart:async'; //非同期処理用
import 'package:http/http.dart' as http;
import 'dart:convert';
class NotionDataManager{
  String m_integrationID;
  String m_dbID;

  NotionDataManager(this.m_integrationID,this.m_dbID){}

  Future<Object> getDBData() async{
    var url="https://api.notion.com/v1/databases/$m_dbID/query";
    var header= {
      "Authorization": "Bearer $m_integrationID",
      "Notion-Version": "2021-05-13" ,
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
     // "Access-Control-Allow-Headers": "*",
      "Access-Control-Allow-Methods": "GET, POST",
      "Access-Control-Allow-Headers": "X-Requested-With"
    };
    var body="{}";
    return jsonDecode(await getData(url, header, body));

  }

  Future<String> getData(String url,Map<String,String> headerList,String bodyData) async {
    var targetSite = Uri.parse(url);

    final response=await http.post(targetSite,headers:headerList,body:bodyData );
    if(200==response.statusCode) {
      return response.body;
    }
    return "";

  }
}