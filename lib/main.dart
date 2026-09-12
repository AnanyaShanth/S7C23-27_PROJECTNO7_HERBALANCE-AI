import 'dart:convert';
import 'dart:io';


import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const HerBalanceApp());
}


class HerBalanceApp extends StatelessWidget {
  const HerBalanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HerBalance AI',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
      ),
      home: const WelcomePage(),
    );
  }
}

// ================= WELCOME PAGE =================

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  static const Color primaryColor = Color(0xFF6B2525);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF8),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -100,
              right: -80,
              child: Container(
                height: 260,
                width: 260,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5DEDC),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -120,
              left: -100,
              child: Container(
                height: 280,
                width: 280,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3E8E1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                children: [
                  const Spacer(),
                  Container(
                    height: 120,
                    width: 120,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/herbalance_logo.jpeg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'HerBalance AI',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Your body. Your health.\nYour personalized journey.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 50),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'Log In',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterPage()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: const BorderSide(color: primaryColor, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'Create an Account',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),
                  const Text(
                    'Your wellness journey starts here ✨',
                    style: TextStyle(fontSize: 13, color: Colors.black45),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= LOGIN PAGE =================

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const Color primaryColor = Color(0xFF6B2525);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            const Text(
              'Welcome back 👋',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Log in to continue your wellness journey.',
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 45),
            const Text('Email Address', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Password', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: const Icon(Icons.visibility_off_outlined),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  'Log In',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    );
                  },
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ================= REGISTER PAGE =================

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const Color primaryColor = Color(0xFF6B2525);

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void createAccount() {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileSetupPage(name: nameController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create your account ✨',
              style: TextStyle(
                fontSize: 29,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Let’s begin your personalized wellness journey.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 40),
            _inputField('Full Name', 'Enter your name', Icons.person_outline, nameController),
            const SizedBox(height: 18),
            _inputField(
              'Email Address',
              'Enter your email',
              Icons.email_outlined,
              emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 18),
            _inputField(
              'Password',
              'Create a password',
              Icons.lock_outline,
              passwordController,
              obscure: true,
            ),
            const SizedBox(height: 18),
            _inputField(
              'Confirm Password',
              'Confirm your password',
              Icons.lock_outline,
              confirmPasswordController,
              obscure: true,
            ),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: createAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget _inputField(
      String label,
      String hint,
      IconData icon,
      TextEditingController controller, {
        bool obscure = false,
        TextInputType? keyboardType,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

// ================= PROFILE SETUP PAGE =================

class ProfileSetupPage extends StatefulWidget {
  final String name;

  const ProfileSetupPage({
    super.key,
    required this.name,
  });

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  static const Color primaryColor = Color(0xFF6B2525);

  late TextEditingController nameController;
  DateTime? selectedDate;
  File? profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() => profileImage = File(pickedFile.path));
    }
  }

  void showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFFFAF8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Wrap(
              children: [
                const Center(
                  child: Text(
                    'Profile Photo',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFF1D9D6),
                    child: Icon(Icons.camera_alt_outlined, color: primaryColor),
                  ),
                  title: const Text('Take a photo'),
                  onTap: () async {
                    Navigator.pop(context);
                    await pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFF1D9D6),
                    child: Icon(Icons.photo_library_outlined, color: primaryColor),
                  ),
                  title: const Text('Choose from gallery'),
                  onTap: () async {
                    Navigator.pop(context);
                    await pickImage(ImageSource.gallery);
                  },
                ),
                if (profileImage != null)
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFDE8E8),
                      child: Icon(Icons.delete_outline, color: Colors.red),
                    ),
                    title: const Text('Remove photo'),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => profileImage = null);
                    },
                  ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = nameController.text.trim();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              'Let’s get to know you 🌸',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Personalize your HerBalance experience.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 15),
            ),
            const SizedBox(height: 35),
            GestureDetector(
              onTap: showPhotoOptions,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 58,
                    backgroundColor: const Color(0xFFF1D9D6),
                    backgroundImage: profileImage != null ? FileImage(profileImage!) : null,
                    child: profileImage == null
                        ? Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    )
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 38,
                      width: 38,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFFFAF8),
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: showPhotoOptions,
              icon: const Icon(Icons.add_a_photo_outlined, color: primaryColor),
              label: Text(
                profileImage == null ? 'Add profile photo' : 'Change profile photo',
                style: const TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
              ),
            ),
            const Text(
              'You can always add or change it later.',
              style: TextStyle(color: Colors.black45, fontSize: 12),
            ),
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Enter your full name',
                prefixIcon: const Icon(Icons.person_outline),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Date of Birth', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: selectDate,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined),
                    const SizedBox(width: 12),
                    Text(
                      selectedDate == null
                          ? 'Select your date of birth'
                          : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 45),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter your name')),
                    );
                    return;
                  }
                  if (selectedDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select your date of birth')),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HealthProfilePage(
                        name: nameController.text.trim(),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ================= HEALTH PROFILE PAGE =================

class HealthProfilePage extends StatefulWidget {
  final String name;

  const HealthProfilePage({
    super.key,
    required this.name,
  });

  @override
  State<HealthProfilePage> createState() => _HealthProfilePageState();
}

class _HealthProfilePageState extends State<HealthProfilePage> {
  static const Color primaryColor = Color(0xFF6B2525);

  String? pcos;
  String? irregularPeriods;
  String? inheritedCondition;

  final healthConditionController = TextEditingController();
  final allergyController = TextEditingController();

  @override
  void dispose() {
    healthConditionController.dispose();
    allergyController.dispose();
    super.dispose();
  }

  Widget optionButton(
      String title,
      String value,
      String? selectedValue,
      Function(String) onSelected,
      ) {
    final isSelected = selectedValue == value;

    return GestureDetector(
      onTap: () {
        setState(() => onSelected(value));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? primaryColor : const Color(0xFFE8DDDA),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget textField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: primaryColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Health Profile ❤️',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Help us understand your health better so we can personalize your wellness experience.',
                style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black54),
              ),
              const SizedBox(height: 35),
              const Text(
                'Do you have PCOS / PCOD?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  optionButton('Yes', 'Yes', pcos, (v) => pcos = v),
                  optionButton('No', 'No', pcos, (v) => pcos = v),
                  optionButton('Not sure', 'Not sure', pcos, (v) => pcos = v),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Are your periods usually irregular?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  optionButton('Yes', 'Yes', irregularPeriods, (v) => irregularPeriods = v),
                  optionButton('No', 'No', irregularPeriods, (v) => irregularPeriods = v),
                  optionButton('Sometimes', 'Sometimes', irregularPeriods, (v) => irregularPeriods = v),
                  optionButton('Not sure', 'Not sure', irregularPeriods, (v) => irregularPeriods = v),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Do you have any inherited or family health conditions?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  optionButton('Yes', 'Yes', inheritedCondition, (v) => inheritedCondition = v),
                  optionButton('No', 'No', inheritedCondition, (v) => inheritedCondition = v),
                  optionButton('Not sure', 'Not sure', inheritedCondition, (v) => inheritedCondition = v),
                ],
              ),
              const SizedBox(height: 30),
              textField(
                'Other health conditions',
                'Optional: Enter any health conditions',
                healthConditionController,
              ),
              const SizedBox(height: 22),
              textField(
                'Allergies',
                'Optional: Enter any allergies',
                allergyController,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    if (pcos == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select whether you have PCOS / PCOD'),
                        ),
                      );
                      return;
                    }

                    if (irregularPeriods == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select your period regularity'),
                        ),
                      );
                      return;
                    }

                    if (inheritedCondition == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select an option for inherited health conditions'),
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CycleHistoryPage(
                          name: widget.name,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= CYCLE HISTORY PAGE =================

class CycleHistoryPage extends StatefulWidget {
  final String name;

  const CycleHistoryPage({
    super.key,
    required this.name,
  });

  @override
  State<CycleHistoryPage> createState() => _CycleHistoryPageState();
}

class _CycleHistoryPageState extends State<CycleHistoryPage> {
  static const Color primaryColor = Color(0xFF6B2525);

  DateTime? lastPeriod;
  DateTime? previousPeriod;

  Future<void> selectDate(bool isLastPeriod) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isLastPeriod) {
          lastPeriod = picked;
        } else {
          previousPeriod = picked;
        }
      });
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'Select date';
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _dateButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_outlined, color: primaryColor),
            const SizedBox(width: 14),
            Text(text, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: primaryColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Cycle History 🌸',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Add your recent period start dates to help estimate your upcoming cycle.',
                style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black54),
              ),
              const SizedBox(height: 35),
              const Text(
                'When did your last period start?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _dateButton(
                text: formatDate(lastPeriod),
                onTap: () => selectDate(true),
              ),
              const SizedBox(height: 30),
              const Text(
                'When did the period before that start?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Optional, but this helps us estimate your cycle better.',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              _dateButton(
                text: formatDate(previousPeriod),
                onTap: () => selectDate(false),
              ),
              const SizedBox(height: 45),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    if (lastPeriod == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select your last period date')),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SkinProfilePage(name: widget.name),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Your predicted period will be shown as an estimate and may vary, especially with irregular cycles.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= SKIN PROFILE PAGE =================

class SkinProfilePage extends StatelessWidget {
  final String name;

  const SkinProfilePage({
    super.key,
    required this.name,
  });

  static const Color primaryColor = Color(0xFF6B2525);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: primaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              const Text(
                'Let’s understand\nyour skin ✨',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Choose how you would like to set up your personalized skin profile.',
                style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black54),
              ),
              const SizedBox(height: 40),
              _skinOption(
                icon: Icons.face_retouching_natural,
                title: 'I know my skin type',
                subtitle: 'Select your skin type manually',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ManualSkinTypePage(name: name),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              _skinOption(
                icon: Icons.camera_alt_outlined,
                title: 'Analyze my skin',
                subtitle: 'Upload a photo and let AI help identify your skin type',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SkinAnalysisPage(name: name),
                    ),
                  );
                },
              ),
              const Spacer(),
              Center(
                child: Text(
                  'You can update your skin profile anytime.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _skinOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF0E2DF)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 58,
              width: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFF5DEDC),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: primaryColor, size: 29),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: primaryColor),
          ],
        ),
      ),
    );
  }
}

