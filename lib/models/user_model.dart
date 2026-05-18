enum UserRole { customer, pharmacist }

class UserModel {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final String? profilePic;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.profilePic,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role.toString().split('.').last,
      'profilePic': profilePic,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      role: map['role'] == 'pharmacist' ? UserRole.pharmacist : UserRole.customer,
      profilePic: map['profilePic'],
    );
  }
}
