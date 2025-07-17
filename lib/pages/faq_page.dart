import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class FAQPage extends StatelessWidget {
  final List<Map<String, String>> faqs = [
    {'question': tr('faq.track_order_q'), 'answer': tr('faq.track_order_a')},
    {'question': tr('faq.edit_address_q'), 'answer': tr('faq.edit_address_a')},
    {
      'question': tr('faq.payment_methods_q'),
      'answer': tr('faq.payment_methods_a'),
    },
    {
      'question': tr('faq.return_product_q'),
      'answer': tr('faq.return_product_a'),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('faq.title'))),
      body: ListView.builder(
        itemCount: faqs.length,
        itemBuilder: (_, i) {
          final item = faqs[i];
          return ExpansionTile(
            title: Text(
              item['question']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(item['answer']!),
              ),
            ],
          );
        },
      ),
    );
  }
}
