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

class UpdateIncome extends ConsumerStatefulWidget {
  final Map<String, dynamic> incomeData;

  const UpdateIncome({Key? key, required this.incomeData}) : super(key: key);

  @override
  _UpdateIncomeState createState() => _UpdateIncomeState();
}

class _UpdateIncomeState extends ConsumerState<UpdateIncome> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Map<String, dynamic>? selectedCategory;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    _amountController.text =
        NumberFormat("#,###").format(widget.incomeData['amount']);
    _descriptionController.text = widget.incomeData['description'];
    selectedCategory = {
      'title': widget.incomeData['categoryName'],
      'icon': widget.incomeData['categoryImage'],
    };

    // Add a listener to format the amount input
    _amountController.addListener(() {
      final text = _amountController.text.replaceAll(',', '');
      if (text.isNotEmpty) {
        final formattedText = NumberFormat("#,###").format(int.parse(text));
        _amountController.value = _amountController.value.copyWith(
          text: formattedText,
          selection: TextSelection.collapsed(offset: formattedText.length),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ແກ້ໄຂລາຍການລາຍຈ່າຍ'),
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
                    categoryCardChoosing(context),
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
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          hintText: 'ປ້ອນຈຳນວນເງີນ'),
                    ),
                    const SizedBox(height: 40),
                    const Text('ລາຍລະອຽດ'),
                    TextField(
                      maxLines: 4,
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
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
              onPressed: () async {
                final userData = ref.read(userDataProvider);

                // Extract raw amount value
                final rawAmount = _amountController.text.replaceAll(',', '');
                final amountValue = double.tryParse(rawAmount) ?? 0.0;

                final updatedData = {
                  'amount': amountValue,
                  'description': _descriptionController.text,
                  'categoryImage': selectedCategory!['icon'],
                  'categoryName': selectedCategory!['title'],
                  'user': userData['_id'].toString(),
                };

                await ApiService.updateOutcome(
                  widget.incomeData['_id'],
                  amount: updatedData['amount'],
                  description: updatedData['description'],
                  categoryImage: updatedData['categoryImage'],
                  categoryName: updatedData['categoryName'],
                  user: updatedData['user'],
                );

                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.success,
                  animType: AnimType.scale,
                  title: 'ສຳເລັດ',
                  desc: 'ແກ້ໄຂລາຍການສຳເລັດ',
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
              child: const Text('ບັນທຶກ'),
            ),
          ),
        ],
      ),
    );
  }

  GestureDetector categoryCardChoosing(BuildContext context) {
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
                const SizedBox(width: 15),
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
