import 'package:flutter/material.dart';
import 'base_slide.dart';

class SlideFour extends BaseSlide {
  const SlideFour({Key? key,
    required double sizeOfFont
    }) : super(key: key, sizeOfFont: sizeOfFont);

  @override
  State<SlideFour> createState() => _SlideFourState();
}

class _SlideFourState extends BaseSlideState<SlideFour> {
  @override
  AssetImage getBackgroundImage() {
    return const AssetImage('assets/background/tricky_part_notification.png');
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
            height: MediaQuery.of(context).size.height * 0.16,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7), // More reliable opacity
              borderRadius: BorderRadius.circular(30),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              
                child: Text(
                  'Stay ahead of surprises - offline maps & GPS alerts warn you near unmarked turns, hidden trail marks, or confusing forks on your way.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: widget.sizeOfFont,
                    fontFamily: 'arial',
                    // fontWeight: FontWeight.bold,
                    color: Colors.black, // Text color
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
