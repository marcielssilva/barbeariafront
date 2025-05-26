class Client {
  final String name;
  final String phone;
  final String email;
  final String password;

  Client({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
  });

  // Convert to JSON for sending to API
  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'email': email,
    'password': password,
  };

  // Create from JSON when receiving from API
  factory Client.fromJson(Map<String, dynamic> json) => Client(
    name: json['name'],
    phone: json['phone'],
    email: json['email'],
    password: '',
  );
}
