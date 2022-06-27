import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({
    Key? key,
    required ValueNotifier<bool> isActive,
  })  : _isActive = isActive,
        super(key: key);

  final ValueNotifier<bool> _isActive;

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
          child: ValueListenableBuilder(
            valueListenable: _isActive,
            builder: (context, value, child) {
              return GestureDetector(
                  onTap: () {
                    _isActive.value = !_isActive.value;
                  },
                  child: _isActive.value
                      ? Image.asset(
                          "assets/images/editicon.png",
                          height: 25,
                        )
                      : Image.asset(
                          "assets/images/editblack.png",
                          height: 25,
                        ));
            },
          ),
        )
      ],
    );
  }
}
