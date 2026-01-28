import 'package:exness_clone/widget/simple_appbar.dart';
import 'package:flutter/material.dart';
import '../../config/flavor_assets.dart';
import '../../theme/app_colors.dart';

class LegalDocumentsScreen extends StatelessWidget {
  const LegalDocumentsScreen({super.key});

  final List<String> documents = const [
    "Client Agreement",
    "General Business Terms",
    "Partnership Agreement",
    "Complaints Procedure for Clients",
    "Bonus Terms and Conditions",
    "Risk Disclosure",
    "Preventing Money Laundering",
    "Privacy Agreement",
    "Key Facts Statement",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppbar(title: 'Legal Documents'),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: documents.length,
              separatorBuilder: (_, __) =>
                  Divider(color: AppColor.transparent, height: 10),
              itemBuilder: (context, index) {
                return SizedBox(
                  height: 45,
                  child: ListTile(
                    dense: true,
                    title: Text(
                      documents[index],
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                    ),
                    onTap: () {},
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'This ${FlavorAssets.appName} is operated by its respective legal entity registered in its country of incorporation and authorised by the relevant financial regulatory authority under its assigned licence number. The registered office address of the entity is maintained as per regulatory requirements.',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }
}
