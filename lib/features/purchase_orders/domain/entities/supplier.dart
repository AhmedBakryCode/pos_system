import 'package:equatable/equatable.dart';

class Supplier extends Equatable {
  final int id;
  final String fname;
  final String lname;
  final String? address;
  final String? phone;
  final String? email;
  final String? createdAt;
  final String? updatedAt;

  const Supplier({
    required this.id,
    required this.fname,
    required this.lname,
    this.address,
    this.phone,
    this.email,
    this.createdAt,
    this.updatedAt,
  });

  String get name => '$fname $lname';

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: int.parse(json['id'].toString()),
      fname: json['fname'] as String,
      lname: json['lname'] as String,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fname': fname,
        'lname': lname,
        'address': address,
        'phone': phone,
        'email': email,
      };

  @override
  List<Object?> get props => [id, fname, lname, address, phone, email, createdAt, updatedAt];
}
