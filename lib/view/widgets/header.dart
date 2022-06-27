import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({
    Key? key,
    required this.isActive,
    required this.onpress,
  }) : super(key: key);

  final bool isActive;

  final VoidCallback onpress;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const Spacer(flex: 1),
        const Expanded(
          flex: 5,
          child: Center(
            child: Text(
              "Comments",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
              onTap: onpress,
              child: Image.asset(
                isActive
                    ? "assets/images/editicon.png"
                    : "assets/images/editblack.png",
                height: 25,
              )),
        ),
      ],
    );
  }
}
