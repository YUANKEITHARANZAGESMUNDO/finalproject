import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController fullNameController = TextEditingController(
    text: ' ',
  );
  final TextEditingController emailController = TextEditingController(
    text: ' ',
  );
  final TextEditingController phoneController = TextEditingController(
    text: ' ',
  );
  final TextEditingController passwordController = TextEditingController(
    text: ' ',
  );

  bool isEditingFullName = false;
  bool isEditingEmail = false;
  bool isEditingPhone = false;
  bool isEditingPassword = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;
    final appBarTextColor = isDark ? Colors.white : Colors.black;
    final iconColor = isDark ? Colors.white : Colors.black;
    final dividerColor = isDark ? Colors.grey[800]! : const Color(0xFFF0F0F0);
    final labelColor = isDark ? Colors.white70 : Colors.black54;
    final textColor = isDark ? Colors.white : Colors.black;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 14, 18, 61),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Anchor',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              TextSpan(
                text: 'Point',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                isEditingFullName = false;
                isEditingEmail = false;
                isEditingPhone = false;
                isEditingPassword = false;
              });
              Navigator.pop(context);
            },
            child: Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
        centerTitle: false,
      ),
      backgroundColor: bgColor,
      body: Stack(
        children: [
          Opacity(
            opacity: 0.5,
            child: SizedBox.expand(
              child: Image.asset('images/ap.png', fit: BoxFit.cover),
            ),
          ),
          ListView(
            children: [
              const SizedBox(height: 24),
              _EditableProfileTile(
                label: 'Full Name',
                controller: fullNameController,
                isEditing: isEditingFullName,
                onTap: () {
                  setState(() {
                    isEditingFullName = true;
                  });
                },
                onSubmitted: (_) {
                  setState(() {
                    isEditingFullName = false;
                  });
                },
                isPassword: false,
                isDark: isDark,
              ),
              _divider(isDark),
              _EditableProfileTile(
                label: 'Email',
                controller: emailController,
                isEditing: isEditingEmail,
                onTap: () {
                  setState(() {
                    isEditingEmail = true;
                  });
                },
                onSubmitted: (_) {
                  setState(() {
                    isEditingEmail = false;
                  });
                },
                isPassword: false,
                isDark: isDark,
              ),
              _divider(isDark),
              _EditableProfileTile(
                label: 'Phone Number',
                controller: phoneController,
                isEditing: isEditingPhone,
                onTap: () {
                  setState(() {
                    isEditingPhone = true;
                  });
                },
                onSubmitted: (_) {
                  setState(() {
                    isEditingPhone = false;
                  });
                },
                isPassword: false,
                isDark: isDark,
              ),
              _divider(isDark),
              _EditableProfileTile(
                label: 'Password',
                controller: passwordController,
                isEditing: isEditingPassword,
                onTap: () {
                  setState(() {
                    isEditingPassword = true;
                  });
                },
                onSubmitted: (_) {
                  setState(() {
                    isEditingPassword = false;
                  });
                },
                isPassword: true,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider(bool isDark) => Divider(
    height: 1,
    thickness: 1,
    color: isDark ? Colors.grey[800]! : const Color(0xFFF0F0F0),
  );
}

class _EditableProfileTile extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isEditing;
  final VoidCallback onTap;
  final ValueChanged<String> onSubmitted;
  final bool isPassword;
  final bool isDark;

  const _EditableProfileTile({
    required this.label,
    required this.controller,
    required this.isEditing,
    required this.onTap,
    required this.onSubmitted,
    required this.isPassword,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor = isDark ? Colors.white70 : Colors.black54;
    final textColor = isDark ? Colors.white : Colors.black;
    final iconColor = isDark ? Colors.white : Colors.black;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      title: Text(
        label,
        style: TextStyle(
          color: labelColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
        ),
      ),
      subtitle: isEditing
          ? TextField(
              controller: controller,
              autofocus: true,
              obscureText: isPassword,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onSubmitted: onSubmitted,
              textInputAction: TextInputAction.done,
            )
          : GestureDetector(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.only(top: 2.0, bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        controller.text,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: iconColor, size: 22),
                  ],
                ),
              ),
            ),
    );
  }
}
