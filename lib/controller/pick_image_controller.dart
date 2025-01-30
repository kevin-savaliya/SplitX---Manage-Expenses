import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/app_font.dart';
import 'package:split/utils/assets.dart';
import 'package:split/utils/string.dart';

class PickImageController extends GetxController {
  final ImagePicker picker = ImagePicker();

  TextEditingController userNameController = TextEditingController();
  TextEditingController groupNameController = TextEditingController();

  final selectedImages = <RxString>[].obs;

  RxBool isAvatarSelected = false.obs;
  RxString selectedAvatarId = "".obs;

  final _selectedGroupProfileImage = "".obs;
  final _selectedUserProfileImage = "".obs;
  final _selectedGroupChatImage = "".obs;

  String get selectedGroupProfileImage => _selectedGroupProfileImage.value;

  String get selectedUserProfileImage => _selectedUserProfileImage.value;

  String get selectedGroupChatImage => _selectedGroupChatImage.value;

  set selectedGroupProfileImage(String value) {
    _selectedGroupProfileImage.value = value;
  }

  set selectedUserProfileImage(String value) {
    _selectedUserProfileImage.value = value;
  }

  set selectedGroupChatImage(String value) {
    _selectedGroupChatImage.value = value;
  }

  TextEditingController titleController = TextEditingController();

