import 'package:flutter/material.dart';
import 'package:ambulo/views/pages/register_page.dart';
import 'dart:ui'; // For ImageFilter
import 'base_slide.dart';

class FinalSlide extends BaseSlide {
  const FinalSlide({Key? key}) : super(key: key);

  @override
  State<FinalSlide> createState() => _FinalSlideState();
}

class _FinalSlideState extends BaseSlideState<FinalSlide> {
  @override
  AssetImage getBackgroundImage() {
    // Use the same image as slide four
    return const AssetImage('assets/background/sunset_mountian.jpg');
  }

  @override
  Widget buildContent(BuildContext context) {
    return Stack(
      children: [
        // Blurred overlay
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            color: Colors.black.withOpacity(0.3),
          ),
        ),
        
        // Center content
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ready to begin your journey?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(180, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => RegisterPage()),
                  );
                },
                child: Text(
                  "Let's Go!",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}