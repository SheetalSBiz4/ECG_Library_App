import 'package:ecg/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class CustomBlackButton extends StatelessWidget {
  final Function press;
  final String label;
  final EdgeInsets margin;
  final double widthSize;
  final double heightSize;

  const CustomBlackButton(
      {Key key,
      this.press,
      this.label,
      this.margin,
      this.widthSize,
      this.heightSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: new EdgeInsets.only(bottom: 18),
      width: widthSize,
      child: Container(
        width: widthSize,
        height: heightSize,
        margin: margin,
        child: FlatButton(
          child: Text(label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: widthSize * 0.12,
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.w700)),
          // textColor: Colors.black,
          padding: EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
            side: BorderSide(
              width: 1,
              color: HexColor('#ff1d1e20'),
            ),
          ),
          onPressed: press,
          color: primaryColor,
          // splashColor: Colors.white70,
            highlightColor: Colors.white30
        ),
      ),
    );
  }
}
