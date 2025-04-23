import 'package:flutter/material.dart';
import 'base_slide.dart';

class SlideTwo extends BaseSlide {
  const SlideTwo({
    Key? key, 
    required double sizeOfFont,
  }) : super(key: key, sizeOfFont: sizeOfFont);

  @override
  State<SlideTwo> createState() => _SlideTwoState();
}

class _SlideTwoState extends BaseSlideState<SlideTwo> {
  @override
  AssetImage getBackgroundImage() {
    return const AssetImage('assets/background/sunset_mountian.jpg');
  }

  @override
  Widget buildContent(BuildContext context) {
  return Stack(
      children: [
        // Rectangle at bottom between buttons
        Positioned(
          bottom: 50,
          left: 20,
          right: 20,
          child: Container(
            // Dynamic height based on screen size
            height: MediaQuery.of(context).size.height * 0.16,// 15% of screen height
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7), // More reliable opacity
              borderRadius: BorderRadius.circular(30),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              
                child: Text(
                  'A peek to the UI - fill it when we have a map page and the community page',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    // fontSize: MediaQuery.of(context).size.width * 0.1,
                    fontSize: widget.sizeOfFont,
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