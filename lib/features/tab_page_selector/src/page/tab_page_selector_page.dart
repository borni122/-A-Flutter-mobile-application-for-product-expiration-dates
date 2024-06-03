import 'package:flutter/material.dart';
import '/features/tab_page_selector/widgets.dart';

class TabPageSelectorPage extends StatefulWidget {
  const TabPageSelectorPage({Key? key}) : super(key: key);

  @override
  TabPageSelectorPageState createState() => TabPageSelectorPageState();
}

class TabPageSelectorPageState extends State<TabPageSelectorPage>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;
  final Map<String, Map<String, String>> _onboardingList = {
    "0": {
      "image": "assets/image/1.png",
      "description": "Stockify Application",
    },
    "1": {
      "image": "assets/image/2.png",
      "description": "QRcode .",
    },
    "2": {
      "image": "assets/image/3.png",
      "description": "barcode",
    }
  };

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: _onboardingList.length, vsync: this);
  }

  void _incrementCounter(int index) {
    setState(() {
      _controller.index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: PageView.builder(
                itemCount: _onboardingList.length,
                onPageChanged: _incrementCounter,
                itemBuilder: (context, index) => TabPageSelectorWidget(
                    data: _onboardingList[index.toString()]!),
              ),
            ),
            SafeArea(
              child: TabPageSelector(
                controller: _controller,
                selectedColor: Colors.black,
                indicatorSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
