
import 'package:flutter/material.dart';

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
  final String title;
  bool finish;
  Todo(this.title,{this.finish = false});
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final List<Todo> todos = 
  [
    Todo("buy a milk"),
    Todo("eat vegetables"),
    Todo("take your meal",finish: true)
  ];

  Future<void> _addTodo() async {
    final text = await showDialog<String>(
      context: context,
      builder: (_) => TodoDialog(),
    );

    final title = (text ?? "").trim();
    if (title.isEmpty) return;

    setState(() {
      todos.insert(0, Todo(title));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center( child: Text('ToDo List')),
      ),
      floatingActionButton: FloatingActionButton(onPressed: _addTodo, child: const Icon(Icons.add),),
      body: todos.isEmpty
          ? const Center(child: Text("No todos yet"))
          : ListView.separated(
              itemCount: todos.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final t = todos[index];

                return Dismissible(
                  key: ValueKey(t.title),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    setState(() {
                      todos.removeAt(index);
                    });
                  },
                  child: ListTile(
                    title: Text(
                      t.title,
                      style: TextStyle(
                        decoration: t.finish
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    leading: Checkbox(
                      value: t.finish,
                      onChanged: (v) {
                        setState(() => t.finish = v ?? false);
                      },
                    ),
                    onTap: () => setState(() => t.finish = !t.finish),
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