class Admin {
  int id;
  String username;
  String password;
  Admin({required this.id, required this.password, required this.username});
  factory Admin.fromJson(Map<String, dynamic> json) => Admin(
        id: int.parse(json['id'].toString()),
        username: json['username'],
        password: json['password'],
      );
}
