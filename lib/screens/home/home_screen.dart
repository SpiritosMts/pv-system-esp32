import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/pv_data_provider.dart';
import '../../providers/prediction_provider.dart';
import 'dashboard_tab.dart';
import 'history_tab.dart';
import 'ai_prediction_tab.dart';
import 'settings_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _tabController;
  late PVDataProvider _pvDataProvider; // Store reference to avoid context access in dispose
  late PredictionProvider _predictionProvider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Start listening to PV data and predictions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pvDataProvider = Provider.of<PVDataProvider>(context, listen: false);
      _pvDataProvider.startListening();
      
      _predictionProvider = Provider.of<PredictionProvider>(context, listen: false);
      _predictionProvider.startListening();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pvDataProvider.stopListening(); // Use stored reference instead of accessing context
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: const [
          DashboardTab(),
          HistoryTab(),
          AIPredictionTab(),
          SettingsTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            _tabController.animateTo(index);
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.psychology),
              label: 'AI Predict',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ).animate().slideY(begin: 1, delay: 300.ms, duration: 600.ms).fadeIn(delay: 300.ms, duration: 600.ms),
    );
  }
}
