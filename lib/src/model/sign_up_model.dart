class SignUpBodyModel {
  String name;
  String phone;
  String email;
  String address;
  String password;
  int role;
  //build constructor

  SignUpBodyModel({
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.password,
    required this.role,


  });

  Map<String, dynamic> toJson(){final Map<String, dynamic> data = <String, dynamic>{};
  data['f_name'] = name;
  data['phone'] = phone;
  data['email'] = email;
  data['address'] = address;
  data['role'] = role;
  data['password'] = password;
  return data;
  }
}