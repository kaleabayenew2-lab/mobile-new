// lib/pages/agent/facility-detail-register.dart
import 'package:flutter/material.dart';
import '../../../utils/validate-agent.dart';

class FacilityDetailRegisterSection extends StatefulWidget {
  final String facilityType; // 'Hospital' or 'Pharmacy'
  final Function(Map<String, dynamic>) onFacilityDetailsChanged;
  final VoidCallback onValidate;

  const FacilityDetailRegisterSection({
    super.key,
    required this.facilityType,
    required this.onFacilityDetailsChanged,
    required this.onValidate,
  });

  @override
  State<FacilityDetailRegisterSection> createState() => _FacilityDetailRegisterSectionState();
}

class _FacilityDetailRegisterSectionState extends State<FacilityDetailRegisterSection> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();
  
  String _selectedHospitalType = 'General Hospital';
  String _selectedPharmacyType = 'Retail Pharmacy';
  String _selectedOwnership = 'Private';
  bool _emergencyEnabled = false;
  bool _is24Hours = false;
  TimeOfDay? _openingTime;
  TimeOfDay? _closingTime;
  
  List<String> _selectedServices = [];
  
  // Dropdown options
  final List<String> _hospitalTypes = [
    'General Hospital',
    'Specialized Hospital',
    'Teaching Hospital',
    'District Hospital',
    'Primary Hospital',
    'Clinic',
    'Medical Center',
  ];

  final List<String> _pharmacyTypes = [
    'Retail Pharmacy',
    'Hospital Pharmacy',
    'Clinical Pharmacy',
    'Compounding Pharmacy',
    'Online Pharmacy',
    'Wholesale Pharmacy',
    'Chain Pharmacy',
  ];

  final List<String> _ownershipOptions = [
    'Private',
    'Public',
  ];

  // Services based on facility type
  final Map<String, List<String>> _servicesByType = {
    'General Hospital': [
      'Emergency Services',
      'Inpatient Care',
      'Outpatient Care',
      'Surgery',
      'Maternity Services',
      'Pediatrics',
      'Cardiology',
      'Radiology',
      'Laboratory Services',
      'Pharmacy',
      'Intensive Care Unit',
      'Ambulance Services',
    ],
    'Specialized Hospital': [
      'Specialized Consultations',
      'Advanced Surgery',
      'Specialized Diagnostics',
      'Rehabilitation',
      'Research Services',
      'Specialized ICU',
      'Organ Transplant',
      'Oncology Services',
    ],
    'Teaching Hospital': [
      'Medical Education',
      'Research Programs',
      'Specialized Clinics',
      'Emergency Care',
      'Residency Programs',
      'Clinical Trials',
      'Referral Services',
    ],
    'District Hospital': [
      'Primary Care',
      'Emergency Services',
      'Maternity Care',
      'Inpatient Services',
      'Diagnostic Services',
      'Preventive Care',
      'Community Health',
    ],
    'Primary Hospital': [
      'Basic Emergency Care',
      'General Medicine',
      'General Surgery',
      'Maternity Services',
      'Pediatric Care',
      'Laboratory Services',
    ],
    'Clinic': [
      'General Checkups',
      'Vaccinations',
      'Minor Procedures',
      'Health Screening',
      'Family Medicine',
      'Consultations',
    ],
    'Medical Center': [
      'Specialized Clinics',
      'Diagnostic Services',
      'Preventive Care',
      'Wellness Programs',
      'Physical Therapy',
      'Specialist Referrals',
    ],
    'Retail Pharmacy': [
      'Prescription Filling',
      'Over Counter Medicines',
      'Health Consultations',
      'Vaccination Services',
      'Health Screening',
      'Medicine Delivery',
      'Medical Devices',
    ],
    'Hospital Pharmacy': [
      'Inpatient Medications',
      'Outpatient Medications',
      'Clinical Pharmacy',
      'IV Admixture Services',
      'Medication Management',
      'Drug Information Services',
    ],
    'Clinical Pharmacy': [
      'Patient Counseling',
      'Medication Therapy Management',
      'Disease Management',
      'Drug Interaction Checks',
      'Clinical Consultations',
    ],
    'Compounding Pharmacy': [
      'Custom Medications',
      'Dosage Adjustments',
      'Allergen-Free Medications',
      'Flavor Additions',
      'Special Formulations',
    ],
    'Online Pharmacy': [
      'Online Prescriptions',
      'Home Delivery',
      'Virtual Consultations',
      'Medicine Reminders',
      'Health Records',
    ],
    'Wholesale Pharmacy': [
      'Bulk Medications',
      'Distribution Services',
      'Supply Chain Management',
      'Inventory Management',
      'Logistics Services',
    ],
    'Chain Pharmacy': [
      'Standard Prescriptions',
      'Health Screenings',
      'Immunizations',
      'Wellness Products',
      'Multiple Locations',
      'Loyalty Programs',
    ],
  };

  @override
  void initState() {
    super.initState();
    _openingTime = const TimeOfDay(hour: 9, minute: 0);
    _closingTime = const TimeOfDay(hour: 17, minute: 0);
    
    _nameController.addListener(_notifyParent);
    _addressController.addListener(_notifyParent);
    _phoneController.addListener(_notifyParent);
    _noteController.addListener(_notifyParent);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyParent();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _notifyParent() {
    widget.onFacilityDetailsChanged({
      'name': _nameController.text,
      'facility_type': widget.facilityType,
      'facility_sub_type': widget.facilityType == 'Hospital' ? _selectedHospitalType : _selectedPharmacyType,
      'ownership': _selectedOwnership,
      'address': _addressController.text,
      'phone': _phoneController.text,
      'note': _noteController.text,
      'emergency_enabled': _emergencyEnabled,
      'is_24_hours': _is24Hours,
      'opening_time': _is24Hours ? '00:00' : '${_openingTime!.hour}:${_openingTime!.minute.toString().padLeft(2, '0')}',
      'closing_time': _is24Hours ? '23:59' : '${_closingTime!.hour}:${_closingTime!.minute.toString().padLeft(2, '0')}',
      'opening_hours': _is24Hours ? '24 Hours' : '${_openingTime!.format(context)} - ${_closingTime!.format(context)}',
      'services': _selectedServices,
    });
  }

  // Time picker methods
  Future<void> _selectOpeningTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _openingTime!,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[600]!,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _openingTime) {
      setState(() {
        _openingTime = picked;
        _is24Hours = false;
      });
      _notifyParent();
    }
  }

  Future<void> _selectClosingTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _closingTime!,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[600]!,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _closingTime) {
      setState(() {
        _closingTime = picked;
        _is24Hours = false;
      });
      _notifyParent();
    }
  }

  void _set24Hours() {
    setState(() {
      _is24Hours = true;
      _openingTime = const TimeOfDay(hour: 0, minute: 0);
      _closingTime = const TimeOfDay(hour: 23, minute: 59);
    });
    _notifyParent();
  }

  void _toggleService(String service) {
    setState(() {
      if (_selectedServices.contains(service)) {
        _selectedServices.remove(service);
      } else {
        _selectedServices.add(service);
      }
    });
    _notifyParent();
  }

  // Validation methods
  String? _validateFacilityName(String? value) => AgentValidator.validateName(value);

  String? _validateAddress(String? value) => AgentValidator.validateAddress(value);

  String? _validatePhone(String? value) => AgentValidator.validatePhone(value);

  // Form validation
  bool validateForm() {
    return _validateFacilityName(_nameController.text) == null &&
           _validateAddress(_addressController.text) == null &&
           _validatePhone(_phoneController.text) == null;
  }

  // Build services section
  Widget _buildServicesSection() {
    String currentType = widget.facilityType == 'Hospital' 
        ? _selectedHospitalType 
        : _selectedPharmacyType;
    
    List<String> services = _servicesByType[currentType] ?? 
        (widget.facilityType == 'Hospital' 
            ? _servicesByType['General Hospital']! 
            : _servicesByType['Retail Pharmacy']!);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medical_services, color: Colors.purple[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Services Offered',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Select multiple',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: services.map((service) {
              bool isSelected = _selectedServices.contains(service);
              return FilterChip(
                label: Text(service),
                selected: isSelected,
                onSelected: (_) => _toggleService(service),
                backgroundColor: Colors.grey[100],
                selectedColor: Colors.blue[100],
                checkmarkColor: Colors.blue[600],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.blue[800] : Colors.grey[800],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                avatar: isSelected 
                    ? const Icon(Icons.check, size: 16, color: Colors.blue)
                    : null,
              );
            }).toList(),
          ),
          if (_selectedServices.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue[600], size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Selected ${_selectedServices.length} service(s)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String currentType = widget.facilityType == 'Hospital' 
        ? _selectedHospitalType 
        : _selectedPharmacyType;
    
    return Column(
      children: [
        // Facility Name Field
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: widget.facilityType == 'Hospital' ? 'Hospital Name' : 'Pharmacy Name',
            hintText: 'Enter ${widget.facilityType == 'Hospital' ? 'hospital' : 'pharmacy'} name',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.business, size: 20),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          validator: _validateFacilityName,
          onChanged: (_) => _notifyParent(),
        ),
        const SizedBox(height: 16),
        
        // Facility Type Dropdown
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            value: currentType,
            decoration: InputDecoration(
              labelText: widget.facilityType == 'Hospital' ? 'Hospital Type' : 'Pharmacy Type',
              prefixIcon: const Icon(Icons.category, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            items: (widget.facilityType == 'Hospital' ? _hospitalTypes : _pharmacyTypes).map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  if (widget.facilityType == 'Hospital') {
                    _selectedHospitalType = newValue;
                  } else {
                    _selectedPharmacyType = newValue;
                  }
                  _selectedServices.clear();
                });
                _notifyParent();
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select ${widget.facilityType == 'Hospital' ? 'hospital' : 'pharmacy'} type';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 16),
        
        // Services Section
        _buildServicesSection(),
        
        // Ownership Dropdown
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedOwnership,
            decoration: const InputDecoration(
              labelText: 'Ownership Type',
              prefixIcon: Icon(Icons.business_center, size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            items: _ownershipOptions.map((String ownership) {
              return DropdownMenuItem<String>(
                value: ownership,
                child: Text(ownership),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedOwnership = newValue;
                });
                _notifyParent();
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select ownership type';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 16),
        
        // Opening Hours Section
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Opening Hours',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              if (!_is24Hours) ...[
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _selectOpeningTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.access_time, color: Colors.blue[600], size: 20),
                              const SizedBox(width: 8),
                              Text(
                                _openingTime != null 
                                    ? _openingTime!.format(context) 
                                    : 'Open Time',
                                style: TextStyle(
                                  color: _openingTime != null ? Colors.black : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.arrow_forward, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _selectClosingTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.access_time, color: Colors.red[600], size: 20),
                              const SizedBox(width: 8),
                              Text(
                                _closingTime != null 
                                    ? _closingTime!.format(context) 
                                    : 'Close Time',
                                style: TextStyle(
                                  color: _closingTime != null ? Colors.black : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _set24Hours,
                      icon: const Icon(Icons.schedule, size: 16),
                      label: const Text('24 Hours Service'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _is24Hours ? Colors.green : Colors.grey[300],
                        foregroundColor: _is24Hours ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              if (_is24Hours)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[600], size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '24/7 Service Selected',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Emergency Toggle Button
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: _emergencyEnabled ? Colors.red : Colors.grey,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Emergency Services',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Switch(
                value: _emergencyEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _emergencyEnabled = value;
                  });
                  _notifyParent();
                },
                activeColor: Colors.red,
                activeTrackColor: Colors.red[200],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Phone Number Field
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            hintText: '912345678 or 712345678',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone, size: 20),
            prefixText: '+251 ',
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          validator: _validatePhone,
          onChanged: (value) {
            String digits = value.replaceAll(RegExp(r'[^0-9]'), '');
            if (digits.length > 9) {
              digits = digits.substring(0, 9);
            }
            if (value != digits) {
              _phoneController.value = TextEditingValue(
                text: digits,
                selection: TextSelection.collapsed(offset: digits.length),
              );
            }
            _notifyParent();
          },
        ),
        const SizedBox(height: 16),
        
        // Address Field
        TextFormField(
          controller: _addressController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Address',
            hintText: 'Enter full address (city, sub-city, street, etc.)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on, size: 20),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          validator: _validateAddress,
          onChanged: (_) => _notifyParent(),
        ),
        const SizedBox(height: 16),
        
        // Note Field
        TextFormField(
          controller: _noteController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Additional Notes',
            hintText: 'Enter any additional information about your facility...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.note, size: 20),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          onChanged: (_) => _notifyParent(),
        ),
      ],
    );
  }
}