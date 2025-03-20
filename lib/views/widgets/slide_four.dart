import 'package:flutter/material.dart';
import 'base_slide.dart';

class SlideFour extends BaseSlide {
  const SlideFour({Key? key}) : super(key: key);

  @override
  State<SlideFour> createState() => _SlideFourState();
}

class _SlideFourState extends BaseSlideState<SlideFour> {
  @override
  AssetImage getBackgroundImage() {
    return const AssetImage('assets/background/luke_skywalker_retrite.jpg');
  }

  @override
  Widget buildContent(BuildContext context) {
  return Stack(
      children: [
        // Main content
        Container(
          padding: EdgeInsets.all(32),
          // add a background image
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background/sunset_mountian.jpg'),
              fit: BoxFit.cover, // Adjust how the image fills the screen
            ),
          ),
        ),
        
        // Rectangle at bottom between buttons
        Positioned(
          bottom: 50,
          left: 20,
          right: 20,
          child: Container(
            // Dynamic height based on screen size
            height: MediaQuery.of(context).size.height * 0.2,// 15% of screen height
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7), // More reliable opacity
              borderRadius: BorderRadius.circular(30),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              
                child: Text(
                  'Tricky part alerts',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.06,
                    fontFamily: 'arial',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
