import 'dart:io';

import 'package:flutter/material.dart';

abstract class HelperImageContract {
  Future<void> addSampleImages(BuildContext context);
  Future<File?> pickImageFile(BuildContext context);
  void addProfilePicture(BuildContext context);
  Future<void> submitForm(BuildContext context, GlobalKey<FormState> formKey);
  Future<String> uploadToCloudinary(File imageFile);
}
