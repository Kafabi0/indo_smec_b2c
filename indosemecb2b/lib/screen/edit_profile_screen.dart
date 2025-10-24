import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

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
  String? gender; // "L" atau "P"

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      phoneNumber = prefs.getString('userLogin');
      emailController.text = prefs.getString('userEmail') ?? '';
      nameController.text = prefs.getString('userName') ?? '';
      gender = prefs.getString('userGender');
      birthdateController.text = prefs.getString('userBirthdate') ?? '';
    });
  }

  Future<void> saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userEmail', emailController.text);
    await prefs.setString('userName', nameController.text);
    if (gender != null) await prefs.setString('userGender', gender!);
    if (birthdateController.text.isNotEmpty) {
      await prefs.setString('userBirthdate', birthdateController.text);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profil berhasil disimpan")),
    );
  }

  Future<void> pickDate() async {
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

  @override
  Widget build(BuildContext context) {
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
                children: const [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text("Ubah Foto Profil",
                      style: TextStyle(color: Colors.grey, fontSize: 13))
                ],
              ),
            ),
            const SizedBox(height: 20),

            fieldLabel("Nomor Handphone"),
            readOnlyField(phoneNumber ?? '-'),

            fieldLabel("Email (Opsional)"),
            inputField("Masukkan Email Kamu", emailController),

            infoBox(
              "Melalui email, kamu bisa melakukan masuk akun dan menerima informasi promo"
            ),

            fieldLabel("Nama"),
            inputField("Nama Kamu", nameController),

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
              onTap: pickDate,
              child: AbsorbPointer(
                child: inputField("DD-MM-YYYY", birthdateController,
                    suffix: const Icon(Icons.calendar_month)),
              ),
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  "Simpan Profil",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget fieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6, top: 12),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
  );

  Widget inputField(String hint, TextEditingController controller, {Widget? suffix}) {
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
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
