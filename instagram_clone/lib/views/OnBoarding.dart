import 'package:flutter/material.dart';
import 'package:instagram_clone/views/LoginPage.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  final _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (value) {
                setState(() {
                  _currentPage = value;
                });
              },
              children: const [
                OnBoardingScreen(
                  heading: 'with your friends',
                  headingText: 'Connect ',
                  imageUrl: 'assets/onboarding.png',
                  paragraph:
                      'stay connected with friends and family, anytime, anywhere!',
                  subheading: 'Direct Message',
                ),
                OnBoardingScreen(
                  heading: 'your best Moments',
                  headingText: 'Post ',
                  imageUrl: 'assets/onboarding1.jpg',
                  paragraph:
                      'Create videos effortlessly. Edit, share, and inspire.',
                  subheading: 'Create Videos',
                ),
                OnBoardingScreen(
                  heading: 'on Instagram',
                  headingText: 'Advertise ',
                  imageUrl: 'assets/onboarding2.jpg',
                  paragraph:
                      "Boost your brand's visibility with Instagram ads. Connect, engage, and grow.",
                  subheading: 'Advertising',
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 40,
              width: 100,
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage == 2) {
                    // Navigate to LoginScreen when on the last page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  } else {
                    // Move to the next page
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: const Color.fromARGB(255, 246, 87, 8),
                ),
                child: Text(_currentPage == 2 ? "Finish" : "Next"),
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          SizedBox(
            height: 12,
            child: ListView.builder(
              itemCount: 3,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Container(
                  height: 12,
                  width: 12,
                  margin: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.white
                        : const Color.fromARGB(255, 85, 85, 85),
                    borderRadius: BorderRadius.circular(50),
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

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({
    super.key,
    required this.imageUrl,
    required this.heading,
    required this.subheading,
    required this.paragraph,
    required this.headingText,
  });

  final String imageUrl;
  final String heading;
  final String subheading;
  final String paragraph;
  final String headingText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 35, right: 35),
      child: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          Image.asset(
            "assets/meta.jpg",
            width: 100,
          ),
          const SizedBox(
            height: 20,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 220,
              margin: const EdgeInsets.only(left: 10),
              padding: const EdgeInsets.only(left: 10),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Color.fromARGB(255, 246, 87, 8),
                    width: 4.0,
                  ),
                ),
              ),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 32),
                  children: [
                    TextSpan(
                      text: headingText,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 246, 87, 8),
                      ),
                    ),
                    TextSpan(text: heading),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          SizedBox(
            height: 300,
            child: Image.asset(
              imageUrl,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Text(
            subheading,
            style: const TextStyle(
              fontSize: 25,
              color: Color.fromARGB(255, 177, 175, 175),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            paragraph,
            style: const TextStyle(
              color: Color.fromARGB(255, 177, 175, 175),
            ),
          ),
        ],
      ),
    );
  }
}