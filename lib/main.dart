import 'package:database1/view.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(MaterialApp(
    home: First(),
    debugShowCheckedModeBanner: false,
  ));
}

class Student {
  int? id;
  String? name;
  String? contact;
  String? password;

  Student({this.id, this.name, this.contact, this.password});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'password': password,
    };
  }
}

class First extends StatefulWidget {
  final Map? data;

  First([this.data]);

  @override
  State<First> createState() => _FirstState();
}

class _FirstState extends State<First> {
  late TextEditingController t1, t2, t3;
  late Database database;

  @override
  void initState() {
    super.initState();
    t1 = TextEditingController();
    t2 = TextEditingController();
    t3 = TextEditingController();
    initDatabase();
    if (widget.data != null) {
      t1.text = widget.data!['name'];
      t2.text = widget.data!['contact'];
      t3.text = widget.data!['password'];
    }
  }

  Future<void> initDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'demo.db');

    database = await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE student (id INTEGER PRIMARY KEY, name TEXT, contact TEXT, password TEXT)');
  }

  Future<void> insertOrUpdateStudent() async {
    String name = t1.text;
    String contact = t2.text;
    String password = t3.text;

    Student student = Student(name: name, contact: contact, password: password);

    if (widget.data != null) {
      student.id = widget.data!['id'];
    }

    try {
      await database.insert('student', student.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      print("Record inserted/updated successfully!");
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          _buildTextField("enter name", t1),
          _buildTextField("enter contact", t2),
          _buildTextField("enter password", t3),
          ElevatedButton(
            onPressed: insertOrUpdateStudent,
            child: Text("Submit"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return view();
              },));
              // View button pressed
            },
            child: Text("View"),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(),
      ),
    );
  }
}