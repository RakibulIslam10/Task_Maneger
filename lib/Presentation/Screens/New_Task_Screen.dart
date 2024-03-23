import 'package:flutter/material.dart';
import 'package:taskmanager/Data/Models/Count_buy_Status_Wrraper.dart';
import 'package:taskmanager/Data/Models/Task_List_Wrapper.dart';
import 'package:taskmanager/Data/Service/Network_Caller.dart';
import 'package:taskmanager/Data/Utils/Urls.dart';
import 'package:taskmanager/Presentation/Screens/Add_New_Task_Screen.dart';
import 'package:taskmanager/Presentation/Utils/Style.dart';
import 'package:taskmanager/Presentation/Widget/Background_Widget.dart';
import 'package:taskmanager/Presentation/Widget/Empty_List_Widget.dart';
import 'package:taskmanager/Presentation/Widget/Profile_App_Bar.dart';
import 'package:taskmanager/Presentation/Widget/SnackBar_Message.dart';
import 'package:taskmanager/Presentation/Widget/Task_Card.dart';
import 'package:taskmanager/Presentation/Widget/Task_Counter_Card.dart';

class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({super.key});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

bool _getAllTaskCountBuyStatusInProgress = false;
bool _taskListWrapperInProgress = false;
bool _updateTaskInProgress = false;

CountBuyTaskWrapper _countByStatusWrapper = CountBuyTaskWrapper();
TaskListWrapper _newTaskListWrapper = TaskListWrapper();

class _NewTaskScreenState extends State<NewTaskScreen> {
  @override
  void initState() {
    getDataFromApi();
    super.initState();
  }

  void getDataFromApi() async {
    getAllTaskCountByStatus();
    getAllTaskNewList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: profileAppBar(),
      body: BackgroundWidget(
          child: Column(
        children: [
          Visibility(
              visible: _getAllTaskCountBuyStatusInProgress == false,
              replacement: const Padding(
                padding: EdgeInsets.all(8.0),
                child: LinearProgressIndicator(),
              ),
              child: taskCounterSection),
          Expanded(
            child: Visibility(
              visible: _taskListWrapperInProgress == false &&
                  _updateTaskInProgress == false,
              replacement: const Center(
                  child: CircularProgressIndicator()),
              child: RefreshIndicator(
                onRefresh: () async => getDataFromApi(),
                child: ListView.builder(
                    itemCount: _newTaskListWrapper.taskList?.length ?? 0,
                    itemBuilder: (context, index) {
                      return TaskCard(
                          color: ColorGreen,
                          taskItems: _newTaskListWrapper.taskList![index],
                          refreshList: () {
                            getDataFromApi();
                          });
                    }),
              ),
            ),
          )
        ],
      )),
      floatingActionButton: FloatingActionButton.extended(
          backgroundColor: ColorBlue,
          icon: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddNewTaskScreen(getApiCall: () {
                    getDataFromApi();
                  }),
                ));
          },
          label: const Text("Add")),
    );
  }

  Widget get taskCounterSection {
    return SizedBox(
      height: 95,
      child: Visibility(visible: _newTaskListWrapper.taskList?.isNotEmpty ?? false,
        replacement: const EmptyListWidget(),
        child: ListView.separated(
          itemCount: _countByStatusWrapper.listOfTaskStatusData?.length ?? 0,
          scrollDirection: Axis.horizontal,
          separatorBuilder: (_, __) {
            return const SizedBox(width: 5);
          },
          itemBuilder: (context, index) {
            return TaskCounterCard(
              title: _countByStatusWrapper.listOfTaskStatusData![index].sId ?? "",
              amount: _countByStatusWrapper.listOfTaskStatusData![index].sum ?? 0,
            );
          },
        ),
      ),
    );
  }

  Future<void> getAllTaskCountByStatus() async {
    setState(() {
      _getAllTaskCountBuyStatusInProgress = true;
    });
    final response = await NetworkCaller.getRequest(Urls.taskCountByStatus);
    if (response.isSuccess) {
      _countByStatusWrapper =
          CountBuyTaskWrapper.fromJson(response.ResponseBody);
      setState(() {
        _getAllTaskCountBuyStatusInProgress = false;
      });
    } else {
      if (mounted) {
        showSnackBarMessage(context, "request failed Try again");
      }
    }
  }

  Future<void> getAllTaskNewList() async {
    setState(() {
      _taskListWrapperInProgress = true;
    });
    final response = await NetworkCaller.getRequest(Urls.newTaskList);
    if (response.isSuccess) {
      _newTaskListWrapper = TaskListWrapper.fromJson(response.ResponseBody);
      ;
      setState(() {
        _taskListWrapperInProgress = false;
      });
    } else {
      if (mounted) {
        showSnackBarMessage(context, "Sorry Task List Getting failed!");
      }
    }
  }
}
