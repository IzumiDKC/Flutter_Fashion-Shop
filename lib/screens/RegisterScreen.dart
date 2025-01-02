import 'package:flutter/material.dart';
import 'package:fb88/api/api_client.dart';
import '../models/AuthModels.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final request = RegisterRequest(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        fullName: _fullNameController.text,
      );

      try {
        final apiClient = ApiClient();
        await apiClient.register(request);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("\u0110\u0103ng k\u00fd th\u00e0nh c\u00f4ng")),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("\u0110\u0103ng k\u00fd th\u1ea5t b\u1ea1i: $e")),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("\u0110\u0103ng K\u00fd"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo or Icon
            Image.network('https://i.imgur.com/qmPSeO1.png',
              height: 100,
              width: 100,
            ),
            SizedBox(height: 20),
            Text(
              "T\u1ea1o t\u00e0i kho\u1ea3n m\u1edbi",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    controller: _fullNameController,
                    label: "H\u1ecd v\u00e0 t\u00ean",
                    icon: Icons.person,
                  ),
                  _buildTextField(
                    controller: _usernameController,
                    label: "T\u00ean \u0111\u0103ng nh\u1eadp",
                    icon: Icons.account_circle,
                  ),
                  _buildTextField(
                    controller: _emailController,
                    label: "Email",
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _buildTextField(
                    controller: _passwordController,
                    label: "M\u1eadt kh\u1ea9u",
                    icon: Icons.lock,
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(
                        vertical: 14.0,
                        horizontal: 32.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "\u0110\u0103ng K\u00fd",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "$label kh\u00f4ng \u0111\u01b0\u1ee3c \u0111\u1ec3 tr\u1ed1ng";
          }
          return null;
        },
      ),
    );
  }
}
