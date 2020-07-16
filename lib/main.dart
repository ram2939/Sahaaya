import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ocr/database.dart';
import 'package:ocr/savedDocs.dart';
import 'package:ocr/textPage.dart';
import 'package:provider/provider.dart';
void main() {
   WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final DocumentProvider database=new DocumentProvider();
  // This widget is the root of your application. 
  initializeDatabase()async{
     await database.open();
  }
  @override
  Widget build(BuildContext context) {
    initializeDatabase();
    return Provider<DocumentProvider>(create: (context){
      // initializeDatabase();
      return database;},
      child: 
     MaterialApp(
      title: 'Ocr',
      theme: ThemeData(
                primarySwatch: Colors.blue,
        
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SavedDocuments()
      // PageView(
      //   children: <Widget>[
          
      //     MyHomePage(),
      //   ],
      // ),
      )
    );
  }
}

class MyHomePage extends StatefulWidget {
 final Function callback;
 MyHomePage(this.callback);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;
  final TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
  final ImagePicker _imagePicker = ImagePicker();
  Future getImageFromCamera() async {
    final pickedFile = await _imagePicker.getImage(source: ImageSource.camera);
    try{
    await cropImage(pickedFile);
    }
    catch (e){
      print(e.toString());
    }
  }

  Future getImageFromGallery() async {
    final pickedFile = await _imagePicker.getImage(source: ImageSource.gallery);
    try{
    await cropImage(pickedFile);
    }
    catch (e){
      print(e.toString());
    }
  }

  Future cropImage(PickedFile pickedFile) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: pickedFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
    setState(() {
      _image = File(croppedFile.path);
    });
    Navigator.pop(context);
  }

  getImage(BuildContext context){
    showModalBottomSheet(context: context, builder: (ctx)
    {
      return Container(
        height: MediaQuery.of(context).size.height*0.2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Text("Pick an Option", style: TextStyle(
                fontSize: 20
              ),),
              Padding(
                padding: const EdgeInsets.only(top:20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(icon: Icon(Icons.photo_camera, size: 40,), onPressed: getImageFromCamera),
                        Text("  Camera")
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(icon: Icon(Icons.image, size: 40,), onPressed: getImageFromGallery),
                        Text("  Gallery")
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: (){
          widget.callback();
          // Provider.of<Function>(context, listen: false).call();
          Navigator.of(context).pop();
        },
          child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              // FlatButton(child: Text("Get Image"),  onPressed: ()=> getImage(context)
                
              // ),
              GestureDetector(
                onTap: ()=>getImage(context),
                  child: Container(
                    // color: Colors.red,
                    height: MediaQuery.of(context).size.height*0.86,
                    width: double.infinity,
                 child:  _image!=null?
                  SingleChildScrollView(child: Image.file(_image, fit: BoxFit.fill,))
                  :Container(
                    color: Colors.black,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.photo_camera, size: 50, color: Colors.white),
                          Text("Tap to select the picture", style: TextStyle(color: Colors.white),),
                        ],
                      )
                    ),
                  ),
                ),
              ),
                GestureDetector(
                  child: Container(
                    height: MediaQuery.of(context).size.height*0.1,
                    // margin: EdgeInsets.symmetric( vertical: 15,
                      // horizontal: 20),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      // borderRadius: BorderRadius.circular(30),
                      color: _image!=null ? Colors.blueAccent : Colors.grey 
                    ),
                    child: Center(child: Text("READ", 
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      // fontFamily: "Raleway"
                    ),
                    ))),
                  onTap: () async {               
                    if(_image!=null){
                    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(_image);
                    final VisionText visionText = await textRecognizer.processImage(visionImage);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>TextPage(visionText.text,isUnsaved: true,callback: widget.callback)));
                    }
                  },
                ),
               
              
            ],
          ),
        ),
        
      ),
    );
  }
  showBlockingDialog(BuildContext context){
    showDialog(
      context: context,
      builder: (BuildContext ctx){
        return Center(
          child: Container(
            child: CircularProgressIndicator(),
          ),
        );
      }
    );
  }
}