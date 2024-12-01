import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:income_track/config/config.dart';
import '../providers/category_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

final List<Map<String, dynamic>> items = [
  {'title': 'ຢາ', 'icon': "$IMAGE_URL/medicine.png"},
  {'title': 'ເຄື່ອງດື່ມ', 'icon': "$IMAGE_URL/lemonade.png"},
  {'title': 'ໜັງສື', 'icon': "$IMAGE_URL/book.png"},
  {'title': 'ລົດຈັກ', 'icon': "$IMAGE_URL/motorcycle.png"},
  {'title': 'ATM', 'icon': "$IMAGE_URL/atm-machine.png"},
  {'title': 'ອາຫານ', 'icon': "$IMAGE_URL/diet.png"},
  {'title': 'ເສື້ອຜ້າ', 'icon': "$IMAGE_URL/shirt.png"},
  {'title': 'ທ່ຽວ', 'icon': "$IMAGE_URL/destination.png"},
  {'title': 'tax', 'icon': "$IMAGE_URL/tax.png"},
  {'title': 'netflix', 'icon': "$IMAGE_URL/netflix.png"},
  {'title': 'ອິນເຕີເນັດ', 'icon': "$IMAGE_URL/cloud-hosting.png"},
  {'title': 'ອອມຄຳ', 'icon': "$IMAGE_URL/gold-bars.png"},
  {'title': 'ໂຊຟາ', 'icon': "$IMAGE_URL/seater-sofa.png"},
  {'title': 'ອຸປະກອນໄອທີ', 'icon': "$IMAGE_URL/desktop-computer.png"},
  {'title': 'ພໍ່', 'icon': "$IMAGE_URL/father.png"},
  {'title': 'ພັນທະກິດ', 'icon': "$IMAGE_URL/mission.png"},
  {'title': 'ຄ່າຮຽນ', 'icon': "$IMAGE_URL/study.png"},
  {'title': 'ຄ່າຫ້ອງ', 'icon': "$IMAGE_URL/house.png"},
  {'title': 'ຄ່າໄຟ', 'icon': "$IMAGE_URL/electricity.png"},
  {'title': 'ChatGPT', 'icon': "$IMAGE_URL/chatgpt1.png"},
  {'title': 'ອຸປະກອນໄຟ້າ', 'icon': "$IMAGE_URL/electric-equipment.png"},
];

categoryBottomSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(8.0),
              child: const Text('ເລືອກຫມວດຫມູ່'),
            ),
            const Divider(),
            // Wrap in Expanded or Flexible to handle height constraints
            Expanded(
              child: GridView.builder(
                itemCount: items.length,
                scrollDirection: Axis.vertical,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisExtent: 85,
                  crossAxisSpacing: 4,
                ),
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Update the selected category in Riverpod
                          ref.read(selectedCategoryProvider.notifier).state =
                              items[index];
                          Navigator.pop(context); // Close the bottom sheet
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.deepPurple.shade100,
                          ),
                          child: CachedNetworkImage(
                            imageUrl: items[index]['icon'],
                            width: 28,
                            height: 28,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('${items[index]['title']}'),
                    ],
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