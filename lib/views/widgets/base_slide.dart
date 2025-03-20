import 'package:flutter/material.dart';

abstract class BaseSlide extends StatefulWidget {
  const BaseSlide({Key? key}) : super(key: key);
}

abstract class BaseSlideState<T extends BaseSlide> extends State<T> {
  bool _imageLoaded = false;
  late final AssetImage _backgroundImage;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  void _loadImage() {
    _backgroundImage = getBackgroundImage();
    _backgroundImage.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((info, _) {
        if (mounted) {
          setState(() {
            _imageLoaded = true;
          });
        }
      }),
    );
  }

  AssetImage getBackgroundImage();

  Widget buildContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background
        AnimatedOpacity(
          opacity: _imageLoaded ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: _backgroundImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        
        // Content
        AnimatedOpacity(
          opacity: _imageLoaded ? 1.0 : 0.0, 
          duration: const Duration(milliseconds: 300),
          child: buildContent(context),
        ),
        
        // Loading indicator
        if (!_imageLoaded)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}