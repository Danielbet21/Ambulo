import 'package:flutter/material.dart';
import 'base_slide.dart';

class SlideOne extends BaseSlide {
  const SlideOne({Key? key}) : super(key: key);

  @override
  State<SlideOne> createState() => _SlideOneState();
}

class _SlideOneState extends BaseSlideState<SlideOne> {
  @override
  AssetImage getBackgroundImage() {
    return const AssetImage('assets/background/luke_skywalker_retrite.jpg');
  }

  @override
  Widget buildContent(BuildContext context) {
  return Center(  // Wrap with Center widget
    child: Column(
      children: [
        SizedBox(height: 150),
        Text(
          'AMBULO',
          style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            fontFamily: 'MyCustomFont',
            color: const Color.fromARGB(255, 225, 169, 0),
          ),
        ),
      ],
    )
  );
  }
}