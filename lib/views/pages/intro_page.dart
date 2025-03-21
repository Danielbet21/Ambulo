import 'package:ambulo/data/styles/conatant.dart';
import 'package:ambulo/views/pages/register_page.dart';
import 'package:ambulo/views/widgets/final_slide.dart';
import 'package:ambulo/views/widgets/slide_four.dart';
import 'package:ambulo/views/widgets/slide_one.dart';
import 'package:ambulo/views/widgets/slide_three.dart';
import 'package:ambulo/views/widgets/slide_two.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class IntroPage extends StatefulWidget {
 const IntroPage({Key? key}) : super(key: key);

  @override
   State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _numPages = 5;

  @override
  Widget build(BuildContext context) {
  final double sizeOfFont = MediaQuery.of(context).size.width * 0.06 > 30 ? 30 : AppConstants.kFontSizeLarge;
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
              SlideOne(sizeOfFont: sizeOfFont),
              // Slide 2
              SlideTwo(sizeOfFont: sizeOfFont),
              // Slide 3
              SlideThree(sizeOfFont: sizeOfFont),
              // Slide 4
              SlideFour(sizeOfFont: sizeOfFont),
              // Slide 5
              FinalSlide(sizeOfFont: sizeOfFont),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 143, 181, 143),
                  side: BorderSide(color: Colors.green.shade800, width: 2), // Add green border
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Optional: rounded corners
                  ),
                ),
                    onPressed: () {
                      _pageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },
                    child: Icon(Icons.arrow_back, color: Colors.black),
                  )
                : 
                SizedBox.shrink(), // Hide on first page
            ),
           if (showButtons && _currentPage < _numPages - 1) // Hide on last page
            Positioned(
              bottom: 30,
              right: 20,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 143, 181, 143),
                  side: BorderSide(color: Colors.green.shade800, width: 2), // Add green border
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Optional: rounded corners
                  ),
                ),
                onPressed: () {
                  // Move to next page (last page button won't be visible)
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                },
                child: Icon(Icons.arrow_forward, color: Colors.black),
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
