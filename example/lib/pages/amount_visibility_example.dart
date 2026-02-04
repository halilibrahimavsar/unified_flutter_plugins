import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unified_flutter_features/unified_flutter_features.dart';

class AmountVisibilityExample extends StatelessWidget {
  const AmountVisibilityExample({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AmountVisibilityCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Amount Visibility Example'),
          actions: const [
            AmountVisibilityButton(),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Amount Display Examples',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Blur Mode Example
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Blur Mode:'),
                      const SizedBox(height: 8),
                      AmountDisplay(
                        amount: 1234.56,
                        style: Theme.of(context).textTheme.titleMedium,
                        obscureMode: AmountObscureMode.blur,
                        blurSigma: 8,
                        animationDuration: const Duration(milliseconds: 280),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Custom blur with 8px sigma and 280ms animation',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Replace Mode Example
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Replace Mode (Custom hidden text):'),
                      SizedBox(height: 8),
                      AmountDisplay(
                        amount: 5000.00,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                        obscureMode: AmountObscureMode.replace,
                        hiddenText: '••••••',
                        animationDuration: Duration(milliseconds: 350),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Custom hidden text with longer animation',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Hide Mode Example
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hide Mode (Maintain Size):'),
                      SizedBox(height: 8),
                      AmountDisplay(
                        amount: 999.99,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                        obscureMode: AmountObscureMode.hide,
                        animationDuration: Duration(milliseconds: 200),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Completely hidden but maintains layout space',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Signed Amount with Blur
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Income Amount (Blur Mode):'),
                      SizedBox(height: 8),
                      SignedAmountDisplay(
                        amount: 1500.50,
                        isExpense: false,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                        obscureMode: AmountObscureMode.blur,
                        blurSigma: 10,
                        animationDuration: Duration(milliseconds: 300),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Income with strong blur effect',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Expense Amount with Custom Replace
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Expense Amount (Custom Replace):'),
                      SizedBox(height: 8),
                      SignedAmountDisplay(
                        amount: 750.25,
                        isExpense: true,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                        obscureMode: AmountObscureMode.replace,
                        hiddenText: '███',
                        animationDuration: Duration(milliseconds: 400),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Expense with custom block characters',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // General Purpose Obfuscator Example
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('General Purpose Widget (Image Blur):'),
                      const SizedBox(height: 8),
                      AmountVisibilityObfuscator(
                        obscureMode: AmountObscureMode.blur,
                        blurSigma: 15,
                        animationDuration: const Duration(milliseconds: 300),
                        hiddenChild: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.lock, size: 40),
                        ),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.purple[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'Sensitive\nContent',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'General obfuscator with custom hidden widget',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                'Tap the eye icon in the app bar to toggle visibility',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
