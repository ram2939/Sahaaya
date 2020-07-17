import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;
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
      title: 'Sahaaya',
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
  final List<Map<String, String>> lang=[
    {'language': 'Assamese', 'lan': 'asm'},
    {'language': 'Bangla', 'lan': 'ben'},
    {'language': 'English', 'lan': 'eng'},
    {'language': 'Gujrati', 'lan': 'guj'},
    {'language': 'Hindi', 'lan': 'hin'},
    {'language': 'Kannada', 'lan': 'kan'},
    {'language': 'Punjabi', 'lan': 'pan'},
    {'language': 'Malyalam', 'lan': 'mal'},
    {'language': 'Marathi', 'lan': 'mar'},
    {'language': 'Tamil', 'lan': 'tam'},
    {'language': 'Telugu', 'lan': 'tel'},
    {'language': 'Urdu', 'lan': 'urd'},
    ];
  String selectedLanguage="eng";
  final TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
  final ImagePicker _imagePicker = ImagePicker();
  Widget langDropDown(){
    return Card(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButton(
          dropdownColor: Colors.black,
          style: TextStyle(
            color: Colors.white
          ),
          value: selectedLanguage,
          items: lang.map((e) => DropdownMenuItem(child: Text(e['language'])
        ,value: e['lan'],)).toList(), onChanged: (String value){
            print(value);
            setState(() {
              selectedLanguage=value;
            });
        }),
      ),
    );
  }
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
  Future<String> getTextFromTesseract() async {
    showBlockingDialog(context);
    var url= "https://ocrtesseractserver.herokuapp.com/";
    
  String base64Image = base64Encode(_image.readAsBytesSync());
  //  String fileName = file.path.split("/").last;

   try{
   var result = await http.post(url, body: {
     "image": base64Image,
     "lang": selectedLanguage
   }).timeout(Duration(seconds: 30), onTimeout: ()=>null);
    Navigator.pop(context);
    return result.body;
   }
   catch(e){
     print(e);
     return "Error";
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
            toolbarColor: Colors.black,
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

  showNetworkError(BuildContext context){
    showDialog(context: context, builder: (context){
      return Dialog(
        backgroundColor:Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          
          height: MediaQuery.of(context).size.height*0.15,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 5),
                child: Text("Internet Connection not found", style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white
                ),),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text("Please connect to internet to continue with languages other than English", style: TextStyle(
                  fontSize: 15, color: Colors.white
                ),),
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
              // langDropDown(),
              // FlatButton(child: Text("Get Image"),  onPressed: ()=> getImage(context)
                
              // ),
              GestureDetector(
                onTap: ()=>getImage(context),
                  child: Container(
                    // color: Colors.red,
                    height: MediaQuery.of(context).size.height*0.86,
                    width: double.infinity,
                 child:  _image!=null?
                  SingleChildScrollView(child: Stack(
                    children: <Widget>[
                      Image.file(_image, fit: BoxFit.fill,),
                      Align(alignment: Alignment.topRight, child: langDropDown(),),
                    ],
                  ))
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
                      if(selectedLanguage.compareTo("eng")==0){
                    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(_image);
                    final VisionText visionText = await textRecognizer.processImage(visionImage);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>TextPage(visionText.text,isUnsaved: true,callback: widget.callback)));
                    }
                    else{
                      var connectivity= await Connectivity().checkConnectivity();

                      if(connectivity == ConnectivityResult.none) showNetworkError(context);
                      else {
                        String text=await getTextFromTesseract();
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>TextPage(text,isUnsaved: true,callback: widget.callback)));
                      }
                    }
                    // else 
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