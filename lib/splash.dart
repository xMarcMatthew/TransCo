import 'package:flutter/material.dart';
import 'main.dart'; // Import your main screen

void main() {
  runApp(MyApp());
}

/*
  Authored by: Francis Reyes
  Company: TransCo
  Project: TransCo mobile app
  Feature: [TRCO - 008] Splash Screen
  Description: a simple splash screen during wait times in the app
*/

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _circleSize;
  double _overlayOpacity = 1.0; // Opacity for the road overlay
  double _iconOpacity = 1.0; // Opacity for the first icon
  double _newIconOpacity = 0.0; // Opacity for the second icon
  double _screenOpacity = 1.0; // Controls entire screen fade-out
  bool _startShrinking = false; // Controls when the background starts shrinking

  @override
  void initState() {
    super.initState();

    // Animation controller for smooth shrinking
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 6),
    );

    // Animate from a very large circle (way outside the screen) to 0
    _circleSize = Tween<double>(begin: 6000, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Start shrinking after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _startShrinking = true;
      });
      _controller.forward();
    });

    // Fade out the overlay after 8 seconds
    Future.delayed(Duration(seconds: 8), () {
      setState(() {
        _overlayOpacity = 0.0;
      });
    });

    // Fade out the first icon and fade in the second icon after 5 seconds
    Future.delayed(Duration(seconds: 7), () {
      setState(() {
        _iconOpacity = 0.0;
        _newIconOpacity = 1.0;
      });
    });

    // Fade out the entire screen and navigate to main.dart after 10 seconds
    Future.delayed(Duration(seconds: 10), () {
      setState(() {
        _screenOpacity = 0.0;
      });
    });

    // Navigate to main.dart after the fade-out completes
    Future.delayed(Duration(seconds: 12), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainScreen()), // Replace with actual main screen widget
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Clean up animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedOpacity(
        duration: Duration(seconds: 2),
        opacity: _screenOpacity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Animated shrinking background in a circular shape
            if (_startShrinking)
              AnimatedBuilder(
                animation: _circleSize,
                builder: (context, child) {
                  return ClipPath(
                    clipper: CircleClipper(_circleSize.value),
                    child: Container(
                      color: Color(0xFF1E2E3E), // Background color
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  );
                },
              ),

            // Overlaying the road map image (Appears first, then fades out)
            AnimatedOpacity(
              duration: Duration(seconds: 2),
              opacity: _overlayOpacity,
              child: Container(
                color: Colors.transparent,
                child: Image.asset(
                  'assets/road_map.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),

            // First Icon (Appears Immediately & Fades Out)
            AnimatedOpacity(
              duration: Duration(seconds: 2),
              opacity: _iconOpacity,
              child: Image.asset(
                'assets/center_icon.png',
                width: 350,
                height: 350,
              ),
            ),

            // Second Icon (Fades In after First Icon Fades Out)
            AnimatedOpacity(
              duration: Duration(seconds: 2),
              opacity: _newIconOpacity,
              child: Image.asset(
                'assets/ncenter_icon.png',
                width: 350,
                height: 350,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom clipper to create a circular shrinking effect
class CircleClipper extends CustomClipper<Path> {
  final double radius;
  CircleClipper(this.radius);

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.addOval(Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: radius,
      height: radius,
    ));
    return path;
  }

  @override
  bool shouldReclip(CircleClipper oldClipper) => true;
}