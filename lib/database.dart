
import 'package:sqflite/sqflite.dart';
final String databaseName= 'ocrDocs.db';
final String tableTodo = 'todo';
final String columnId = '_id';
final String columnTitle = 'title';
final String columnText = 'text';

class Document {
  int id;
  String title;
  String text;
  Document({this.id, this.title, this.text});
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnTitle: title,
      columnText: text,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  // Todo();

  static Document fromMap(Map<String, dynamic> map) {
    
    return  Document(id:map[columnId], title: map[columnTitle], text: map[columnText]);
  }
}


class DocumentProvider {
  Database db;
  DocumentProvider(){
    open();
  }
  Future open() async {
    String path= await getDatabasesPath();
    path=path + "/"+databaseName;
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table $tableTodo ( 
  $columnId integer primary key autoincrement, 
  $columnTitle text not null,
  $columnText text not null)
''');
    });
  }

  Future<Document> insert(Document todo) async {
    todo.id = await db.insert(tableTodo, todo.toMap());
    return todo;
  }
  Future<List<Document>> getAllDocs()async{
    if(db==null) await open();
    print("db: "+db.isOpen.toString());
    List<Map<String, dynamic>> records = await db.query(tableTodo
    // , limit: 5, offset: (page-1)*10
    );
    List<Document> docs=[];
    for( var i in records){
        docs.add(Document.fromMap(i));
    }
    return docs;
  }
  Future<Document> getTodo(int id) async {
    List<Map> maps = await db.query(tableTodo,
        columns: [columnId, columnText, columnTitle],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return Document.fromMap(maps.first);
    }
    return null;
  }

  Future<int> delete(int id) async {
    return await db.delete(tableTodo, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> update(Document todo) async {
    return await db.update(tableTodo, todo.toMap(),
        where: '$columnId = ?', whereArgs: [todo.id]);
  }

  Future close() async => db.close();
}