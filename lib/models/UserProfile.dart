class UserProfile {
  final String userName;
  final String email;
  final String fullName;
  final String age;
  final String address;
  final String phoneNumber;

  UserProfile({
    required this.userName,
    required this.email,
    required this.fullName,
    required this.age,
    required this.address,
    required this.phoneNumber,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userName: json['userName'],
      email: json['email'],
      fullName: json['fullName'],
      age: json['age'],
      address: json['address'],
      phoneNumber: json['phoneNumber'],
    );
  }
}
