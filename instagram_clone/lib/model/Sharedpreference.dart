import 'package:shared_preferences/shared_preferences.dart';
//shared preference store data as key - value
// save - get - delete - clear
class Cachehelper {
  static late SharedPreferences sharedPreferences;   //declare
  static Future<void> cacheInitialization() async {
    sharedPreferences = await SharedPreferences.getInstance();  //assignment
  }
  //methods
//1-set data
  Future <bool> setData({required String key,required dynamic value}) async {
    if(value is String){
      return await sharedPreferences.setString(key, value);
    }
    if(value is int){
      return await sharedPreferences.setInt(key, value);
    }
    if(value is double){
      return await sharedPreferences.setDouble(key, value);
    }
    if(value is bool){
      return await sharedPreferences.setBool(key, value);
    }
    return false;
  }
  //2-get data
  dynamic getData({required String key}){
    return sharedPreferences.get(key);
  }
  //3-delete data
  Future<bool> deleteData({required String key}){
    return sharedPreferences.remove(key);
  
  }
  }