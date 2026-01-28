import 'package:exness_clone/widget/color.dart';
import 'package:exness_clone/widget/simple_appbar.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';


class EconomicCalendarScreen extends StatelessWidget {
  const EconomicCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> events = [
      {
        'flag': '🇳🇿',
        'title': 'Composite NZ PCI',
        'country': 'NZ',
        'impact': 1,
        'date': 'Tomorrow',
      },
      {
        'flag': '🇳🇿',
        'title': 'Services NZ PSI',
        'country': 'NZ',
        'impact': 1,
        'date': 'Tomorrow',
      },
      {
        'flag': '🇿🇦',
        'title': 'Youth Day',
        'country': 'ZA',
        'impact': 1,
        'date': 'Tomorrow',
      },
      {
        'flag': '🇨🇳',
        'title': 'House Price Index YoY',
        'country': 'CN',
        'impact': 1,
        'date': 'Tomorrow',
      },
      {
        'flag': '🇨🇳',
        'title': 'Unemployment Rate',
        'country': 'CN',
        'impact': 3,
        'date': 'Tomorrow',
      },
      {
        'flag': '🇨🇳',
        'title': 'Retail Sales YoY',
        'country': 'CN',
        'impact': 3,
        'date': 'Tomorrow',
      },
      {
        'flag': '🇨🇳',
        'title': 'Industrial Production YoY',
        'country': 'CN',
        'impact': 3,
        'date': 'Tomorrow',
      },
      {
        'flag': '🇨🇳',
        'title': 'Fixed Asset Investment (YTD) YoY',
        'country': 'CN',
        'impact': 1,
        'date': 'Tomorrow',
      },
      {
        'flag': '🇮🇳',
        'title': 'Passenger Vehicles Sales YoY',
        'country': 'IN',
        'impact': 1,
        'date': 'Tomorrow',
      },
      {
        'flag': '🇰🇷',
        'title': '10-Year KTB Auction',
        'country': 'KR',
        'impact': 1,
        'date': 'Tomorrow',
      },
      {
        'flag': '🇳🇿',
        'title': 'Composite NZ PCI',
        'country': 'NZ',
        'impact': 1,
        'date': 'Tomorrow',
      },
      {
        'flag': '🇳🇿',
        'title': 'Services NZ PSI',
        'country': 'NZ',
        'impact': 1,
        'date': 'Tomorrow',
      },
      {
        'flag': '🇿🇦',
        'title': 'Youth Day',
        'country': 'ZA',
        'impact': 1,
        'date': 'Tomorrow',
      },
      {
        'flag': '🇨🇳',
        'title': 'House Price Index YoY',
        'country': 'CN',
        'impact': 1,
        'date': 'Tomorrow',
      },
      {
        'flag': '🇨🇳',
        'title': 'Unemployment Rate',
        'country': 'CN',
        'impact': 3,
        'date': 'Tomorrow',
      },
      {
        'flag': '🇨🇳',
        'title': 'Retail Sales YoY',
        'country': 'CN',
        'impact': 3,
        'date': 'Tomorrow',
      },
      {
        'flag': '🇨🇳',
        'title': 'Industrial Production YoY',
        'country': 'CN',
        'impact': 3,
        'date': 'Tomorrow',
      },
      {
        'flag': '🇨🇳',
        'title': 'Fixed Asset Investment (YTD) YoY',
        'country': 'CN',
        'impact': 1,
        'date': 'Tomorrow',
      },
      {
        'flag': '🇮🇳',
        'title': 'Passenger Vehicles Sales YoY',
        'country': 'IN',
        'impact': 1,
        'date': 'Tomorrow',
      },
      {
        'flag': '🇰🇷',
        'title': '10-Year KTB Auction',
        'country': 'KR',
        'impact': 1,
        'date': 'Tomorrow',
      },
    ];

    return Scaffold(
      appBar: SimpleAppbar(title: 'Economic Calendar'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

           Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Text(
              'TOMORROW',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColor.greyColor,
                fontSize: 12
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return ListTile(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => EconomicCalenderDetails()));
                  },
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColor.transparent,
                    child: Text(event['flag'], style: const TextStyle(fontSize: 18)),
                  ),
                  title: Text(event['title'],
                      style: const TextStyle(fontWeight: FontWeight.w600,fontSize: 14)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Text(event['country'],style: TextStyle(fontWeight: FontWeight.w500,fontSize: 12),),
                        const SizedBox(width: 8),
                        Row(
                          children: List.generate(
                            event['impact'],
                                (i) => Padding(
                              padding: const EdgeInsets.only(right: 2),
                              child: Container(
                                width: 6,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: AppColor.amberColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(event['date'],style: TextStyle(fontSize: 12,color: AppColor.greyColor),),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class EconomicCalenderDetails extends StatefulWidget {
  const EconomicCalenderDetails({super.key});

  @override
  State<EconomicCalenderDetails> createState() => _EconomicCalenderDetailsState();
}

class _EconomicCalenderDetailsState extends State<EconomicCalenderDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: SimpleAppbar(title: 'NZ'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(

            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Composite NZ PCI',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                    '16 Jun 2025 4:00:00 am',
                    style: TextStyle(color: AppColor.greyColor),
                  ),
                  Row(
                    children: [
                       Text('Volatility',
                          style: TextStyle(color:AppColor.greyColor)),
                      const SizedBox(width: 6),
                      Row(
                        children: List.generate(
                          2,
                              (index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 1),
                            child: Container(
                              width: 6,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppColor.amberColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:  [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Actual',
                          style: TextStyle(color: AppColor.greyColor, fontSize: 13)),
                      SizedBox(height: 4),
                      Text('–', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Consensus',
                          style: TextStyle(color: AppColor.greyColor, fontSize: 13)),
                      SizedBox(height: 4),
                      Text('48.20',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Previous',
                          style: TextStyle(color: AppColor.greyColor, fontSize: 13)),
                      SizedBox(height: 4),
                      Text('48.20',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

