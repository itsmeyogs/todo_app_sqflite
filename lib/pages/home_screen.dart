import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todo_app/database/tasks_database.dart';
import 'package:todo_app/pages/add_task_screen.dart';
import 'package:todo_app/pages/all_task_screen.dart';

import '../models/task.dart';


const List<String> sort = <String>['Priority', 'High', 'Normal', 'Low'];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = false;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  var dropDownValue = sort.first;

  List<Task> tasks = [];


  Future<void> getTasksByDate(String date, String priority) async{
    setState(() => isLoading= true);
    tasks = await TasksDatabase.instance.readDataByDate(date, priority);
    setState(() =>isLoading = false);
  }

  @override
  void initState(){
    getTasksByDate(_selectedDay.toLocal().toString().split(" ")[0], dropDownValue);
    super.initState();
  }

  @override
  void dispose(){
    TasksDatabase.instance.close();
    super.dispose();
  }

  void refreshData(){
    setState(() {
      getTasksByDate(_selectedDay.toLocal().toString().split(" ")[0],dropDownValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          forceMaterialTransparency: true,
          title: const Text(
            "Todo App",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                        builder:(_) => const AddTaskScreen())
                  ).then((result){
                    if(result==true){
                      refreshData();
                    }
                  });
                }, icon: const Icon(Icons.add_circle_outline_outlined))
          ],
        ),
        body: isLoading? const Center( child: CircularProgressIndicator()) :
          Column(
            children: [
              TableCalendar(
                focusedDay: _focusedDay,
                firstDay: DateTime.utc(2024),
                lastDay: DateTime.utc(2050),
                calendarFormat: CalendarFormat.week,
                headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    refreshData();
                  });
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 110,
                    height: 45,
                    child: DropdownButtonFormField(
                      decoration: const InputDecoration(
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide.none
                        ),
                        prefixIcon: Icon(Icons.sort),
                      ),
                      icon: Container(),
                      value: dropDownValue,
                      items: sort.map((item) =>
                          DropdownMenuItem<String>(
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
                  TextButton(onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (_)=> const AllTaskScreen()));

                  }, child: const Text("All Tasks", style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold,color: Colors.black),))
                ],
              ),
              Container(decoration: const BoxDecoration(
                  border: Border(
                      top: (BorderSide(color: Colors.black, width: 0.1)))),
              ),
              // Add some spacing
              Expanded(
                child: tasks.isEmpty? const Center(child: Text("Empty Task")) :
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return taskCard(task);// Display each task
                    },
                                    ),
                  ),
              ),
            ],
          )
    );
  }

  Widget taskCard(Task task){
    return InkWell(
      onTap: () async{
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AddTaskScreen(
            task: task,
          ))
        ).then((result){
          if(result==true){
            refreshData();
          }
        });
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
          child: Row(
            children: [
              Checkbox(value: task.isCompleted, onChanged: (value) async{
                await TasksDatabase.instance.markTaskAsCompleted(id: task.id!, isCompleted: value!);
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

