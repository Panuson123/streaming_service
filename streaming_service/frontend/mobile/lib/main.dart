import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const StreamingPriceApp());
}

class StreamingPriceApp extends StatelessWidget {
  const StreamingPriceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Streaming Service Price Prediction',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const StreamingPricePage(),
    );
  }
}

class StreamingPricePage extends StatefulWidget {
  const StreamingPricePage({super.key});

  @override
  State<StreamingPricePage> createState() => _StreamingPricePageState();
}

class _StreamingPricePageState extends State<StreamingPricePage> {
  DateTime? selectedDate;
  bool loading = false;
  String? error;
  double? price;
  String? currency;

  Future<void> predictPrice() async {
    setState(() {
      loading = true;
      error = null;
      price = null;
      currency = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/api/streaming_service'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'service_date': DateFormat('yyyy-MM-dd').format(selectedDate!),
        }),
      );

      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        setState(() {
          price = (data['price'] as num).toDouble();
          currency = data['currency'];
        });
      } else {
        setState(() {
          error = data['detail']?.toString() ?? data['error'] ?? 'Unknown error';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Network error';
      });
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(2010),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(color: Colors.purple.shade100),
          ),
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'ทำนายราคาบริการ Streaming',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6D28D9),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => pickDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'เลือกวันที่ (YYYY-MM-DD)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    controller: TextEditingController(
                      text: selectedDate != null
                          ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                          : '',
                    ),
                    readOnly: true,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading || selectedDate == null ? null : predictPrice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: loading
                        ? Colors.purple.shade200
                        : Colors.purple.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  child: loading
                      ? const Text('กำลังทำนาย...')
                      : const Text('ทำนายราคา'),
                ),
              ),
              if (price != null && currency != null)
                Container(
                  margin: const EdgeInsets.only(top: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    border: Border.all(color: Colors.purple.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'ราคาคาดการณ์: $price $currency',
                    style: const TextStyle(
                      color: Color(0xFF6D28D9),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              if (error != null)
                Container(
                  margin: const EdgeInsets.only(top: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'เกิดข้อผิดพลาด: $error',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}