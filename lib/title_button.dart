import 'package:flutter/material.dart';

typedef TitelClick = dynamic Function();

class TitleButton extends StatefulWidget {
  const TitleButton(
      {Key? key,
      required this.iconData,
      required this.label,
      required this.bgcolor,
      required this.titelClick})
      : super(key: key);
  final IconData iconData;
  final String label;
  final Color bgcolor;
  final TitelClick? titelClick;
  @override
  State<TitleButton> createState() => _TitleButton();
}

class _TitleButton extends State<TitleButton> {
  bool focuseState = false;
  Widget showIconOrText() {
    Widget childs;
    if (focuseState) {
      childs = Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(widget.iconData),
          Text(
            widget.label,
            style: TextStyle(fontSize: MediaQuery.of(context).size.width / 55),
          )
        ],
      );
    } else {
      childs = Icon(widget.iconData);
    }
    return childs;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: focuseState
          ? MediaQuery.of(context).size.width * 0.12
          : MediaQuery.of(context).size.width * 0.05,
      child: InkWell(
        autofocus: false,
        onFocusChange: (value) {
          setState(() {
            focuseState = value;
          });
        },
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        onTap: widget.titelClick,
        //focusColor: Colors.transparent,
        child: Container(
          width: focuseState
              ? MediaQuery.of(context).size.width * 0.15
              : MediaQuery.of(context).size.width * 0.03,
          //height: MediaQuery.of(context).size.height * 0.08,
          decoration: BoxDecoration(
              color: focuseState ? Colors.lightBlue : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: focuseState ? Colors.lightBlue : Colors.transparent)),
          child: showIconOrText(),
        ),
      ),
    );
  }
}
