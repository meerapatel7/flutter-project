class User {
  late int _userId;
  late String _name;
  late String _email;
  late String _password;

  int get userId => _userId;

  set userId(int value) {
    _userId = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get password => _password;

  set password(String value) {
    _password = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  Map<String, dynamic> toMap() {
    return {
      '_userId': this._userId,
    };
  }
}