  CroppedFile? croppedPostFile;
  CroppedFile? croppedProfileFile;

  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  pickImageFromCamera() async {
    try {
      final XFile? image = await picker.pickImage(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.front,
          imageQuality: 50);

      if (image != null) {
        File imageFile = File(image.path);

        croppedProfileFile = await ImageCropper().cropImage(
          sourcePath: imageFile.path,
          uiSettings: [
            AndroidUiSettings(
              toolbarColor: AppColors.white,
              toolbarTitle: 'Crop Image',
            ),
            IOSUiSettings(
              title: 'Crop Image',
            )
          ],
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
            CropAspectRatioPreset.ratio5x4,
            CropAspectRatioPreset.ratio5x3,
            CropAspectRatioPreset.ratio7x5,
          ],
        );

        if (croppedProfileFile != null) {
          selectedImages.add(croppedProfileFile!.path.obs);
          print("Image Picked and Cropped from Camera : $selectedImages");
        } else {
          print("Cropping cancelled");
        }
      } else {
        print("Image picking cancelled");
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  pickImageFromGallery() async {
    final XFile? image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image != null) {
      File imageFile = File(image.path);
      croppedProfileFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarColor: AppColors.white,
            toolbarTitle: 'Crop Image',
          ),
          IOSUiSettings(
            title: 'Crop Image',
          )
        ],
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9,
          CropAspectRatioPreset.ratio5x4,
          CropAspectRatioPreset.ratio5x3,
          CropAspectRatioPreset.ratio7x5,
        ],
      );

      selectedImages.add(croppedProfileFile!.path.obs);

      print("Image Picked From Gallery");
    }
    Get.back();
  }

  Future<void> pickGroupChatImage(context) async {
    final XFile? image =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (image != null) {
      File imageFile = File(image.path);
      croppedProfileFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarColor: AppColors.white,
            toolbarTitle: 'Crop Image',
          ),
          IOSUiSettings(
            title: 'Crop Image',
          )
        ],
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9,
          CropAspectRatioPreset.ratio5x4,
          CropAspectRatioPreset.ratio5x3,
          CropAspectRatioPreset.ratio7x5,
        ],
      );
      selectedAvatarId.value = "";
      selectedGroupChatImage = croppedProfileFile!.path;
      _selectedGroupChatImage.value = croppedProfileFile!.path;

      print("Group Chat Image Picked From Gallery");
    }
  }

  Future<void> pickGroupImage(context) async {
    final XFile? image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (image != null) {
      // _selectedImage.value = image.path;

      File imageFile = File(image.path);
      croppedProfileFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarColor: AppColors.white,
            toolbarTitle: 'Crop Image',
          ),
          IOSUiSettings(
            title: 'Crop Image',
          )
        ],
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9,
          CropAspectRatioPreset.ratio5x4,
          CropAspectRatioPreset.ratio5x3,
          CropAspectRatioPreset.ratio7x5,
        ],
      );

      _selectedGroupProfileImage.value = croppedProfileFile!.path;

      print("Image Picked From Gallery");
    }
    // return showModalBottomSheet(
    //   backgroundColor: Colors.transparent,
    //   context: context,
    //   builder: (context) {
    //     return Container(
    //       height: 170,
    //       margin: const EdgeInsets.symmetric(horizontal: 5),
    //       padding: const EdgeInsets.symmetric(horizontal: 15),
    //       decoration: BoxDecoration(
    //         borderRadius: const BorderRadius.only(
    //             topRight: Radius.circular(15), topLeft: Radius.circular(15)),
    //         color: AppColors.white,
    //       ),
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.start,
    //         children: [
    //           const SizedBox(
    //             height: 25,
    //           ),
    //           Text(
    //             ConstString.selectchoice,
    //             style: Theme.of(context).textTheme.titleLarge!.copyWith(
    //                 fontSize: 16,
    //                 color: AppColors.black,
    //                 fontFamily: AppFont.fontSemiBold),
    //           ),
    //           const SizedBox(
    //             height: 10,
    //           ),
    //           Container(
    //             margin: const EdgeInsets.all(5),
    //             height: 1,
    //             width: double.infinity,
    //             decoration: BoxDecoration(
    //               borderRadius: BorderRadius.circular(10),
    //               color: AppColors.splashdetail,
    //             ),
    //           ),
    //           const SizedBox(
    //             height: 15,
    //           ),
    //           Row(
    //             children: [
    //               Expanded(
    //                 child: GestureDetector(
    //                   onTap: () async {
    //                     final XFile? image = await picker.pickImage(
    //                         source: ImageSource.camera, imageQuality: 40);
    //
    //                     if (image != null) {
    //                       // _selectedImage.value = image.path;
    //
    //                       File imageFile = File(image.path);
    //                       croppedProfileFile = await ImageCropper().cropImage(
    //                         sourcePath: imageFile.path,
    //                         uiSettings: [
    //                           AndroidUiSettings(
    //                             toolbarColor: AppColors.white,
    //                             toolbarTitle: 'Crop Image',
    //                           ),
    //                           IOSUiSettings(
    //                             title: 'Crop Image',
    //                           )
    //                         ],
    //                         aspectRatioPresets: [
    //                           CropAspectRatioPreset.square,
    //                           CropAspectRatioPreset.ratio3x2,
    //                           CropAspectRatioPreset.original,
    //                           CropAspectRatioPreset.ratio4x3,
    //                           CropAspectRatioPreset.ratio16x9,
    //                           CropAspectRatioPreset.ratio5x4,
    //                           CropAspectRatioPreset.ratio5x3,
    //                           CropAspectRatioPreset.ratio7x5,
    //                         ],
    //                       );
    //
    //                       _selectedGroupProfileImage.value =
    //                           croppedProfileFile!.path;
    //
    //                       print("Image Picked From Camera");
    //                     }
    //                     Get.back();
    //                   },
    //                   child: Column(
    //                     children: [
    //                       Image.asset(AppIcons.camerapng, height: 45),
    //                       const SizedBox(
    //                         height: 10,
    //                       ),
    //                       Text(
    //                         ConstString.camera,
    //                         style: Theme.of(context)
    //                             .textTheme
    //                             .bodySmall!
    //                             .copyWith(
    //                                 fontSize: 14.5, color: AppColors.black),
    //                       )
    //                     ],
    //                   ),
    //                 ),
    //               ),
    //               Expanded(
    //                   child: GestureDetector(
    //                 onTap: () async {
    //                   final XFile? image = await picker.pickImage(
    //                       source: ImageSource.gallery, imageQuality: 50);
    //
    //                   if (image != null) {
    //                     // _selectedImage.value = image.path;
    //
    //                     File imageFile = File(image.path);
    //                     croppedProfileFile = await ImageCropper().cropImage(
    //                       sourcePath: imageFile.path,
    //                       uiSettings: [
    //                         AndroidUiSettings(
    //                           toolbarColor: AppColors.white,
    //                           toolbarTitle: 'Crop Image',
    //                         ),
    //                         IOSUiSettings(
    //                           title: 'Crop Image',
    //                         )
    //                       ],
    //                       aspectRatioPresets: [
    //                         CropAspectRatioPreset.square,
    //                         CropAspectRatioPreset.ratio3x2,
    //                         CropAspectRatioPreset.original,
    //                         CropAspectRatioPreset.ratio4x3,
    //                         CropAspectRatioPreset.ratio16x9,
    //                         CropAspectRatioPreset.ratio5x4,
    //                         CropAspectRatioPreset.ratio5x3,
    //                         CropAspectRatioPreset.ratio7x5,
    //                       ],
    //                     );
    //
    //                     _selectedGroupProfileImage.value =
    //                         croppedProfileFile!.path;
    //
    //                     print("Image Picked From Gallery");
    //                   }
    //                   Get.back();
    //                 },
    //                 child: Column(
    //                   children: [
    //                     Image.asset(AppIcons.gallerypng, height: 45),
    //                     const SizedBox(
    //                       height: 10,
    //                     ),
    //                     Text(
    //                       ConstString.gallery,
    //                       style: Theme.of(context)
    //                           .textTheme
    //                           .bodySmall!
    //                           .copyWith(fontSize: 14.5, color: AppColors.black),
    //                     )
    //                   ],
    //                 ),
    //               )),
    //             ],
    //           )
    //         ],
    //       ),
    //     );
    //   },
    // );
  }

  Future<void> pickUserImage(context) async {
    final XFile? image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (image != null) {
      File imageFile = File(image.path);
      croppedProfileFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarColor: AppColors.white,
            toolbarTitle: 'Crop Image',
          ),
          IOSUiSettings(
            title: 'Crop Image',
          )
        ],
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9,
          CropAspectRatioPreset.ratio5x4,
          CropAspectRatioPreset.ratio5x3,
          CropAspectRatioPreset.ratio7x5,
        ],
      );
      selectedAvatarId.value = "";
      selectedUserProfileImage = croppedProfileFile!.path;
      _selectedUserProfileImage.value = croppedProfileFile!.path;

      print("Image Picked From Gallery");
    }
    // Get.back();
    // return showModalBottomSheet(
    //   backgroundColor: Colors.transparent,
    //   context: context,
    //   builder: (context) {
    //     return Container(
    //       height: 170,
    //       margin: const EdgeInsets.symmetric(horizontal: 5),
    //       padding: const EdgeInsets.symmetric(horizontal: 15),
    //       decoration: BoxDecoration(
    //         borderRadius: const BorderRadius.only(
    //             topRight: Radius.circular(15), topLeft: Radius.circular(15)),
    //         color: AppColors.white,
    //       ),
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.start,
    //         children: [
    //           const SizedBox(
    //             height: 25,
    //           ),
    //           Text(
    //             ConstString.selectchoice,
    //             style: Theme.of(context).textTheme.titleLarge!.copyWith(
    //                 fontSize: 16,
    //                 color: AppColors.black,
    //                 fontFamily: AppFont.fontSemiBold),
    //           ),
    //           const SizedBox(
    //             height: 10,
    //           ),
    //           Container(
    //             margin: const EdgeInsets.all(5),
    //             height: 1,
    //             width: double.infinity,
    //             decoration: BoxDecoration(
    //               borderRadius: BorderRadius.circular(10),
    //               color: AppColors.splashdetail,
    //             ),
    //           ),
    //           const SizedBox(
    //             height: 15,
    //           ),
    //           Row(
    //             children: [
    //               Expanded(
    //                 child: GestureDetector(
    //                   onTap: () async {
    //                     // selectedAvatarId.value = "";
    //                     final XFile? image = await picker.pickImage(
    //                         source: ImageSource.camera, imageQuality: 40);
    //
    //                     if (image != null) {
    //                       // _selectedImage.value = image.path;
    //
    //                       File imageFile = File(image.path);
    //                       croppedProfileFile = await ImageCropper().cropImage(
    //                         sourcePath: imageFile.path,
    //                         uiSettings: [
    //                           AndroidUiSettings(
    //                             toolbarColor: AppColors.white,
    //                             toolbarTitle: 'Crop Image',
    //                           ),
    //                           IOSUiSettings(
    //                             title: 'Crop Image',
    //                           )
    //                         ],
    //                         aspectRatioPresets: [
    //                           CropAspectRatioPreset.square,
    //                           CropAspectRatioPreset.ratio3x2,
    //                           CropAspectRatioPreset.original,
    //                           CropAspectRatioPreset.ratio4x3,
    //                           CropAspectRatioPreset.ratio16x9,
    //                           CropAspectRatioPreset.ratio5x4,
    //                           CropAspectRatioPreset.ratio5x3,
    //                           CropAspectRatioPreset.ratio7x5,
    //                         ],
    //                       );
    //                       selectedAvatarId.value = "";
    //                       selectedUserProfileImage = croppedProfileFile!.path;
    //                       _selectedUserProfileImage.value =
    //                           croppedProfileFile!.path;
    //
    //                       print("Image Picked From Camera");
    //                     }
    //                     Get.back();
    //                   },
    //                   child: Column(
    //                     children: [
    //                       Image.asset(AppIcons.camerapng, height: 45),
    //                       const SizedBox(
    //                         height: 10,
    //                       ),
    //                       Text(
    //                         ConstString.camera,
    //                         style: Theme.of(context)
    //                             .textTheme
    //                             .bodySmall!
    //                             .copyWith(
    //                                 fontSize: 14.5, color: AppColors.black),
    //                       )
    //                     ],
    //                   ),
    //                 ),
    //               ),
    //               Expanded(
    //                   child: GestureDetector(
    //                 onTap: () async {
    //                   // selectedAvatarId.value = "";
    //                   final XFile? image = await picker.pickImage(
    //                       source: ImageSource.gallery, imageQuality: 50);
    //
    //                   if (image != null) {
    //                     File imageFile = File(image.path);
    //                     croppedProfileFile = await ImageCropper().cropImage(
    //                       sourcePath: imageFile.path,
    //                       uiSettings: [
    //                         AndroidUiSettings(
    //                           toolbarColor: AppColors.white,
    //                           toolbarTitle: 'Crop Image',
    //                         ),
    //                         IOSUiSettings(
    //                           title: 'Crop Image',
    //                         )
    //                       ],
    //                       aspectRatioPresets: [
    //                         CropAspectRatioPreset.square,
    //                         CropAspectRatioPreset.ratio3x2,
    //                         CropAspectRatioPreset.original,
    //                         CropAspectRatioPreset.ratio4x3,
    //                         CropAspectRatioPreset.ratio16x9,
    //                         CropAspectRatioPreset.ratio5x4,
    //                         CropAspectRatioPreset.ratio5x3,
    //                         CropAspectRatioPreset.ratio7x5,
    //                       ],
    //                     );
    //                     selectedAvatarId.value = "";
    //                     selectedUserProfileImage = croppedProfileFile!.path;
    //                     _selectedUserProfileImage.value =
    //                         croppedProfileFile!.path;
    //
    //                     print("Image Picked From Gallery");
    //                   }
    //                   Get.back();
    //                 },
    //                 child: Column(
    //                   children: [
    //                     Image.asset(AppIcons.gallerypng, height: 45),
    //                     const SizedBox(
    //                       height: 10,
    //                     ),
    //                     Text(
    //                       ConstString.gallery,
    //                       style: Theme.of(context)
    //                           .textTheme
    //                           .bodySmall!
    //                           .copyWith(fontSize: 14.5, color: AppColors.black),
    //                     )
    //                   ],
    //                 ),
    //               )),
    //               Expanded(
    //                   child: GestureDetector(
    //                 onTap: () async {
    //                   // _selectedUserProfileImage.value = "";
    //                   Get.back();
    //                   pickUserAvatar(context);
    //                 },
    //                 child: Column(
    //                   children: [
    //                     Image.asset(AppImages.avatar0, height: 45),
    //                     const SizedBox(
    //                       height: 10,
    //                     ),
    //                     Text(
    //                       ConstString.avatar,
    //                       style: Theme.of(context)
    //                           .textTheme
    //                           .bodySmall!
    //                           .copyWith(fontSize: 14.5, color: AppColors.black),
    //                     )
    //                   ],
    //                 ),
    //               )),
    //             ],
    //           )
    //         ],
    //       ),
    //     );
    //   },
    // );
  }

  Future<void> pickUserAvatar(BuildContext context) async {
    // Example list of avatars (assuming these are asset paths)
    final List<String> avatarList = [
      AppImages.avatar1,
      AppImages.avatar2,
      AppImages.avatar3,
      AppImages.avatar4,
      AppImages.avatar5,
      AppImages.avatar6,
      AppImages.avatar7,
      AppImages.avatar8,
      AppImages.avatar9,
      AppImages.avatar10,
      AppImages.avatar11,
      AppImages.avatar12,
      AppImages.avatar13,
      AppImages.avatar14,
      AppImages.avatar15,
      AppImages.avatar16,
      AppImages.avatar17,
      AppImages.avatar18,
      AppImages.avatar19,
      AppImages.avatar20,
      AppImages.avatar21,
      AppImages.avatar22,
      AppImages.avatar23
    ];

    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 500, // Adjust the height as necessary
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: AppColors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              /// show title as a Pic Avtar from below
              const SizedBox(
                height: 10,
              ),
              Text(
                'Select Avatar',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontSize: 16,
                    color: AppColors.black,
                    fontFamily: AppFont.fontSemiBold),
              ),

              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Number of columns
                    crossAxisSpacing: 20, // Horizontal space between items
                    mainAxisSpacing: 10, // Vertical space between items
                  ),
                  itemCount: avatarList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        selectedAvatarId.value =
                            avatarList[index].split('/').last.split('.').first;
                        print(selectedAvatarId);
                        selectedUserProfileImage = '';
                        Get.back();
                      },
                      child: Container(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(avatarList[index]),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String> uploadImage(File image) async {
    final storageReference = FirebaseStorage.instance.ref().child(
        'prescriptions/$currentUserId/${DateTime.now().toIso8601String()}.jpg');
    final uploadTask = storageReference.putFile(image);
    await uploadTask.whenComplete(() => {});
    final downloadUrl = await storageReference.getDownloadURL();
    return downloadUrl;
  }
}
