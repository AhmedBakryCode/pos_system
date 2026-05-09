class User {
  final int id;
  final String fname;
  final String lname;
  final String email;
  final String? phone;
  final String? profileImage;
  final String? address;
  final String role;

  const User({
    required this.id,
    required this.fname,
    required this.lname,
    required this.email,
    this.phone,
    this.profileImage,
    this.address,
    required this.role,
  });

  String get fullName => '$fname $lname';

  factory User.fromJson(Map<String, dynamic> json) {
    String? profileImage = json['profile_image'] as String?;
    if (profileImage != null) {
      // Fix potential misconfiguration from backend where it returns internal paths
      if (profileImage.contains('app/public/')) {
        profileImage = profileImage.replaceAll('app/public/', '');
      }
      // Normalize double storage or relative paths
      if (profileImage.contains('storage/../../storage/')) {
        profileImage = profileImage.replaceAll('storage/../../storage/', 'storage/');
      }
    }
    
    return User(
      id: int.parse(json['id'].toString()),
      fname: json['fname'] as String,
      lname: json['lname'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      profileImage: profileImage,
      address: json['address'] as String?,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fname': fname,
      'lname': lname,
      'email': email,
      'phone': phone,
      'profile_image': profileImage,
      'address': address,
      'role': role,
    };
  }
}
