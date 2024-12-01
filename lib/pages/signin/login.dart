
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:income_track/providers/auth_provider.dart';

class Login extends ConsumerWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              const Text(
                'ວາງແຜນການເງີນ',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'ວາງແຜນການເງີນເພື່ອອະນາຄົດທີ່ດີຂຶ້ນ',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  labelText: 'ເບີໂທ',
                ),
              ),
               SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: !authState.isPasswordVisible,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  labelText: 'ລະຫັດຜ່ານ',
                  suffix: GestureDetector(
                    onTap: () {
                      ref
                          .read(authProvider.notifier)
                          .togglePasswordVisibility();
                    },
                    child: authState.isPasswordVisible
                        ? const Icon(Icons.visibility)
                        : const Icon(Icons.visibility_off),
                  ),
                ),
              ),
              const SizedBox(height: 42),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.deepPurple.shade200),
                  onPressed: () {
                    ref.read(authProvider.notifier).login(
                          _emailController.text,
                          _passwordController.text,
                          context,
                        );
                  },
                  child: authState.isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'ເຂົ້າສູ່ລະບົບ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              if (authState.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  authState.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('ຍັງບໍມີບັນຊີ?'),
                  TextButton(
                    child: Text(
                      'ລົງທະບຽນ',
                      style: TextStyle(
                        color: Colors.deepPurple.shade600,
                      ),
                    ),
                    onPressed: () {
                      context.go('/register');
                    },
                  )
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
