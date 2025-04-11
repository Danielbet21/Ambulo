import 'package:ambulo/data/styles/constant.dart';
import 'package:flutter/material.dart';

class ProfileCategory extends StatelessWidget {
  final String nameOfCategory;

  const ProfileCategory({
    super.key,
    required this.nameOfCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            side: const BorderSide(
              color: Color.fromARGB(255, 214, 211, 211),
              width: 1,
            ),
          ),
          onPressed: () {
            // Handle button press
            Navigator.pushNamed(context, '/$nameOfCategory');
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            width: 400,
            child: Row(
              // make the items be in as far as possible
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(nameOfCategory, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 111, 111, 111))),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
         AppConstants.kSizedBoxMedium,
      ],
    );
  }
}
