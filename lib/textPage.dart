import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:ocr/database.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class TextPage extends StatefulWidget {
  final String text;
  bool isUnsaved;
  final Function callback;
  TextPage(this.text, {this.isUnsaved=false, this.callback});
  @override
  _TextPageState createState() => _TextPageState();
}

class _TextPageState extends State<TextPage> {
  FlutterTts flutterTts;
  final TextEditingController docName=TextEditingController(text: DateTime.now().toIso8601String().split('.')[0]);
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
    // docName.selection = TextSelection(baseOffset: 0, extentOffset: docName.value.text.length);
    showDialog(context: context, builder: (context){
    return   Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: 
      Container(
        height: MediaQuery.of(context).size.height*0.2,
        width: MediaQuery.of(context).size.width*0.8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top : 30.0),
              child: Text("Enter Title", style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18
              ),),
            ),
            Container(
        // decoration: BoxDecoration(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: TextField(
            style: TextStyle(
          ),
            controller: docName,
            onTap: () => docName.selection = TextSelection(baseOffset: 0, extentOffset: docName.value.text.length),
          ),
        ),
      ),
      Container(
        width: MediaQuery.of(context).size.width*0.8,
        // color: Colors.red,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
          color: Colors.black
        ),
        child: FlatButton(onPressed: ()async{
          if(docName.text.isNotEmpty){
          Provider.of<DocumentProvider>(context, listen:false).insert(new Document(title: docName.text, text: widget.text));
          Toast.show("Saved Successfully", context);
          setState(() {
            widget.isUnsaved=false;
          });
          // Fluttertoast.showToast(msg: "Saved Successfully");
          Navigator.pop(context);
          }
          else Toast.show("Title cannot be empty", context);
        },
         child: Text("Save", style: TextStyle(
           color: Colors.white
         ),)),
      ),
      //  FlatButton(onPressed: (){
      //    Navigator.pop(context);
      //  }, child: Text("Cancel"))

          ],
        )),
      // content: 
      
     );
    });
  }
  int ttsState=0; //paused =0 playing =1

  @override
  void initState() {
    super.initState();
    flutterTts= new FlutterTts();
  }
Future _speak() async {
    // await flutterTts.setVolume(volume);
    // await flutterTts.setSpeechRate(rate);
    // await flutterTts.setPitch(pitch);

    if (widget.text != null) {
      if (widget.text.isNotEmpty) {
        var result = await flutterTts.speak(widget.text);
        if (result == 1) setState(() => ttsState = 1);
      }
    }
  }

  Future _pause() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = 0);
  }
  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
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
            floatingActionButton: FloatingActionButton(
              tooltip: "Text to Speech",
              backgroundColor: textColor,
              onPressed: (){
                if(ttsState == 0){
                  _speak();
                }
                else _pause();
              },
              child: ttsState == 0 ? 
              Icon(Icons.play_arrow, color: bgColor) 
              :
              Icon(Icons.pause)
            ),
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
              tooltip: "Tap to show/hide Toolbar",
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
