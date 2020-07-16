import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:ocr/database.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class TextPage extends StatefulWidget {
  final String text;
  final bool isUnsaved;
  final Function callback;
  TextPage(this.text, {this.isUnsaved=false, this.callback});
  @override
  _TextPageState createState() => _TextPageState();
}

class _TextPageState extends State<TextPage> {
  final TextEditingController docName=TextEditingController(text: DateTime.now().millisecondsSinceEpoch.toString().split(".")[0]);
  final List<String> modes = ["Light", "Dark", "Dyslexia"];
  final List<String> fonts = ["Comfortaa", 'ComicNeue', 'Open Dyslexic', 'Serif'];
  double letterSpacing=0;
  double fontSize = 15;
  Color bgColor = Colors.white;
  Color textColor = Colors.black;
  String fontFamily = "Serif";
  String mode = "Light";
  bool showTextBar = false;
  getDocName(BuildContext context) async{
    showDialog(context: context, builder: (context){
    return   AlertDialog(
      title: Text("Enter the name"),
      content: TextField(
        controller: docName,
      ),
      actions: <Widget>[
        FlatButton(onPressed: ()async{
          Provider.of<DocumentProvider>(context, listen:false).insert(new Document(title: docName.text, text: widget.text));
          Toast.show("Saved Successfully", context);
          // Fluttertoast.showToast(msg: "Saved Successfully");
          Navigator.pop(context);
        },
         child: Text("Save"))
      ],
     );
    });
  }
  @override
  Widget build(BuildContext context) {
    TextStyle _textStyle = TextStyle(color: textColor, fontFamily: fontFamily);
    return WillPopScope(
      onWillPop: (){
        print("Hello");
        if(widget.callback!=null) widget.callback();
        Navigator.pop(context);
      },
          child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          bottom: PreferredSize(
              preferredSize: showTextBar
                  ? Size(double.infinity, 120)
                  : Size(double.infinity, 0),
              child: showTextBar
                  ? Column(
                    children: <Widget>[
                      Text("Font Size",
                      style: TextStyle(
                      color: textColor,
                      fontFamily: fontFamily,
                    
                    ),
                      ),
                      Row(
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: SliderTheme(
                                data: SliderThemeData(
                                    trackHeight: 10,
                                    valueIndicatorColor: textColor,
                                    valueIndicatorTextStyle:
                                        TextStyle(color: bgColor),
                                    activeTrackColor: textColor,
                                    thumbColor: textColor,
                                    inactiveTrackColor: Colors.redAccent),
                                child: Slider(
                                    value: fontSize,
                                    min: 15,
                                    max: 50,
                                    label: "$fontSize",
                                    divisions: 35,
                                    onChanged: (newValue) {
                                      setState(() {
                                        fontSize = newValue;
                                      });
                                    }),
                              ),
                            ),
                            Text(
                              fontSize.toStringAsPrecision(3),
                              style: _textStyle,
                            ),
                          ],
                        ),
                        //letter spacing 
                    Text("Letter Spacing",
                    style: TextStyle(
                      color: textColor,
                      fontFamily: fontFamily,
                    
                    ),),
                      Row(
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: SliderTheme(
                                data: SliderThemeData(
                                    trackHeight: 10,
                                    valueIndicatorColor: textColor,
                                    valueIndicatorTextStyle:
                                        TextStyle(color: bgColor),
                                    activeTrackColor: textColor,
                                    thumbColor: textColor,
                                    inactiveTrackColor: Colors.redAccent),
                                child: Slider(
                                    value: letterSpacing,
                                    min: 0,
                                    max: 5,
                                    label: "$letterSpacing",
                                    divisions: 10,
                                    onChanged: (newValue) {
                                      setState(() {
                                        letterSpacing = newValue;
                                      });
                                    }),
                              ),
                            ),
                            Text(
                              letterSpacing.toStringAsPrecision(3),
                              style: _textStyle,
                            ),
                          ],
                        ),
                    ],
                  )
                  : Container()),
          automaticallyImplyLeading: false,
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              color: bgColor == Colors.black ? Colors.white : Colors.black,
              onPressed: () {
                if(widget.callback!=null) widget.callback();
                Navigator.pop(context);
              }),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              DropdownButton(
                  dropdownColor: bgColor,
                  value: fontFamily,
                  items: fonts
                      .map((e) => DropdownMenuItem<String>(
                          value: e,
                          child: Text(
                            e,
                            style: TextStyle(
                              fontFamily: e,
                              color: textColor,
                            ),
                          )))
                      .toList(),
                  onChanged: (String font) {
                    setState(() {
                      print(font);
                      fontFamily = font.toString();
                    });
                  }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: DropdownButton(
                    dropdownColor: bgColor,
                    value: mode,
                    items: modes
                        .map((e) => DropdownMenuItem<String>(
                            value: e, child: Text(e, style: _textStyle)))
                        .toList(),
                    onChanged: (String newMode) {
                      if (newMode.compareTo("Light") == 0) {
                        bgColor = Colors.white;
                        textColor = Colors.black;
                      } else if (newMode.compareTo("Dark") == 0) {
                        bgColor = Colors.black;
                        textColor = Colors.white;
                      } else {
                        bgColor = Colors.yellow;
                        textColor = Colors.black;
                      }

                      setState(() {
                        mode = newMode;
                      });
                    }),
              ),
            ],
          ),
          backgroundColor: bgColor,
          titleSpacing: 0,
          
          actions: <Widget>[
            widget.isUnsaved ?
                            IconButton(icon: Icon(Icons.save, color: textColor),
                            tooltip: "Save",
                            onPressed: () async {
                              await getDocName(context);
                              
                            },)
                            :Container(),
            IconButton(
              icon: !showTextBar
                  ? Icon(Icons.expand_more, color: textColor)
                  : Icon(
                      Icons.expand_less,
                      color: textColor,
                    ),
              onPressed: () {
                setState(() {
                  showTextBar = !showTextBar;
                });
              },
            )
          ],
        ),
        backgroundColor: bgColor,
        body: SafeArea(
          child: Container(
            color: bgColor,
            width: double.infinity,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.text,
                  style: TextStyle(
                      color: textColor,
                      fontSize: fontSize,
                      fontFamily: fontFamily,
                      letterSpacing: letterSpacing),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
