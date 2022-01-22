import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:todo_app/shared/components/components.dart';
import 'package:flutter_conditional_rendering/flutter_conditional_rendering.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final titleController = TextEditingController();
  final timeController = TextEditingController();
  final dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppCubit()..createDataBase(),
      // .. means internally saves the object in a variable then access it within the second . dot
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (BuildContext context, AppStates state) {
          if (state is InsertIntoDataBseState) {
            Navigator.pop(context);
          }
        },
        builder: (BuildContext context, AppStates state) {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              elevation: 0.0,
              title: Text(cubit.appBatTitles[cubit.currentIndex]),
            ),
            body: Conditional.single(
              context: context,
              conditionBuilder: (context) => state is! LoadingIndicatorState,
              widgetBuilder: (context) => cubit.screens[cubit.currentIndex],
              fallbackBuilder: (context) => Center(
                child: CircularProgressIndicator(),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (cubit.isBottomSheetOpened) {
                  if (_formKey.currentState!.validate()) {
                    cubit.insertIntoDataBase(
                      time: timeController.text,
                      date: dateController.text,
                      title: titleController.text,
                    );
                  }
                } else {
                  _scaffoldKey.currentState!
                      .showBottomSheet(
                        (context) => Container(
                          padding: EdgeInsets.all(20.0),
                          color: Colors.grey[100],
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                defaultFormField(
                                  controller: titleController,
                                  label: 'task title',
                                  prefixIcon: Icons.title,
                                  validateFunction: (String? value) {
                                    if (value!.isEmpty) {
                                      print('the value is $value');
                                      return 'pls enter a task title';
                                    } else {
                                      return null;
                                    }
                                  },
                                  inputType: TextInputType.text,
                                  onTap: () {},
                                ),
                                SizedBox(height: 15),
                                defaultFormField(
                                  controller: timeController,
                                  label: 'task time',
                                  prefixIcon: Icons.watch_later,
                                  validateFunction: (String? value) {
                                    if (value!.isEmpty) {
                                      return 'pls enter a task time';
                                    } else {
                                      return null;
                                    }
                                  },
                                  inputType: TextInputType.datetime,
                                  onTap: () {
                                    showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    ).then((selectedTime) {
                                      timeController.text = selectedTime!
                                          .format(context)
                                          .toString();
                                    });
                                  },
                                ),
                                SizedBox(height: 15),
                                defaultFormField(
                                  controller: dateController,
                                  label: 'task date',
                                  prefixIcon: Icons.calendar_today_outlined,
                                  validateFunction: (String? value) {
                                    if (value!.isEmpty) {
                                      return 'pls enter a task date';
                                    } else {
                                      return null;
                                    }
                                  },
                                  inputType: TextInputType.datetime,
                                  onTap: () {
                                    showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.parse('2022-02-17'),
                                    ).then((selectedDate) {
                                      dateController.text = DateFormat.yMMMd()
                                          .format(selectedDate!)
                                          .toString();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .closed
                      .then((value) {
                    cubit.changeBottomSheetState(
                        isOpened: false, icon: Icons.edit);
                  });

                  cubit.changeBottomSheetState(isOpened: true, icon: Icons.add);
                }
              },
              child: Icon(cubit.fabIcon),
            ),
            bottomNavigationBar: BottomNavigationBar(
              elevation: 0.0,
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: (selectedIndex) {
                cubit.changeNavBarIndex(selectedIndex);
              },
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Tasks'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.check_circle_outline), label: 'Done'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.archive_outlined), label: 'Archived'),
              ],
            ),
          );
        },
      ),
    );
  }
}
