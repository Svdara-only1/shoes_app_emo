// import 'package:computer_store/bloc/cart_bloc.dart';
import 'package:computer_store/bloc/cart_bloc.dart';
import 'package:computer_store/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

// ignore: must_be_immutable
class PaymentScreen extends StatefulWidget {
  double totalAmount;
  PaymentScreen({super.key, required this.totalAmount});

  // final CartState cart = CartState(cartList: []);
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedBank = "";

  String _prettyDateTime() {
    final now = DateTime.now();
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    String two(int n) => n.toString().padLeft(2, "0");
    return "${two(now.day)} ${months[now.month - 1]} ${now.year} • ${two(now.hour)}:${two(now.minute)}";
  }

  void _showQrThenSuccessAndGoHome() {
    int scanCount = 0; // Counter for scans
    const int totalScans = 10; // Number of seconds/counts to simulate scanning

    // Show QR dialog with counter
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            // Timer to update scan count every second
            Future.delayed(const Duration(seconds: 1), () {
              if (!mounted) return;
              if (scanCount < totalScans) {
                setStateDialog(() {
                  scanCount++;
                });
              } else {
                // After counter finishes, close QR and show success
                Navigator.of(context).pop();
                _showSuccessDialog();
              }
            });

            return AlertDialog(
              title: const Text("Scan Here"),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: SizedBox(
                width: 320,
                height: 370,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    QrImageView(
                      data: 'This is a simple QR code',
                      version: QrVersions.auto,
                      size: 320,
                      gapless: false,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Scanned:  $scanCount • Wait for $totalScans s",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSuccessDialog() {
    context.read<CartBloc>().add(ClearCart());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Container(
            width: 300,
            height: 300,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Image.network(
                  "https://i.pinimg.com/736x/48/56/ed/4856ed48c1120a2cbe35ff7a9ee3368e.jpg",
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 30),
                const Text(
                  "Order Confirm",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Thank you for your order!",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(Colorr.primaryColorBlue),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text("Back"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Color(Colorr.primaryColorBlue);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header: Amount + Date
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.payments_rounded, color: primary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Total Amount",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "\$ ${widget.totalAmount.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month_rounded,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _prettyDateTime(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Section title
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Choose Payment Method",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 12),

                // Options
                paymentOption(
                  bank: "ABA",
                  subtitle: "Pay via ABA Mobile / QR",
                  image:
                      "https://play-lh.googleusercontent.com/WU6sZMD1UspzwqYnlACtmN60rckp8hoINSgsR21mKLJBbsHPwXtzwvOocpjC7FcO1g",
                ),
                const SizedBox(height: 12),
                paymentOption(
                  bank: "ACLEDA",
                  subtitle: "Pay via ACLEDA Mobile / QR",
                  image:
                      "https://www.acledabank.com.kh/kh/assets/download_material/download-logo-blue.jpg",
                ),
                const SizedBox(height: 12),
                paymentOption(
                  bank: "Cash on delivery",
                  subtitle: "Pay when the order arrives",
                  image:
                      "https://img.freepik.com/free-vector/man-riding-scooter-white-background_1308-46379.jpg?semt=ais_hybrid&w=740&q=80",
                ),

                const Spacer(),

                // Pay Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      // cart.remove();
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
                        context.read<CartBloc>().add(ClearCart());

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Order placed successfully (Cash on Delivery)",
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );

                        // Go back Home after success
                        Future.delayed(const Duration(seconds: 1), () {
                          if (!mounted) return;
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                content: Container(
                                  width: 300,
                                  height: 300,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 40),
                                      Image.network(
                                        "https://i.pinimg.com/736x/48/56/ed/4856ed48c1120a2cbe35ff7a9ee3368e.jpg",
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                      SizedBox(height: 30),
                                      Text(
                                        "Order confirm",
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "Thank you for Order Me",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      SizedBox(height: 20),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(
                                            Colorr.primaryColorBlue,
                                          ),
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () {
                                          Navigator.of(
                                            context,
                                          ).popUntil((route) => route.isFirst);
                                        },
                                        child: Text("Back"),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        });
                        return;
                      }

                      // ABA or ACLEDA -> show QR, wait 30s, success, go Home
                      if (selectedBank == "ABA" || selectedBank == "ACLEDA") {
                        _showQrThenSuccessAndGoHome();
                      }

                      // Redirect snackbar (kept)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Redirecting to $selectedBank payment"),
                          backgroundColor: primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          selectedBank.isEmpty
                              ? "Pay now"
                              : "Pay with $selectedBank",
                          style: const TextStyle(
                            fontSize: 17,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Secure payment • Your information is protected",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget paymentOption({
    required String bank,
    required String image,
    String? subtitle,
  }) {
    final primary = Color(Colorr.primaryColorBlue);
    bool isSelected = selectedBank == bank;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        setState(() {
          selectedBank = bank;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? primary.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primary : Colors.grey.shade200,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.07 : 0.04),
              blurRadius: isSelected ? 18 : 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 52,
                height: 52,
                color: Colors.grey.shade50,
                child: Image.network(image, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bank,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: isSelected ? primary : Colors.grey.shade400,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
