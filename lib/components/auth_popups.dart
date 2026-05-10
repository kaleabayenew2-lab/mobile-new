import 'package:flutter/material.dart';
import '../pages/auth/login.dart';
import '../pages/auth/register.dart';
import '../pages/auth/reset_password.dart';
import 'popup_model.dart';

/// Authentication popup wrapper class that provides reusable popup methods
class AuthPopups {
  /// Shows the login popup
  static Future<void> showLoginPopup(BuildContext context) async {
    await PopupModel.showCustomPopup(
      context: context,
      content: const LoginPage(),
      maxWidth: 400,
      maxHeight: MediaQuery.of(context).size.height * 0.8,
      barrierColor: Colors.transparent,
    );
  }

  /// Shows the register popup
  static Future<void> showRegisterPopup(BuildContext context) async {
    await PopupModel.showCustomPopup(
      context: context,
      content: const RegisterPage(),
      maxWidth: 500,
      maxHeight: MediaQuery.of(context).size.height * 0.9,
      barrierColor: Colors.transparent,
    );
  }

  /// Shows the reset password popup
  static Future<void> showResetPasswordPopup(BuildContext context) async {
    await PopupModel.showCustomPopup(
      context: context,
      content: const ResetPasswordPage(),
      maxWidth: 400,
      maxHeight: MediaQuery.of(context).size.height * 0.8,
    );
  }

  /// Shows login popup with navigation callback
  static Future<void> showLoginPopupWithNavigation(
    BuildContext context, {
    VoidCallback? onLoginSuccess,
    VoidCallback? onPopupClosed,
  }) async {
    await PopupModel.showCustomPopup(
      context: context,
      content: LoginPage(
        onLoginSuccess: onLoginSuccess,
      ),
      maxWidth: 400,
      maxHeight: MediaQuery.of(context).size.height * 0.8,
      barrierColor: Colors.transparent,
    );
    
    onPopupClosed?.call();
  }

  /// Shows register popup with navigation callback
  static Future<void> showRegisterPopupWithNavigation(
    BuildContext context, {
    VoidCallback? onRegisterSuccess,
    VoidCallback? onPopupClosed,
  }) async {
    await PopupModel.showCustomPopup(
      context: context,
      content: RegisterPage(
        onRegisterSuccess: onRegisterSuccess,
      ),
      maxWidth: 500,
      maxHeight: MediaQuery.of(context).size.height * 0.9,
    );
    
    onPopupClosed?.call();
  }

  /// Shows reset password popup with navigation callback
  static Future<void> showResetPasswordPopupWithNavigation(
    BuildContext context, {
    VoidCallback? onPasswordResetSuccess,
    VoidCallback? onPopupClosed,
  }) async {
    await PopupModel.showCustomPopup(
      context: context,
      content: ResetPasswordPage(
        onPasswordResetSuccess: onPasswordResetSuccess,
      ),
      maxWidth: 400,
      maxHeight: MediaQuery.of(context).size.height * 0.8,
      barrierColor: Colors.transparent,
    );
    
    onPopupClosed?.call();
  }

  /// Shows authentication choice popup (Login/Register)
  static Future<String?> showAuthChoicePopup(BuildContext context) async {
    return await showDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Welcome',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      color: Colors.grey[600],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Message
                Text(
                  'Choose an option to continue:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Buttons
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop('login'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop('register'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Colors.blue, width: 1),
                          ),
                        ),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Shows a generic authentication error popup
  static Future<void> showAuthErrorPopup(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    await PopupModel.showInfoPopup(
      context: context,
      title: title,
      message: message,
      icon: Icons.error,
      iconColor: Colors.red,
    );
  }

  /// Shows a generic authentication success popup
  static Future<void> showAuthSuccessPopup(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    await PopupModel.showInfoPopup(
      context: context,
      title: title,
      message: message,
      icon: Icons.check_circle,
      iconColor: Colors.green,
    );
  }
}
