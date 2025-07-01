import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:martfury/src/model/login_request.dart';
import 'package:martfury/src/service/auth_service.dart';
import 'package:martfury/src/service/token_service.dart';
import 'package:martfury/core/app_config.dart';
import 'package:martfury/src/theme/app_fonts.dart';
import 'package:martfury/src/theme/app_colors.dart';
import 'package:martfury/src/view/screen/sign_up_screen.dart';
import 'package:martfury/src/view/screen/forgot_password_screen.dart';
import 'package:martfury/src/view/screen/main_screen.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:twitter_login/twitter_login.dart';
import 'package:easy_localization/easy_localization.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSocialLoading = false;
  String? _socialSignInProvider;

  @override
  void initState() {
    super.initState();
    _emailController.text = AppConfig.testEmail;
    _passwordController.text = AppConfig.testPassword;
  }

  void _navigateToSignUp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    );
  }

  void _navigateToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
    );
  }

  Future<void> _signIn() async {
    if (!_validateInputs()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final loginRequest = LoginRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final authService = AuthService();
      final response = await authService.login(loginRequest);

      if (!mounted) return;

      // Store the token
      if (response['token'] != null) {
        await TokenService.saveToken(response['token']);

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        throw Exception('No token received from server');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _validateInputs() {
    if (_emailController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'auth.please_enter_your_email'.tr());
      return false;
    }
    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'auth.please_enter_your_password'.tr());
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text(
                'auth.sign_in'.tr(),
                style: kAppTextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'auth.welcome_back'.tr(),
                style: kAppTextStyle(
                  fontSize: 16,
                  color: AppColors.getSecondaryTextColor(context),
                ),
              ),
              const SizedBox(height: 32),
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(0x33),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: kAppTextStyle(color: AppColors.error, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'common.email'.tr(),
                  style: kAppTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'auth.email_placeholder'.tr(),
                  hintStyle: kAppTextStyle(
                    color: AppColors.getHintTextColor(context),
                  ),
                  filled: true,
                  fillColor: AppColors.getSurfaceColor(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState(() => _errorMessage = null),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'auth.password'.tr(),
                  style: kAppTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: '••••••',
                  hintStyle: kAppTextStyle(
                    color: AppColors.getHintTextColor(context),
                  ),
                  filled: true,
                  fillColor: AppColors.getSurfaceColor(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.getSecondaryTextColor(context),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                onChanged: (_) => setState(() => _errorMessage = null),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _navigateToForgotPassword,
                  child: Text(
                    'auth.forgot_password'.tr(),
                    style: kAppTextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
                            'auth.sign_in'.tr(),
                            style: kAppTextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 32),
              if (AppConfig.hasAnySocialLoginEnabled) ...[
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: AppColors.getBorderColor(context),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'auth.or_continue_with'.tr(),
                        style: kAppTextStyle(
                          color: AppColors.getSecondaryTextColor(context),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: AppColors.getBorderColor(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (AppConfig.enableAppleSignIn) ...[
                      _socialButton(
                        'assets/images/icons/apple.svg',
                        'apple',
                        onTap: () async {
                          setState(() {
                            _isSocialLoading = true;
                            _socialSignInProvider = 'apple';
                            _errorMessage = null;
                          });
                          try {
                            final credential =
                                await SignInWithApple.getAppleIDCredential(
                                  scopes: [
                                    AppleIDAuthorizationScopes.email,
                                    AppleIDAuthorizationScopes.fullName,
                                  ],
                                );

                            final authService = AuthService();
                            final response = await authService.signInWithApple(
                              credential.identityToken ?? '',
                            );

                            if (response['token'] != null) {
                              await TokenService.saveToken(response['token']);

                              if (!context.mounted) return;

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MainScreen(),
                                ),
                              );
                            } else {
                              setState(() {
                                _errorMessage = 'Apple login failed';
                              });
                              return;
                            }
                          } catch (e) {
                            if (!context.mounted) return;
                            setState(() {
                              _errorMessage = e.toString();
                            });
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isSocialLoading = false;
                                _socialSignInProvider = null;
                              });
                            }
                          }
                        },
                      ),
                      const SizedBox(width: 20),
                    ],
                    if (AppConfig.enableGoogleSignIn) ...[
                      _socialButton(
                        'assets/images/icons/google.svg',
                        'google',
                        onTap: () async {
                          setState(() {
                            _isSocialLoading = true;
                            _socialSignInProvider = 'google';
                            _errorMessage = null;
                          });

                          try {
                            final googleSignIn = GoogleSignIn(
                              clientId: AppConfig.googleClientId,
                              serverClientId: AppConfig.googleServerClientId,
                              scopes: ['email'],
                            );

                            final account = await googleSignIn.signIn();

                            final auth = await account?.authentication;

                            if (auth?.idToken == null) {
                              setState(() {
                                _errorMessage = 'Google login failed';
                              });
                              return;
                            }

                            final authService = AuthService();
                            final response = await authService.signInWithGoogle(
                              auth!.idToken!,
                            );

                            if (response['token'] != null) {
                              await TokenService.saveToken(response['token']);

                              if (!context.mounted) return;

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MainScreen(),
                                ),
                              );
                            } else {
                              setState(() {
                                _errorMessage = 'Google login failed';
                              });
                              return;
                            }
                          } catch (e) {
                            if (!context.mounted) return;
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isSocialLoading = false;
                                _socialSignInProvider = null;
                              });
                            }
                          }
                        },
                      ),
                      const SizedBox(width: 20),
                    ],
                    if (AppConfig.enableFacebookSignIn) ...[
                      _socialButton(
                        'assets/images/icons/facebook.svg',
                        'facebook',
                        onTap: () async {
                          setState(() {
                            _isSocialLoading = true;
                            _socialSignInProvider = 'facebook';
                            _errorMessage = null;
                          });
                          try {
                            final LoginResult result = await FacebookAuth
                                .instance
                                .login(
                                  loginBehavior:
                                      LoginBehavior.nativeWithFallback,
                                );

                            if (result.status == LoginStatus.success) {
                              final accessToken = result.accessToken!.token;

                              final authService = AuthService();
                              final response =
                                  await authService.signInWithFacebook(
                                    accessToken,
                                  );

                              if (response['token'] != null) {
                                await TokenService.saveToken(response['token']);

                                if (!context.mounted) return;

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MainScreen(),
                                  ),
                                );
                              } else {
                                setState(() {
                                  _errorMessage = 'Facebook login failed';
                                });
                                return;
                              }
                            } else {
                              setState(() {
                                _errorMessage = 'Facebook login failed';
                              });
                              return;
                            }
                          } catch (e) {
                            if (!context.mounted) return;
                            setState(() {
                              _errorMessage = e.toString();
                            });
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isSocialLoading = false;
                                _socialSignInProvider = null;
                              });
                            }
                          }
                        },
                      ),
                      const SizedBox(width: 20),
                    ],
                    if (AppConfig.enableTwitterSignIn) ...[
                      _socialButton(
                        'assets/images/icons/x.svg',
                        'twitter',
                        onTap: () async {
                          setState(() {
                            _isSocialLoading = true;
                            _socialSignInProvider = 'twitter';
                            _errorMessage = null;
                          });
                          try {
                            final twitterLogin = TwitterLogin(
                              apiKey: AppConfig.twitterConsumerKey!,
                              apiSecretKey: AppConfig.twitterConsumerSecret!,
                              redirectURI: AppConfig.twitterRedirectUri,
                            );

                            final authResult = await twitterLogin.login();

                            if (authResult.status ==
                                TwitterLoginStatus.loggedIn) {
                              final authService = AuthService();
                              final response =
                                  await authService.signInWithTwitter(
                                    authResult.authToken!,
                                    authResult.authTokenSecret!,
                                  );

                              if (response['token'] != null) {
                                await TokenService.saveToken(response['token']);

                                if (!context.mounted) return;

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MainScreen(),
                                  ),
                                );
                              } else {
                                setState(() {
                                  _errorMessage = 'X login failed';
                                });
                                return;
                              }
                            } else {
                              setState(() {
                                _errorMessage = 'X login failed';
                              });
                              return;
                            }
                          } catch (e) {
                            if (!context.mounted) return;
                            setState(() {
                              _errorMessage = e.toString();
                            });
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isSocialLoading = false;
                                _socialSignInProvider = null;
                              });
                            }
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'auth.dont_have_account'.tr(),
                    style: kAppTextStyle(
                      color: AppColors.getSecondaryTextColor(context),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: _navigateToSignUp,
                    child: Text(
                      'auth.sign_up'.tr(),
                      style: kAppTextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.arrow_back_ios,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'app.back_to_homepage'.tr(),
                      style: kAppTextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialButton(
    String iconPath,
    String provider, {
    required Function() onTap,
  }) {
    final isLoading = _isSocialLoading && _socialSignInProvider == provider;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.getBorderColor(context),
            width: 0.5,
          ),
        ),
        child:
            isLoading
                ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
                : SvgPicture.asset(iconPath, height: 30, width: 30),
      ),
    );
  }
}
