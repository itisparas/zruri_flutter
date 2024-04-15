import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:zruri_flutter/core/constants/app_defaults.dart';

class PostAdSuccess extends StatelessWidget {
  const PostAdSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 16,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: AppDefaults.margin),
                child: SvgPicture.asset(
                  'assets/svg/post-ad-success.svg',
                  alignment: Alignment.topCenter,
                  fit: BoxFit.scaleDown,
                ),
              ),
            ),
            const SizedBox(
              height: AppDefaults.margin,
            ),
            Text(
              'Congratulations!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(
              height: AppDefaults.margin,
            ),
            const Text('yayy! your ad will be live shortly.'),
            Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              margin: const EdgeInsets.all(AppDefaults.margin),
              padding: const EdgeInsets.all(AppDefaults.padding),
              width: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: Get.width / 4,
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(AppDefaults.radius),
                    ),
                    child: Image.asset('assets/marketing-spotlight.png'),
                  ),
                  const SizedBox(
                    width: AppDefaults.margin,
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Put your ad in Spotlight!',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(
                          height: AppDefaults.padding / 2,
                        ),
                        const Text(
                          'Reach more buyers and sell your product/service faster by putting your ad into spotlight.',
                          softWrap: true,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDefaults.margin,
                vertical: AppDefaults.margin / 4,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Turn spotlight on'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDefaults.margin,
                vertical: AppDefaults.margin / 4,
              ),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Preview your ad'),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
