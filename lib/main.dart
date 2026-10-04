import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
                          color: Colors.black.withValues(alpha: 0.08),
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



class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const Color primaryColor = Color(0xFF6B2525);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Color primaryColor = Color(0xFF6B2525);

  // Controllers to get the entered email and password
  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  bool isLoading = false;
  bool hidePassword = true;

  // ================= LOGIN FUNCTION =================

  Future<void> loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Check empty fields
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password.'),
        ),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      // Firebase login
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      // Login successful
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(
            name: email.split('@')[0],
            skinType: 'Not analyzed',
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      String message;

      switch (e.code) {
        case 'invalid-credential':
          message = 'Incorrect email or password.';
          break;

        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        case 'user-disabled':
          message = 'This account has been disabled.';
          break;

        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;

        default:
          message = 'Login failed. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    }
  }

  // ================= DISPOSE =================

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ================= UI =================

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
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 45),

            // ================= EMAIL =================

            const Text(
              'Email Address',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: emailController,

              keyboardType:
              TextInputType.emailAddress,

              decoration: InputDecoration(
                hintText: 'Enter your email',

                prefixIcon: const Icon(
                  Icons.email_outlined,
                ),

                filled: true,

                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(16),

                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================= PASSWORD =================

            const Text(
              'Password',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: passwordController,

              obscureText: hidePassword,

              decoration: InputDecoration(
                hintText: 'Enter your password',

                prefixIcon: const Icon(
                  Icons.lock_outline,
                ),

                suffixIcon: IconButton(
                  icon: Icon(
                    hidePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),

                  onPressed: () {
                    setState(() {
                      hidePassword =
                      !hidePassword;
                    });
                  },
                ),

                filled: true,

                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(16),

                  borderSide: BorderSide.none,
                ),
              ),
            ),

            // ================= FORGOT PASSWORD =================

            Align(
              alignment: Alignment.centerRight,

              child: TextButton(
                onPressed: () {
                  // We can add Firebase
                  // password reset here later.
                },

                child: const Text(
                  'Forgot Password?',

                  style: TextStyle(
                    color: primaryColor,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ================= LOGIN BUTTON =================

            SizedBox(
              width: double.infinity,
              height: 58,

              child: ElevatedButton(
                onPressed:
                isLoading ? null : loginUser,

                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(18),
                  ),
                ),

                child: isLoading
                    ? const SizedBox(
                  width: 25,
                  height: 25,

                  child:
                  CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
                    : const Text(
                  'Log In',

                  style: TextStyle(
                    fontSize: 17,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ================= REGISTER =================

            Row(
              mainAxisAlignment:
              MainAxisAlignment.center,

              children: [

                const Text(
                  "Don't have an account? ",
                ),

                GestureDetector(
                  onTap: () {

                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                        const RegisterPage(),
                      ),
                    );
                  },

                  child: const Text(
                    'Register',

                    style: TextStyle(
                      color: primaryColor,
                      fontWeight:
                      FontWeight.bold,
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

  Future<void> createAccount() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
        ),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
        ),
      );
      return;
    }

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      print('Account created: ${credential.user?.email}');

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProfileSetupPage(
            name: nameController.text.trim(),
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Registration failed';

      if (e.code == 'email-already-in-use') {
        message = 'This email is already registered';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong: $e'),
        ),
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
              style: TextStyle(
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 40),

            _inputField(
              'Full Name',
              'Enter your name',
              Icons.person_outline,
              nameController,
            ),

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
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
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
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

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

  bool isLoading = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadHealthProfile();
  }

  @override
  void dispose() {
    healthConditionController.dispose();
    allergyController.dispose();
    super.dispose();
  }

  // ================= LOAD PROFILE =================

  Future<void> loadHealthProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      setState(() {
        isLoading = true;
      });

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();

        if (data != null) {
          setState(() {
            pcos = data['pcos'];
            irregularPeriods = data['irregularPeriods'];
            inheritedCondition = data['inheritedCondition'];

            healthConditionController.text =
                data['healthConditions'] ?? '';

            allergyController.text =
                data['allergies'] ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading health profile: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ================= SAVE PROFILE =================

  Future<void> saveHealthProfile() async {
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
          content: Text(
            'Please select an option for inherited health conditions',
          ),
        ),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login again.'),
          ),
        );
        return;
      }

      setState(() {
        isSaving = true;
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'name': widget.name,
          'email': user.email,

          'pcos': pcos,
          'irregularPeriods': irregularPeriods,
          'inheritedCondition': inheritedCondition,

          'healthConditions':
          healthConditionController.text.trim(),

          'allergies':
          allergyController.text.trim(),

          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Health profile saved successfully ❤️'),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CycleHistoryPage(
            name: widget.name,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error saving health profile: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save health profile: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // ================= OPTION BUTTON =================

  Widget optionButton(
      String title,
      String value,
      String? selectedValue,
      Function(String) onSelected,
      ) {
    final isSelected = selectedValue == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          onSelected(value);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : const Color(0xFFE8DDDA),
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

  // ================= TEXT FIELD =================

  Widget textField(
      String label,
      String hint,
      TextEditingController controller,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
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

  // ================= UI =================

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
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : SingleChildScrollView(
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
                'Keep your health information updated so HERBALANCE AI can personalize your wellness and product safety analysis.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 35),

              const Text(
                'Do you have PCOS / PCOD?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  optionButton(
                    'Yes',
                    'Yes',
                    pcos,
                        (v) => pcos = v,
                  ),
                  optionButton(
                    'No',
                    'No',
                    pcos,
                        (v) => pcos = v,
                  ),
                  optionButton(
                    'Not sure',
                    'Not sure',
                    pcos,
                        (v) => pcos = v,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                'Are your periods usually irregular?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  optionButton(
                    'Yes',
                    'Yes',
                    irregularPeriods,
                        (v) => irregularPeriods = v,
                  ),
                  optionButton(
                    'No',
                    'No',
                    irregularPeriods,
                        (v) => irregularPeriods = v,
                  ),
                  optionButton(
                    'Sometimes',
                    'Sometimes',
                    irregularPeriods,
                        (v) => irregularPeriods = v,
                  ),
                  optionButton(
                    'Not sure',
                    'Not sure',
                    irregularPeriods,
                        (v) => irregularPeriods = v,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                'Do you have any inherited or family health conditions?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  optionButton(
                    'Yes',
                    'Yes',
                    inheritedCondition,
                        (v) => inheritedCondition = v,
                  ),
                  optionButton(
                    'No',
                    'No',
                    inheritedCondition,
                        (v) => inheritedCondition = v,
                  ),
                  optionButton(
                    'Not sure',
                    'Not sure',
                    inheritedCondition,
                        (v) => inheritedCondition = v,
                  ),
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
                  onPressed: isSaving
                      ? null
                      : saveHealthProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Save & Continue',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
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
        SnackBar(
          content: Text('Unable to select image: $e'),
        ),
      );
    }
  }

  void showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFFFAF8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
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
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: primaryColor,
                    ),
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
                    child: Icon(
                      Icons.photo_library_outlined,
                      color: primaryColor,
                    ),
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
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
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
        const SnackBar(
          content: Text('Please add a skin image to continue.'),
        ),
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
        Uri.parse(
          Platform.isAndroid
              ? 'http://10.0.2.2:8003/analyze-skin'
              : 'http://127.0.0.1:8003/analyze-skin',
        ),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          skinImage!.path,
        ),
      );

      print('Sending image to HerBalance backend...');

      final response = await request.send();

      final responseBody =
      await response.stream.bytesToString();

      print('Backend status: ${response.statusCode}');
      print('Backend response: $responseBody');

      final data = jsonDecode(responseBody);

      if (!mounted) return;

      setState(() {
        isAnalyzing = false;
      });

      // Backend returned an error
      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message']?.toString() ??
                  data['detail']?.toString() ??
                  'Skin analysis failed.',
            ),
          ),
        );
        return;
      }

      // Backend can return success:false
      if (data['success'] == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message']?.toString() ??
                  'Please upload a clear human face/skin image.',
            ),
          ),
        );
        return;
      }

      // Check whether skin type was returned
      if (data['skin_type'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Skin analysis returned no result.',
            ),
          ),
        );
        return;
      }

      final detectedSkinType =
      data['skin_type'].toString().toLowerCase();

      double? detectedConfidence;

      if (data['confidence'] != null) {
        detectedConfidence = double.tryParse(
          data['confidence'].toString(),
        );
      }

      // Display result
      setState(() {
        skinType = detectedSkinType;
        confidence = detectedConfidence;
      });

      print('Skin Type: $detectedSkinType');
      print('Confidence: $detectedConfidence');

      // -----------------------------------------
      // SAVE RESULT TO FIRESTORE
      // -----------------------------------------

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        try {
          final updateData = <String, dynamic>{
            'skinType': detectedSkinType,
            'updatedAt': FieldValue.serverTimestamp(),
          };

          if (detectedConfidence != null) {
            updateData['skinConfidence'] =
                detectedConfidence;
          }

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(
            updateData,
            SetOptions(merge: true),
          );

          print(
            'Skin type saved to Firestore successfully.',
          );
        } catch (firestoreError) {
          print(
            'Firestore save error: $firestoreError',
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Skin analysis completed, but the result could not be saved.',
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isAnalyzing = false;
      });

      print('ANALYSIS ERROR: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to connect to HerBalance AI: $e',
          ),
        ),
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
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
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
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Take a clear photo or choose one from your gallery. Our AI will analyze it to estimate your skin type.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 30),

              GestureDetector(
                onTap: isAnalyzing
                    ? null
                    : showImageOptions,
                child: Container(
                  height: 280,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5DEDC),
                    borderRadius:
                    BorderRadius.circular(24),
                  ),
                  child: skinImage == null
                      ? const Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        size: 55,
                        color: primaryColor,
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Tap to add your skin photo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                          FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Camera or Gallery',
                        style: TextStyle(
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  )
                      : ClipRRect(
                    borderRadius:
                    BorderRadius.circular(24),
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
                    onPressed: isAnalyzing
                        ? null
                        : showImageOptions,
                    icon: const Icon(
                      Icons.edit_outlined,
                    ),
                    label: const Text(
                      'Change photo',
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: primaryColor,
                    ),
                  ),
                ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed:
                  isAnalyzing ? null : analyzeSkin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(16),
                    ),
                  ),
                  child: isAnalyzing
                      ? const SizedBox(
                    width: 25,
                    height: 25,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Analyze Skin',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
                    borderRadius:
                    BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        size: 38,
                        color: primaryColor,
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'Your estimated skin type',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
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
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                          ),
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
                          style:
                          ElevatedButton.styleFrom(
                            backgroundColor:
                            primaryColor,
                            foregroundColor:
                            Colors.white,
                          ),
                          child:
                          const Text('Continue'),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              const Text(
                'For better results, use natural lighting, avoid heavy makeup, and make sure your face is clearly visible.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black45,
                  height: 1.4,
                ),
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
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
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
                    icon: const Icon(
                      Icons.notifications_none,
                      color: primaryColor,
                    ),
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
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
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
                context,
                icon: Icons.face_retouching_natural,
                iconBackground: const Color(0xFFF1D9D6),
                title: 'Your Skin Type',
                subtitle: skinType.toUpperCase(),
              ),

              const SizedBox(height: 18),
              _overviewCard(
                context,
                icon: Icons.calendar_month,
                iconBackground: const Color(0xFFFFE5E8),
                title: 'Period Tracker',
                subtitle: 'Track your cycle and get predictions',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PeriodTrackerPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 18),

              _overviewCard(
                context,
                icon: Icons.self_improvement,
                iconBackground: const Color(0xFFE6F4EA),
                title: 'Wellness Recommendations',
                subtitle: 'Workout and nutrition based on you',
              ),

              const SizedBox(height: 18),

              // NEW INGREDIENT CHECKER
              _overviewCard(
                context,
                icon: Icons.science_outlined,
                iconBackground: const Color(0xFFF1D9D6),
                title: 'Cosmetic Ingredient Checker',
                subtitle: 'Scan ingredients and check suitability for you',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CosmeticIngredientPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 18),

              _overviewCard(
                context,
                icon: Icons.medication_outlined,
                iconBackground: const Color(0xFFF1D9D6),
                title: 'Medicine Checker',
                subtitle: 'Check medicine safety for you',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MedicineAnalyzerPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _overviewCard(
      BuildContext context, {
        required IconData icon,
        required Color iconBackground,
        required String title,
        required String subtitle,
        VoidCallback? onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            const BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
            ),
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
              child: Icon(
                icon,
                color: primaryColor,
                size: 30,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
class CosmeticIngredientPage extends StatefulWidget {
  const CosmeticIngredientPage({super.key});

  @override
  State<CosmeticIngredientPage> createState() =>
      _CosmeticIngredientPageState();
}

class _CosmeticIngredientPageState
    extends State<CosmeticIngredientPage> {
  final ImagePicker _picker = ImagePicker();

  File? selectedImage;
  bool isAnalyzing = false;

  Map<String, dynamic>? analysisResult;

  static const Color primaryColor = Color(0xFF6B2525);

  // =====================================================
  // PICK IMAGE
  // =====================================================

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        selectedImage = File(image.path);
        analysisResult = null;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to select image: $e'),
        ),
      );
    }
  }

  // =====================================================
  // ANALYZE PRODUCT
  // =====================================================
  // =====================================================
