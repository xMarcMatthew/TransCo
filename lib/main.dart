import 'package:flutter/material.dart';
import 'package:transco/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/gestures.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity, // Use Play Integrity for Android
  );

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MainScreen(),
  ));
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    ); 
  }
}

/*
  Authored by: Josh Morante
  Company: TransCo
  Project: TransCo mobile app
  Feature: [TRCO - 002] Log in Page
  Description: Log in page for users
*/
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isPasswordVisible = false; // State to toggle password visibility

  // Function to handle login with Firebase
  Future<void> _login() async {
    try {
      // Sign in with email and password
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // On successful login, navigate to the next screen (e.g., a HomeScreen)
      // Replace this with your desired navigation
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()), // Define HomeScreen
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          _errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          _errorMessage = 'Incorrect password.';
        } else {
          _errorMessage = 'Error: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred.';
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Welcome to ',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: 'Tra',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 206, 46, 59),
                          ),
                        ),
                        TextSpan(
                          text: 'ns',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 253, 190, 59),
                          ),
                        ),
                        TextSpan(
                          text: 'Co',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 2, 183, 176),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'EMAIL',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Francis@gmail.com',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'PASSWORD',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible, // Toggle visibility
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(255, 233, 255, 242),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                if (_errorMessage != null) ...[
                  SizedBox(height: 10),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ],
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => ResetPassword()),
                      );
                    },
                    child: Text(
                      'Forgot your password?',
                      style: TextStyle(color: Colors.blue, fontSize: 14),
                    ),
                  ),
                ),
                Center(child: Text('OR', style: TextStyle(color: Colors.grey))),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => SignUpScreen()),
                      );
                    },
                    child: Text(
                      'Create an account',
                      style: TextStyle(color: Colors.blue, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*
  Authored by: Marc Bagasbas
  Company: TransCo
  Project: TransCo mobile app
  Feature: [TRCO - 001] Registration Page
  Description: page 1 of the registration page, It is still in progress for completion
*/
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _errorMessage;
  bool _isPasswordVisible = false; // State to toggle password visibility
  bool _isConfirmPasswordVisible = false; // State to toggle confirm password visibility

  Future<void> _signUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match.';
      });
      return;
    }

    try {
      // Create user with email and password
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Update user profile with first and last name
      await userCredential.user?.updateDisplayName(
        '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
      );

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      // Navigate to the email verification screen
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => SignUpScreen2()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'weak-password') {
          _errorMessage = 'The password is too weak.';
        } else if (e.code == 'email-already-in-use') {
          _errorMessage = 'The email is already in use.';
        } else {
          _errorMessage = 'Error: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred.';
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 100,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => LoginScreen()),
                            );
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Welcome to ',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: 'Tra',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 206, 46, 59),
                                ),
                              ),
                              TextSpan(
                                text: 'ns',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 253, 190, 59),
                                ),
                              ),
                              TextSpan(
                                text: 'Co',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 2, 183, 176),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'FIRST NAME',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    hintText: 'Josh',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'LAST NAME',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    hintText: 'Reyes',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'EMAIL',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Francis@gmail.com',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'PASSWORD',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible, // Toggle visibility
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(255, 233, 255, 242),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'CONFIRM PASSWORD',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible, // Toggle visibility
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(255, 233, 255, 242),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Password must be at least 8 characters, containing a letter, number, and a unique character.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                if (_errorMessage != null) ...[
                  SizedBox(height: 10),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
                SizedBox(height: 40),
                Text(
                  'By creating an account, you agree to our Terms of Services and Privacy Policy',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Create account',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*
  Authored by: Marc Bagasbas
  Company: TransCo
  Project: TransCo mobile app
  Feature: [TRCO - 003] Email Verification
  Description: Email Verification page, still in progress
*/
class SignUpScreen2 extends StatefulWidget {
  const SignUpScreen2({super.key});

  @override
  _SignUpScreen2State createState() => _SignUpScreen2State();
}

class _SignUpScreen2State extends State<SignUpScreen2> {
  String? _message;

  Future<void> _resendVerificationEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      setState(() {
        _message = 'Verification email resent! Please check your inbox.';
      });
    } else if (user == null) {
      setState(() {
        _message = 'Error: No user is signed in.';
      });
    }
  }

  Future<void> _verifyEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload(); // Refresh user data
      if (user.emailVerified) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        setState(() {
          _message = 'Email not verified yet. Please check your inbox and click the verification link.';
        });
      }
    } else {
      setState(() {
        _message = 'Error: No user is signed in.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 100,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => SignUpScreen()),
                            );
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Welcome to ',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: 'Tra',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 206, 46, 59),
                                ),
                              ),
                              TextSpan(
                                text: 'ns',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 253, 190, 59),
                                ),
                              ),
                              TextSpan(
                                text: 'Co',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 2, 183, 176),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Verify your ',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: 'Email ',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Text(
                    'We have sent a verification link to your email. Please check your inbox and click the link to verify your email.',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Didn’t receive the email? ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: 'Resend it.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = _resendVerificationEmail,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_message != null) ...[
                  SizedBox(height: 10),
                  Center(
                    child: Text(
                      _message!,
                      style: TextStyle(
                        color: _message!.contains('Error') ? Colors.red : Colors.green,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _verifyEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'I’ve Verified My Email',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*
  Authored by: Josh Morante
  Company: TransCo
  Project: TransCo mobile app
  Feature: [TRCO - 004] Reset Password
  Description: Password Reset page for users
*/
class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _emailController = TextEditingController();
  String? _message;

  Future<void> _resetPassword() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      setState(() {
        _message = 'Password reset email sent! Check your inbox.';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          _message = 'No user found for that email.';
        } else {
          _message = 'Error: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        _message = 'An unexpected error occurred.';
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 100,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => LoginScreen()),
                            );
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Welcome to ',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: 'Tra',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 206, 46, 59),
                                ),
                              ),
                              TextSpan(
                                text: 'ns',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 253, 190, 59),
                                ),
                              ),
                              TextSpan(
                                text: 'Co',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 2, 183, 176),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Reset ',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: 'Password ',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'EMAIL',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Francis@gmail.com',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                if (_message != null) ...[
                  SizedBox(height: 10),
                  Text(
                    _message!,
                    style: TextStyle(
                      color: _message!.contains('Error') ? Colors.red : Colors.green,
                      fontSize: 14,
                    ),
                  ),
                ],
                SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 2, 183, 176),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Reset Password',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 430,
          height: 932,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 430,
                  height: 928,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/430x928"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                top: 690,
                child: Text(
                  'Google',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Positioned(
                left: 364,
                top: 665,
                child: Container(
                  width: 51,
                  height: 51,
                  decoration: ShapeDecoration(
                    color: Colors.white.withValues(alpha: 204),
                    shape: OvalBorder(),
                  ),
                ),
              ),
              Positioned(
                left: 379,
                top: 680,
                child: Container(
                  width: 21,
                  height: 21,
                  decoration: ShapeDecoration(
                    shape: OvalBorder(
                      side: BorderSide(
                        width: 6,
                        color: const Color(0xFF02B7B0),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 400,
                top: 691,
                child: Container(
                  width: 5,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        strokeAlign: BorderSide.strokeAlignCenter,
                        color: const Color(0xFF02B7B0),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 374,
                top: 691,
                child: Container(
                  width: 5,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        strokeAlign: BorderSide.strokeAlignCenter,
                        color: const Color(0xFF02B7B0),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 390,
                top: 680,
                child: Container(
                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(-1.57),
                  width: 5,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        strokeAlign: BorderSide.strokeAlignCenter,
                        color: const Color(0xFF02B7B0),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 390,
                top: 706,
                child: Container(
                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(-1.57),
                  width: 5,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        strokeAlign: BorderSide.strokeAlignCenter,
                        color: const Color(0xFF02B7B0),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 10,
                top: 775,
                child: Container(
                  width: 410,
                  height: 50,
                  decoration: ShapeDecoration(
                    color: Colors.black.withValues(alpha: 26),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 379,
                top: 788,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: ShapeDecoration(
                    shape: OvalBorder(
                      side: BorderSide(
                        width: 3,
                        color: const Color(0xFF02B7B0),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 395.83,
                top: 804,
                child: Container(
                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(0.79),
                  width: 6,
                  height: 4,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignCenter,
                        color: const Color(0xFF02B7B0),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 25,
                top: 25,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: ShapeDecoration(
                    color: Colors.black.withValues(alpha: 38),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  ),
                ),
              ),
              Positioned(
                left: 26,
                top: 30,
                child: Container(
                  width: 58,
                  height: 50,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/58x50"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 834,
                child: Container(
                  width: 429,
                  height: 98,
                  decoration: BoxDecoration(color: const Color(0xFFFAFFFD)),
                ),
              ),
              Positioned(
                left: 77,
                top: 842,
                child: Container(
                  width: 23,
                  height: 33,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/23x33"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 39,
                top: 883,
                child: SizedBox(
                  width: 100,
                  height: 28,
                  child: Text(
                    'Explore',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFFCE2E3B),
                      fontSize: 20,
                      fontFamily: 'Creato Display',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 204,
                top: 844,
                child: Container(
                  width: 21,
                  height: 31,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/21x31"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 165,
                top: 883,
                child: SizedBox(
                  width: 100,
                  height: 28,
                  child: Text(
                    'Saved',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFFFDBE3B),
                      fontSize: 20,
                      fontFamily: 'Creato Display',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 294,
                top: 883,
                child: SizedBox(
                  width: 100,
                  height: 28,
                  child: Text(
                    'Discover',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF02B7B0),
                      fontSize: 20,
                      fontFamily: 'Creato Display',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 326,
                top: 842,
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/35x35"),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}