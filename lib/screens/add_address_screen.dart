import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../services/address_service.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final houseCtrl = TextEditingController();
  final areaCtrl = TextEditingController();
  final landmarkCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final pinCtrl = TextEditingController();

  final AddressService service = AddressService();

  bool _isSaving = false;
  bool _isFetchingLocation = false;

  double? _latitude;
  double? _longitude;

  String _selectedType = "Home";

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    houseCtrl.dispose();
    areaCtrl.dispose();
    landmarkCtrl.dispose();
    cityCtrl.dispose();
    pinCtrl.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFFFC8019)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      hintStyle: const TextStyle(
        color: Colors.grey,
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFFC8019),
          width: 1.2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  Widget _buildAddressTypeChip(String label) {
    final isSelected = _selectedType == label;

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedType = label),
      selectedColor: const Color(0xFFFC8019),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: BorderSide(
          color: isSelected ? const Color(0xFFFC8019) : Colors.grey.shade300,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    );
  }

  Future<void> _useCurrentLocation() async {
    try {
      setState(() => _isFetchingLocation = true);

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception("Location service is disabled");
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied");
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception("Location permission permanently denied");
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      try {
        // Attempt 1: Try native geocoding (Works on Android/iOS natively)
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          houseCtrl.text = "${place.subThoroughfare ?? ''} ${place.thoroughfare ?? ''}".trim();
          areaCtrl.text = "${place.subLocality ?? place.locality ?? ''}".trim();
          cityCtrl.text = "${place.locality ?? place.subAdministrativeArea ?? ''}".trim();
          pinCtrl.text = place.postalCode ?? '';
          landmarkCtrl.text = place.name ?? '';
        }
      } catch (e) {
        // Attempt 2: Bulletproof Fallback to REST API (Works on Web/Windows testing)
        final url = Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&addressdetails=1');

        final response = await http.get(url, headers: {
          'User-Agent': 'FlutterDeliveryApp/1.0', // Required by Nominatim
        });

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final address = data['address'] ?? {};

          // 1. House / Flat
          houseCtrl.text = address['house_number'] ?? address['building'] ?? '';

          // 2. Area / Street (Smart hierarchy for Indian addresses & map oddities)
          List<String> areaParts = [];
          if (address['road'] != null) areaParts.add(address['road']);
          if (address['neighbourhood'] != null) areaParts.add(address['neighbourhood']);
          if (address['suburb'] != null) areaParts.add(address['suburb']);
          if (address['village'] != null) areaParts.add(address['village']);
          if (address['hamlet'] != null) areaParts.add(address['hamlet']);
          
          // Remove duplicates and limit to the 2 most relevant pieces
          var uniqueAreas = areaParts.toSet().toList();
          if (uniqueAreas.length > 2) {
            uniqueAreas = uniqueAreas.sublist(0, 2); 
          }
          areaCtrl.text = uniqueAreas.join(', ');

          // 3. City
          cityCtrl.text = address['city'] ?? 
                          address['town'] ?? 
                          address['municipality'] ?? 
                          address['state_district'] ?? '';
          
          // 4. Pincode
          pinCtrl.text = address['postcode'] ?? '';

          // 5. Landmark (Strictly points of interest, leave blank otherwise)
          landmarkCtrl.text = address['amenity'] ?? 
                              address['shop'] ?? 
                              address['office'] ?? 
                              address['tourism'] ?? '';

        } else {
          throw Exception("Could not fetch address data on this platform.");
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Location fetched successfully"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isFetchingLocation = false);
      }
    }
  }

  Future<void> _saveAddress() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await service.addAddress(
        name: nameCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        houseNo: houseCtrl.text.trim(),
        area: areaCtrl.text.trim(),
        landmark: landmarkCtrl.text.trim(),
        city: cityCtrl.text.trim(),
        pincode: pinCtrl.text.trim(),
        addressType: _selectedType,
        latitude: _latitude,
        longitude: _longitude,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$_selectedType address saved successfully"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save address: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFFC8019);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.8,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Add Address",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              InkWell(
                onTap: _isFetchingLocation ? null : _useCurrentLocation,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.my_location, color: primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _isFetchingLocation
                              ? "Fetching current location..."
                              : "Use Current Location",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _isFetchingLocation
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: primaryColor,
                              ),
                            )
                          : const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration(
                        hint: "Full Name",
                        icon: Icons.person_outline,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Full name is required";
                        }
                        if (value.trim().length < 3) {
                          return "Enter valid full name";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: _inputDecoration(
                        hint: "Phone Number",
                        icon: Icons.call_outlined,
                      ).copyWith(counterText: ""),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Phone number is required";
                        }
                        if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value.trim())) {
                          return "Enter valid 10-digit mobile number";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: houseCtrl,
                      decoration: _inputDecoration(
                        hint: "Flat / House No / Building",
                        icon: Icons.home_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "House / Flat details required";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: areaCtrl,
                      decoration: _inputDecoration(
                        hint: "Area / Street / Locality",
                        icon: Icons.location_on_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Area / Street is required";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: landmarkCtrl,
                      decoration: _inputDecoration(
                        hint: "Landmark (Optional)",
                        icon: Icons.place_outlined,
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: cityCtrl,
                      decoration: _inputDecoration(
                        hint: "City",
                        icon: Icons.location_city_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "City is required";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: pinCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: _inputDecoration(
                        hint: "Pincode",
                        icon: Icons.pin_drop_outlined,
                      ).copyWith(counterText: ""),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Pincode is required";
                        }
                        if (!RegExp(r'^[1-9][0-9]{5}$').hasMatch(value.trim())) {
                          return "Enter valid 6-digit pincode";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Save as",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        _buildAddressTypeChip("Home"),
                        const SizedBox(width: 10),
                        _buildAddressTypeChip("Work"),
                        const SizedBox(width: 10),
                        _buildAddressTypeChip("Other"),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Save Address",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
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