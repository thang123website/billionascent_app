import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:martfury/src/service/profile_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:martfury/src/theme/app_fonts.dart';
import 'package:martfury/src/theme/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const EditProfileScreen({super.key, required this.profileData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  // Các trường bổ sung
  final _accountTypeController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _businessTaxCodeController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _industryController = TextEditingController();
  final _registrantAddressController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.profileData['name'] is String ? widget.profileData['name'] : '';
    _emailController.text = widget.profileData['email'] is String ? widget.profileData['email'] : '';
    _phoneController.text = widget.profileData['phone'] is String ? widget.profileData['phone'] : '';
    final accountType = widget.profileData['account_type'];
    _accountTypeController.text = accountType is String
        ? accountType
        : (accountType is Map && accountType['value'] is String ? accountType['value'] : '');
    _companyNameController.text = widget.profileData['company_name'] is String ? widget.profileData['company_name'] : '';
    _businessTaxCodeController.text = widget.profileData['business_tax_code'] is String ? widget.profileData['business_tax_code'] : '';
    _businessAddressController.text = widget.profileData['business_address'] is String ? widget.profileData['business_address'] : '';
    _industryController.text = widget.profileData['industry'] is String ? widget.profileData['industry'] : '';
    _registrantAddressController.text = widget.profileData['registrant_address'] is String ? widget.profileData['registrant_address'] : '';
    if (widget.profileData['dob'] != null && widget.profileData['dob'] is String && widget.profileData['dob'].isNotEmpty) {
      try {
        final date = DateTime.parse(widget.profileData['dob']).toLocal();
        _dobController.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      } catch (e) {
        _dobController.text = widget.profileData['dob'];
      }
    } else {
      _dobController.text = '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _accountTypeController.dispose();
    _companyNameController.dispose();
    _businessTaxCodeController.dispose();
    _businessAddressController.dispose();
    _industryController.dispose();
    _registrantAddressController.dispose();
    super.dispose();
  }
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final updatedData = await _profileService.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        dob: _dobController.text.trim().isNotEmpty ? _dobController.text.trim() : null,
        accountType: _accountTypeController.text.trim().isNotEmpty ? _accountTypeController.text.trim() : null,
        companyName: _companyNameController.text.trim().isNotEmpty ? _companyNameController.text.trim() : null,
        businessTaxCode: _businessTaxCodeController.text.trim().isNotEmpty ? _businessTaxCodeController.text.trim() : null,
        businessAddress: _businessAddressController.text.trim().isNotEmpty ? _businessAddressController.text.trim() : null,
        industry: _industryController.text.trim().isNotEmpty ? _industryController.text.trim() : null,
        registrantAddress: _registrantAddressController.text.trim().isNotEmpty ? _registrantAddressController.text.trim() : null,
      );
      if (!mounted) return;

      // Include the existing avatar URL in the returned data
      final result = {...updatedData, 'avatar': widget.profileData['avatar']};

      // Show success SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('auth.profile_update_success'.tr()),
          backgroundColor: Colors.green,
        ),
      );

      // Return the updated data to the previous screen
      Navigator.pop(context, result);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateAvatar() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      setState(() {
        _isLoading = true;
      });

      final updatedData = await _profileService.updateAvatar(File(image.path));

      if (mounted) {
        setState(() {
          widget.profileData['avatar'] = updatedData['avatar'];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avatar updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Edit Profile',
          style: kAppTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error!,
                    style: kAppTextStyle(color: AppColors.error, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _updateAvatar,
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2,
                              ),
                              image: DecorationImage(
                                image: NetworkImage(
                                  widget.profileData['avatar'] ??
                                      'https://example.com/profile.jpg',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tap to change profile picture',
                      style: kAppTextStyle(
                        fontSize: 14,
                        color: AppColors.getSecondaryTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              Text(
                'Name',
                style: kAppTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.getPrimaryTextColor(context),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                style: kAppTextStyle(
                  fontSize: 16,
                  color: AppColors.getPrimaryTextColor(context),
                ),
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  hintStyle: kAppTextStyle(
                    color: AppColors.getHintTextColor(context),
                  ),
                  filled: true,
                  fillColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkSurface
                          : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Email',
                style: kAppTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.getPrimaryTextColor(context),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: kAppTextStyle(
                  fontSize: 16,
                  color: AppColors.getPrimaryTextColor(context),
                ),
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  hintStyle: kAppTextStyle(
                    color: AppColors.getHintTextColor(context),
                  ),
                  filled: true,
                  fillColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkSurface
                          : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Phone',
                style: kAppTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.getPrimaryTextColor(context),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: kAppTextStyle(
                  fontSize: 16,
                  color: AppColors.getPrimaryTextColor(context),
                ),
                decoration: InputDecoration(
                  hintText: 'Enter your phone number',
                  hintStyle: kAppTextStyle(
                    color: AppColors.getHintTextColor(context),
                  ),
                  filled: true,
                  fillColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkSurface
                          : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Date of Birth',
                style: kAppTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.getPrimaryTextColor(context),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dobController,
                keyboardType: TextInputType.datetime,
                readOnly: true,
                style: kAppTextStyle(
                  fontSize: 16,
                  color: AppColors.getPrimaryTextColor(context),
                ),
                decoration: InputDecoration(
                  hintText: 'Select date of birth',
                  hintStyle: kAppTextStyle(
                    color: AppColors.getHintTextColor(context),
                  ),
                  filled: true,
                  fillColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkSurface
                          : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.calendar_today,
                      color: AppColors.getSecondaryTextColor(context),
                    ),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate:
                            _dobController.text.isNotEmpty
                                ? DateTime.tryParse(_dobController.text) ??
                                    DateTime.now()
                                : DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppColors.primary,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (date != null) {
                        setState(() {
                          _dobController.text =
                              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                        });
                      }
                    },
                  ),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    // Check if the date format is valid (YYYY-MM-DD)
                    final RegExp dateFormat = RegExp(
                      r'^\d{4}-(?:0[1-9]|1[0-2])-(?:0[1-9]|[12]\d|3[01])$',
                    );
                    if (!dateFormat.hasMatch(value)) {
                      return 'Please enter a valid date in YYYY-MM-DD format';
                    }

                    // Check if the date is valid
                    try {
                      final date = DateTime.parse(value);
                      if (date.isAfter(DateTime.now())) {
                        return 'Date of birth cannot be in the future';
                      }
                      if (date.isBefore(DateTime(1900))) {
                        return 'Date of birth must be after 1900';
                      }
                    } catch (e) {
                      return 'Please enter a valid date';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              // Account Type (read-only)
              Text('auth.account_type_label'.tr(), style: kAppTextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.getPrimaryTextColor(context))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _accountTypeController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'personal/organization',
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Account type cannot be changed after registration (Current: ${_accountTypeController.text.isNotEmpty ? _accountTypeController.text : 'Unknown'})',
                style: kAppTextStyle(fontSize: 12, color: AppColors.getSecondaryTextColor(context)),
              ),
              const SizedBox(height: 24),
              // Show organization fields only if account type is Organization
              if (_accountTypeController.text.trim().toLowerCase() == 'organization' || _accountTypeController.text.trim().toLowerCase() == 'tổ chức') ...[
                Text('auth.company_name_label'.tr(), style: kAppTextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.getPrimaryTextColor(context))),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _companyNameController,
                  decoration: InputDecoration(
                    hintText: 'auth.company_name_hint'.tr(),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkSurface
                        : Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 24),
                Text('auth.business_tax_code_label'.tr(), style: kAppTextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.getPrimaryTextColor(context))),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _businessTaxCodeController,
                  decoration: InputDecoration(
                    hintText: 'auth.business_tax_code_hint'.tr(),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkSurface
                        : Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 24),
                Text('auth.business_address_label'.tr(), style: kAppTextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.getPrimaryTextColor(context))),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _businessAddressController,
                  decoration: InputDecoration(
                    hintText: 'auth.business_address_hint'.tr(),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkSurface
                        : Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 24),
                Text('auth.industry_label'.tr(), style: kAppTextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.getPrimaryTextColor(context))),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _industryController,
                  decoration: InputDecoration(
                    hintText: 'auth.industry_hint'.tr(),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkSurface
                        : Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 24),
                Text('auth.registrant_address_label'.tr(), style: kAppTextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.getPrimaryTextColor(context))),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _registrantAddressController,
                  decoration: InputDecoration(
                    hintText: 'auth.registrant_address_hint'.tr(),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkSurface
                        : Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 24),
    
              ],
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
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
                            'Save Changes',
                            style: kAppTextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
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
