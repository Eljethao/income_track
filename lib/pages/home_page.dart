import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:income_track/config/config.dart';
import 'package:income_track/providers/auth_provider.dart';
import 'package:income_track/widgets/loading_page.dart';
import 'package:intl/intl.dart'; // Import intl for number formatting
import 'package:awesome_dialog/awesome_dialog.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  Map<String, dynamic> _outcomesData = {};
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch outcomes dynamically after state initialization
    final userState = ref.watch(userDataProvider);
    if (userState.isNotEmpty && userState['_id'] != null) {
      getOutComeByUser(userState['_id']);
    } else {
      print("No user logged in");
      setState(() {
        _isLoading = false; // Stop loading if no user is logged in
      });
    }
  }

  void deleteOutcome(String id) async {
    try {
      final userState = ref.read(userDataProvider);
      final userId = userState['_id'];

      if (userId == null) return;

      final url = Uri.parse('$ENDPOINT_URL/v1/api/outcomes/$id');
      final response = await http.delete(url, headers: {
        'Content-Type': 'application/json',
        'user': userId,
      });

      if (response.statusCode == 200) {
        // Refresh the outcomes list after deletion
        getOutComeByUser(userId);
        context.pop();
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.scale,
          title: 'ສຳເລັດ',
          desc: 'ລືບລາຍການສຳເລັດ',
          btnOkOnPress: () {
            context.go('/home'); // Navigate to the home page
          },
          btnOkText: 'ຕົກລົງ',
          dismissOnTouchOutside: false,
        ).show();
      } else {
        print("Failed to delete outcome: ${response.reasonPhrase}");
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.scale,
          title: 'ບໍສຳເລັດ',
          desc: 'ລືບລາຍການບໍສຳເລັດ',
          btnOkOnPress: () {
            context.go('/home'); // Navigate to the home page
          },
          btnOkText: 'ຕົກລົງ',
          dismissOnTouchOutside: false,
        ).show();
      }
    } catch (e) {
      print("Error deleting outcome: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ລືບລາຍການບໍ່ສຳເລັດ')),
      );
    }
  }

  void getOutComeByUser(String userId) async {
    try {
      final url = Uri.parse('$ENDPOINT_URL/v1/api/outcomes?user=$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _outcomesData = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        print("Error: ${response.reasonPhrase}");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching outcomes: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    DateFormat formatter = DateFormat('dd-MM-yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ສະຫລຸບລາຍຈ່າຍ',
          style: TextStyle(),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple.shade100,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.account_circle,
              size: 40,
            ),
            onPressed: () {
              context.go('/profile');
            },
          )
        ],
      ),
      body: _isLoading
          ?  Center(
              child: LoadingPage(), // Show loading indicator
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  walletCard(context),
                  const SizedBox(height: 30),
                  filterGroupCard(),
                  const SizedBox(height: 30),
                  Expanded(
                    child: ListView.builder(
                      itemCount: (_outcomesData['outcomes'] ?? []).length,
                      itemBuilder: (context, index) {
                        final outcome = _outcomesData['outcomes'][index];
                        return Column(
                          children: [
                            ListTile(
                              leading: CachedNetworkImage(
                                imageUrl: outcome['categoryImage'],
                                width: 28,
                                height: 28,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                              title: Text(
                                outcome['categoryName'] ?? 'Unknown Category',
                                style: const TextStyle(fontSize: 14),
                              ),
                              subtitle: Text(
                                outcome['description'] ?? 'No description',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.grey.shade500),
                              ),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '-${NumberFormat("#,###").format(outcome['amount'] ?? 0)} ກີບ',
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.red),
                                  ),
                                  Text(
                                    formatter.format(
                                        DateTime.parse(outcome['createdAt']) ??
                                            DateTime.now()),
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.deepPurple.shade100),
                                        child: CachedNetworkImage(
                                          imageUrl: outcome['categoryImage'],
                                          width: 38,
                                          height: 38,
                                          placeholder: (context, url) =>
                                              const CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                        ),
                                      ),
                                      content: SizedBox(
                                        height: 65,
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text('ລາຍລະອຽດ: '),
                                                Text(outcome['description'] ??
                                                    'N/A')
                                              ],
                                            ),
                                            const Divider(),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text('ຈຳນວນເງິນ: '),
                                                Text(
                                                    '-${NumberFormat("#,###").format(outcome['amount'] ?? 0)} ກີບ')
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            // Delete Button
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.red.shade600,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  )),
                                              onPressed: () {
                                                deleteOutcome(outcome['_id']);
                                              },
                                              child: const Row(
                                                children: [
                                                  Icon(Icons.delete),
                                                  Text('ລືບ'),
                                                ],
                                              ),
                                            ),
                                            // Update Button
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  backgroundColor: Colors
                                                      .deepPurple.shade100),
                                              onPressed: () {
                                                context.go('/update',
                                                    extra: outcome);
                                              },
                                              child: const Row(
                                                children: [
                                                  Icon(Icons.edit),
                                                  Text('ແກ້ໄຂ'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            const Divider(),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Row walletCard(BuildContext context) {
    final totalOutcomes = _outcomesData["totalOutcomes"] ?? 0;
    final formattedAmount =
        NumberFormat("#,###").format(totalOutcomes); // Format the amount

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.15,
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/wallet.png",
                    width: 55,
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ຈຳນວນເງີນປັດຈຸບັນ',
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        '$formattedAmount ກີບ',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Row filterGroupCard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          width: 50,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Column(
            children: [
              Icon(Icons.account_balance_wallet),
              Text(
                'ລາຍຈ່າຍ',
                style: TextStyle(fontSize: 10),
              )
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 1, // Width of the divider
          height: 40, // Height of the divider
          color: Colors.grey, // Color of the divider
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.all(8.0),
          width: 50,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Column(
            children: [
              Icon(Icons.query_stats),
              Text(
                'ວິເຄາະ',
                style: TextStyle(fontSize: 10),
              )
            ],
          ),
        ),
      ],
    );
  }
}
