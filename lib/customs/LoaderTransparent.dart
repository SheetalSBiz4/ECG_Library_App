import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoaderTransparent extends StatelessWidget {
  double height;
  double width;
  Color colorValue;
  double size;

  LoaderTransparent(this.size, {this.colorValue});

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Container(
        height: height,
        width: width,
        color: Colors.transparent,
        child: Center(
            child: SizedBox(
                height: size * 0.13,
                width: size * 0.13,
                child: Image.asset(
                  'assets/images/loader_red.gif',
                  fit: BoxFit.fill,
                ) // use you custom loader or default loader
                // CircularProgressIndicator(
                //     valueColor: AlwaysStoppedAnimation(Colors.blue),
                //     strokeWidth: 5.0)
                )));
  }
}