// ANALYZE PRODUCT
// =====================================================
  Future<void> analyzeProduct() async {
    // =================================================
    // ASK CURRENT SKIN CONDITION FIRST
    // =================================================
    Future<Map<String, dynamic>?> showCurrentConditionDialog() async {
      final List<String> conditions = [
        'Acne',
        'Irritation',
        'Dryness',
        'Redness',
        'Pigmentation',
        'None',
        'Other',
      ];

      List<String> selectedConditions = [];

      bool? allergicReaction;
      bool? currentTreatments;

      return showDialog<Map<String, dynamic>>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (
                context,
                setDialogState,
                ) {
              return AlertDialog(
                title: const Text(
                  'Current Skin Condition',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B2525),
                  ),
                ),

                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tell us about your current skin condition so HerBalance AI can personalize the analysis.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'Current skin concerns',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      ...conditions.map(
                            (condition) {
                          final bool isSelected =
                          selectedConditions
                              .contains(condition);

                          return CheckboxListTile(
                            contentPadding:
                            EdgeInsets.zero,
                            dense: true,
                            title: Text(condition),
                            value: isSelected,
                            activeColor:
                            const Color(0xFF6B2525),
                            onChanged: (value) {
                              setDialogState(() {
                                if (condition == 'None') {
                                  if (value == true) {
                                    selectedConditions =
                                    ['None'];
                                  } else {
                                    selectedConditions
                                        .remove('None');
                                  }
                                } else {
                                  selectedConditions
                                      .remove('None');

                                  if (value == true) {
                                    if (!selectedConditions
                                        .contains(
                                        condition)) {
                                      selectedConditions
                                          .add(condition);
                                    }
                                  } else {
                                    selectedConditions
                                        .remove(condition);
                                  }
                                }
                              });
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      const Divider(),

                      const SizedBox(height: 10),

                      const Text(
                        'Are you currently experiencing an allergic reaction or unusual skin sensitivity?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<bool>(
                              contentPadding:
                              EdgeInsets.zero,
                              dense: true,
                              title: const Text('Yes'),
                              value: true,
                              groupValue:
                              allergicReaction,
                              activeColor:
                              const Color(
                                  0xFF6B2525),
                              onChanged: (value) {
                                setDialogState(() {
                                  allergicReaction =
                                      value;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<bool>(
                              contentPadding:
                              EdgeInsets.zero,
                              dense: true,
                              title: const Text('No'),
                              value: false,
                              groupValue:
                              allergicReaction,
                              activeColor:
                              const Color(
                                  0xFF6B2525),
                              onChanged: (value) {
                                setDialogState(() {
                                  allergicReaction =
                                      value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'Are you currently using any skin treatments?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<bool>(
                              contentPadding:
                              EdgeInsets.zero,
                              dense: true,
                              title: const Text('Yes'),
                              value: true,
                              groupValue:
                              currentTreatments,
                              activeColor:
                              const Color(
                                  0xFF6B2525),
                              onChanged: (value) {
                                setDialogState(() {
                                  currentTreatments =
                                      value;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<bool>(
                              contentPadding:
                              EdgeInsets.zero,
                              dense: true,
                              title: const Text('No'),
                              value: false,
                              groupValue:
                              currentTreatments,
                              activeColor:
                              const Color(
                                  0xFF6B2525),
                              onChanged: (value) {
                                setDialogState(() {
                                  currentTreatments =
                                      value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(
                        dialogContext,
                      );
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFF6B2525),
                      foregroundColor:
                      Colors.white,
                    ),
                    onPressed: () {
                      if (selectedConditions
                          .isEmpty) {
                        selectedConditions =
                        ['None'];
                      }

                      Navigator.pop(
                        dialogContext,
                        {
                          'skin_problems':
                          selectedConditions,
                          'allergic_reaction':
                          allergicReaction ??
                              false,
                          'current_treatments':
                          currentTreatments ??
                              false,
                        },
                      );
                    },
                    child: const Text(
                      'Continue',
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    }
    final Map<String, dynamic>? currentCondition =
    await showCurrentConditionDialog();

    if (currentCondition == null) {
      return;
    }

    // =================================================
    // GET CURRENT USER
    // =================================================

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please login again to continue.',
          ),
        ),
      );
      return;
    }

    setState(() {
      isAnalyzing = true;
      analysisResult = null;
    });

    try {
      // =================================================
      // GET USER PROFILE
      // =================================================

      final userDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userData = userDocument.data() ?? {};

      final Map<String, dynamic> userProfile = {
        'skin_type': userData['skinType'] ?? 'unknown',
        'pcos': userData['pcos'] ?? false,
        'irregular_periods':
        userData['irregularPeriods'] ?? false,
        'inherited_condition':
        userData['inheritedCondition'] ?? false,
        'health_conditions':
        userData['healthConditions'] ?? '',
        'allergies':
        userData['allergies'] ?? '',
      };

      debugPrint(
        'HERBALANCE USER PROFILE: $userProfile',
      );

      print(
        'CURRENT CONDITION: $currentCondition',
      );

      // =================================================
      // CREATE REQUEST
      // =================================================
      final uri = Uri.parse(
        Platform.isAndroid
            ? 'http://10.0.2.2:8003/analyze-cosmetic'
            : 'http://127.0.0.1:8003/analyze-cosmetic',
      );
      final request = http.MultipartRequest(
        'POST',
        uri,
      );

      // =================================================
      // ADD IMAGE
      // =================================================

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          selectedImage!.path,
        ),
      );

      // =================================================
      // ADD USER PROFILE
      // =================================================

      request.fields['profile'] =
          jsonEncode(userProfile);

      // =================================================
      // ADD CURRENT CONDITION
      // =================================================

      request.fields['current_condition'] =
          jsonEncode(currentCondition);

      print(
        'Sending cosmetic analysis request...',
      );

      print(
        'Profile sent: ${request.fields['profile']}',
      );

      print(
        'Current condition sent: '
            '${request.fields['current_condition']}',
      );

      // =================================================
      // SEND REQUEST
      // =================================================

      final streamedResponse =
      await request.send();

      final response =
      await http.Response.fromStream(
        streamedResponse,
      );

      print(
        'Cosmetic API status: ${response.statusCode}',
      );

      print(
        'Cosmetic API response: ${response.body}',
      );

      if (!mounted) return;

      // =================================================
      // CHECK HTTP STATUS
      // =================================================

      if (response.statusCode != 200) {
        setState(() {
          isAnalyzing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'AI analysis failed (${response.statusCode}).',
            ),
          ),
        );

        return;
      }

      // =================================================
      // DECODE RESPONSE
      // =================================================

      final Map<String, dynamic> data =
      jsonDecode(response.body);

      // =================================================
      // CHECK SUCCESS
      // =================================================

      if (data['success'] != true) {
        setState(() {
          isAnalyzing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message'] ??
                  'Unable to analyze this product.',
            ),
          ),
        );

        return;
      }

      // =================================================
      // SAVE RESULT FOR UI
      // =================================================

      setState(() {
        isAnalyzing = false;
        analysisResult = data;
      });

      // =================================================
      // SAVE ANALYSIS HISTORY
      // =================================================

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('cosmeticAnalyses')
            .add({
          'productName':
          data['product_name'] ?? 'Unknown',

          'overallStatus':
          data['overall_status'] ?? 'UNKNOWN',

          'compatibilityScore':
          data['compatibility_score'] ?? 0,

          'compatibilityLabel':
          data['compatibility_label'] ?? '',

          'compatibilityNote':
          data['compatibility_note'] ?? '',

          'summary':
          data['summary'] ?? '',

          'ingredients':
          data['ingredients'] ?? [],

          'unknownIngredients':
          data['unknown_ingredients'] ?? [],

          'personalizedConcerns':
          data['personalized_concerns'] ?? [],

          'ingredientFindings':
          data['ingredient_findings'] ?? [],

          'recommendations':
          data['recommendations'] ?? [],

          'disclaimer':
          data['disclaimer'] ?? '',

          'currentCondition':
          currentCondition,

          'analyzedAt':
          FieldValue.serverTimestamp(),
        });

        print(
          'Cosmetic analysis saved to Firestore.',
        );
      } catch (saveError) {
        print(
          'Could not save cosmetic analysis history: '
              '$saveError',
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isAnalyzing = false;
      });

      print(
        'COSMETIC ANALYSIS ERROR: $e',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to connect to HerBalance AI: $e',
          ),
        ),
      );
    }
  }
  // =====================================================
  // AI ANALYSIS RESULT
  // =====================================================
  Widget buildAnalysisResult() {
    if (analysisResult == null) {
      return const SizedBox.shrink();
    }

    // ============================================================
    // DATA FROM BACKEND
    // ============================================================

    final String status =
        analysisResult!['overall_status']?.toString() ??
            'UNKNOWN';

    final String summary =
        analysisResult!['summary']?.toString() ?? '';

    final dynamic scoreValue =
    analysisResult!['compatibility_score'];

    final int compatibilityScore =
    scoreValue is num
        ? scoreValue.round()
        : int.tryParse(
      scoreValue?.toString() ?? '',
    ) ??
        0;

    final String compatibilityLabel =
        analysisResult!['compatibility_label']
            ?.toString() ??
            'Not Available';

    final String compatibilityNote =
        analysisResult!['compatibility_note']
            ?.toString() ??
            '';

    final List<dynamic> ingredients =
    analysisResult!['ingredients'] is List
        ? analysisResult!['ingredients']
        : [];

    final List<dynamic> concerns =
    analysisResult!['personalized_concerns']
    is List
        ? analysisResult!['personalized_concerns']
        : [];

    final List<dynamic> recommendations =
    analysisResult!['recommendations']
    is List
        ? analysisResult!['recommendations']
        : [];

    final List<dynamic> unknownIngredients =
    analysisResult!['unknown_ingredients']
    is List
        ? analysisResult!['unknown_ingredients']
        : [];

    final dynamic currentConditionData =
    analysisResult!['current_condition_used'];

    final Map<String, dynamic> currentCondition =
    currentConditionData is Map
        ? Map<String, dynamic>.from(
      currentConditionData,
    )
        : {};

    final String disclaimer =
        analysisResult!['disclaimer']?.toString() ??
            'This analysis is an informational screening tool and is not a medical diagnosis.';

    // ============================================================
    // STATUS DESIGN
    // ============================================================

    Color statusColor;
    IconData statusIcon;
    String statusTitle;
    String statusDescription;

    switch (status.toUpperCase()) {
      case 'GENERALLY SUITABLE':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_rounded;
        statusTitle = 'Generally Suitable';
        statusDescription =
        'No major concern was identified from the recognized ingredients for the information provided.';

        break;

      case 'CAUTION':
        statusColor = Colors.orange;
        statusIcon = Icons.warning_rounded;
        statusTitle = 'Use With Caution';
        statusDescription =
        'Some ingredients may require additional consideration based on their properties, your profile, or current skin condition.';

        break;

      case 'HIGH CONCERN':
        statusColor = Colors.red;
        statusIcon = Icons.error_rounded;
        statusTitle = 'Higher Concern';
        statusDescription =
        'One or more recognized ingredients have been flagged for a higher level of concern.';

        break;

      default:
        statusColor = Colors.deepOrange;
        statusIcon = Icons.info_rounded;
        statusTitle = 'Unable to Fully Assess';
        statusDescription =
        'The available ingredient information could not be interpreted completely.';
    }

    // ============================================================
    // SECTION TITLE
    // ============================================================

    Widget sectionTitle(
        String title,
        IconData icon,
        ) {
      return Row(
        children: [
          Icon(
            icon,
            color: primaryColor,
            size: 21,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
        ],
      );
    }

    // ============================================================
    // BULLET
    // ============================================================

    Widget bulletItem(String text) {
      return Padding(
        padding: const EdgeInsets.only(
          bottom: 10,
        ),
        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(
                top: 7,
              ),
              child: Icon(
                Icons.circle,
                size: 6,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ============================================================
    // CURRENT CONDITION TEXT
    // ============================================================

    List<String> currentSkinProblems = [];

    final dynamic skinProblems =
    currentCondition['skin_problems'];

    if (skinProblems is List) {
      currentSkinProblems =
          skinProblems
              .map(
                (e) => e.toString(),
          )
              .where(
                (e) =>
            e.isNotEmpty &&
                e.toLowerCase() != 'none',
          )
              .toList();
    }

    final bool allergicReaction =
        currentCondition['allergic_reaction'] ==
            true ||
            currentCondition['allergic_reaction']
                ?.toString()
                .toLowerCase() ==
                'true' ||
            currentCondition['allergic_reaction']
                ?.toString()
                .toLowerCase() ==
                'yes';

    final bool currentTreatments =
        currentCondition['current_treatments'] ==
            true ||
            currentCondition['current_treatments']
                ?.toString()
                .toLowerCase() ==
                'true' ||
            currentCondition['current_treatments']
                ?.toString()
                .toLowerCase() ==
                'yes';

    // ============================================================
    // INGREDIENT CARD
    // ============================================================

    Widget ingredientCard(
        dynamic ingredient,
        ) {
      if (ingredient is! Map) {
        return const SizedBox.shrink();
      }

      final Map<String, dynamic> item =
      Map<String, dynamic>.from(
        ingredient,
      );

      final String name =
          item['name']?.toString() ??
              'Unknown Ingredient';

      final String level =
          item['level']?.toString() ??
              'UNKNOWN';

      final String function =
          item['function']?.toString() ??
              '';

      final String reason =
          item['reason']?.toString() ??
              '';

      Color levelColor;
      Color levelBackground;

      switch (level.toUpperCase()) {
        case 'GENERALLY SUITABLE':
          levelColor = Colors.green.shade700;
          levelBackground =
              Colors.green.shade50;
          break;

        case 'CAUTION':
          levelColor = Colors.orange.shade800;
          levelBackground =
              Colors.orange.shade50;
          break;

        case 'HIGH CONCERN':
          levelColor = Colors.red.shade700;
          levelBackground =
              Colors.red.shade50;
          break;

        default:
          levelColor = Colors.grey.shade700;
          levelBackground =
              Colors.grey.shade100;
      }

      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(
          bottom: 12,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(16),
          border: Border.all(
            color:
            const Color(0xFFE8D5D2),
          ),
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: levelBackground,
                    borderRadius:
                    BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Text(
                    level,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                      FontWeight.bold,
                      color: levelColor,
                    ),
                  ),
                ),
              ],
            ),

            if (function.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                function,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                  FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],

            if (reason.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                reason,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: Colors.black87,
                ),
              ),
            ],
          ],
        ),
      );
    }

    // ============================================================
    // RESULT UI
    // ============================================================

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),

        // ========================================================
        // OVERALL ASSESSMENT
        // ========================================================

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(
              0.08,
            ),
            borderRadius:
            BorderRadius.circular(22),
            border: Border.all(
              color: statusColor.withOpacity(
                0.35,
              ),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                statusIcon,
                size: 52,
                color: statusColor,
              ),

              const SizedBox(height: 10),

              const Text(
                'Overall Assessment',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  fontWeight:
                  FontWeight.w500,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                statusTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight:
                  FontWeight.bold,
                  color: statusColor,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                statusDescription,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // ========================================================
        // COMPATIBILITY SCREENING
        // ========================================================

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.circular(18),
            border: Border.all(
              color:
              const Color(0xFFE8D5D2),
            ),
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              sectionTitle(
                'Compatibility Screening',
                Icons.health_and_safety_outlined,
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  SizedBox(
                    width: 82,
                    height: 82,
                    child: Stack(
                      alignment:
                      Alignment.center,
                      children: [
                        SizedBox(
                          width: 82,
                          height: 82,
                          child:
                          CircularProgressIndicator(
                            value:
                            compatibilityScore /
                                100,
                            strokeWidth: 8,
                            backgroundColor:
                            Colors.grey.shade200,
                            valueColor:
                            AlwaysStoppedAnimation<
                                Color>(
                              statusColor,
                            ),
                          ),
                        ),
                        Text(
                          '$compatibilityScore',
                          style:
                          const TextStyle(
                            fontSize: 20,
                            fontWeight:
                            FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 18),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$compatibilityScore / 100',
                          style:
                          const TextStyle(
                            fontSize: 22,
                            fontWeight:
                            FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          compatibilityLabel,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                            FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (compatibilityNote
                  .isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  compatibilityNote,
                  style:
                  const TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: Colors.black54,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 18),

        // ========================================================
        // SUMMARY
        // ========================================================

        if (summary.isNotEmpty)
          Container(
            width: double.infinity,
            padding:
            const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(18),
              border: Border.all(
                color:
                const Color(0xFFE8D5D2),
              ),
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                sectionTitle(
                  'Summary',
                  Icons.description_outlined,
                ),
                const SizedBox(height: 12),
                Text(
                  summary,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 18),

        // ========================================================
        // CURRENT CONDITION
        // ========================================================

        if (currentSkinProblems.isNotEmpty ||
            allergicReaction ||
            currentTreatments)
          Container(
            width: double.infinity,
            padding:
            const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color:
              const Color(0xFFF8EDEE),
              borderRadius:
              BorderRadius.circular(18),
              border: Border.all(
                color:
                const Color(0xFFE8D5D2),
              ),
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                sectionTitle(
                  'Current Skin Condition',
                  Icons.face_retouching_natural,
                ),

                const SizedBox(height: 14),

                if (currentSkinProblems
                    .isNotEmpty)
                  bulletItem(
                    'Current skin concerns: ${currentSkinProblems.join(', ')}.',
                  ),

                if (allergicReaction)
                  bulletItem(
                    'You reported a current allergic reaction or unusual sensitivity.',
                  ),

                if (currentTreatments)
                  bulletItem(
                    'You reported that you are currently using a skin treatment.',
                  ),

                const SizedBox(height: 2),

                const Text(
                  'This information was considered as context during the screening.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 18),

        // ========================================================
        // INGREDIENTS
        // ========================================================

        Container(
          width: double.infinity,
          padding:
          const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.circular(18),
            border: Border.all(
              color:
              const Color(0xFFE8D5D2),
            ),
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              sectionTitle(
                'Ingredients Identified',
                Icons.science_outlined,
              ),

              const SizedBox(height: 14),

              if (ingredients.isEmpty)
                const Text(
                  'No ingredients could be confidently identified from the image.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                )
              else
                ...ingredients.map(
                  ingredientCard,
                ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // ========================================================
        // PERSONALIZED CONCERNS
        // ========================================================

        Container(
          width: double.infinity,
          padding:
          const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color:
            const Color(0xFFFFF8ED),
            borderRadius:
            BorderRadius.circular(18),
            border: Border.all(
              color:
              const Color(0xFFF0D8B0),
            ),
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              sectionTitle(
                'Personalized Considerations',
                Icons.person_search_outlined,
              ),

              const SizedBox(height: 14),

              if (concerns.isEmpty)
                const Text(
                  'No additional personalized concerns were identified.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                )
              else
                ...concerns.map(
                      (item) => bulletItem(
                    item.toString(),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // ========================================================
        // UNKNOWN INGREDIENTS
        // ========================================================

        if (unknownIngredients.isNotEmpty)
          Container(
            width: double.infinity,
            padding:
            const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color:
              const Color(0xFFFFF8ED),
              borderRadius:
              BorderRadius.circular(18),
              border: Border.all(
                color:
                const Color(0xFFF0D8B0),
              ),
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                sectionTitle(
                  'Ingredients Not Confidently Identified',
                  Icons.help_outline_rounded,
                ),

                const SizedBox(height: 12),

                const Text(
                  'These entries could not be confidently assessed from the available ingredient knowledge base. They are not automatically considered unsafe.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 14),

                ...unknownIngredients.map(
                      (item) => bulletItem(
                    item.toString(),
                  ),
                ),
              ],
            ),
          ),

        if (unknownIngredients.isNotEmpty)
          const SizedBox(height: 18),

        // ========================================================
        // RECOMMENDATIONS
        // ========================================================

        Container(
          width: double.infinity,
          padding:
          const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color:
            const Color(0xFFF2F8F2),
            borderRadius:
            BorderRadius.circular(18),
            border: Border.all(
              color:
              const Color(0xFFCFE3CF),
            ),
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              sectionTitle(
                'HerBalance Recommendations',
                Icons.lightbulb_outline,
              ),

              const SizedBox(height: 14),

              if (recommendations.isEmpty)
                const Text(
                  'No additional recommendations were generated.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                )
              else
                ...recommendations.map(
                      (item) => bulletItem(
                    item.toString(),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // ========================================================
        // DISCLAIMER
        // ========================================================

        Container(
          width: double.infinity,
          padding:
          const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius:
            BorderRadius.circular(15),
          ),
          child: Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline,
                size: 20,
                color: Colors.black54,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  disclaimer,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 25),
      ],
    );
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFFFFAF8),
      appBar: AppBar(
        title: const Text(
          'Ingredient Checker',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:
        const Color(0xFFFFFAF8),
        elevation: 0,
        iconTheme:
        const IconThemeData(
          color: primaryColor,
        ),
      ),
      body: SingleChildScrollView(
        padding:
        const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            const Text(
              'Check Your Cosmetic',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Upload a photo of the ingredient label and '
                  'HERBALANCE AI will check it based on your current profile.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 25),

            // -------------------------------------------------
            // IMAGE PREVIEW
            // -------------------------------------------------

            Container(
              width: double.infinity,
              height: 260,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(22),
                border: Border.all(
                  color:
                  const Color(0xFFE8D5D2),
                ),
              ),
              child: selectedImage == null
                  ? const Column(
                mainAxisAlignment:
                MainAxisAlignment
                    .center,
                children: [
                  Icon(
                    Icons.image_outlined,
                    size: 65,
                    color: primaryColor,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No ingredient image selected',
                    style: TextStyle(
                      color:
                      Colors.black54,
                    ),
                  ),
                ],
              )
                  : ClipRRect(
                borderRadius:
                BorderRadius.circular(
                  22,
                ),
                child: Image.file(
                  selectedImage!,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // -------------------------------------------------
            // CAMERA + GALLERY
            // -------------------------------------------------

            Row(
              children: [
                Expanded(
                  child:
                  OutlinedButton.icon(
                    onPressed: isAnalyzing
                        ? null
                        : () {
                      pickImage(
                        ImageSource
                            .camera,
                      );
                    },
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                    ),
                    label: const Text(
                      'Take Photo',
                    ),
                    style:
                    OutlinedButton
                        .styleFrom(
                      foregroundColor:
                      primaryColor,
                      side:
                      const BorderSide(
                        color: primaryColor,
                      ),
                      padding:
                      const EdgeInsets
                          .symmetric(
                        vertical: 15,
                      ),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          14,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child:
                  OutlinedButton.icon(
                    onPressed: isAnalyzing
                        ? null
                        : () {
                      pickImage(
                        ImageSource
                            .gallery,
                      );
                    },
                    icon: const Icon(
                      Icons
                          .photo_library_outlined,
                    ),
                    label:
                    const Text('Gallery'),
                    style:
                    OutlinedButton
                        .styleFrom(
                      foregroundColor:
                      primaryColor,
                      side:
                      const BorderSide(
                        color: primaryColor,
                      ),
                      padding:
                      const EdgeInsets
                          .symmetric(
                        vertical: 15,
                      ),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // -------------------------------------------------
            // ANALYZE BUTTON
            // -------------------------------------------------

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isAnalyzing
                    ? null
                    : analyzeProduct,
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  primaryColor,
                  foregroundColor:
                  Colors.white,
                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 17,
                  ),
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      16,
                    ),
                  ),
                ),
                child: isAnalyzing
                    ? const Row(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .center,
                  children: [
                    SizedBox(
                      height: 22,
                      width: 22,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        color:
                        Colors.white,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Analyzing...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight
                            .bold,
                      ),
                    ),
                  ],
                )
                    : const Text(
                  'Analyze Ingredients',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // -------------------------------------------------
            // INFORMATION CARD
            // -------------------------------------------------

            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color:
                const Color(0xFFF8EDEE),
                borderRadius:
                BorderRadius.circular(18),
              ),
              child: const Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: primaryColor,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your latest health profile will be considered '
                          'when analyzing each product.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // -------------------------------------------------
            // AI RESULT
            // -------------------------------------------------

            buildAnalysisResult(),
          ],
        ),
      ),
    );
  }
}
class MedicineAnalyzerPage extends StatefulWidget {
  MedicineAnalyzerPage({super.key});

  @override
  State<MedicineAnalyzerPage> createState() =>
      _MedicineAnalyzerPageState();
}

class _MedicineAnalyzerPageState extends State<MedicineAnalyzerPage> {
  final ImagePicker _picker = ImagePicker();

  File? selectedImage;
  bool isAnalyzing = false;

  Map<String, dynamic>? analysisResult;

  List<String> selectedSymptoms = [];
  bool? hasCurrentProblems;
  bool? takingTreatments;
  final TextEditingController treatmentController =
  TextEditingController();

  static const Color primaryColor = Color(0xFF6B2525);

  // =====================================================
  // PICK IMAGE
  // =====================================================

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        selectedImage = File(image.path);
        analysisResult = null;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to select image: $e'),
        ),
      );
    }
  }

  // =====================================================
  // CURRENT HEALTH CONDITION
  // =====================================================

  Future<bool> askCurrentHealthCondition() async {
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Current Health Condition',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          content: const Text(
            'Are you currently experiencing any health problems or symptoms?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (result == null) {
      return false;
    }

    hasCurrentProblems = result;

    if (result == true) {
      return await askSymptoms();
    }

    return true;
  }

  // =====================================================
  // SYMPTOMS
  // =====================================================

  Future<bool> askSymptoms() async {
    final List<String> symptoms = [
      'Fever',
      'Cough',
      'Cold',
      'Headache',
      'Pain',
      'Breathing difficulty',
      'Wheezing',
      'Stomach problems',
      'Skin problems',
      'Other',
    ];

    List<String> temporarySelected = List.from(selectedSymptoms);

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Current Symptoms',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    children: symptoms.map((symptom) {
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(symptom),
                        value: temporarySelected.contains(symptom),
                        activeColor: primaryColor,
                        onChanged: (value) {
                          setDialogState(() {
                            if (value == true) {
                              temporarySelected.add(symptom);
                            } else {
                              temporarySelected.remove(symptom);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    selectedSymptoms = temporarySelected;
                    Navigator.pop(dialogContext, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Continue'),
                ),
              ],
            );
          },
        );
      },
    );

    return result == true;
  }

  // =====================================================
  // CURRENT MEDICINES / TREATMENTS
  // =====================================================

  Future<bool> askCurrentTreatments() async {
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Current Treatments',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are you currently taking any medicines or undergoing any treatments?',
              ),
              const SizedBox(height: 15),
              TextField(
                controller: treatmentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Enter medicines or treatments (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                takingTreatments = false;
                treatmentController.clear();
                Navigator.pop(dialogContext, true);
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                takingTreatments = true;
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    return result == true;
  }

  // =====================================================
  // ANALYZE MEDICINE
  // =====================================================

  Future<void> analyzeMedicine() async {
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a medicine image first.'),
        ),
      );
      return;
    }

    final healthCompleted = await askCurrentHealthCondition();

    if (!healthCompleted) return;

    final treatmentCompleted = await askCurrentTreatments();

    if (!treatmentCompleted) return;

    setState(() {
      isAnalyzing = true;
      analysisResult = null;
    });

    try {
      final uri = Uri.parse(
        'http://127.0.0.1:8003/analyze-medicine',
      );

      final request = http.MultipartRequest(
        'POST',
        uri,
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          selectedImage!.path,
        ),
      );

      final currentCondition = {
        'current_symptoms': selectedSymptoms,
        'current_treatments': takingTreatments == true
            ? treatmentController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList()
            : [],
      };

      request.fields['current_condition'] =
          jsonEncode(currentCondition);

      final response = await request.send();

      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);

        setState(() {
          analysisResult = data;
        });
      } else {
        throw Exception(
          'Server returned ${response.statusCode}',
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Medicine analysis failed: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isAnalyzing = false;
        });
      }
    }
  }

  // =====================================================
  // RESULT
  // =====================================================

Widget buildAnalysisResult() {
if (analysisResult == null) {
return const SizedBox.shrink();
}

final result = analysisResult!;

final String medicineName =
result['medicine_name']?.toString() ?? 'Unknown';

final String status =
result['overall_status']?.toString() ??
'INSUFFICIENT INFORMATION';

final dynamic scoreValue =
result['compatibility_score'];

final int? compatibilityScore =
scoreValue is num
? scoreValue.round()
: int.tryParse(
scoreValue?.toString() ?? '',
);

final String compatibilityLabel =
result['compatibility_label']?.toString() ??
'Not Available';

final String compatibilityNote =
result['compatibility_note']?.toString() ??
'';

final List<String> recommendations =
result['recommendations'] is List
? List<String>.from(
result['recommendations'],
)
: <String>[];

final List<String> precautions =
result['important_precautions'] is List
? List<String>.from(
result['important_precautions'],
)
: <String>[];

final List<String> concerns =
result['personalized_concerns'] is List
? List<String>.from(
result['personalized_concerns'],
)
: <String>[];

// ---------------------------------------------------------
// SAFETY DISPLAY
// ---------------------------------------------------------

Color safetyColor;
IconData safetyIcon;
String safetyTitle;
String safetyDescription;

switch (status.toUpperCase()) {
case 'NO SPECIFIC SAFETY CONCERN FOUND':
safetyColor = Colors.green;
safetyIcon = Icons.check_circle_rounded;
safetyTitle = 'No Specific Safety Concern Found';
safetyDescription =
'No specific concern was identified from the available medicine information and the information you provided.';
break;

case 'POTENTIAL SAFETY CONCERN':
safetyColor = Colors.orange;
safetyIcon = Icons.warning_rounded;
safetyTitle = 'Potential Safety Concern';
safetyDescription =
'One or more personalized considerations were identified. Review the concerns and consult a doctor or pharmacist before using the medicine.';
break;

default:
safetyColor = Colors.deepOrange;
safetyIcon = Icons.info_rounded;
safetyTitle = 'Unable to Fully Assess';
safetyDescription =
'There was not enough reliable information to make a complete personalized assessment.';
}

return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [

const SizedBox(height: 25),

// =====================================================
// MEDICINE ANALYSIS
// =====================================================

Container(
width: double.infinity,
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(18),
boxShadow: const [
BoxShadow(
color: Colors.black12,
blurRadius: 8,
),
],
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [

const Text(
'Medicine Analysis',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
color: primaryColor,
),
),

const SizedBox(height: 15),

Text(
'Medicine: $medicineName',
style: const TextStyle(
fontSize: 17,
fontWeight: FontWeight.bold,
),
),
],
),
),

const SizedBox(height: 18),

// =====================================================
// SAFETY ASSESSMENT
// =====================================================

Container(
width: double.infinity,
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: safetyColor.withOpacity(0.08),
borderRadius: BorderRadius.circular(18),
border: Border.all(
color: safetyColor.withOpacity(0.35),
width: 1.5,
),
),
child: Column(
children: [

Icon(
safetyIcon,
size: 48,
color: safetyColor,
),

const SizedBox(height: 10),

const Text(
'Safety Assessment',
style: TextStyle(
fontSize: 15,
color: Colors.black54,
fontWeight: FontWeight.w500,
),
),

const SizedBox(height: 6),

Text(
safetyTitle,
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 21,
fontWeight: FontWeight.bold,
color: safetyColor,
),
),

const SizedBox(height: 10),

Text(
safetyDescription,
textAlign: TextAlign.center,
style: const TextStyle(
fontSize: 13,
height: 1.45,
color: Colors.black87,
),
),
],
),
),

const SizedBox(height: 18),

// =====================================================
// PERSONALIZED COMPATIBILITY
// =====================================================

if (compatibilityScore != null)
Container(
width: double.infinity,
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(18),
border: Border.all(
color: const Color(0xFFE8D5D2),
),
),
child: Column(
children: [

const Text(
'Personalized Compatibility',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
color: primaryColor,
),
),

const SizedBox(height: 18),

SizedBox(
width: 110,
height: 110,
child: Stack(
alignment: Alignment.center,
children: [

SizedBox(
width: 110,
height: 110,
child: CircularProgressIndicator(
value:
compatibilityScore / 100,
strokeWidth: 10,
backgroundColor:
Colors.grey.shade200,
valueColor:
AlwaysStoppedAnimation<Color>(
safetyColor,
),
),
),

Text(
'$compatibilityScore',
style: const TextStyle(
fontSize: 27,
fontWeight: FontWeight.bold,
color: primaryColor,
),
),
],
),
),

const SizedBox(height: 15),

Text(
'$compatibilityScore / 100',
style: const TextStyle(
fontSize: 23,
fontWeight: FontWeight.bold,
color: primaryColor,
),
),

const SizedBox(height: 5),

Text(
compatibilityLabel,
style: TextStyle(
fontSize: 15,
fontWeight: FontWeight.w600,
color: safetyColor,
),
),

if (compatibilityNote.isNotEmpty) ...[
const SizedBox(height: 12),

Text(
compatibilityNote,
textAlign: TextAlign.center,
style: const TextStyle(
fontSize: 12,
height: 1.45,
color: Colors.black54,
),
),
],
],
),
),

// =====================================================
// CONCERNS
// =====================================================

if (concerns.isNotEmpty) ...[
const SizedBox(height: 18),

Container(
width: double.infinity,
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: const Color(0xFFFFF8ED),
borderRadius: BorderRadius.circular(18),
border: Border.all(
color: const Color(0xFFF0D8B0),
),
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [

const Text(
'Personalized Concerns',
style: TextStyle(
fontSize: 17,
fontWeight: FontWeight.bold,
color: primaryColor,
),
),

const SizedBox(height: 12),

...concerns.map(
(item) => Padding(
padding:
const EdgeInsets.only(bottom: 8),
child: Text(
'• $item',
style: const TextStyle(
fontSize: 14,
height: 1.4,
),
),
),
),
],
),
),
],

// =====================================================
// PRECAUTIONS
// =====================================================

if (precautions.isNotEmpty) ...[
const SizedBox(height: 18),

Container(
width: double.infinity,
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(18),
border: Border.all(
color: const Color(0xFFE8D5D2),
),
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [

const Text(
'Important Precautions',
style: TextStyle(
fontSize: 17,
fontWeight: FontWeight.bold,
color: primaryColor,
),
),

const SizedBox(height: 12),

...precautions.map(
(item) => Padding(
padding:
const EdgeInsets.only(bottom: 8),
child: Text(
'• $item',
style: const TextStyle(
fontSize: 14,
height: 1.4,
),
),
),
),
],
),
),
],

// =====================================================
// RECOMMENDATIONS
// =====================================================

const SizedBox(height: 18),

Container(
width: double.infinity,
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: const Color(0xFFF2F8F2),
borderRadius: BorderRadius.circular(18),
border: Border.all(
color: const Color(0xFFCFE3CF),
),
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [

const Text(
'HerBalance Recommendations',
style: TextStyle(
fontSize: 17,
fontWeight: FontWeight.bold,
color: primaryColor,
),
),

const SizedBox(height: 12),

if (recommendations.isEmpty)
const Text(
'No additional recommendations were generated.',
style: TextStyle(
fontSize: 14,
color: Colors.black54,
),
)
else
...recommendations.map(
(item) => Padding(
padding:
const EdgeInsets.only(bottom: 8),
child: Text(
'• $item',
style: const TextStyle(
fontSize: 14,
height: 1.4,
),
),
),
),
],
),
),

