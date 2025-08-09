class AnalyticModel {
  String? screenName;

  AnalyticModel({ this.screenName});

  AnalyticModel.fromJson(Map<String, dynamic> json) {
    screenName = json['screen_name'];
  }

  Map<String, Object> toJson() {
    final Map<String, Object> data = new Map<String, Object>();
    data['screen_name'] = this.screenName ?? "";
    return data;
  }
}
