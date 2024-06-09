import 'package:flutter/material.dart';

import '../database/tasks_database.dart';
import '../models/task.dart';
import 'add_task_screen.dart';

const List<String> sort = <String>['Priority', 'High', 'Normal', 'Low'];

class AllTaskScreen extends StatefulWidget {
  const AllTaskScreen({super.key});

  @override
  State<AllTaskScreen> createState() => _AllTaskScreenState();
}

class _AllTaskScreenState extends State<AllTaskScreen> {
  bool isLoading = false;
  var dropDownValue = sort.first;

  List<Task> tasks = [];

  Future<void> getAllTasks(String priority) async {
    setState(() => isLoading = true);
    tasks = await TasksDatabase.instance.readAllTasks(priority);
    setState(() => isLoading = false);
  }

  @override
  void initState() {
    getAllTasks(dropDownValue);
    super.initState();
  }

  void refreshData() {
    setState(() {
      getAllTasks(dropDownValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        forceMaterialTransparency: true,
        title: const Text("All Task",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: SizedBox(
              width: 110,
              height: 45,
              child: DropdownButtonFormField(
                decoration: const InputDecoration(
                  enabledBorder:
                      UnderlineInputBorder(borderSide: BorderSide.none),
                  prefixIcon: Icon(Icons.sort),
                ),
                icon: Container(),
                value: dropDownValue,
                items: sort
                    .map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    dropDownValue = value!;
                    refreshData();
                  });
                },
              ),
            ),
          )
        ],
      ),
      body: tasks.isEmpty
          ? Center(
              child: Text("Empty Tasks"),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return allTaskCard(task); // Display each task
                },
              ),
            ),
    );
  }

  Widget allTaskCard(Task task) {
    return InkWell(
      onTap: () async {
        await Navigator.of(context)
            .push(MaterialPageRoute(
                builder: (_) => AddTaskScreen(
                      task: task,
                    )))
            .then((result) {
          if (result == true) {
            refreshData();
          }
        });
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Row(
            children: [
              Checkbox(
                  value: task.isCompleted,
                  onChanged: (value) async {
                    await TasksDatabase.instance
                        .markTaskAsCompleted(id: task.id!, isCompleted: value!);
                    refreshData();
                  }),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${task.startTime} - ${task.endTime}",
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    task.date.toLocal().toString().split(" ")[0],
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.only(
                        top: 4, bottom: 4, right: 8, left: 8),
                    child: Text(
                      task.priority,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
