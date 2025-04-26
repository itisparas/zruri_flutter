import 'package:flutter/material.dart';
import 'package:zruri_flutter/core/components/listing_item.dart';
import 'package:zruri_flutter/core/constants/app_defaults.dart';

class Recommendations extends StatelessWidget {
  const Recommendations({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'For you',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(
            height: AppDefaults.padding / 4,
          ),
          ListingItem(
            image: '24-300x200.jpg',
            price: '10,000',
            title:
                'Maruti Suzuki Wagon-R 2014 model first-owner perfect condition',
            timeline: 'Today',
            location: 'Gurugram, HR',
          ),
          ListingItem(
            image: '656-300x200.jpg',
            price: '12,936',
            title:
                'Hyundai i20 Sports edition 2019 model first-owner recently bought',
            timeline: 'last week',
            location: 'Kharar, PB',
          )
        ],
      ),
    );
  }
}
