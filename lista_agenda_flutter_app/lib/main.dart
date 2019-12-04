import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final _toDoController = TextEditingController();

  List _toDoList = [];
  Map<String, dynamic>_lastRemoved;
  int _lastRemovedPos;


  @override
  void initState() {
    super.initState();
    _readData().then((data){
      setState(() {

        _toDoList = jsonDecode(data);
      });
      });
  }

  void _addToDo(){
   setState(() {
     Map<String, dynamic> newToDo = Map();
     newToDo["title"] = _toDoController.text;
     _toDoController.text = "";
     newToDo["ok"] = false;
     _toDoList.add(newToDo);
     _saveData();
   });
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));//isso é para a ação demorar 1 segundo para acontecer

    setState(() {
      _toDoList.sort((a, b){ //ordena a lista usando as funções do Dart faz a comparação entre a e b (procurando saber quem é o maior)
        if(a["ok"] && !b["ok"]){
          return 1;
        }else if(!a["ok"] && b["ok"])return -1;
        else return 0;
      });
      _saveData();
    });

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
               Expanded(
                 child:  TextField(
                   controller: _toDoController,
                   decoration: InputDecoration(
                       labelText: "Nova Tarefa",
                       labelStyle: TextStyle(color: Colors.blueAccent)
                   ),
                 ),
               ),
                RaisedButton(
                  color: Colors.blueAccent,
                  child: Text("ADD"),
                  textColor: Colors.white,
                  onPressed: _addToDo,
                )
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator( onRefresh: _refresh,
                child: ListView.builder(
                    padding: EdgeInsets.only(top: 10.0),
                    itemCount: _toDoList.length,
                    itemBuilder: buildItem)),
          )
        ],
      ),
    );
  }

  Widget buildItem (context, index){
    return Dismissible(key: Key(DateTime.now().millisecondsSinceEpoch.toString()),  //essa key indica qual elemento está sendo deslizado
      background: Container(

        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),//o valor x corresponde a 90% a direita
          child: Icon(Icons.delete_outline, color: Colors.white,),
        ),
      ),
      direction: DismissDirection.startToEnd ,//dá a direção do dismissble da esquerda para a direita
      child: CheckboxListTile(
        title: Text(_toDoList[index]["title"]),
        value: (_toDoList[index]["ok"]),
        secondary: CircleAvatar(
          child: Icon(_toDoList[index]["ok"] ?
          Icons.check: Icons.error ),),
        onChanged: (c){
          setState(() {
            _toDoList[index]["ok"] = c;
            _saveData();
          });
        },
      ),

      onDismissed: (direction){
      setState(() {
        _lastRemoved = Map.from(_toDoList[index]);  // duplica o item a ser removido, e fica de backup caso queira restaura-lo
        _lastRemovedPos = index; //salva a posição que quer remover
        _toDoList.removeAt(index);//remove da lista
        _saveData();

        final snack = SnackBar(
          content: Text("Tarefa \"${_lastRemoved["title"] }\"removida!"),
          action: SnackBarAction(label: "Desfazer",
            onPressed: (){
            setState(() { //atualiza a tela
              _toDoList.insert(_lastRemovedPos, _lastRemoved);//depois de pressionado o botão insere novamente o elemento que seria eliminado na lista
              _saveData();
            });

            }),
          duration: Duration(seconds: 5),
        );
        Scaffold.of(context).removeCurrentSnackBar();//para quando atualiza mostrar sem sobrepor
        Scaffold.of(context).showSnackBar(snack);//para mostrar o snakBar

      });

      },

    );
  }







  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData( )async{
    try{

      final file = await _getFile();

      return file.readAsString();

    }catch(e){

      return null;
    }
  }

}