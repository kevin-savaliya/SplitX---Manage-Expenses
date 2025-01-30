import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  //signin
  static Future<http.Response> signin() async {
    print("Called");
    final response = await http.post(
      Uri.parse('http://localhost/mightyfitness%20bankend/api/login'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        "email": "savaliyakevin77@gmail.com",
        "user_type": "user",
        "password": "123456"
      }),
    );

    print(response.body);

    return response;
  }
}
