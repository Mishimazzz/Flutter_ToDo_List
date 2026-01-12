
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


void main()
{
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "ToDo List Demo",
      theme: ThemeData(useMaterial3:true),
      home: const TodoPage(),
    );
  }
}

class Todo {
  final String id;
  final String title;
  bool finish;

  Todo({required this.id, required this.title, this.finish = false});

  factory Todo.fromJson(Map<String, dynamic> j) {
    return Todo(
      id: j["id"],
      title: j["title"],
      finish: j["finish"] ?? false,
    );
  }
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final String baseUrl = "http://10.0.2.2:3000"; // Android 模拟器访问电脑
  List<Todo> todos = [];

  @override
  void initState() {
    super.initState();
    fetchTodos();
  }

  Future<void> fetchTodos() async {
    final r = await http.get(Uri.parse("$baseUrl/todos"));
    final list = jsonDecode(r.body) as List;
    setState(() {
      todos = list.map((e) => Todo.fromJson(e)).toList();
    });
  }

  Future<void> addTodo(String title) async {
    await http.post(
      Uri.parse("$baseUrl/todos"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"title": title}),
    );
    await fetchTodos();
  }

  //如果用户完成了todo，需要更新UI（fetchTodos）， 然后put给后端
  Future<void> updateTodo(Todo t) async {
    await http.put(
      Uri.parse("$baseUrl/todos/${t.id}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"finish": t.finish}),
    );
    await fetchTodos();
  }

  Future<void> deleteTodo(String id) async {
    await http.delete(Uri.parse("$baseUrl/todos/$id"));
    await fetchTodos();
  }

  Future<void> _addTodo() async {
    final text = await showDialog<String>(
      context: context,
      builder: (_) => TodoDialog(),
    );

    final title = (text ?? "").trim();
    if (title.isEmpty) return;

    await addTodo(title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('ToDo List'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        child: const Icon(Icons.add),
      ),
      body: todos.isEmpty
          ? const Center(child: Text("No todos yet"))
          : ListView.separated(
              itemCount: todos.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final t = todos[index];

                return Dismissible(
                  key: ValueKey(t.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) async {
                    await deleteTodo(t.id);
                  },
                  child: ListTile(
                    title: Text(
                      t.title,
                      style: TextStyle(
                        decoration: t.finish ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    leading: Checkbox(
                      value: t.finish,
                      onChanged: (v) async {
                        t.finish = v ?? false;
                        await updateTodo(t);
                      },
                    ),
                    onTap: () async {
                      t.finish = !t.finish;
                      await updateTodo(t);
                    },
                  ),
                );
              },
            ),
    );
  }
}

//添加todo项目的弹窗
class TodoDialog extends StatelessWidget {
  TodoDialog({super.key});

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("New ToDo"),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: "e.g. Buy milk"),
        onSubmitted: (_) => Navigator.pop(context, controller.text.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text.trim()),
          child: const Text("Add"),
        ),
      ],
    );
  }
}