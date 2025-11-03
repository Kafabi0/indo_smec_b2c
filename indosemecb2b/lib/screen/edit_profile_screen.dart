import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../utils/user_data_manager.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();

  String? phoneNumber;
  String? gender;
  String? imagePath; // ✅ path foto profil user

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final loginValue = await UserDataManager.getCurrentUserLogin();
    if (loginValue == null) return;

    final profile = await UserDataManager.getUserProfile(loginValue);
    setState(() {
      phoneNumber = loginValue;
      emailController.text = profile?['email'] ?? '';
      nameController.text = profile?['name'] ?? '';
      gender = profile?['gender'];
      birthdateController.text = profile?['birthdate'] ?? '';
      imagePath = profile?['imagePath'];
    });
  }

  Future<void> _saveProfile() async {
    final loginValue = await UserDataManager.getCurrentUserLogin();
    if (loginValue == null) return;

    final profileData = {
      'email': emailController.text,
      'name': nameController.text,
      'gender': gender,
      'birthdate': birthdateController.text,
      'imagePath': imagePath,
    };

    await UserDataManager.saveUserProfile(loginValue, profileData);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profil berhasil disimpan")));
    }
  }

  Future<void> _pickDate() async {
    DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (selected != null) {
      birthdateController.text = DateFormat('dd-MM-yyyy').format(selected);
      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final source = await showDialog<ImageSource>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Pilih Foto Profil"),
            content: const Text(
              "Ambil foto dari kamera atau pilih dari galeri.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, ImageSource.camera),
                child: const Text("Kamera"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, ImageSource.gallery),
                child: const Text("Galeri"),
              ),
            ],
          ),
    );

    if (source == null) return;

    final picked = await picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) {
      setState(() {
        imagePath = picked.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && File(imagePath!).existsSync();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ubah Profil"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.grey[300],
                      backgroundImage:
                          hasImage ? FileImage(File(imagePath!)) : null,
                      child:
                          !hasImage
                              ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              )
                              : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Ubah Foto Profil",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            fieldLabel("Nomor Handphone"),
            readOnlyField(phoneNumber ?? '-'),

            fieldLabel("Email (Opsional)"),
            inputField("Masukkan Email Kamu", emailController),

            infoBox(
              "Melalui email, kamu bisa menerima info promo dan login akun.",
            ),

            // fieldLabel("Nama"),
            // inputField("Nama Kamu", nameController),

            fieldLabel("Jenis Kelamin"),
            Row(
              children: [
                genderRadio("L", "Laki-laki"),
                const SizedBox(width: 20),
                genderRadio("P", "Perempuan"),
              ],
            ),

            fieldLabel("Tanggal Lahir"),
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: inputField(
                  "DD-MM-YYYY",
                  birthdateController,
                  suffix: const Icon(Icons.calendar_month),
                ),
              ),
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  "Simpan Profil",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget fieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6, top: 12),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
  );

  Widget inputField(
    String hint,
    TextEditingController controller, {
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget readOnlyField(String value) {
    return TextField(
      controller: TextEditingController(text: value),
      readOnly: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[300],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget genderRadio(String val, String label) {
    return Row(
      children: [
        Radio<String>(
          value: val,
          groupValue: gender,
          onChanged: (newVal) => setState(() => gender = newVal),
        ),
        Text(label),
      ],
    );
  }

  Widget infoBox(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(bottom: 10, top: 6),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}
