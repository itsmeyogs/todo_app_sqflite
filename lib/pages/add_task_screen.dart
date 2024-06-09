import 'dart:async';
import 'package:flutter/material.dart';
import 'package:todo_app/database/tasks_database.dart';
import 'package:todo_app/models/task.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key, this.task});

  final Task? task;

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  late TextEditingController _titleC;
  late TextEditingController _descC;
  late TextEditingController _dateC;
  late TextEditingController _timeStartC;
  late TextEditingController _timeEndC;
  final _formKey = GlobalKey<FormState>();
  late String _priorityTask;
  bool _isUpdate = false;

  DateTime selected = DateTime.now();
  DateTime initial = DateTime(2024);
  DateTime last = DateTime(2050);

  @override
  void initState() {
    _titleC = TextEditingController();
    _descC = TextEditingController();
    _dateC = TextEditingController();
    _timeStartC = TextEditingController();
    _timeEndC = TextEditingController();
    _priorityTask = "";
    if (widget.task != null) {
      _titleC.text = widget.task!.title;
      _descC.text = widget.task!.description;
      _dateC.text = widget.task!.date.toLocal().toString().split(" ")[0];
      _timeStartC.text = widget.task!.startTime;
      _timeEndC.text = widget.task!.startTime;
      _priorityTask = widget.task!.priority;
      _isUpdate = true;
      selected = widget.task!.date;
    }
    super.initState();
  }

  @override
  void dispose() {
    _titleC.dispose();
    _descC.dispose();
    _dateC.dispose();
    _timeStartC.dispose();
    _timeEndC.dispose();
    _priorityTask = "";
    super.dispose();
  }

  Future<void> addTask() async {
    final task = Task(
        title: _titleC.text,
        description: _descC.text,
        date: selected,
        startTime: _timeStartC.text,
        endTime: _timeEndC.text,
        priority: _priorityTask,
        isCompleted: false);
    await TasksDatabase.instance.createTask(task);
  }

  Future<void> updateTask() async {
    final task = widget.task!.copy(
      title: _titleC.text,
      description: _descC.text,
      date: selected,
      startTime: _timeStartC.text,
      endTime: _timeEndC.text,
      priority: _priorityTask,
    );
    await TasksDatabase.instance.updateTask(task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        forceMaterialTransparency: true,
        title: Text(
          _isUpdate ? "Update Task" : "Add Task",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          _isUpdate
              ? IconButton(
                  onPressed: () async {
                    await TasksDatabase.instance.deleteTask(widget.task!.id!);
                    Navigator.pop(context, true);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Successfully Deleted Task"),
                        duration: Duration(milliseconds: 700)));
                  },
                  icon: const Icon(Icons.delete))
              : const Text(""),
        ],
        shape: const Border(
            bottom: BorderSide(
          color: Colors.black,
          width: 0.1,
        )),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Text(
                  "Title",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
              ),
              TextField(
                controller: _titleC,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
                child: Text("Description",
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
              ),
              TextFormField(
                controller: _descC,
                maxLines: 5,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
                child: Text("Date & Time",
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: SizedBox(
                        width: 100,
                        height: 40,
                        child: TextField(
                          onTap: () {
                            displayTimeStartPicker(context);
                          },
                          style: const TextStyle(fontSize: 14),
                          keyboardType: TextInputType.datetime,
                          controller: _timeStartC,
                          readOnly: true,
                          textAlignVertical: TextAlignVertical.center,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            hintText: "Start Time",
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: SizedBox(
                        width: 100,
                        height: 40,
                        child: TextField(
                          onTap: () {
                            displayTimeEndPicker(context);
                          },
                          style: const TextStyle(fontSize: 14),
                          controller: _timeEndC,
                          readOnly: true,
                          textAlignVertical: TextAlignVertical.center,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            hintText: "End Time",
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      height: 40,
                      child: TextField(
                        onTap: () {
                          displayDatePicker(context);
                        },
                        style: const TextStyle(fontSize: 14),
                        controller: _dateC,
                        textAlignVertical: TextAlignVertical.center,
                        textAlign: TextAlign.center,
                        readOnly: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          hintText: "Date",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text("Priority",
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RadioMenuButton(
                      value: "High",
                      groupValue: _priorityTask,
                      onChanged: (value) {
                        setState(() {
                          _priorityTask = value!;
                        });
                      },
                      child: const Text("High")),
                  RadioMenuButton(
                      value: "Normal",
                      groupValue: _priorityTask,
                      onChanged: (value) {
                        setState(() {
                          _priorityTask = value!;
                        });
                      },
                      child: const Text("Normal")),
                  RadioMenuButton(
                      value: "Low",
                      groupValue: _priorityTask,
                      onChanged: (value) {
                        setState(() {
                          _priorityTask = value!;
                        });
                      },
                      child: const Text("Low")),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: TextButton(
                      onPressed: () {
                        addUpdateTask();
                        Navigator.pop(context, true);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Successfully Saved Task"),
                          duration: Duration(milliseconds: 500),
                        ));
                      },
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white),
                      child: Text(_isUpdate ? "Update" : "Save")),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addUpdateTask() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
    }
    final isUpdating = widget.task != null;
    if (isUpdating) {
      await updateTask();
    } else {
      await addTask();
    }
  }

  Future displayDatePicker(BuildContext context) async {
    var date = await showDatePicker(
      context: context,
      initialDate: selected,
      firstDate: initial,
      lastDate: last,
    );

    if (date != null) {
      setState(() {
        _dateC.text = date.toLocal().toString().split(" ")[0];
        selected = date;
      });
    }
  }

  Future displayTimeStartPicker(BuildContext context) async {
    var time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (time != null) {
      setState(() {
        _timeStartC.text = formatTime(time);
      });
    }
  }

  Future displayTimeEndPicker(BuildContext context) async {
    var time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (time != null) {
      setState(() {
        _timeEndC.text = formatTime(time);
      });
    }
  }

  String formatTime(TimeOfDay time) {
    String hourString = time.hour.toString().padLeft(2, '0');
    String minuteString = time.minute.toString().padLeft(2, '0');
    return "$hourString:$minuteString";
  }
}
