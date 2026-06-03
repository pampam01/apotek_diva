class UserModel {
  final int idUser;
  final String username;
  final String role;
  final String namaLengkap;

  UserModel({
    required this.idUser,
    required this.username,
    required this.role,
    required this.namaLengkap,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idUser: json['id_user'] is String ? int.parse(json['id_user']) : json['id_user'],
      username: json['username'],
      role: json['role'],
      namaLengkap: json['nama_lengkap'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_user': idUser,
      'username': username,
      'role': role,
      'nama_lengkap': namaLengkap,
    };
  }
}
