import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  static List<String> todo = [];
  static List<String> date = [];
  late Timer timer;
  DateTime now = DateTime.now();
  @override
  void initState() {
    super.initState();
    getList();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        now = DateTime.now();
      });
    });
  }

  static Future getList() async {
    final prefs = await SharedPreferences.getInstance();
    todo = prefs.getStringList("ToDoList") ?? [];
    date = prefs.getStringList("DateTime") ?? [];
    return prefs.getStringList("ToDoList") ?? [];
  }

  static Future setList() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList("DateTime", date);
    return prefs.setStringList("ToDoList", todo);
  }

  Widget updateList() {
    return ListView.builder(
        itemCount: todo.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(todo[index]),
              subtitle: Text(date[index]),
              trailing: IconButton(
                  onPressed: () {
                    todo.removeAt(index);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                        'To Do Removed',
                        style: TextStyle(color: Colors.red),
                      ),
                      duration: Duration(milliseconds: 2000),
                    ));
                    setState(() {
                      setList();
                      getList();
                    });
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  )),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      getList();
    });
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(
          Icons.done,
          color: Colors.white,
        ),

        backgroundColor: Theme.of(context)
            .colorScheme
            .primary, // Here we take the value from the MyHomePage object that was created by
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        child: RefreshIndicator(child: updateList(), onRefresh: refresh),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _pushAddTodoScreen();
        },
        tooltip: 'Increment',
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }

  void _pushAddTodoScreen() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: const Text('New Task')),
            body: Column(
              children: [
                TextField(
                  autofocus: true,
                  onSubmitted: (String val) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('New To Do Added'),
                      duration: Duration(milliseconds: 2000),
                    ));
                    if (val != "") {
                      todo.add(val);
                      date.add(now.toString());
                      setState(() {
                        setList();
                      });
                      setState(() {
                        getList();
                      });
                    }
                    Navigator.pop(context);
                  },
                  decoration: const InputDecoration(
                      hintText: 'Enter your task here',
                      contentPadding: EdgeInsets.all(16.0)),
                ),
              ],
            ));
      },
    ));
  }

  Future<void> refresh() {
    setState(() {
      getList();
      updateList();
    });
    ();
    return Future.delayed(Duration(seconds: 4));
  }
}
