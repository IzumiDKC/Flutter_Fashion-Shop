class UserProfile {
  final String userName;
  final String email;
  final String fullName;
  final String? age;
  final String? address;
  final String? phoneNumber;

  UserProfile({
    required this.userName,
    required this.email,
    required this.fullName,
    this.age,
    this.address,
    this.phoneNumber,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userName: json['userName'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      age: json['age'] as String?,
      address: json['address'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
    );
  }
}
