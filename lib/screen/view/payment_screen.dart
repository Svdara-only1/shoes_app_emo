import 'package:computer_store/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

// ignore: must_be_immutable
class PaymentScreen extends StatefulWidget {
  double totalAmount;
  PaymentScreen({super.key, required this.totalAmount});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedBank = "";
  // example amount

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Amount Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    "Total Amount",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "\$ ${widget.totalAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Choose Payment Method",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 12),

            // ABA Bank
            paymentOption(
              bank: "ABA",
              image:
                  "https://play-lh.googleusercontent.com/WU6sZMD1UspzwqYnlACtmN60rckp8hoINSgsR21mKLJBbsHPwXtzwvOocpjC7FcO1g",
            ),

            const SizedBox(height: 12),

            // ACLEDA Bank
            paymentOption(
              bank: "ACLEDA",
              image:
                  "https://www.acledabank.com.kh/kh/assets/download_material/download-logo-blue.jpg",
            ),

            const SizedBox(height: 12),

            // Delivery
            paymentOption(
              bank: "Cash on delivery",
              image:
                  "https://img.freepik.com/free-vector/man-riding-scooter-white-background_1308-46379.jpg?semt=ais_hybrid&w=740&q=80",
            ),

            const Spacer(),

            // Pay Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  if (selectedBank.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please select a payment method"),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }

                  // Cash on Delivery
                  if (selectedBank == "Cash on delivery") {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Order placed successfully (Cash on Delivery)",
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                  if(selectedBank == "ABA" || selectedBank == "ACLEDA"){
                    showDialog(context: context, builder: (context) {
                      return AlertDialog(
                        title: Text("Scan Here"),
                        backgroundColor: Colors.white,
                        content: Container(
                          width: 320,
                          height: 320,
                          child: Center(
                            child: QrImageView(
                              data: 'This is a simple QR code',
                              version: QrVersions.auto,
                              size: 320,
                              gapless: false,
                            ),
                          ),
                        ),
                      );
                    },);
                  }
                  // ABA or ACLEDA
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Redirecting to $selectedBank payment"),
                      backgroundColor: Color(Colorr.primaryColorBlue),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );

                  // TODO:
                  // Navigate to QR / Bank payment screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(Colorr.primaryColorBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Pay with $selectedBank",
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget paymentOption({required String bank, required String image}) {
    bool isSelected = selectedBank == bank;

    return InkWell(
      onTap: () {
        setState(() {
          selectedBank = bank;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Color(Colorr.primaryColorBlue)
                : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Image.network(image, width: 50, height: 50, fit: BoxFit.cover),
            SizedBox(width: 16),
            Text(
              bank,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? Color(Colorr.primaryColorBlue) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
