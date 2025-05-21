import 'package:flutter/material.dart';
import 'package:transco/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import 'package:geolocator/geolocator.dart';

// Initialize the app with Firebase and App Check
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primaryColor: Colors.teal,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: Colors.teal,
        secondary: const Color.fromARGB(255, 206, 46, 59),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.black),
        labelSmall: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    ),
    home: const MainScreen(),
  ));
}

// MainScreen serves as the entry point with authentication check
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Error occurred while checking auth state.')),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          return const LoginScreen();
        }

        return const HomeScreen();
      },
    );
  }
}

/*
  Authored by: Josh Morante
  Company: TransCo
  Project: TransCo mobile app
  Feature: [TRCO-002] Log in Page
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
  bool _isPasswordVisible = false;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter an email.');
      return;
    }
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter a password.');
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') _errorMessage = 'No user found for that email.';
        else if (e.code == 'wrong-password') _errorMessage = 'Incorrect password.';
        else if (e.code == 'invalid-email') _errorMessage = 'Invalid email format.';
        else _errorMessage = 'Error: ${e.message}';
      });
    } catch (e) {
      setState(() => _errorMessage = 'An unexpected error occurred.');
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
                const SizedBox(height: 40),
                Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Welcome to ',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                        TextSpan(
                          text: 'TransCo',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 2, 183, 176),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Text('EMAIL', style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 5),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 20),
                Text('PASSWORD', style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 5),
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(255, 233, 255, 242),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 14)),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ResetPassword())),
                    child: const Text('Forgot your password?', style: TextStyle(color: Colors.blue, fontSize: 14)),
                  ),
                ),
                Center(child: Text('OR', style: Theme.of(context).textTheme.labelSmall)),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SignUpScreen())),
                    child: const Text('Create an account', style: TextStyle(color: Colors.blue, fontSize: 14)),
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
  Feature: [TRCO-001] Registration Page
  Description: Registration page for new users
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
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  bool _isPasswordValid(String password) {
    final regex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&.])[A-Za-z\d@$!%*#?&.]{8,}$');
    return regex.hasMatch(password);
  }

  Future<void> _signUp() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      setState(() => _errorMessage = 'Please enter your first and last name.');
      return;
    }
    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter an email.');
      return;
    }
    if (password.isEmpty || confirmPassword.isEmpty) {
      setState(() => _errorMessage = 'Please enter and confirm your password.');
      return;
    }
    if (!_isPasswordValid(password)) {
      setState(() {
        _errorMessage =
            'Password must be at least 8 characters, containing a letter, number, and special character.';
      });
      return;
    }
    if (password != confirmPassword) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName('$firstName $lastName');
      await userCredential.user?.sendEmailVerification();
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SignUpScreen2()));
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'weak-password') _errorMessage = 'The password is too weak.';
        else if (e.code == 'email-already-in-use') _errorMessage = 'The email is already in use.';
        else if (e.code == 'invalid-email') _errorMessage = 'Invalid email format.';
        else _errorMessage = 'Error: ${e.message}';
      });
    } catch (e) {
      setState(() => _errorMessage = 'An unexpected error occurred.');
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
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.of(context).pop(),
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
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                              TextSpan(
                                text: 'TransCo',
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 2, 183, 176),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Text('FIRST NAME', style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 5),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 20),
                Text('LAST NAME', style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 5),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 20),
                Text('EMAIL', style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 5),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 20),
                Text('PASSWORD', style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 5),
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(255, 233, 255, 242),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('CONFIRM PASSWORD', style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 5),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(255, 233, 255, 242),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    suffixIcon: IconButton(
                      icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                      onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Password must be at least 8 characters, containing a letter, number, and a unique character.',
                  style: Theme.of(context).textTheme.labelSmall,
                  textAlign: TextAlign.center,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 14), textAlign: TextAlign.center),
                ],
                const SizedBox(height: 40),
                Text(
                  'By creating an account, you agree to our Terms of Services and Privacy Policy',
                  style: Theme.of(context).textTheme.labelSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _signUp,
                    child: const Text('Create account', style: TextStyle(fontSize: 16)),
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
  Feature: [TRCO-003] Email Verification
  Description: Email verification page
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
      setState(() => _message = 'Verification email resent! Please check your inbox.');
    } else if (user == null) {
      setState(() => _message = 'Error: No user is signed in.');
    }
  }

  Future<void> _verifyEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      if (user.emailVerified) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MainScreen()));
      } else {
        setState(() {
          _message = 'Email not verified yet. Please check your inbox and click the verification link.';
        });
      }
    } else {
      setState(() => _message = 'Error: No user is signed in.');
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
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.of(context).pop(),
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
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                              TextSpan(
                                text: 'TransCo',
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 2, 183, 176),
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
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Verify your ',
                                style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic, color: Colors.black),
                              ),
                              TextSpan(
                                text: 'Email ',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'We have sent a verification link to your email. Please check your inbox and click the link to verify your email.',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Didn’t receive the email?',
                          style: TextStyle(fontSize: 12, color: Colors.black),
                        ),
                        WidgetSpan(
                          child: TextButton(
                            onPressed: _resendVerificationEmail,
                            child: const Text('Resend it.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_message != null) ...[
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      _message!,
                      style: TextStyle(color: _message!.contains('Error') ? Colors.red : Colors.green, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _verifyEmail,
                    child: const Text('I’ve Verified My Email', style: TextStyle(fontSize: 16)),
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
  Feature: [TRCO-004] Reset Password
  Description: Password reset page for users
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
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _message = 'Please enter an email.');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() => _message = 'Password reset email sent! Check your inbox.');
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') _message = 'No user found for that email.';
        else if (e.code == 'invalid-email') _message = 'Invalid email format.';
        else _message = 'Error: ${e.message}';
      });
    } catch (e) {
      setState(() => _message = 'An unexpected error occurred.');
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
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.of(context).pop(),
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
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                              TextSpan(
                                text: 'TransCo',
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 2, 183, 176),
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
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Reset ',
                                style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic, color: Colors.black),
                              ),
                              TextSpan(
                                text: 'Password ',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Text('EMAIL', style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 5),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                if (_message != null) ...[
                  const SizedBox(height: 10),
                  Text(_message!, style: TextStyle(color: _message!.contains('Error') ? Colors.red : Colors.green, fontSize: 14)),
                ],
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _resetPassword,
                    child: const Text('Reset Password', style: TextStyle(fontSize: 16)),
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
  Feature: [TRCO-005] Home Screen
  Description: Home screen with Google Maps, local search functionality, and navigation overlay
*/
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool _showSearchSuggestions = false;
  bool _isFabVisible = true;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late Animation<double> _drawerAnimation;
  bool _isDrawerOpen = false;

  // Google Maps related variables
  GoogleMapController? _mapController;
  static const LatLng _initialPosition = LatLng(37.7749, -122.4194);
  bool _isMapLoading = true;

  // Local dataset for search
  final List<Map<String, dynamic>> _localPlaces = [
    {
      'title': 'San Francisco, CA, USA',
      'subtitle': 'City in California',
      'lat': 37.7749,
      'lng': -122.4194,
    },
    {
      'title': 'New York, NY, USA',
      'subtitle': 'City in New York',
      'lat': 40.7128,
      'lng': -74.0060,
    },
    {
      'title': 'Los Angeles, CA, USA',
      'subtitle': 'City in California',
      'lat': 34.0522,
      'lng': -118.2437,
    },
    {
      'title': 'Chicago, IL, USA',
      'subtitle': 'City in Illinois',
      'lat': 41.8781,
      'lng': -87.6298,
    },
  ];

  List<Map<String, dynamic>> _placeSuggestions = [];
  bool _isLoadingSuggestions = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _drawerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.locationWhenInUse.status;
    if (!status.isGranted) {
      status = await Permission.locationWhenInUse.request();
    }
    if (status.isGranted) {
      print('Location permission granted');
    } else {
      print('Location permission denied');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission is required to use the map.')),
        );
      }
    }
  }

  Future<void> _fetchPlaceSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _placeSuggestions = [];
        _isLoadingSuggestions = false;
      });
      return;
    }

    setState(() => _isLoadingSuggestions = true);

    final filteredPlaces = _localPlaces
        .where((place) =>
            place['title'].toLowerCase().contains(query.toLowerCase()) ||
            place['subtitle'].toLowerCase().contains(query.toLowerCase()))
        .map((place) => {
              'title': place['title'] as String,
              'subtitle': place['subtitle'] as String,
              'lat': place['lat'] as double,
              'lng': place['lng'] as double,
            })
        .toList();

    setState(() {
      _placeSuggestions = filteredPlaces;
      _isLoadingSuggestions = false;
    });
  }

  Future<void> _moveToPlace(Map<String, dynamic> place) async {
    final coordinates = LatLng(place['lat'] as double, place['lng'] as double);
    if (_mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: coordinates, zoom: 15)),
      );
      setState(() {
        _searchController.text = place['title'] as String;
        _showSearchSuggestions = false;
        _searchFocusNode.unfocus();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not move to location.')));
    }
  }

  Future<void> _discoverRandomNearby() async {
    if (_localPlaces.isNotEmpty && _mapController != null) {
      final random = Random();
      final randomPlace = _localPlaces[random.nextInt(_localPlaces.length)];
      await _moveToPlace(randomPlace);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Discovered ${randomPlace['title']}!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No places available to discover.')));
    }
  }

  void _openDrawer() {
    setState(() {
      _isFabVisible = false;
      _isDrawerOpen = true;
    });
    _animationController.forward();
    print('Drawer opened, isDrawerOpen: $_isDrawerOpen, isFabVisible: $_isFabVisible');
  }

  Future<void> _closeDrawer() async {
    _animationController.reverse();
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _isDrawerOpen = false;
      _isFabVisible = true;
    });
    print('Drawer close initiated, isDrawerOpen: $_isDrawerOpen, isFabVisible: $_isFabVisible');
  }

  void _closeSearch() {
    setState(() => _showSearchSuggestions = false);
    _searchFocusNode.unfocus();
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isDrawerOpen) {
          print('Back button pressed, closing drawer');
          _closeDrawer();
          return false;
        }
        return true;
      },
      child: GestureDetector(
        onTap: () {
          if (_showSearchSuggestions || _searchFocusNode.hasFocus) _closeSearch();
        },
        behavior: HitTestBehavior.opaque,
        child: Scaffold(
          key: _scaffoldKey,
          body: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {},
                  child: GoogleMap(
                    initialCameraPosition: const CameraPosition(target: _initialPosition, zoom: 12),
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                      setState(() => _isMapLoading = false);
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: false,
                  ),
                ),
              ),
              if (_isMapLoading)
                const Positioned.fill(child: Center(child: CircularProgressIndicator())),
              Positioned(
                left: 16,
                right: 16,
                bottom: 80,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 3)),
                        ],
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() => _showSearchSuggestions = true);
                              _searchFocusNode.requestFocus();
                            },
                            child: const Icon(Icons.search, color: Colors.grey),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              decoration: const InputDecoration(hintText: 'Search here...', border: InputBorder.none),
                              onTap: () => setState(() => _showSearchSuggestions = true),
                              onChanged: _fetchPlaceSuggestions,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_showSearchSuggestions)
                      Container(
                        margin: const EdgeInsets.only(top: 5),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 3)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_isLoadingSuggestions)
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            else if (_placeSuggestions.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('No results found', style: TextStyle(fontSize: 14, color: Colors.grey)),
                              )
                            else
                              ..._placeSuggestions.map((suggestion) {
                                return ListTile(
                                  leading: const Icon(Icons.location_on_outlined, color: Colors.grey),
                                  title: Text(suggestion['title']!, style: const TextStyle(fontSize: 16)),
                                  subtitle: Text(suggestion['subtitle']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  onTap: () => _moveToPlace(suggestion),
                                );
                              }).toList(),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (_isDrawerOpen)
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Stack(
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            print('Outside tap detected on custom overlay');
                            _closeDrawer();
                          },
                          child: Container(color: Colors.black.withOpacity(0.1)),
                        ),
                        Transform.translate(
                          offset: Offset(-300 * (1 - _drawerAnimation.value), 0),
                          child: Container(
                            width: 300,
                            color: Colors.white,
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
                                  color: Theme.of(context).primaryColor,
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Image.asset(
                                          'assets/ncenter_icon.png',
                                          height: 150,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Text('Logo not found', style: TextStyle(color: Colors.white, fontSize: 16)),
                                        ),
                                      ),
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: IconButton(
                                          icon: const Icon(Icons.close, color: Colors.white),
                                          onPressed: _closeDrawer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.person, color: Colors.grey),
                                  title: const Text('Profile'),
                                  onTap: () {
                                    _closeDrawer();
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProfileScreen()));
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.settings, color: Colors.grey),
                                  title: const Text('Settings'),
                                  onTap: () {
                                    _closeDrawer();
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.logout, color: Colors.grey),
                                  title: const Text('Log Out'),
                                  onTap: () async {
                                    await FirebaseAuth.instance.signOut();
                                    _closeDrawer();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
          floatingActionButton: _isFabVisible
              ? Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: FloatingActionButton(
                    onPressed: _openDrawer,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(Icons.menu, color: Colors.white),
                  ),
                )
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.white,
            selectedItemColor: Theme.of(context).colorScheme.secondary,
            unselectedItemColor: Colors.grey,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.place), label: 'Explore'),
              BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
              BottomNavigationBarItem(icon: Icon(Icons.casino), label: 'Discover'),
            ],
            currentIndex: 0,
            onTap: (index) {
              if (index == 2) _discoverRandomNearby();
            },
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
  Feature: [TRCO-006] Profile Page
  Description: Profile page for users to view and edit their information
