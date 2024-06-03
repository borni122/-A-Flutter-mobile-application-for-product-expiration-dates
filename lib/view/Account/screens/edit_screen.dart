import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import '../../../core/view_model/profile_view_model.dart';
import '../widgets/edit_item.dart';
import '../../../constance.dart';

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final ProfileViewModel _profileViewModel = Get.find();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _picUrl = '';

  @override
  void initState() {
    super.initState();
    final user = _profileViewModel.userModel;
    _nameController.text = user!.name;
    _emailController.text = user.email;
    _picUrl = user.pic;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Ionicons.chevron_back_outline),
        ),
        leadingWidth: 80,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () async {
                await _profileViewModel.updateUserProfile(
                  _nameController.text,
                  _emailController.text,
                  _picUrl,
                );
                Navigator.pop(context);
              },
              style: IconButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                fixedSize: const Size(60, 50),
                elevation: 3,
              ),
              icon: const Icon(Ionicons.checkmark, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Account",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              GetBuilder<ProfileViewModel>(
                builder: (controller) {
                  return EditItem(
                    title: "Photo",
                    widget: Column(
                      children: [
                        CircleAvatar(
                          backgroundImage: _picUrl.isNotEmpty
                              ? NetworkImage(_picUrl) as ImageProvider<Object>
                              : const AssetImage("assets/avatar.png"),
                          radius: 50,
                        ),
                        TextButton(
                          onPressed: () async {
                            await _profileViewModel.pickImage();
                            if (mounted) { // Check if widget is still mounted
                              setState(() {
                                _picUrl = _profileViewModel.userModel!.pic;
                              });
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.lightBlueAccent,
                          ),
                          child: const Text("Upload Image"),
                        )
                      ],
                    ),
                  );
                },
              ),
              EditItem(
                title: "Name",
                widget: TextField(
                  controller: _nameController,
                ),
              ),
              const SizedBox(height: 40),
              EditItem(
                title: "Email",
                widget: TextField(
                  controller: _emailController,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}