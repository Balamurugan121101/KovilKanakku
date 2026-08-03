import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../models/user_model.dart';
import '../../../repositories/user_repository.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final UserRepository _userRepository = UserRepository();
  UserModel? userModel;
  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    _loadUser();
  }


  Future<void> _loadUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      return;
    }

    final user = await _userRepository.getUser(
      firebaseUser.uid,
    );

    if (mounted) {
      setState(() {
        userModel = user;
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      context.go(AppRoutes.login);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Kovil Kanakku",
        ),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(
              Icons.logout,
            ),
          )
        ],
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            _welcomeCard(),
            const SizedBox(height: 20),
            const Text(
              "Overview",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    title: "Today's Donation",
                    value: "₹ 0",
                    icon: Icons.currency_rupee,
                  ),
                ),
                Expanded(
                  child: _summaryCard(
                    title: "Today's Expense",
                    value: "₹ 0",
                    icon: Icons.money_off,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    title: "Total Donation",
                    value: "₹ 0",
                    icon:
                    Icons.volunteer_activism,
                  ),
                ),
                Expanded(
                  child: _summaryCard(
                    title: "Total Expense",
                    value: "₹ 0",
                    icon:
                    Icons.receipt_long,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              "Management",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _menuCard(
              title: "Donations",
              subtitle:
              "Manage temple donations",
              icon:
              Icons.volunteer_activism,
              onTap: () {
                context.push(
                  '/donations',
                );
              },
            ),
            _menuCard(
              title: "Expenses",
              subtitle:
              "Track temple expenses",
              icon:
              Icons.money_off,
              onTap: () {},
            ),
            _menuCard(
              title: "Events",
              subtitle:
              "Manage temple events",
              icon:
              Icons.event,
              onTap: () {},
            ),
            _menuCard(
              title: "Reports",
              subtitle:
              "View financial reports",
              icon:
              Icons.bar_chart,
              onTap: () {},
            ),
            _menuCard(
              title: "Settings",
              subtitle:
              "Temple configuration",
              icon:
              Icons.settings,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _welcomeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              child: Icon(
                Icons.temple_hindu,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome",
                ),
                Text(
                  userModel?.name ??
                      "Admin",
                  style:
                  const TextStyle(
                    fontSize: 20,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
                Text(
                  userModel?.role ??
                      "",
                  style:
                  const TextStyle(
                    color:
                    Colors.grey,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding:
        const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              value,
              style:
              const TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              title,
              textAlign:
              TextAlign.center,
              style:
              const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading:
        CircleAvatar(
          child:
          Icon(icon),
        ),
        title:
        Text(
          title,
          style:
          const TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),
        subtitle:
        Text(subtitle),
        trailing:
        const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
      ),
    );
  }
}