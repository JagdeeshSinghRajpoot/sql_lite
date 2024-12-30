import 'package:flutter/material.dart';
import 'package:sql_lite/data/local/db_helper.dart';

class NewHomePage extends StatefulWidget{
  const NewHomePage({super.key});

  @override
  State<NewHomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<NewHomePage>{
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  List<Map<String, dynamic>> allNotes = [];
  DBHelper? dbRef;

  @override
  void initState() {
    super.initState();
    dbRef = DBHelper.getInstance;
    getNotes();
  }

  void getNotes() async{
    allNotes = await dbRef!.getAllNotes();
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      body: allNotes.isNotEmpty ? ListView.builder(
        itemCount: allNotes.length,
        itemBuilder: (_,index){
          return ListTile(
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text('${index+1}',style: const TextStyle(fontSize: 18),),
            ),
            title: Text(allNotes[index][DBHelper.COLUMN_NOTE_TITLE],style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
            subtitle: Text(allNotes[index][DBHelper.COLUMN_NOTE_DESC],maxLines: 2, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black12),),
            trailing: SizedBox(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: (){
                        titleController.text = allNotes[index][DBHelper.COLUMN_NOTE_TITLE];
                        descController.text = allNotes[index][DBHelper.COLUMN_NOTE_DESC];
                        showModalBottomSheet(context: context, builder: (context){
                          return getBottomSheetWidget(isUpdate: true, sno: allNotes[index][DBHelper.COLUMN_NOTE_SNO]);
                        });

                      },
                      icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                      onPressed: () async{
                        bool check = await dbRef!.deleteNote(sno: allNotes[index][DBHelper.COLUMN_NOTE_SNO]);
                        if(check){
                          getNotes();
                        }
                      },
                      icon: const Icon(Icons.delete,color: Colors.redAccent,)
                  ),
                ],
              ),
            ),
          );
        }) : const Center(
          child: Text('No Notes vet!!'),
        ),


        floatingActionButton: FloatingActionButton(onPressed: ()async{
          //note to be added from here
          titleController.clear();
          descController.clear();
          showModalBottomSheet(context: context, builder: (context){
            return getBottomSheetWidget();
          });
        },
        child: const Icon(Icons.add)),
    );
  }

  Widget getBottomSheetWidget({bool isUpdate = false, int sno = 0}){
    return Container(
      padding: const EdgeInsets.all(15),
      width: double.infinity,
      child: Column(
        children: [
          Text(isUpdate ? 'Update Note' : 'Add Note', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
          const SizedBox(height: 21,),

          TextField(
            controller: titleController,
            decoration: InputDecoration(
                label: const Text("Title *"),
                hintText: "Enter your title here",
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                )
            ),),
          const SizedBox(height: 21,),

          TextField(
            controller: descController,
            maxLines: 4,
            decoration: InputDecoration(
                label: const Text("description *"),
                hintText: "Enter your description here",
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11)
                )
            ),),

          const SizedBox(height: 21,),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                    style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                        side: const BorderSide(
                            width: 4,
                            color: Colors.black
                        )
                    )),
                    onPressed: ()async{
                      var title = titleController.text;
                      var desc = descController.text;

                      if(title.isNotEmpty && desc.isNotEmpty){
                        bool check = isUpdate ? await dbRef!.updateNote(mtitle: title, mdesc: desc, sno: sno) : await dbRef!.addNote(mTitle: title, mDesc: desc);
                        if(check){
                          getNotes();
                        }

                      }else{
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all the required blanks!!")));
                      }

                      Navigator.pop(context);
                    }, child: Text(isUpdate ? 'Update' : "Add Note")),
              ),

              const SizedBox(width: 20,),
              Expanded(child: OutlinedButton(
                  style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                      side: const BorderSide(
                          width: 4,
                          color: Colors.black
                      )
                  )),
                  onPressed: (){
                    Navigator.pop(context);
                  }, child: const Text("Cancel"))),

            ],
          ),

        ],
      ),
    );
  }
  
}
