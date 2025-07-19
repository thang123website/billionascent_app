import 'package:flutter/material.dart';
import 'package:martfury/src/service/auth_service.dart';
import 'package:martfury/src/model/register_request.dart';
import 'package:martfury/src/theme/app_fonts.dart';
import 'package:martfury/src/theme/app_colors.dart';
import 'package:martfury/src/view/screen/sign_in_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String? _formError;
  // Common controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscurePasswordConfirmation = true;
  bool _isLoading = false;

  // Individual controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Organization controllers
  final _companyNameController = TextEditingController();
  final _businessTaxCodeController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _industryController = TextEditingController();
  final _registrantNameController = TextEditingController();
  final _registrantPhoneController = TextEditingController();
  final _registrantAddressController = TextEditingController();

  int _selectedTab = 0; // 0: Individual, 1: Organization

  @override
  void dispose() {
    // Common
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    // Individual
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    // Organization
    _companyNameController.dispose();
    _businessTaxCodeController.dispose();
    _businessAddressController.dispose();
    _industryController.dispose();
    _registrantNameController.dispose();
    _registrantPhoneController.dispose();
    _registrantAddressController.dispose();
    super.dispose();
  }

  void _navigateToSignIn() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  Future<void> _signUp() async {
    // Validate required fields
    setState(() {
      _formError = null;
    });
    if (_selectedTab == 0) {
      // Individual
      final phone = _phoneController.text.trim();
      if (_firstNameController.text.trim().isEmpty ||
          _lastNameController.text.trim().isEmpty ||
          _emailController.text.trim().isEmpty ||
          phone.isEmpty ||
          _passwordController.text.isEmpty ||
          _passwordConfirmationController.text.isEmpty) {
        setState(() {
          _formError = 'messages.fill_all_fields'.tr();
        });
        return;
      }
      // Validate phone is digits only
      if (!RegExp(r'^\d+$').hasMatch(phone)) {
        setState(() {
          _formError = 'auth.phone_digits_only'.tr();
        });
        return;
      }
      // Validate phone length
      if (phone.length < 8 || phone.length > 15) {
        setState(() {
          _formError = 'auth.phone_length_invalid'.tr();
        });
        return;
      }
    } else {
      // Organization: kiểm tra từng trường và hiển thị lỗi cụ thể
      final orgFieldErrors = <String>[];
          if (_companyNameController.text.trim().isEmpty) orgFieldErrors.add('org.company_name_required'.tr());
          if (_businessTaxCodeController.text.trim().isEmpty) orgFieldErrors.add('org.business_tax_code_required'.tr());
          if (_businessAddressController.text.trim().isEmpty) orgFieldErrors.add('org.business_address_required'.tr());
          if (_industryController.text.trim().isEmpty) orgFieldErrors.add('org.industry_required'.tr());
          if (_registrantNameController.text.trim().isEmpty) orgFieldErrors.add('org.registrant_name_required'.tr());
          if (_registrantPhoneController.text.trim().isEmpty) {
            orgFieldErrors.add('org.registrant_phone_required'.tr());
          } else if (!RegExp(r'^\d+$').hasMatch(_registrantPhoneController.text.trim())) {
            orgFieldErrors.add('org.registrant_phone_digits_only'.tr());
          } else if (_registrantPhoneController.text.trim().length < 8 || _registrantPhoneController.text.trim().length > 15) {
            orgFieldErrors.add('org.registrant_phone_length_invalid'.tr());
          }
          if (_registrantAddressController.text.trim().isEmpty) orgFieldErrors.add('org.registrant_address_required'.tr());
          if (_emailController.text.trim().isEmpty) orgFieldErrors.add('org.email_required'.tr());
          if (_passwordController.text.isEmpty) orgFieldErrors.add('org.password_required'.tr());
          if (_passwordConfirmationController.text.isEmpty) orgFieldErrors.add('org.password_confirmation_required'.tr());
      if (orgFieldErrors.isNotEmpty) {
        setState(() {
          _formError = orgFieldErrors.join('\n');
        });
        return;
      }
    }

    if (_passwordController.text != _passwordConfirmationController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('auth.passwords_do_not_match'.tr()),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      dynamic response;
      if (_selectedTab == 0) {
        // Individual
        final data = {
          'account_type': 'personal',
          'name': _firstNameController.text + ' ' + _lastNameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'password_confirmation': _passwordConfirmationController.text,
          'phone': _phoneController.text,
        };
        response = await authService.registerPersonal(data);
      } else {
        // Organization
        final orgData = {
          'account_type': 'organization',
          'company_name': _companyNameController.text,
          'business_tax_code': _businessTaxCodeController.text,
          'business_address': _businessAddressController.text,
          'industry': _industryController.text,
          'registrant_name': _registrantNameController.text,
          'registrant_phone': _registrantPhoneController.text,
          'registrant_address': _registrantAddressController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'password_confirmation': _passwordConfirmationController.text,
        };
        response = await authService.registerOrganization(orgData);
      }

      // Xử lý thành công nếu response['success'] == true hoặc response['error'] == false và message chứa 'register'
      final isRegisterSuccess = (response['success'] == true) || (response['error'] == false && response['message'] != null && response['message'].toString().toLowerCase().contains('register'));
      if (isRegisterSuccess) {
        if (mounted) {
          setState(() {
            _formError = null; // Xóa banner lỗi khi thành công
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_selectedTab == 0 ? 'messages.register_success'.tr() : 'messages.register_org_success'.tr()),
              backgroundColor: AppColors.success,
            ),
          );
          _navigateToSignIn();
        }
      } else {
        // Ưu tiên hiển thị lỗi chi tiết từ API nếu có
        String errorMsg = '';
        if (response['errors'] != null && response['errors'] is Map) {
          final errors = response['errors'] as Map<String, dynamic>;
          final List<String> allErrors = [];
          errors.forEach((key, value) {
            if (key == 'email' && value is List) {
              bool isFormat = false;
              bool isDuplicate = false;
              for (var v in value) {
                final msg = v.toString().toLowerCase();
                if (msg.contains('valid email') || msg.contains('địa chỉ email hợp lệ') || msg.contains('email') && msg.contains('format')) {
                  isFormat = true;
                }
                if (msg.contains('already been taken') || msg.contains('đã được sử dụng') || msg.contains('exists')) {
                  isDuplicate = true;
                }
              }
              if (isFormat) allErrors.add('The email format is invalid or missing.');
              if (isDuplicate) allErrors.add('This email is already registered.');
              if (!isFormat && !isDuplicate) {
                for (var v in value) {
                  if (v != null && v.toString().trim().isNotEmpty) {
                    allErrors.add(v.toString());
                  }
                }
              }
            } else if (value is List) {
              for (var v in value) {
                if (v != null && v.toString().trim().isNotEmpty) {
                  allErrors.add(v.toString());
                }
              }
            } else if (value != null && value.toString().trim().isNotEmpty) {
              allErrors.add(value.toString());
            }
          });
          if (allErrors.isNotEmpty) {
            errorMsg = allErrors.join('\n');
          }
        }
        print('error: $response');
        // Nếu không có lỗi chi tiết thì lấy message tổng quát
        if (errorMsg.isEmpty) {
          errorMsg = response['message'] ?? 'messages.error_occurred'.tr();
        }
        setState(() {
          _formError = errorMsg;
        });
      }
    } catch (e) {
      setState(() {
        _formError = 'messages.error_occurred'.tr();
      });
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
    // Hiển thị lỗi validate phía trên form
    Widget? errorBanner;
    if (_formError != null && _formError!.isNotEmpty) {
      errorBanner = Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _formError!.split('\n').map((msg) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              msg,
              style: kAppTextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          )).toList(),
        ),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (errorBanner != null) errorBanner,
              Align(
                alignment: Alignment.center,
                child: Text(
                  'auth.create_account'.tr(),
                  style: kAppTextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'auth.enter_details_to_create_account'.tr(),
                  style: kAppTextStyle(
                    fontSize: 16,
                    color: AppColors.getSecondaryTextColor(context),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // TabBar
              Container(
                decoration: BoxDecoration(
                  color: AppColors.getSurfaceColor(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0 ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Individual',
                            style: kAppTextStyle(
                              color: _selectedTab == 0 ? Colors.white : AppColors.getSecondaryTextColor(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1 ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Organization',
                            style: kAppTextStyle(
                              color: _selectedTab == 1 ? Colors.white : AppColors.getSecondaryTextColor(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (_selectedTab == 0) ...[
                // Individual Form
                Text(
                  'auth.first_name'.tr(),
                  style: kAppTextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    hintText: 'auth.first_name_placeholder'.tr(),
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
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 24),
                Text(
                  'auth.last_name'.tr(),
                  style: kAppTextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    hintText: 'auth.last_name_placeholder'.tr(),
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
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 24),
                Text(
                  'common.email'.tr(),
                  style: kAppTextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
                ),
                const SizedBox(height: 24),
                Text(
                  'common.phone'.tr(),
                  style: kAppTextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    hintText: 'auth.phone_placeholder'.tr(),
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
                  keyboardType: TextInputType.phone,
                ),
              ] else ...[
                // Organization Form
                Text('org.company_name'.tr(), style: kAppTextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: _companyNameController,
                  decoration: InputDecoration(
                    hintText: 'org.company_name_placeholder'.tr(),
                    hintStyle: kAppTextStyle(color: AppColors.getHintTextColor(context)),
                    filled: true,
                    fillColor: AppColors.getSurfaceColor(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 16),
                Text('org.business_tax_code'.tr(), style: kAppTextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: _businessTaxCodeController,
                  decoration: InputDecoration(
                    hintText: 'org.business_tax_code_placeholder'.tr(),
                    hintStyle: kAppTextStyle(color: AppColors.getHintTextColor(context)),
                    filled: true,
                    fillColor: AppColors.getSurfaceColor(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 16),
                Text('org.business_address'.tr(), style: kAppTextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: _businessAddressController,
                  decoration: InputDecoration(
                    hintText: 'org.business_address_placeholder'.tr(),
                    hintStyle: kAppTextStyle(color: AppColors.getHintTextColor(context)),
                    filled: true,
                    fillColor: AppColors.getSurfaceColor(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 16),
                Text('org.industry'.tr(), style: kAppTextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: _industryController,
                  decoration: InputDecoration(
                    hintText: 'org.industry_placeholder'.tr(),
                    hintStyle: kAppTextStyle(color: AppColors.getHintTextColor(context)),
                    filled: true,
                    fillColor: AppColors.getSurfaceColor(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 16),
                Text('org.registrant_name'.tr(), style: kAppTextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: _registrantNameController,
                  decoration: InputDecoration(
                    hintText: 'org.registrant_name_placeholder'.tr(),
                    hintStyle: kAppTextStyle(color: AppColors.getHintTextColor(context)),
                    filled: true,
                    fillColor: AppColors.getSurfaceColor(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 16),
                Text('org.registrant_phone'.tr(), style: kAppTextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: _registrantPhoneController,
                  decoration: InputDecoration(
                    hintText: 'org.registrant_phone_placeholder'.tr(),
                    hintStyle: kAppTextStyle(color: AppColors.getHintTextColor(context)),
                    filled: true,
                    fillColor: AppColors.getSurfaceColor(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                Text('org.registrant_address'.tr(), style: kAppTextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: _registrantAddressController,
                  decoration: InputDecoration(
                    hintText: 'org.registrant_address_placeholder'.tr(),
                    hintStyle: kAppTextStyle(color: AppColors.getHintTextColor(context)),
                    filled: true,
                    fillColor: AppColors.getSurfaceColor(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 16),
                Text('org.email'.tr(), style: kAppTextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'org.email_placeholder'.tr(),
                    hintStyle: kAppTextStyle(color: AppColors.getHintTextColor(context)),
                    filled: true,
                    fillColor: AppColors.getSurfaceColor(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
              if (_selectedTab == 0 || _selectedTab == 1) ...[
                const SizedBox(height: 24),
                Text('Password *', style: kAppTextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: '••••••••••',
                    hintStyle: kAppTextStyle(color: AppColors.getHintTextColor(context)),
                    filled: true,
                    fillColor: AppColors.getSurfaceColor(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.getSecondaryTextColor(context),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Confirm Password *', style: kAppTextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordConfirmationController,
                  obscureText: _obscurePasswordConfirmation,
                  decoration: InputDecoration(
                    hintText: '••••••••••',
                    hintStyle: kAppTextStyle(color: AppColors.getHintTextColor(context)),
                    filled: true,
                    fillColor: AppColors.getSurfaceColor(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePasswordConfirmation ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.getSecondaryTextColor(context),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePasswordConfirmation = !_obscurePasswordConfirmation;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // ...removed agree to terms checkbox...
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : Text(
                            'Register',
                            style: kAppTextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'auth.already_have_account'.tr(),
                    style: kAppTextStyle(
                      color: AppColors.getSecondaryTextColor(context),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: _navigateToSignIn,
                    child: Text(
                      'auth.sign_in'.tr(),
                      style: kAppTextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
