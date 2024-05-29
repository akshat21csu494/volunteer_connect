import 'package:flutter/material.dart';

class Accordion extends StatefulWidget {

  final Text title;
  final List<Widget> subTitles;
  double borderRadius;
  double contentPadding;
  Color borderColor;
  Color titleBackgroundColor;
  Color subtitleBackgroundColor;

  Accordion({
    super.key,
    required this.title,
    required this.subTitles,
    this.borderRadius = 12.0,
    this.contentPadding = 12.0,
    this.borderColor = Colors.transparent,
    this.titleBackgroundColor = const Color(0xfff1f1f1),
    this.subtitleBackgroundColor =  Colors.transparent,
  });


  @override
  State<Accordion> createState() => _AccordionState();
}

class _AccordionState extends State<Accordion> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: widget.borderColor),
        borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () {
              setState(()=> isExpanded = !isExpanded );
            },
            child: Container(
              decoration: BoxDecoration(
                color: widget.titleBackgroundColor,
                borderRadius: isExpanded
                    ? BorderRadius.only(
                        topLeft: Radius.circular(widget.borderRadius),
                        topRight: Radius.circular(widget.borderRadius),
                      )
                    : BorderRadius.all(
                        Radius.circular(widget.borderRadius),
                      ),
              ),
              padding: EdgeInsets.all(widget.contentPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  widget.title,
                  Icon(isExpanded
                      ? Icons.keyboard_arrow_up_sharp
                      : Icons.keyboard_arrow_down_sharp
                  ),
                ],
              ),
            ),
          ),
          if(isExpanded)
            Container(
              decoration: BoxDecoration(
                color: widget.subtitleBackgroundColor,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(widget.borderRadius),
                  bottomLeft: Radius.circular(widget.borderRadius),
                ),
              ),
              padding: EdgeInsets.all(widget.contentPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.subTitles,
              ),
            ),
        ],
      ),
    );
  }
}
