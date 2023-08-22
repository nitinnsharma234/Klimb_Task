
class ProfileModel {
  final String setting_id;
  final String id;
  final String themeColor;
  final double textSize;

  // final String themeColor;
  // final int textSize;

  ProfileModel({required this.setting_id, required this.id, required this.themeColor, required this.textSize});

  Map<String, dynamic> toMap() {
    return {
      'setting_id':setting_id,
      'id': id,
      'themeColor': themeColor,
      'textSize': textSize,
      // 'themeColor':themeColor,
      // 'textSize':textSize
    };
  }

  static ProfileModel fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'],
      setting_id: map['setting_id'],
      themeColor: map['themeColor'],
      textSize: map['textSize'],
    );
  }
}