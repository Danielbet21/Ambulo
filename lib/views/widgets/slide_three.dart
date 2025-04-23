// import 'package:ambulo/data/styles/conatant.dart';
// import 'package:flutter/material.dart';

// class SlideThree extends StatelessWidget {
//   const SlideThree({Key? key}) : super(key: key);

//   @override
//    Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         // Main content
//         Container(
//           padding: EdgeInsets.all(32),
//           // add a background image
//           decoration: const BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage('assets/background/mountain_rige_fog.jpg'),
//               fit: BoxFit.cover, // Adjust how the image fills the screen
//             ),
//           ),
//         ),
        
//         // Rectangle at bottom between buttons
//         Positioned(
//           bottom: 50,
//           left: 20,
//           right: 20,
//           child: Container(
//             // Dynamic height based on screen size
//             height: MediaQuery.of(context).size.height * 0.2,// 15% of screen height
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.7), // More reliable opacity
//               borderRadius: BorderRadius.circular(30),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 'Demograph Alerts',
//                  textAlign: TextAlign.center,
//                 style: TextStyle(
//                     // fontSize: 24,
//                     fontSize: MediaQuery.of(context).size.width * 0.06,
//                     fontFamily: 'arial',
//                     fontWeight: FontWeight.bold,),
                
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'base_slide.dart';

class SlideThree extends BaseSlide {
  const SlideThree({Key? key,
    required double sizeOfFont
    }) : super(key: key, sizeOfFont: sizeOfFont);

  @override
  State<SlideThree> createState() => _SlideThreeState();
}

class _SlideThreeState extends BaseSlideState<SlideThree> {
  @override
  AssetImage getBackgroundImage() {
    return const AssetImage('assets/background/demograph_notification.png');
  }

  @override
  Widget buildContent(BuildContext context) {
  return  Stack(
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
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Get real-time alerts about protests or disruptions to health centers or transit and more - right when it matters.',
                 textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: widget.sizeOfFont,
                    fontFamily: 'arial',
                    color: Colors.black,
                    ),
                
              ),
            ),
          ),
        ),
      ],
    );
  }
}