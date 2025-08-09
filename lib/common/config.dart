import 'package:flutter/services.dart';
import 'package:lynk_an/common/theme.dart';
import 'package:lynk_an/data/local/shared_prefs/shared_prefs.dart';
import 'package:lynk_an/data/local/shared_prefs/shared_prefs_key.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'assets.dart';
import 'globals.dart';
import 'lang_key.dart';
import 'utils/utility.dart';

class Config {

  static Future<void> getPreferences() async {
    await SharedPreferences.getInstance().then((event) async {
      Globals.prefs = SharedPrefs(event);
      dynamic jsonResult = Utility.stringToJson(await rootBundle.loadString(Assets.configJson));
      Globals.applicationMode = jsonResult["environment"];
      Globals.config = Config.fromJson(jsonResult[jsonResult["environment"]]);
      if((Globals.config.langDefault ?? "").isNotEmpty){
        LangKey.langDefault = Globals.config.langDefault!;
      }
      double size = Globals.prefs.getDouble(SharedPrefsKey.font_size, value: AppTextSizes.body);
      if(size != AppTextSizes.body) {
        AppTextSizes.update(size);
      }
    });
    return;
  }

  String? server;
  String? langDefault;
  bool? enableLang;
  String? releaseDate;
  bool? displayPrint;

  Config(
      {
        this.server,
        this.langDefault,
        this.enableLang,
        this.releaseDate,
        this.displayPrint});

  Config.fromJson(Map<String, dynamic> json) {
    server = json['server'];
    if (!server!.endsWith("/")) {
      server = "$server/";
    }
    langDefault = json['langDefault'];
    enableLang = json['enableLang'] ?? false;
    releaseDate = json['releaseDate'];
    displayPrint = json['displayPrint'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['server'] = this.server;
    data['langDefault'] = this.langDefault;
    data['enableLang'] = this.enableLang;
    data['releaseDate'] = this.releaseDate;
    data['displayPrint'] = this.displayPrint;
    return data;
  }
}
