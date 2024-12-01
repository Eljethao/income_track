import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:income_track/config/config.dart';
import 'package:go_router/go_router.dart';

class AuthState {
  final bool isLoading;
  final bool isPasswordVisible;
  final String? errorMessage;
  final Map<String, dynamic>? userData;

  AuthState({
    this.isLoading = false,
    this.isPasswordVisible = false,
    this.errorMessage,
    this.userData,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isPasswordVisible,
    String? errorMessage,
    Map<String, dynamic>? userData,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      errorMessage: errorMessage,
      userData: userData,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
    return AuthNotifier(ref);
  });

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref; // Add Ref to interact with other providers

  AuthNotifier(this.ref) : super(AuthState());

  

  Future<void> login(
      String phone, String password, BuildContext context) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final String url = "$ENDPOINT_URL/v1/api/users/login";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"phone": phone, "password": password}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Save user data to the UserDataNotifier
        ref
            .read(userDataProvider.notifier)
            .loadUserData(json.encode(responseData));

        state = state.copyWith(isLoading: false, userData: responseData);
        context.go('/home'); // Navigate to home
      } else {
        final responseData = json.decode(response.body);
        state = state.copyWith(
          isLoading: false,
          errorMessage: responseData['message'] ?? 'Login failed.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An error occurred. Please try again.',
      );
    }
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }
}

final userDataProvider =
    StateNotifierProvider<UserDataNotifier, Map<String, dynamic>>((ref) {
  return UserDataNotifier();
});

class UserDataNotifier extends StateNotifier<Map<String, dynamic>> {
  UserDataNotifier() : super({});

  // Load user data (simulating fetching from a local source like SharedPreferences or API)
  Future<void> loadUserData(String userDataJson) async {
    try {
      print("userDataJson: $userDataJson");
      state = json.decode(userDataJson);
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  // Clear user data (for logout or other purposes)
  void clearUserData() {
    state = {};
  }
}
