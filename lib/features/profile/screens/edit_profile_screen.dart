import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../cubit/profile_cubit.dart';
import '../repository/local_image_service.dart';
import '../../../models/user_profile.dart';
import '../../../core/widgets/profile_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;
  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _universityController;
  late double _studyGoal;
  String? _photoPath;
  bool _saving = false;

  final _localImageService = LocalImageService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.displayName);
    _universityController = TextEditingController(text: widget.profile.university);
    _studyGoal = widget.profile.studyGoalHours;
    _photoPath = widget.profile.photoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _universityController.dispose();
    super.dispose();
  }

  Future<void> _pickAndCropImage() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 95,
    );
    if (picked == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 90,
      compressFormat: ImageCompressFormat.jpg,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Profile Picture',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          backgroundColor: Colors.black,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          aspectRatioPresets: const [CropAspectRatioPreset.square],
          hideBottomControls: false,
          cropFrameColor: Colors.white,
          cropGridColor: Colors.white54,
          showCropGrid: true,
        ),
        IOSUiSettings(
          title: 'Crop Profile Picture',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          aspectRatioPresets: const [CropAspectRatioPreset.square],
          rotateButtonsHidden: false,
          resetButtonHidden: false,
        ),
      ],
    );
    if (cropped == null) return;

    setState(() => _saving = true);
    try {
      final savedPath = await _localImageService.saveProfilePicture(
        widget.profile.uid,
        File(cropped.path),
      );
      setState(() => _photoPath = savedPath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save image: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _save() {
    final updated = widget.profile.copyWith(
      displayName: _nameController.text.trim(),
      university: _universityController.text.trim(),
      studyGoalHours: _studyGoal,
      photoUrl: _photoPath,
    );
    context.read<ProfileCubit>().updateProfile(updated);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Stack(
              children: [
                ProfileAvatar(
                  imagePath: _photoPath,
                  fallbackInitial: widget.profile.displayName.isNotEmpty
                      ? widget.profile.displayName[0]
                      : '',
                  radius: 48,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 18,
                    child: _saving
                        ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : IconButton(
                      icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                      onPressed: _pickAndCropImage,
                      tooltip: _photoPath == null ? 'Add photo' : 'Change photo',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Display Name'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _universityController,
            decoration: const InputDecoration(labelText: 'University / College'),
          ),
          const SizedBox(height: 24),
          Text('Daily Study Goal: ${_studyGoal.toStringAsFixed(1)} hours'),
          Slider(
            value: _studyGoal,
            min: 1,
            max: 12,
            divisions: 22,
            label: '${_studyGoal.toStringAsFixed(1)}h',
            onChanged: (value) => setState(() => _studyGoal = value),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _save, child: const Text('Save Changes')),
        ],
      ),
    );
  }
}