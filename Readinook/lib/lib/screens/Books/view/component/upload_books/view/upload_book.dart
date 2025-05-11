import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reedinook/screens/Books/view/component/upload_books/controller/upload_book_controller.dart';
import 'package:reedinook/utils/colors.dart';

class UploadBooks extends StatefulWidget {
  const UploadBooks({super.key});

  @override
  State<UploadBooks> createState() => _UploadBooksState();
}

class _UploadBooksState extends State<UploadBooks> {
  final UploadBooksController uploadBooksController =
      Get.put(UploadBooksController());
//  final HomeController homeController = Get.find<HomeController>();

  // String currentUser= '';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController ratingController = TextEditingController();
  final TextEditingController pagesController = TextEditingController();
  final TextEditingController isbnController = TextEditingController();
  final TextEditingController bookFormatController = TextEditingController();
  // final TextEditingController genresController = TextEditingController();
  final TextEditingController totalRatingController = TextEditingController();
  String? selectedGenre;

// @override
//   void initState() {
//     super.initState();
//     currentUser = homeController.username;
//   }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      backgroundColor: AppColor.bgcolor,
      body: Stack(
        children: [
          // Background Image
          Container(
            height: MediaQuery.of(context).size.height * 0.25,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/openbooks.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 30,
            left: 12,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Positioned Text "Upload Books"
          Positioned(
            top: MediaQuery.of(context).size.height * 0.1,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Upload Books',
                style: TextStyle(
                  color: AppColor.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.6),
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Positioned Text "Share your story with readers"
          Positioned(
            top: MediaQuery.of(context).size.height * 0.17,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                "Share your story with readers",
                style: TextStyle(
                  color: AppColor.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Scrollable Form in Card
          Padding(
            padding: const EdgeInsets.only(
                top: 180), // Adjusted for proper positioning
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Card with Form
                  Card(
                    color: AppColor.bgcolor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 0), // Removed horizontal margin
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildTextField(
                              "Author Name",
                              uploadBooksController.authorController,
                              onChanged: (value) {
                                uploadBooksController.validateField(
                                    "Author Name", value);
                              },
                            ),
                            _buildTextField(
                              "Title",
                              uploadBooksController.titleController,
                              onChanged: (value) {
                                uploadBooksController.validateField(
                                    "Title", value);
                              },
                            ),

                            _buildTextField(
                              "Description",
                              uploadBooksController.descriptionController,
                              maxLines: 3,
                              onChanged: (value) {
                                uploadBooksController.validateField(
                                    "Description", value);
                              },
                            ),
                            _buildTextField(
                              "Rating (out of 5)",
                              uploadBooksController.ratingController,
                              inputType: TextInputType.number,
                              onChanged: (value) {
                                uploadBooksController.validateField(
                                    "Rating (out of 5)", value);
                              },
                            ),
                            _buildTextField(
                              "Total Pages",
                              uploadBooksController.pagesController,
                              inputType: TextInputType.number,
                              onChanged: (value) {
                                uploadBooksController.validateField(
                                    "Total Pages", value);
                              },
                            ),
                            _buildTextField(
                              "ISBN",
                              uploadBooksController.isbnController,
                              onChanged: (value) {
                                uploadBooksController.validateField(
                                    "ISBN", value);
                              },
                            ),
                            _buildTextField(
                              "Book Format",
                              uploadBooksController.bookFormatController,
                              onChanged: (value) {
                                uploadBooksController.validateField(
                                    "Book Format", value);
                              },
                            ),
                            // Dropdown for genres
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: DropdownButtonFormField<String>(
                                value: selectedGenre,
                                hint: const Text(
                                  "Select Genre",
                                  style: TextStyle(color: AppColor.iconstext),
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: AppColor.unselected,
                                ),
                                dropdownColor: AppColor
                                    .unselected, // Background color for the dropdown menu
                                iconEnabledColor: AppColor
                                    .iconstext, // Color for the dropdown arrow
                                items: [
                                  'History',
                                  'Art',
                                  'Politics',
                                  'Romance',
                                  'Biography',
                                  'Fantasy',
                                ].map((genre) {
                                  return DropdownMenuItem<String>(
                                    value: genre,
                                    child: Text(
                                      genre,
                                      style:
                                          TextStyle(color: AppColor.iconstext),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  setState(() {
                                    uploadBooksController.selectedGenre = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a genre';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            _buildTextField(
                              "Total Ratings",
                              uploadBooksController.totalRatingController,
                              inputType: TextInputType.number,
                              onChanged: (value) {
                                uploadBooksController.validateField(
                                    "Total Ratings", value);
                              },
                            ),
                            const SizedBox(height: 16),
// Upload Image
                            GestureDetector(
                              onTap: uploadBooksController.pickImage,
                              child: Obx(() => Container(
                                    height: 150,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                      image: uploadBooksController
                                                  .selectedImage.value !=
                                              null
                                          ? DecorationImage(
                                              image: FileImage(
                                                  uploadBooksController
                                                      .selectedImage.value!),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: uploadBooksController
                                                .selectedImage.value ==
                                            null
                                        ? const Center(
                                            child: Text(
                                              "Upload Book Image",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey),
                                            ),
                                          )
                                        : null,
                                  )),
                            ),
                            const SizedBox(height: 20),

                            // Submit Button
                            Obx(() => ElevatedButton(
                                  onPressed: () {
                                    // Run validation for all fields
                                    _formKey.currentState!
                                        .save(); // Save field values
                                    if (_formKey.currentState!.validate()) {
                                      if (!uploadBooksController
                                          .isLoading.value) {
                                        uploadBooksController
                                            .uploadBookDetails(currentUserId);
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColor.clickedbutton,
                                  ),
                                  child: uploadBooksController.isLoading.value
                                      ? const SizedBox
                                          .shrink() // Do not show circular indicator
                                      : const Text("Submit"),
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Obx(() {
            if (uploadBooksController.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType inputType = TextInputType.text,
      int maxLines = 1,
      Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Obx(() {
        // Using GetX for dynamic state updates
        return TextFormField(
          controller: controller,
          keyboardType: inputType,
          maxLines: maxLines,
          style: const TextStyle(
            color: AppColor.white,
          ),
          onChanged: onChanged, // Trigger validation on input change
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
              color: AppColor.iconstext,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColor.clickedbutton,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColor.unselected,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: AppColor.unselected,
            errorText:
                uploadBooksController.errors[label], // Show error if exists
          ),
          onFieldSubmitted: (value) {
            uploadBooksController.validateField(
                label, value); // Validation on field submit
          },
          validator: (value) {
            return uploadBooksController
                .errors[label]; // Validation during form submission
          },
        );
      }),
    );
  }
}