// ================= MANUAL SKIN TYPE PAGE =================

class ManualSkinTypePage extends StatefulWidget {
  final String name;

  const ManualSkinTypePage({
    super.key,
    required this.name,
  });

  @override
  State<ManualSkinTypePage> createState() => _ManualSkinTypePageState();
}

class _ManualSkinTypePageState extends State<ManualSkinTypePage> {
  static const Color primaryColor = Color(0xFF6B2525);
  String? selectedSkinType;

  final List<Map<String, dynamic>> skinTypes = [
    {
      'name': 'Normal',
      'icon': Icons.sentiment_satisfied_alt,
      'description': 'Balanced and comfortable skin',
    },
    {
      'name': 'Dry',
      'icon': Icons.water_drop_outlined,
      'description': 'May feel tight or flaky',
    },
    {
      'name': 'Oily',
      'icon': Icons.water_drop,
      'description': 'Often appears shiny or greasy',
    },
    {
      'name': 'Combination',
      'icon': Icons.face_retouching_natural,
      'description': 'Different areas may be dry or oily',
    },
    {
      'name': 'Sensitive',
      'icon': Icons.spa_outlined,
      'description': 'May react easily to some products',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: primaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What is your skin type? ✨',
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: primaryColor),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose the option that best describes your skin.',
                style: TextStyle(color: Colors.black54, fontSize: 15),
              ),
              const SizedBox(height: 25),
              Expanded(
                child: ListView.separated(
                  itemCount: skinTypes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final skin = skinTypes[index];
                    final isSelected = selectedSkinType == skin['name'];

                    return InkWell(
                      onTap: () => setState(() => selectedSkinType = skin['name']),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFF5DEDC) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? primaryColor : const Color(0xFFF0E2DF),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(skin['icon'], color: primaryColor, size: 28),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    skin['name'],
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    skin['description'],
                                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle, color: primaryColor),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: selectedSkinType == null
                      ? null
                      : () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomePage(
                          name: widget.name,
                          skinType: selectedSkinType!,
                        ),
                      ),
                          (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= SKIN ANALYSIS PAGE =================

class SkinAnalysisPage extends StatefulWidget {
  final String name;

  const SkinAnalysisPage({
    super.key,
    required this.name,
  });

  @override
  State<SkinAnalysisPage> createState() => _SkinAnalysisPageState();
}

class _SkinAnalysisPageState extends State<SkinAnalysisPage> {
  static const Color primaryColor = Color(0xFF6B2525);

  final ImagePicker _picker = ImagePicker();
  File? skinImage;
  bool isAnalyzing = false;
  String? skinType;
  double? confidence;

  Future<void> pickSkinImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          skinImage = File(pickedFile.path);
          skinType = null;
          confidence = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to select image: $e')),
      );
    }
  }

  void showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFFFAF8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Wrap(
              children: [
                const Center(
                  child: Text(
                    'Choose Skin Photo',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFF1D9D6),
                    child: Icon(Icons.camera_alt_outlined, color: primaryColor),
                  ),
                  title: const Text('Take a photo'),
                  subtitle: const Text('Use your camera'),
                  onTap: () async {
                    Navigator.pop(context);
                    await pickSkinImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFF1D9D6),
                    child: Icon(Icons.photo_library_outlined, color: primaryColor),
                  ),
                  title: const Text('Choose from gallery'),
                  subtitle: const Text('Select an existing photo'),
                  onTap: () async {
                    Navigator.pop(context);
                    await pickSkinImage(ImageSource.gallery);
                  },
                ),
                if (skinImage != null)
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFDE8E8),
                      child: Icon(Icons.delete_outline, color: Colors.red),
                    ),
                    title: const Text('Remove photo'),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        skinImage = null;
                        skinType = null;
                        confidence = null;
                      });
                    },
                  ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> analyzeSkin() async {
    if (skinImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a skin photo first.')),
      );
      return;
    }

    setState(() {
      isAnalyzing = true;
      skinType = null;
      confidence = null;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:8001/analyze-skin'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('file', skinImage!.path),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          skinType = data['skin_type']?.toString();
          if (data['confidence'] != null) {
            confidence = double.tryParse(data['confidence'].toString());
          }
          isAnalyzing = false;
        });
      } else {
        setState(() => isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['detail']?.toString() ?? 'Skin analysis failed.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isAnalyzing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to connect to HerBalance AI: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: primaryColor,
        title: const Text(
          'Skin Analysis',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Analyze your skin 📷',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor),
              ),
              const SizedBox(height: 10),
              const Text(
                'Take a clear photo or choose one from your gallery. Our AI will analyze it to estimate your skin type.',
                style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black54),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: isAnalyzing ? null : showImageOptions,
                child: Container(
                  height: 280,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5DEDC),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: skinImage == null
                      ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined, size: 55, color: primaryColor),
                      SizedBox(height: 15),
                      Text(
                        'Tap to add your skin photo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Camera or Gallery', style: TextStyle(color: Colors.black45)),
                    ],
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.file(
                      skinImage!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (skinImage != null)
                Center(
                  child: TextButton.icon(
                    onPressed: isAnalyzing ? null : showImageOptions,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Change photo'),
                    style: TextButton.styleFrom(foregroundColor: primaryColor),
                  ),
                ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isAnalyzing ? null : analyzeSkin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: isAnalyzing
                      ? const SizedBox(
                    width: 25,
                    height: 25,
                    child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                  )
                      : const Text(
                    'Analyze Skin',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              if (skinType != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1D9D6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.auto_awesome, size: 38, color: primaryColor),
                      const SizedBox(height: 10),
                      const Text(
                        'Your estimated skin type',
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        skinType!.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      if (confidence != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Confidence: ${confidence!.toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 15, color: Colors.black54),
                        ),
                      ],
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HomePage(
                                  name: widget.name,
                                  skinType: skinType!,
                                ),
                              ),
                                  (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Continue'),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              const Text(
                'For better results, use natural lighting, avoid heavy makeup, and make sure your face is clearly visible.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black45, height: 1.4),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= HOME PAGE =================

class HomePage extends StatelessWidget {
  final String name;
  final String skinType;

  const HomePage({
    super.key,
    required this.name,
    required this.skinType,
  });

  static const Color primaryColor = Color(0xFF6B2525);

  @override
  Widget build(BuildContext context) {
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFFF1D9D6),
                    child: Text(
                      firstLetter,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hello Dear 🌸',
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none, color: primaryColor),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your health,\nyour balance 💕',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Small steps today create a healthier tomorrow.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Your Health Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 15),
              _overviewCard(
                icon: Icons.face_retouching_natural,
                iconBackground: const Color(0xFFF1D9D6),
                title: 'Your Skin Type',
                subtitle: skinType.toUpperCase(),
              ),
              const SizedBox(height: 18),
              _overviewCard(
                icon: Icons.calendar_month,
                iconBackground: const Color(0xFFFFE5E8),
                title: 'Period Tracker',
                subtitle: 'Track your cycle and get predictions',
              ),
              const SizedBox(height: 18),
              _overviewCard(
                icon: Icons.self_improvement,
                iconBackground: const Color(0xFFE6F4EA),
                title: 'Wellness Recommendations',
                subtitle: 'Workout and nutrition based on you',
              ),
              const SizedBox(height: 18),
              _overviewCard(
                icon: Icons.medication_outlined,
                iconBackground: const Color(0xFFF1D9D6),
                title: 'Medicine Checker',
                subtitle: 'Check medicine safety for you',
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _overviewCard({
    required IconData icon,
    required Color iconBackground,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          const BoxShadow(color: Colors.black12, blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: primaryColor, size: 30),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(subtitle, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 18),
        ],
      ),
    );
  }
}
