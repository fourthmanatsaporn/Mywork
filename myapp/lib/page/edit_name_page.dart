import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../state/team_controller.dart';


class EditNamePage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();


  EditNamePage({super.key});


  @override
  Widget build(BuildContext context) {
    final TeamController controller = Get.find<TeamController>();


    // preload ชื่อที่มีอยู่แล้ว
    nameController.text = controller.playerName.value;


    return Scaffold(
      appBar: AppBar(
        title: const Text("แก้ไขชื่อผู้เล่น"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "ชื่อผู้เล่น",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                controller.playerName.value = nameController.text;
                Get.back(); // กลับไปหน้าเดิม
              },
              child: const Text("บันทึก"),
            )
          ],
        ),
      ),
    );
  }
}



