import 'package:flutter/material.dart';
import 'dart:async';
import '../database_helper.dart';
import '../Note.dart';
import 'note_details.dart';
import 'package:sqflite/sqflite.dart';




class NoteList extends StatefulWidget {
  @override
   _NoteListState createState() => _NoteListState();
}
class _NoteListState extends State<NoteList> {
   
//  Defining Variables

   DatabaseHelper databaseHelper =DatabaseHelper();
   List<Note> noteList;
   Note note;
   int count=0;


   @override
   Widget build(BuildContext context) {
    
    //On Opening of an Application, refreshing the content of note_list.dart
    if(noteList==null)
    {
      noteList=List<Note>();
      updateListView(); //Updates the list of notes
    }


    return Scaffold(
      
      appBar: AppBar(
          title:Text('Do it later'),
          backgroundColor: Colors.teal,
        ),
      
      body: getNoteListView(),// UI Design
  
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        child: Icon(Icons.add),
        onPressed: (){
          navigateToDetail(Note('','',2), 'Add Note'); //navigating to note_details.dart with null values
        },
      ),
    );
  }

  // On Pressing Floating action Button or any Note in list it navigates to note_details.dart
  
  void navigateToDetail(Note note,String title) async {
    bool result = await Navigator.push(context, 
      MaterialPageRoute(
        builder: (BuildContext context){
          return NoteDetail(title,note);
        }
      )
    );
    if(result==true)
    {
      updateListView();
    }
  }

  ListView getNoteListView(){
    
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context,position){
        return Dismissible(
                  key: Key(UniqueKey().toString()),
                  onDismissed: (direction) {
                // Remove the item from the data source.
                   setState(() {
                     _delete(this.noteList[position].id);
                  });

                // Then show a snackbar.
                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text("note deleted")));
                  },
                  
                  child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),
            ),
            color: Colors.cyan[100],
            elevation: 4.0,
            child: ListTile(
              title: Text(
                this.noteList[position].title,
                style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 25),
              ),
              subtitle: Text(this.noteList[position].date,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.0,
                ),
              ),
              trailing: GestureDetector(
                child: Icon(Icons.edit,color: Colors.black,size: 30,),
                onTap: (){
                  navigateToDetail(this.noteList[position], 'Edit');// Navigate to note_details with note and title as parameter
                }
              ),
            ),
          ),
        );
      },
    );
  }
  void updateListView(){
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database){
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList){
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length; 
        });
      });
    });
  }
  void _delete(note) async{
    int result = await databaseHelper.deleteNote(note.id);
    if(result!=0){
      _showAlertDialog('Status', 'Note Deleted Successufully !');
    }
    else{
      _showAlertDialog('Status', 'ERROR - Deleting Note!');
    }
  }

    void _showAlertDialog(String title,String message){
    AlertDialog alertDialog= AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context,builder: (_){ 
        return alertDialog;
      }
    );
  }
  
} 