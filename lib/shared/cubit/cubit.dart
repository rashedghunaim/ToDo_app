import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archived_tasks/archived_tasks_screen.dart';
import 'package:todo_app/modules/done_tasks/done_tasks_screen.dart';
import 'package:todo_app/modules/new_tasks/new_tasks_screen.dart';
import 'package:todo_app/shared/cubit/states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  static AppCubit get(BuildContext context) => BlocProvider.of(context);

  int currentIndex = 0;

  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];

  List<String> appBatTitles = [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];

  void changeNavBarIndex(int selectedIndex) {
    currentIndex = selectedIndex;
    emit(ChangeNavigationBarState());
  }

  late Database dataBase;

  // List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> newTasks = [];
  List<Map<String, dynamic>> doneTasks = [];
  List<Map<String, dynamic>> archivedTasks = [];

  Future<void> createDataBase() async {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (dataBase, version) {
        print('DataBse has been created');
        dataBase
            .execute(
                'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT , time TEXT , date TEXT , status TEXT)')
            .then((future) {
          print('Table has been created');
        });
      },
      onOpen: (dataBase) {
        print('DataBse has been opened');
        getDataFromDataBase(dataBase);
      },
    ).then((value) {
      dataBase = value;
      emit(CreateDataBseState());
    });
  }

  Future<void> insertIntoDataBase({
    required String title,
    required String time,
    required String date,
  }) async {
    emit(LoadingIndicatorState());

    await dataBase.transaction((transAction) {
      return transAction
          .rawInsert(
        'INSERT INTO tasks (title , time , date  , status ) VALUES ("$title" , "$time" , "$date" , "new")',
      )
          .then((value) {
        print('inserted successfully');
        emit(InsertIntoDataBseState());

        getDataFromDataBase(dataBase);
      });
    });
  }

  Future<void> getDataFromDataBase(Database database) async {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];
    database.rawQuery('SELECT * FROM tasks').then((query) {
      print('retrieving records succeed');
      print(query.toString());
      // tasks = query;
      query.forEach((element) {
        if (element['status'] == 'new') {
          newTasks.add(element);
        } else if (element['status'] == 'done') {
          doneTasks.add(element);
        } else {
          archivedTasks.add(element);
        }
      });
      emit(GetFromDataBseState());
    });
  }

  Future<void> updateData({required String status, required int id}) async {
    dataBase.rawUpdate(
      'UPDATE tasks SET status  = ? WHERE id = ?',
      ['$status', id],
    ).then((value) {
      emit(UpdateData());
      print('record has been updated');
      getDataFromDataBase(dataBase);
    });
  }



  Future<void> deleteTask(int id)async{
    dataBase.rawDelete('DELETE FROM tasks WHERE id = ?' , [id]).then((value){
      print('record has been deleted ');
      getDataFromDataBase(dataBase);
      emit(DeleteTask());
    });
  }



  bool isBottomSheetOpened = false;
  IconData fabIcon = Icons.edit;

  void changeBottomSheetState(
      {required bool isOpened, required IconData icon}) {
    isBottomSheetOpened = isOpened;
    fabIcon = icon;
    emit(ToggleBottomSheetState());
  }
}
