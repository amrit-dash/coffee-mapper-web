import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_mapper_web/providers/admin_provider.dart';
import 'package:coffee_mapper_web/utils/responsive_utils.dart';
import 'package:coffee_mapper_web/widgets/layout/header.dart';
import 'package:coffee_mapper_web/widgets/layout/side_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final Widget returnScreen;

  const LoginScreen({
    super.key,
    required this.returnScreen,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _invalidPassword = false;
  bool _invalidEmail = false;
  String? _loginErrorMessage;

  Future<void> _signInWithEmailAndPassword() async {
    setState(() {
      _isLoading = true;
      _invalidEmail = false;
      _invalidPassword = false;
    });

    try {
      // First attempt to sign in
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Check if user is admin
      final adminDoc = await _firestore
          .collection('admins')
          .doc(userCredential.user?.email)
          .get();

      if (!adminDoc.exists) {
        // If not admin, sign out and show error
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  const Text(
                      'Access denied. You do not have admin privileges.'),
                ],
              ),
            ),
          );
          // Navigate back to original screen after showing error
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => widget.returnScreen),
          );
        }
        return;
      }

      // Set admin data in provider
      ref
          .read(adminProvider.notifier)
          .checkAdminStatus(userCredential.user?.email);

      if (mounted) {
        // Show success message before navigation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline,
                    color: Colors.white, size: 16),
                const SizedBox(width: 8),
                const Text('Successfully logged in as admin'),
              ],
            ),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => widget.returnScreen),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'Invalid email format.';
          _invalidEmail = true;
          _loginErrorMessage = errorMessage;
          break;
        case 'user-disabled':
          errorMessage = 'User account disabled.';
          break;
        case 'user-not-found':
          errorMessage = 'User not found.';
          break;
        case 'invalid-credential':
          errorMessage = 'Incorrect password.';
          _invalidPassword = true;
          _loginErrorMessage = errorMessage;
          break;
        default:
          errorMessage = 'Login failed. Please try again.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(errorMessage),
              ],
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isMobileView = ResponsiveUtils.isMobile(screenWidth);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).cardColor,
      body: SafeArea(
        child: Column(
          children: [
            const Header(),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMobileView) const SideMenu(isLoginScreen: true),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth:
                              screenWidth < 600 ? screenWidth * 0.95 : 500,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  ResponsiveUtils.getPadding(screenWidth)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                  height:
                                      ResponsiveUtils.getPadding(screenHeight) *
                                          5),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: ResponsiveUtils.getPadding(
                                              screenWidth) *
                                          0.5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Log in to continue',
                                        style: TextStyle(
                                          fontFamily: 'Gilroy-SemiBold',
                                          fontSize: ResponsiveUtils.getFontSize(
                                              screenWidth, 22),
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.07),
                                      _buildEmailTextField(context),
                                      SizedBox(height: screenHeight * 0.025),
                                      _buildPasswordTextField(context),
                                      SizedBox(height: screenHeight * 0.02),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () async {
                                            final email = _emailController.text;

                                            if (email.isEmpty) {
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Please enter your email address')),
                                              );
                                              _emailController.selection =
                                                  TextSelection.fromPosition(
                                                TextPosition(
                                                    offset: _emailController
                                                        .text.length),
                                              );
                                              return;
                                            }

                                            try {
                                              await FirebaseAuth.instance
                                                  .sendPasswordResetEmail(
                                                      email: email);
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Password reset email sent!')),
                                              );
                                            } on FirebaseAuthException catch (e) {
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(e.message ??
                                                      'Failed to send reset email'),
                                                ),
                                              );
                                            }
                                          },
                                          child: Text(
                                            'Forgot Password?',
                                            style: TextStyle(
                                              fontFamily: 'Gilroy-Medium',
                                              fontSize:
                                                  ResponsiveUtils.getFontSize(
                                                      screenWidth, 12),
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              _buildLoginButton(context),
                              SizedBox(height: screenHeight * 0.07),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildEmailTextField(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(screenWidth, 16),
          ),
          decoration: InputDecoration(
            hintText: 'Enter Email',
            hintStyle: TextStyle(
              fontFamily: 'Gilroy-Medium',
              fontSize: ResponsiveUtils.getFontSize(screenWidth, 16),
              color: Theme.of(context).colorScheme.secondary,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.error),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.error),
            ),
            errorStyle: TextStyle(
              fontFamily: 'Gilroy-Medium',
              fontSize: ResponsiveUtils.getFontSize(screenWidth, 12),
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            if (value == null || value.isEmpty) {
              _invalidEmail = false;
              return 'Please enter an email!';
            }
            if (_invalidEmail) {
              return _loginErrorMessage;
            }
            return null;
          },
        ),
        Positioned(
          right: 13,
          top: 15,
          child: Icon(
            Icons.email_outlined,
            size: ResponsiveUtils.getFontSize(screenWidth, 20),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTextField(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        TextFormField(
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(screenWidth, 16),
            color: (_obscurePassword)
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.secondary,
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: 'Enter Password',
            hintStyle: TextStyle(
              fontFamily: 'Gilroy-Medium',
              fontSize: ResponsiveUtils.getFontSize(screenWidth, 16),
              color: Theme.of(context).colorScheme.secondary,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.error),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.error),
            ),
            errorStyle: TextStyle(
              fontFamily: 'Gilroy-Medium',
              fontSize: ResponsiveUtils.getFontSize(screenWidth, 12),
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              _invalidPassword = false;
              return 'Please enter a password!';
            }
            if (_invalidPassword) {
              return _loginErrorMessage;
            }
            return null;
          },
        ),
        Positioned(
          right: 0,
          top: 0,
          child: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Theme.of(context).colorScheme.error,
              size: ResponsiveUtils.getFontSize(screenWidth, 20),
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      height: screenHeight * 0.15,
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getPadding(screenWidth),
        vertical: ResponsiveUtils.getPadding(screenWidth) * 0.8,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 0,
        ),
        onPressed: _signInWithEmailAndPassword,
        child: _isLoading
            ? SizedBox(
                height: ResponsiveUtils.getFontSize(screenWidth, 20),
                width: ResponsiveUtils.getFontSize(screenWidth, 20),
                child: CircularProgressIndicator(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Let\'s Begin!',
                style: TextStyle(
                  fontFamily: 'Gilroy-Medium',
                  fontSize: ResponsiveUtils.getFontSize(screenWidth, 19),
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
      ),
    );
  }
}
