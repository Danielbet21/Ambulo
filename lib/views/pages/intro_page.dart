import 'package:ambulo/views/pages/register_page.dart';
import 'package:ambulo/views/widgets/slide_four.dart';
import 'package:ambulo/views/widgets/slide_one.dart';
import 'package:ambulo/views/widgets/slide_three.dart';
import 'package:ambulo/views/widgets/slide_two.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _numPages = 4;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
  final isLikelyMobileSize = screenWidth < 600;
  final showButtons = kIsWeb && !isLikelyMobileSize;

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: [
              // Slide 1
              SlideOne(),
              // Slide 2
              SlideTwo(),
              // Slide 3
              SlideThree(),
              // Slide 4
              SlideFour(),
            ],
          ),
          // Dots indicator and Next/Done button
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < _numPages; i++)
                  _buildIndicator(i == _currentPage),
              ],
            ),
          ),
           if(showButtons)
          // Previous button - add this new Positioned widget
            Positioned(
              bottom: 30,
              left: 20,
              child: _currentPage > 0 ? 
              ElevatedButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },
                    child: Icon(Icons.arrow_back),
                  )
                : 
                SizedBox.shrink(), // Hide on first page
            ),
           if(showButtons)
            Positioned(
              bottom: 30,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage == _numPages - 1) {
                    // On the last slide -> do something (e.g., navigate or close)
                    // For example:
                    Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => RegisterPage()));
                  } else {
                    // Move to next page
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  }
                },
                child: _currentPage == _numPages - 1 ? Text("Let's go!") : Icon(Icons.arrow_forward),
              ),
            ),
            if (!showButtons && _currentPage == _numPages - 1)
            Positioned(
              bottom: 10,
              right: 20,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Adjust radius as needed
                  ),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  ),
                onPressed: () {
                  Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => RegisterPage()));
                },
                child: Text("Let's go!"),
              ),
            ), 
        ],
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isActive ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.blue : Colors.grey,
        borderRadius: BorderRadius.all(Radius.circular(2)),
      ),
    );
  }
}
