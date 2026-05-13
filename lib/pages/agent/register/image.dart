// lib/pages/agent/image.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImageSection extends StatefulWidget {
  final Function(File?) onProfileImageChanged;
  final Function(List<File>) onGalleryImagesChanged;
  final Function(int?) onSelectedImageIndexChanged;

  const ImageSection({
    super.key,
    required this.onProfileImageChanged,
    required this.onGalleryImagesChanged,
    required this.onSelectedImageIndexChanged,
  });

  @override
  State<ImageSection> createState() => _ImageSectionState();
}

class _ImageSectionState extends State<ImageSection> {
  File? _profileImage;
  List<File> _galleryImages = [];
  int? _selectedImageIndex;

  // Image picker methods
  Future<void> _pickProfileImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
          _selectedImageIndex = null;
        });
        widget.onProfileImageChanged(_profileImage);
        widget.onSelectedImageIndexChanged(_selectedImageIndex);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking profile image: $e')),
        );
      }
    }
  }

  Future<void> _pickGalleryImages() async {
    try {
      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage();
      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        setState(() {
          _galleryImages = pickedFiles.map((file) => File(file.path)).toList();
          _profileImage = null;
          _selectedImageIndex = null;
        });
        widget.onProfileImageChanged(_profileImage);
        widget.onGalleryImagesChanged(_galleryImages);
        widget.onSelectedImageIndexChanged(_selectedImageIndex);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking gallery images: $e')),
        );
      }
    }
  }

  void _selectGalleryImage(int index) {
    setState(() {
      _selectedImageIndex = index;
      _profileImage = null;
    });
    widget.onProfileImageChanged(_profileImage);
    widget.onSelectedImageIndexChanged(_selectedImageIndex);
  }

  void _removeGalleryImage(int index) {
    setState(() {
      _galleryImages.removeAt(index);
      if (_selectedImageIndex == index) {
        _selectedImageIndex = null;
      } else if (_selectedImageIndex != null && _selectedImageIndex! > index) {
        _selectedImageIndex = _selectedImageIndex! - 1;
      }
    });
    widget.onGalleryImagesChanged(_galleryImages);
    widget.onSelectedImageIndexChanged(_selectedImageIndex);
  }

  void _removeProfileImage() {
    setState(() {
      _profileImage = null;
    });
    widget.onProfileImageChanged(_profileImage);
  }

  // Build profile image section
  Widget _buildProfileImageSection() {
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
              Icon(Icons.image, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Profile Image',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _pickProfileImage,
                icon: const Icon(Icons.camera_alt, size: 16),
                label: const Text('Choose Image', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_profileImage != null) ...[
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue[600]!, width: 3),
                    ),
                    child: ClipOval(
                      child: Image.file(
                        _profileImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Text(
                            'Error loading image',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _removeProfileImage,
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Remove Image', style: TextStyle(color: Colors.red)),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person, color: Colors.grey, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      'No profile image selected',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _pickProfileImage,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Image', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Build gallery section
  Widget _buildGallerySection() {
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
              Icon(Icons.photo_library, color: Colors.green[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Gallery Images',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _pickGalleryImages,
                icon: const Icon(Icons.add_photo_alternate, size: 16),
                label: const Text('Add Images', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_galleryImages.isEmpty) ...[
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_library_outlined, color: Colors.grey, size: 48),
                    SizedBox(height: 8),
                    Text(
                      'No gallery images',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add up to 10 images',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            SizedBox(
              height: 200,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: _galleryImages.length > 10 ? 10 : _galleryImages.length,
                itemBuilder: (context, index) {
                  final image = _galleryImages[index];
                  final isSelected = _selectedImageIndex == index;
                  return GestureDetector(
                    onTap: () => _selectGalleryImage(index),
                    onLongPress: () => _removeGalleryImage(index),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? Colors.blue[600]! : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Stack(
                          children: [
                            Image.file(
                              image,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) => Center(
                                child: Text(
                                  'Error',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            ),
                            if (isSelected)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[600],
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            Positioned(
                              top: 4,
                              left: 4,
                              child: GestureDetector(
                                onTap: () => _removeGalleryImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_galleryImages.length > 10)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Maximum 10 images. ${_galleryImages.length - 10} more not shown.',
                  style: TextStyle(color: Colors.orange[600], fontSize: 12),
                ),
              ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildProfileImageSection(),
        const SizedBox(height: 16),
        _buildGallerySection(),
      ],
    );
  }
}