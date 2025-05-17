class UserDTO {
  final String id;
  final String email;
  final String role;
  final String firstName;
  final String lastName;
  final String dateOfBirth;

  UserDTO({
    required this.id,
    required this.email,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
  });

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      id: json['id'],
      email: json['email'],
      role: json['role'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      dateOfBirth: json['dateOfBirth'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
    };
  }
}
