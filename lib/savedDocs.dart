import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:ocr/database.dart';
import 'package:ocr/main.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import 'textPage.dart';

class SavedDocuments extends StatefulWidget {
  @override
  _SavedDocumentsState createState() => _SavedDocumentsState();
}

class _SavedDocumentsState extends State<SavedDocuments> {
  // ScrollController _scrollController = ScrollController();
  // bool isLoading=false;
  bool isEdit=false;
  int selectedId;
  // int page=1;
  @override
  void initState(){
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) { getDocs();});
  }
  // _scrollListener(){      if (_scrollController.position.maxScrollExtent == _scrollController.offset) {
  //       // isLoading=!isLoading;
  //       if (!isLoading) {
  //         page++;
  //         print("isLoading");
  //         // isLoading = !isLoading;
  //         getDocs(page);
          
  //         // Perform event when user reach at the end of list (e.g. do Api call)
  //       }
  //     }
  // }
List<Document> docs=[];
getDocs()async {
  var d=await Provider.of<DocumentProvider>(context, listen: false).getAllDocs();
  if(mounted)
  setState(() {
    docs=d;
  });
}
// toggleEdit(){
// setState(() {
//   isEdit=!isEdit;
// });
// }
// setCurrent(int id){
//   this.selectedId=id;
// }

deleteDoc(int id){
 setState(() {
//  isEdit=false;
 docs.removeWhere((element) => element.id==id);  
 });
 Provider.of<DocumentProvider>(context, listen: false).delete(id);
 
Toast.show("Successfully Deleted", context);
//  getDocs();
}

@override
void dispose() {

  // _scrollController.removeListener(_scrollListener);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {    
    return SafeArea(
          child: Scaffold(
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (contex)=>MyHomePage(getDocs)));
            },
            child: Icon(Icons.add, color: Colors.black,)),
            // extendBodyBehindAppBar: true,
            backgroundColor: Colors.black,
            appBar: AppBar(
              // actions: <Widget>[
              //     isEdit ?
              //     IconButton(icon: Icon(Icons.delete), onPressed: (){
              //           deleteDoc(this.selectedId);
              //     })
              //     : Container()
              // ],
              title: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 50),
                  child: Text("App Name"),
                ),
              ),
              backgroundColor: Colors.transparent,
            ),
                      body: Container(
                           child:  ListView.builder(
                            //  controller: _scrollController,
                              itemCount: docs.length,
                              itemBuilder: (context, i){
                                if(docs.length > 0)
                              return DocTile(docs[i], deleteCallback: deleteDoc);
                              else return Center(child: Text("No Documents", style: TextStyle(color: Colors.white),),);
                            }
                            )
                      )
          )
    );
                          }
}

class DocTile extends StatefulWidget {
  final Document doc;
  final Function deleteCallback;
  // final Function toggleEditCallback;
  // final Function setCurrentIdCallback;
  DocTile(this.doc, {this.deleteCallback} 
  // {this.toggleEditCallback, this.setCurrentIdCallback}
  );

  @override
  _DocTileState createState() => _DocTileState();
}

class _DocTileState extends State<DocTile> {
  bool selected=false;
  TextEditingController title= new TextEditingController(); 
showEditName(BuildContext context){
  title.text=widget.doc.title;
  showDialog(context: context, builder: (context){
    return AlertDialog(
      title: Text("Enter the name"),
      content: TextField(
        controller: title,
      ),
      actions: <Widget>[
        FlatButton(onPressed: ()async{
          setState(() {
          widget.doc.title=title.text;
          selected=false;  
          });
          
          Provider.of<DocumentProvider>(context, listen:false).update(widget.doc);
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
    return
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
      child: GestureDetector(
              onHorizontalDragUpdate: (details){
                // if(details.localPosition== Offset.fromDirection(3.14))
                if(details.delta.dx < 0)
                setState(() {
                  selected=true;
                });
                else if(details.delta.dx > 0) {
                  setState(() {
                    selected=false;
                  });
                }
              },
              child: Container(
                // margin: EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: selected==true ? Colors.grey : Colors.white,
                
              ),
              
              child: Row(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft:Radius.circular(20) ),
                color: Colors.white,
              ),
                    width: selected ?  
                    MediaQuery.of(context).size.width*0.65
                    :MediaQuery.of(context).size.width*0.9,
                    child: ListTile(
            subtitle: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.doc.text,
                      maxLines: 3,
                      style: TextStyle(
                        
                      ),
                    ),
            ),
            title: Text(widget.doc.title,
            style: TextStyle(
                    color: Colors.black
            ),),
            // trailing: ,
            onTap:(){ 
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>TextPage(widget.doc.text)));
            }
          ),
                  ),
            selected ?
           Container(
                  width: MediaQuery.of(context).size.width*0.25,
                  color: Colors.grey,
                  child: 
                  Row(
                    children: <Widget>[
                      IconButton(icon: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Icon(Icons.edit),
                      ), onPressed: (){
                        print("Edited");
                        showEditName(context);
                      },),
                      IconButton(icon: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Icon(Icons.delete),
                      ), onPressed: (){
                        print("Deleted");
                          this.widget.deleteCallback(widget.doc.id);
                      },),
                    ],
                  )
                  
                )
                : Container(),
                ],
              ),
        ),
      ),
    );
  }
}