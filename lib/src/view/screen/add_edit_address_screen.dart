import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:martfury/src/service/address_service.dart';
import 'package:martfury/src/service/country_service.dart';
import 'package:martfury/src/model/address.dart';
import 'package:martfury/src/model/country.dart';
import 'package:martfury/src/theme/app_fonts.dart';
import 'package:martfury/src/theme/app_colors.dart';

class AddEditAddressScreen extends StatefulWidget {
  final Address? address;

  const AddEditAddressScreen({super.key, this.address});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _addressService = AddressService();
  final _countryService = CountryService();
  List<Country> _countries = [];
  String _selectedCountry = '';
  bool _isDefault = false;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isDeleting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCountries();
    if (widget.address != null) {
      _nameController.text = widget.address!.name;
      _emailController.text = widget.address!.email;
      _phoneController.text = widget.address!.phone;
      _addressController.text = widget.address!.address;
      _cityController.text = widget.address!.city;
      _stateController.text = widget.address!.state;
      _zipCodeController.text = widget.address!.zipCode ?? '';
      _selectedCountry = widget.address!.country;
      _isDefault = widget.address!.isDefault;
    }
  }

  Future<void> _loadCountries() async {
    try {
      final countries = await _countryService.getCountries();
      setState(() {
        _countries = countries;
        _isLoading = false;
        if (_selectedCountry.isEmpty && countries.isNotEmpty) {
          _selectedCountry = countries.first.name;
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      if (widget.address == null) {
        await _addressService.createAddress(
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          country: _selectedCountry,
          state: _stateController.text,
          city: _cityController.text,
          address: _addressController.text,
          isDefault: _isDefault,
          zipCode: _zipCodeController.text,
        );
      } else {
        await _addressService.updateAddress(
          id: widget.address!.id,
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          country: _selectedCountry,
          state: _stateController.text,
          city: _cityController.text,
          address: _addressController.text,
          isDefault: _isDefault,
          zipCode: _zipCodeController.text,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.address == null
                  ? 'address.created_successfully'.tr()
                  : 'address.updated_successfully'.tr(),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('address.save_failed'.tr()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteAddress() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      await _addressService.deleteAddress(widget.address!.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('address.deleted_successfully'.tr()),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('address.delete_failed'.tr()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.red[900]!.withValues(alpha: 0.2)
                            : Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.red[300]
                            : Colors.red[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'address.delete_confirm'.tr(),
                    style: kAppTextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getPrimaryTextColor(context),
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              'address.delete_confirm_message'.tr(),
              style: kAppTextStyle(
                fontSize: 14,
                color: AppColors.getSecondaryTextColor(context),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'common.cancel'.tr(),
                  style: kAppTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getSecondaryTextColor(context),
                  ),
                ),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteAddress();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'common.delete'.tr(),
                  style: kAppTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          widget.address == null
              ? 'address.add_new'.tr()
              : 'address.edit_address'.tr(),
          style: kAppTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions:
            widget.address != null
                ? [
                  IconButton(
                    onPressed: _isDeleting ? null : _showDeleteDialog,
                    icon:
                        _isDeleting
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2,
                              ),
                            )
                            : const Icon(Icons.delete_outline),
                    color: Colors.black,
                  ),
                ]
                : null,
      ),
      body:
          _isLoading
              ? _buildLoadingState()
              : _error != null
              ? _buildErrorState()
              : _buildForm(),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSkeletonFormCard(),
          const SizedBox(height: 32),
          _buildSkeletonSaveButton(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSkeletonFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.getBorderColor(context), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header skeleton
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.getSkeletonColor(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 150,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.getSkeletonColor(context),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Form fields skeleton
            _buildSkeletonTextField(),
            const SizedBox(height: 16),
            _buildSkeletonTextField(),
            const SizedBox(height: 16),
            _buildSkeletonTextField(),
            const SizedBox(height: 16),
            _buildSkeletonTextField(),
            const SizedBox(height: 16),

            // State and City row skeleton
            Row(
              children: [
                Expanded(child: _buildSkeletonTextField()),
                const SizedBox(width: 16),
                Expanded(child: _buildSkeletonTextField()),
              ],
            ),
            const SizedBox(height: 16),
            _buildSkeletonTextField(height: 80), // Address field (multiline)
            const SizedBox(height: 16),
            _buildSkeletonTextField(),
            const SizedBox(height: 20),

            // Switch skeleton
            Container(
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.getSkeletonColor(
                  context,
                ).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.getBorderColor(context)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 16,
                            decoration: BoxDecoration(
                              color: AppColors.getSkeletonColor(context),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 200,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.getSkeletonColor(context),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.getSkeletonColor(context),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonTextField({double height = 56}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.getSkeletonColor(context).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorderColor(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.getSkeletonColor(context),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 100,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.getSkeletonColor(context),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonSaveButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.getSkeletonColor(context),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'common.error_occurred'.tr(),
              style: kAppTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.getPrimaryTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: kAppTextStyle(
                fontSize: 14,
                color: AppColors.getSecondaryTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _loadCountries,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: Text('common.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFormCard(),
            const SizedBox(height: 32),
            _buildSaveButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.getBorderColor(context), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.address == null
                      ? 'address.add_new'.tr()
                      : 'address.edit_address'.tr(),
                  style: kAppTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getPrimaryTextColor(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Personal Information Fields
            _buildTextField(
              controller: _nameController,
              label: 'common.name'.tr(),
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'address.name_required'.tr();
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              label: 'common.email'.tr(),
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'common.email_required'.tr();
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'address.invalid_email'.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneController,
              label: 'common.phone'.tr(),
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'address.phone_required'.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Location Fields
            _buildCountryDropdown(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _stateController,
                    label: 'address.state'.tr(),
                    icon: Icons.map_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'address.state_required'.tr();
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _cityController,
                    label: 'address.city'.tr(),
                    icon: Icons.location_city_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'address.city_required'.tr();
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _addressController,
              label: 'address.address'.tr(),
              icon: Icons.home_outlined,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'address.address_required'.tr();
                }
                return null;
              },
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _zipCodeController,
              label: 'address.zip_code'.tr(),
              icon: Icons.local_post_office_outlined,
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'address.zip_code_required'.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Default Address Setting
            Container(
              decoration: BoxDecoration(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkSurface
                        : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.getBorderColor(context)),
              ),
              child: SwitchListTile(
                title: Text(
                  'address.set_default'.tr(),
                  style: kAppTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.getPrimaryTextColor(context),
                  ),
                ),
                subtitle: Text(
                  'address.set_default_description'.tr(),
                  style: kAppTextStyle(
                    fontSize: 14,
                    color: AppColors.getSecondaryTextColor(context),
                  ),
                ),
                value: _isDefault,
                activeColor: AppColors.primary,
                onChanged: (value) {
                  setState(() {
                    _isDefault = value;
                  });
                },
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 56,
      child: FilledButton(
        onPressed: _isSaving ? null : _saveAddress,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          disabledBackgroundColor: AppColors.getSecondaryTextColor(context),
        ),
        child:
            _isSaving
                ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2,
                  ),
                )
                : Text(
                  widget.address == null
                      ? 'address.save'.tr()
                      : 'address.update'.tr(),
                  style: kAppTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: AppColors.getSecondaryTextColor(context),
          size: 20,
        ),
        filled: true,
        fillColor:
            Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkSurface
                : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.getBorderColor(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.getBorderColor(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: kAppTextStyle(
          fontSize: 14,
          color: AppColors.getSecondaryTextColor(context),
        ),
      ),
      style: kAppTextStyle(
        fontSize: 16,
        color: AppColors.getPrimaryTextColor(context),
      ),
      validator: validator,
    );
  }

  Widget _buildCountryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCountry.isEmpty ? null : _selectedCountry,
      decoration: InputDecoration(
        labelText: 'address.country'.tr(),
        prefixIcon: Icon(
          Icons.public,
          color: AppColors.getSecondaryTextColor(context),
          size: 20,
        ),
        filled: true,
        fillColor:
            Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkSurface
                : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.getBorderColor(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.getBorderColor(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: kAppTextStyle(
          fontSize: 14,
          color: AppColors.getSecondaryTextColor(context),
        ),
      ),
      isExpanded: true,
      items:
          _countries
              .map(
                (country) => DropdownMenuItem(
                  value: country.name,
                  child: Text(
                    country.name,
                    style: kAppTextStyle(
                      fontSize: 16,
                      color: AppColors.getPrimaryTextColor(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
      onChanged: (value) {
        setState(() {
          _selectedCountry = value!;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'address.country_required'.tr();
        }
        return null;
      },
    );
  }
}
