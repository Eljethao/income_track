import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:income_track/config/config.dart';
import 'package:income_track/providers/auth_provider.dart';
import 'package:income_track/providers/category_provider.dart';
import 'package:income_track/services/api_service.dart';
import 'package:income_track/widgets/category_bottom_sheet.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class AddIncome extends ConsumerWidget {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  AddIncome({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    double amountValue = 0.0;

    // Add a listener to format the amount with commas
    _amountController.addListener(() {
      final text = _amountController.text.replaceAll(',', '');
      if (text.isNotEmpty) {
        // Format the amount with commas
        final formattedText = NumberFormat("#,###").format(int.parse(text));

        // Assign the raw value (without commas) to ApiService
        amountValue = double.tryParse(text) ?? 0.0;

        _amountController.value = _amountController.value.copyWith(
          text: NumberFormat("#,###").format(int.parse(text)),
          selection:
              TextSelection.collapsed(offset: _amountController.text.length),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('ເພີ່ມລາຍການລາຍຈ່າຍ'),
        backgroundColor: Colors.deepPurple.shade100,
        leading: IconButton(
          onPressed: () {
            context.go('/home');
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('ເລືອກໝວດຫມູ່'),
                    categoryCardChoosing(context, ref, selectedCategory),
                    const SizedBox(height: 40),
                    const Text('ຈໍານວນເງີນ'),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.payments_rounded,
                            color: Colors.deepPurple.shade200,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              6.0,
                            ), // Adjust the radius as needed
                          ),
                          hintText: 'ປ້ອນຈຳນວນເງີນ'),
                    ),
                    const SizedBox(height: 40),
                    const Text('ລາຍລະອຽດ'),
                    TextField(
                      maxLines: 4,
                      controller: _categoryController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)),
                        hintText: 'ປ້ອນລາຍລະອຽດ',
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                final userData = ref.read(userDataProvider);

                ApiService.createOutcome(
                  amount: amountValue,
                  description: _categoryController.text,
                  categoryImage: selectedCategory!['icon'],
                  categoryName: selectedCategory['title'],
                  user: userData['_id'].toString(),
                );

                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.success,
                  animType: AnimType.scale,
                  title: 'ສຳເລັດ',
                  desc: 'ເພີ່ມລາຍການສຳເລັດ',
                  btnOkOnPress: () {
                    context.go('/home'); // Navigate to the home page
                  },
                  btnOkText: 'ຕົກລົງ',
                  dismissOnTouchOutside: false,
                ).show();
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                backgroundColor: Colors.deepPurple.shade100,
              ),
              child: const Text('ເພີ່ມ'),
            ),
          )
        ],
      ),
    );
  }

  GestureDetector categoryCardChoosing(BuildContext context, WidgetRef ref,
      Map<String, dynamic>? selectedCategory) {
    return GestureDetector(
      onTap: () {
        categoryBottomSheet(context, ref);
      },
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade600, width: 2),
            borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // Icon(
                //   selectedCategory?['icon'] ?? Icons.food_bank_outlined,
                //   size: 45,
                // ),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.deepPurple.shade100,
                  ),
                  child: CachedNetworkImage(
                    imageUrl:
                        selectedCategory?['icon'] ?? '$IMAGE_URL/diet.png',
                    width: 28,
                    height: 28,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        Image.network('$IMAGE_URL/diet.png'),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Text(
                  selectedCategory?['title'] ?? 'ອາຫານ',
                  style: const TextStyle(fontSize: 20),
                )
              ],
            ),
            const Icon(Icons.arrow_forward_ios)
          ],
        ),
      ),
    );
  }
}