const SizedBox(height: 18),

// =====================================================
// DISCLAIMER
// =====================================================

Container(
width: double.infinity,
padding: const EdgeInsets.all(15),
decoration: BoxDecoration(
color: Colors.grey.shade100,
borderRadius: BorderRadius.circular(15),
),
child: const Text(
'This is an AI-assisted medicine screening tool. '
'The compatibility score is not a percentage of safety '
'and does not guarantee that a medicine is safe for you. '
'Do not start, stop, or change a medicine based only on '
'this analysis. Consult a doctor or pharmacist.',
style: TextStyle(
fontSize: 12,
height: 1.4,
color: Colors.black54,
),
),
),

const SizedBox(height: 25),
],
);
}
  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF8),

      appBar: AppBar(
        title: const Text(
          'Medicine Checker',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFFFFAF8),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: primaryColor,
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(
              'Check Your Medicine',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Upload a photo of the medicine label and '
                  'HERBALANCE AI will screen it using available '
                  'medicine information and your current condition.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 25),

            // =================================================
            // IMAGE PREVIEW
            // =================================================

            Container(
              width: double.infinity,
              height: 260,

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFFE8D5D2),
                ),
              ),

              child: selectedImage == null

                  ? const Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [

                  Icon(
                    Icons.medication_outlined,
                    size: 65,
                    color: primaryColor,
                  ),

                  SizedBox(height: 12),

                  Text(
                    'No medicine image selected',
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),

                ],
              )

                  : ClipRRect(
                borderRadius:
                BorderRadius.circular(22),

                child: Image.file(
                  selectedImage!,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =================================================
            // CAMERA + GALLERY
            // =================================================

            Row(
              children: [

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isAnalyzing
                        ? null
                        : () {
                      pickImage(
                        ImageSource.camera,
                      );
                    },

                    icon: const Icon(
                      Icons.camera_alt_outlined,
                    ),

                    label: const Text(
                      'Take Photo',
                    ),

                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,

                      side: const BorderSide(
                        color: primaryColor,
                      ),

                      padding:
                      const EdgeInsets.symmetric(
                        vertical: 15,
                      ),

                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isAnalyzing
                        ? null
                        : () {
                      pickImage(
                        ImageSource.gallery,
                      );
                    },

                    icon: const Icon(
                      Icons.photo_library_outlined,
                    ),

                    label: const Text(
                      'Gallery',
                    ),

                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,

                      side: const BorderSide(
                        color: primaryColor,
                      ),

                      padding:
                      const EdgeInsets.symmetric(
                        vertical: 15,
                      ),

                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // =================================================
            // ANALYZE BUTTON
            // =================================================

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: isAnalyzing
                    ? null
                    : analyzeMedicine,

                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,

                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 17,
                  ),

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(16),
                  ),
                ),

                child: isAnalyzing

                    ? const Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children: [

                    SizedBox(
                      height: 22,
                      width: 22,

                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(width: 12),

                    Text(
                      'Analyzing...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                  ],
                )

                    : const Text(
                  'Analyze Medicine',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // =================================================
            // INFORMATION CARD
            // =================================================

            Container(
              width: double.infinity,

              padding:
              const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: const Color(0xFFF8EDEE),
                borderRadius:
                BorderRadius.circular(18),
              ),

              child: const Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Icon(
                    Icons.info_outline,
                    color: primaryColor,
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      'HERBALANCE AI considers the medicine '
                          'information available from trusted sources '
                          'together with the current symptoms and '
                          'treatments you provide.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),

                ],
              ),
            ),

            // =================================================
            // RESULT
            // =================================================

            buildAnalysisResult(),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  void dispose() {
    treatmentController.dispose();
    super.dispose();
  }
}
// your other classes above
class PeriodTrackerPage extends StatefulWidget {
  const PeriodTrackerPage({super.key});

  @override
  State<PeriodTrackerPage> createState() => _PeriodTrackerPageState();
}

class _PeriodTrackerPageState extends State<PeriodTrackerPage> {
  DateTime? lastPeriodDate;

  int cycleLength = 28;
  int periodLength = 5;

  DateTime? nextPeriodDate;
  int? cycleDay;
  String currentPhase = '';

  // ---------------------------------------------------------
  // PHASE INFORMATION
  // ---------------------------------------------------------

  Map<String, dynamic> getPhaseInfo() {
    switch (currentPhase) {
      case 'Menstrual Phase':
        return {
          'emoji': '🩸',
          'title': 'Menstrual Phase',
          'subtitle': 'Your period is here',
          'description':
          'This is the beginning of your cycle. Your body is shedding the uterine lining.',
          'speciality':
          'Energy may be lower during this phase, so gentle movement and enough rest can be helpful.',
          'tips': [
            'Stay hydrated',
            'Choose iron-rich and nourishing foods',
            'Gentle walking or stretching may feel comfortable',
            'Listen to your body and rest when needed',
          ],
        };

      case 'Follicular Phase':
        return {
          'emoji': '🌱',
          'title': 'Follicular Phase',
          'subtitle': 'Your energy may begin to rise',
          'description':
          'After your period, follicles in the ovaries develop and the body prepares for ovulation.',
          'speciality':
          'Many people notice increasing energy, motivation and a fresher feeling during this phase.',
          'tips': [
            'Gradually increase physical activity',
            'Focus on balanced meals',
            'Include protein, vegetables and whole grains',
            'Use your increasing energy for activities you enjoy',
          ],
        };

      case 'Ovulation Phase':
        return {
          'emoji': '🌸',
          'title': 'Ovulation Phase',
          'subtitle': 'Around the middle of your cycle',
          'description':
          'Ovulation is when an egg is released from an ovary. The timing can vary between cycles.',
          'speciality':
          'Some people notice increased energy, changes in cervical mucus or mild abdominal sensations.',
          'tips': [
            'Stay hydrated',
            'Continue balanced nutrition',
            'Keep track of any changes you notice',
            'Remember that app predictions are estimates',
          ],
        };

      default:
        return {
          'emoji': '🌙',
          'title': 'Luteal Phase',
          'subtitle': 'Your body prepares for the next period',
          'description':
          'After ovulation, the body enters the luteal phase and prepares for the possibility of pregnancy.',
          'speciality':
          'Some people experience PMS-related changes such as bloating, mood changes, breast tenderness or fatigue.',
          'tips': [
            'Prioritize sleep and rest',
            'Stay hydrated',
            'Choose regular balanced meals',
            'Gentle exercise may help you feel better',
          ],
        };
    }
  }

  // ---------------------------------------------------------
  // DATE PICKER
  // ---------------------------------------------------------

  Future<void> selectLastPeriodDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        lastPeriodDate = picked;
        calculateCycle();
      });
    }
  }

  // ---------------------------------------------------------
  // CALCULATE CYCLE
  // ---------------------------------------------------------

  void calculateCycle() {
    if (lastPeriodDate == null) return;

    final today = DateTime.now();

    final difference =
        DateTime(today.year, today.month, today.day)
            .difference(
          DateTime(
            lastPeriodDate!.year,
            lastPeriodDate!.month,
            lastPeriodDate!.day,
          ),
        )
            .inDays;

    int calculatedDay = difference + 1;

    if (calculatedDay < 1) {
      calculatedDay = 1;
    }

    final nextPeriod =
    lastPeriodDate!.add(Duration(days: cycleLength));

    String phase;

    if (calculatedDay <= periodLength) {
      phase = 'Menstrual Phase';
    } else {
      final ovulationDay = cycleLength - 14;

      if (calculatedDay < ovulationDay) {
        phase = 'Follicular Phase';
      } else if (calculatedDay <= ovulationDay + 1) {
        phase = 'Ovulation Phase';
      } else {
        phase = 'Luteal Phase';
      }
    }

    setState(() {
      cycleDay = calculatedDay;
      nextPeriodDate = nextPeriod;
      currentPhase = phase;
    });
  }

  // ---------------------------------------------------------
  // DATE FORMAT
  // ---------------------------------------------------------

  String formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  int daysUntilNextPeriod() {
    if (nextPeriodDate == null) return 0;

    final today = DateTime.now();

    return nextPeriodDate!
        .difference(
      DateTime(today.year, today.month, today.day),
    )
        .inDays;
  }

  // ---------------------------------------------------------
  // PHASE COLORS
  // ---------------------------------------------------------

  Color getPhaseColor() {
    switch (currentPhase) {
      case 'Menstrual Phase':
        return const Color(0xFFB84C65);

      case 'Follicular Phase':
        return const Color(0xFF7BAE7F);

      case 'Ovulation Phase':
        return const Color(0xFFE69A54);

      default:
        return const Color(0xFF8667A9);
    }
  }

  // ---------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final phase = getPhaseInfo();
    final phaseColor = getPhaseColor();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF8),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFAF8),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Period Tracker',
          style: TextStyle(
            color: Color(0xFF6B2525),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // -------------------------------------------------
            // INTRO
            // -------------------------------------------------

            const Text(
              'Understand your cycle 🌸',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4B2525),
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'Track your cycle, understand your current phase, '
                  'and get an estimated next period date.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 22),

            // -------------------------------------------------
            // DATE INPUT
            // -------------------------------------------------

            GestureDetector(
              onTap: selectLastPeriodDate,

              child: Container(
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFF0DADA),
                  ),
                ),

                child: Row(
                  children: [

                    Container(
                      padding: const EdgeInsets.all(12),

                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE5E8),
                        borderRadius:
                        BorderRadius.circular(14),
                      ),

                      child: const Icon(
                        Icons.calendar_month,
                        color: Color(0xFF9B3F4F),
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [

                          const Text(
                            'Last period started',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            lastPeriodDate == null
                                ? 'Tap to select date'
                                : formatDate(
                              lastPeriodDate!,
                            ),

                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // -------------------------------------------------
            // SETTINGS
            // -------------------------------------------------

            Row(
              children: [

                Expanded(
                  child: _smallSettingCard(
                    title: 'Cycle',
                    value: '$cycleLength days',
                    icon: Icons.loop,
                    onTap: () {
                      _showCycleLengthPicker();
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _smallSettingCard(
                    title: 'Period',
                    value: '$periodLength days',
                    icon: Icons.water_drop_outlined,
                    onTap: () {
                      _showPeriodLengthPicker();
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // -------------------------------------------------
            // CURRENT PHASE HERO
            // -------------------------------------------------

            if (currentPhase.isNotEmpty)

              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(23),

                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      phaseColor.withOpacity(0.95),
                      phaseColor.withOpacity(0.72),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),

                  borderRadius: BorderRadius.circular(26),

                  boxShadow: [
                    BoxShadow(
                      color: phaseColor.withOpacity(0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                      children: [

                        const Text(
                          'CURRENT PHASE',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),

                        Text(
                          phase['emoji'],
                          style: const TextStyle(
                            fontSize: 30,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'You are in your',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      phase['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      phase['subtitle'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 22),

                    Row(
                      children: [

                        _heroStat(
                          'Cycle Day',
                          '$cycleDay',
                        ),

                        const SizedBox(width: 35),

                        _heroStat(
                          'Cycle Length',
                          '$cycleLength days',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // -------------------------------------------------
            // NO DATE MESSAGE
            // -------------------------------------------------

            if (currentPhase.isEmpty)

              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(25),

                decoration: BoxDecoration(
                  color: const Color(0xFFFFE5E8),
                  borderRadius: BorderRadius.circular(24),
                ),

                child: const Column(
                  children: [

                    Text(
                      '🌸',
                      style: TextStyle(fontSize: 45),
                    ),

                    SizedBox(height: 12),

                    Text(
                      'Let’s find your current phase',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B2525),
                      ),
                    ),

                    SizedBox(height: 7),

                    Text(
                      'Select the date your last period started '
                          'to calculate your current cycle.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

            if (currentPhase.isNotEmpty) ...[

              const SizedBox(height: 20),

              // -------------------------------------------------
              // PHASE SPECIALITY
              // -------------------------------------------------

              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(21),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: phaseColor.withOpacity(0.18),
                  ),
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Text(
                      '${phase['emoji']}  About this phase',

                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4B2525),
                      ),
                    ),

                    const SizedBox(height: 13),

                    Text(
                      phase['description'],

                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Container(
                      padding: const EdgeInsets.all(14),

                      decoration: BoxDecoration(
                        color:
                        phaseColor.withOpacity(0.08),
                        borderRadius:
                        BorderRadius.circular(14),
                      ),

                      child: Text(
                        phase['speciality'],

                        style: TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          color: phaseColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // -------------------------------------------------
              // WHAT YOU CAN DO
              // -------------------------------------------------

              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(21),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    const Text(
                      '✨ Helpful for this phase',

                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4B2525),
                      ),
                    ),

                    const SizedBox(height: 14),

                    ...List.generate(
                      (phase['tips'] as List).length,
                          (index) {

                        return Padding(
                          padding:
                          const EdgeInsets.only(
                            bottom: 12,
                          ),

                          child: Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children: [

                              Container(
                                width: 8,
                                height: 8,

                                margin:
                                const EdgeInsets.only(
                                  top: 6,
                                ),

                                decoration:
                                BoxDecoration(
                                  color: phaseColor,
                                  shape: BoxShape.circle,
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Text(
                                  phase['tips'][index],

                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // -------------------------------------------------
              // NEXT PERIOD
              // -------------------------------------------------

              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(21),

                decoration: BoxDecoration(
                  color: const Color(0xFF6B2525),
                  borderRadius: BorderRadius.circular(22),
                ),

                child: Row(
                  children: [

                    Container(
                      padding: const EdgeInsets.all(13),

                      decoration: BoxDecoration(
                        color: Colors.white
                            .withOpacity(0.12),
                        borderRadius:
                        BorderRadius.circular(14),
                      ),

                      child: const Icon(
                        Icons.event_available,
                        color: Colors.white,
                        size: 27,
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [

                          const Text(
                            'Estimated next period',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            formatDate(nextPeriodDate!),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            daysUntilNextPeriod() > 0
                                ? '${daysUntilNextPeriod()} days to go'
                                : daysUntilNextPeriod() == 0
                                ? 'Expected today'
                                : 'Your period may be late',

                            style: TextStyle(
                              color:
                              daysUntilNextPeriod() < 0
                                  ? Colors.white
                                  : Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Predictions are estimates and your cycle can naturally vary from month to month.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black45,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // SMALL SETTING CARD
  // ---------------------------------------------------------

  Widget _smallSettingCard({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(15),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: Colors.black.withOpacity(0.06),
          ),
        ),

        child: Row(
          children: [

            Icon(
              icon,
              size: 21,
              color: const Color(0xFF6B2525),
            ),

            const SizedBox(width: 9),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // HERO STAT
  // ---------------------------------------------------------

  Widget _heroStat(
      String title,
      String value,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------
  // CYCLE LENGTH PICKER
  // ---------------------------------------------------------

  void _showCycleLengthPicker() {
    showModalBottomSheet(
      context: context,

      builder: (context) {
        return SafeArea(
          child: ListView.builder(
            itemCount: 21,

            itemBuilder: (context, index) {

              final days = index + 21;

              return ListTile(
                title: Text('$days days'),

                trailing: cycleLength == days
                    ? const Icon(
                  Icons.check,
                  color: Color(0xFF6B2525),
                )
                    : null,

                onTap: () {
                  setState(() {
                    cycleLength = days;
                  });

                  Navigator.pop(context);

                  if (lastPeriodDate != null) {
                    calculateCycle();
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------
  // PERIOD LENGTH PICKER
  // ---------------------------------------------------------

  void _showPeriodLengthPicker() {
    showModalBottomSheet(
      context: context,

      builder: (context) {
        return SafeArea(
          child: ListView.builder(
            itemCount: 8,

            itemBuilder: (context, index) {

              final days = index + 2;

              return ListTile(
                title: Text('$days days'),

                trailing: periodLength == days
                    ? const Icon(
                  Icons.check,
                  color: Color(0xFF6B2525),
                )
                    : null,

                onTap: () {
                  setState(() {
                    periodLength = days;
                  });

                  Navigator.pop(context);

                  if (lastPeriodDate != null) {
                    calculateCycle();
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}