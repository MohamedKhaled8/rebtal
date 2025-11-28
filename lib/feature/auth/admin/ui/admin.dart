import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("admin" , 
        style: TextStyle(
          color: ColorManager.black,
          fontSize: 35
        ),
        ),
      ),
    );
  }
}