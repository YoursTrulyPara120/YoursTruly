import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';



class SelectableCard extends StatefulWidget {
  final List options;
  final List optionImg;
  var height;
  var leftRightPadding;
  var gridCount;
  var textSize;
  final Function(String) onSelected;
  final selectedCard;

  SelectableCard({this.options,this.optionImg, this.onSelected, this.height, this.gridCount, this.textSize, this.leftRightPadding,  this.selectedCard});

  @override
  _SelectableCardState createState() => _SelectableCardState();
}

class _SelectableCardState extends State<SelectableCard> {
  int _selected;

  @override
  void initState() {
    super.initState();
    selectedCard();
  }

  void selectedCard(){
    setState(() {
      _selected = widget.selectedCard ;
    });
  }

  @override
  Widget build(BuildContext context) {

    return GridView.builder(
      itemCount: widget.options.length,
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),

      padding: EdgeInsets.only(bottom: 30, right: widget.leftRightPadding == null ? 18 : widget.leftRightPadding,left: widget.leftRightPadding == null ? 10 : widget.leftRightPadding, top: 3),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.gridCount == null ? 2 : widget.gridCount,
          childAspectRatio: widget.height,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            widget.onSelected("${widget.options[index]}");
            setState(() {
              _selected = index ;
            });
          },
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: 16,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _selected == index ? ([const Color(0xff9083e8), Color(0xff9083e8)]) : ([Colors.white, Colors.white]),
                  begin: FractionalOffset.centerLeft,
                  end: FractionalOffset.centerRight,
                ),
              ),
              alignment: Alignment.center,
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [ widget.optionImg == null ? SvgPicture.asset("") :
                    SvgPicture.asset(widget.optionImg[index],
                      height: 30,
                      width: 30,
                      fit: BoxFit.cover,
                      color: _selected == index ? Colors.white : Colors.black,
                    ),
                    Text(
                      "${widget.options[index]}",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _selected == index ? Colors.white : Colors.black,
                        fontSize: widget.textSize == null ?  16.0 : widget.textSize,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}