*/
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
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
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Your ',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                              const TextSpan(
                                text: 'Profile',
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
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade300,
                    child: const Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    user?.displayName ?? 'No Name',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    user?.email ?? 'No Email',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'Account Details',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.email, color: Colors.grey),
                  title: const Text('Email'),
                  subtitle: Text(user?.email ?? 'No Email'),
                ),
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.grey),
                  title: const Text('Name'),
                  subtitle: Text(user?.displayName ?? 'No Name'),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit Profile feature coming soon!')));
                    },
                    child: const Text('Edit Profile', style: TextStyle(fontSize: 16)),
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
  Feature: [TRCO-007] Settings Page
  Description: Settings page for users to manage app preferences
*/
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

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
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'App ',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                              const TextSpan(
                                text: 'Settings',
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
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Preferences',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  title: const Text('Enable Notifications'),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() => _notificationsEnabled = value);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Notifications ${value ? 'enabled' : 'disabled'} (placeholder)')),
                    );
                  },
                ),
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: _darkModeEnabled,
                  onChanged: (value) {
                    setState(() => _darkModeEnabled = value);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Dark Mode ${value ? 'enabled' : 'disabled'} (placeholder)')),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Account',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.lock, color: Colors.grey),
                  title: const Text('Change Password'),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ResetPassword())),
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete Account'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delete Account feature coming soon!')));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}