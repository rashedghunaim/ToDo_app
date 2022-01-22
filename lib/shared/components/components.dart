import 'package:flutter/material.dart';
import 'package:flutter_conditional_rendering/conditional.dart';
import 'package:todo_app/shared/cubit/cubit.dart';

Widget defaultButton({
  required String title,
  required Function onTap,
  Color backGroundColor = Colors.blue,
  bool isTitleUpperCase = true,
  double width = double.infinity,
  double height = 40.0,
}) {
  return Container(
    child: MaterialButton(
      onPressed: () => onTap,
      child: Text(
        isTitleUpperCase ? title.toUpperCase() : title,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    ),
  );
}

Widget defaultFormField({
  required TextEditingController controller,
  required String? Function(String?) validateFunction,
  required String label,
  required IconData prefixIcon,
  required void Function() onTap,
  bool isEnabled = true,
  TextInputType inputType = TextInputType.text,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: inputType,
    validator: validateFunction,
    onTap: onTap,
    enabled: isEnabled,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(prefixIcon),
      border: OutlineInputBorder(),
    ),
  );
}

Widget taskItem(Map<String, dynamic> task , BuildContext context) {
  return Dismissible(
    key: Key(task['id'].toString()),
    onDismissed: (direction){
     AppCubit.get(context).deleteTask(task['id']);
    },
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 40.0,
            child: Text(task['time']),
          ),
          SizedBox(
            width: 20.0,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  task['title'],
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  task['date'],
                  style: TextStyle(color: Colors.grey),
                )
              ],
            ),

          ) ,
          SizedBox(
            width: 20.0,
          ),
          IconButton(onPressed: (){
            AppCubit.get(context).updateData(status: 'done', id: task['id'] ) ;
          },icon: Icon(Icons.check_box , color: Colors.green,),),
          IconButton(onPressed: (){
            AppCubit.get(context).updateData(status: 'archived', id: task['id'] ) ;
          },icon: Icon(Icons.archive , color: Colors.black45,),),
        ],
      ),
    ),
  );
}




Widget tasksBuilder(BuildContext context , List<Map<String,dynamic>> tasks ){
  return Conditional.single(
    context: context,
    conditionBuilder: (context) =>
    tasks.isNotEmpty,
    fallbackBuilder: (context) => Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu,
            size: 100.0,
            color: Colors.grey,
          ),
          Text(
            'Not tasks yet , start adding some ',
            style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey
            ),
          ),
        ],
      ),
    ),
    widgetBuilder: (context) => ListView.separated(
      itemBuilder: (context, index) =>
          taskItem(tasks[index], context),
      separatorBuilder: (context, index) => Divider(),
      itemCount: tasks.length,
    ),
  );
}