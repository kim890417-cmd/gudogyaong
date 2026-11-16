import 'package:flutter/material.dart';
import 'models/pet_profile.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/tracker_screen.dart';
import 'screens/encyclopedia_screen.dart';
import 'screens/play_screen.dart';
import 'screens/store_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GudogyaongApp());
}

class GudogyaongApp extends StatelessWidget {
  const GudogyaongApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '구독야옹',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({Key? key}) : super(key: key);

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  List<PetProfile> _profiles = [];
  PetProfile? _currentPet;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  void _loadProfiles() async {
    final list = await StorageService.loadProfiles();
    final savedId = await StorageService.loadCurrentPetId();
    PetProfile? matched;
    if (savedId != null) {
      matched = list.cast<PetProfile?>().firstWhere(
            (p) => p?.id == savedId,
            orElse: () => null,
          );
    }

    setState(() {
      _profiles = list;
      _currentPet = matched ?? list.first;
      _isLoading = false;
    });
  }

  void _onPetChanged(PetProfile newPet) async {
    setState(() => _currentPet = newPet);
    await StorageService.saveCurrentPetId(newPet.id);
  }

  void _onNewPetRegistered(PetProfile newPet) async {
    _profiles.add(newPet);
    await StorageService.saveProfiles(_profiles);
    _onPetChanged(newPet);
    setState(() {
      _currentIndex = 0; // 홈으로 이동
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _currentPet == null) {
      return const Scaffold(
        backgroundColor: AppTheme.cream,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.terracotta),
        ),
      );
    }

    final pages = [
      HomeScreen(
        currentPet: _currentPet!,
        allProfiles: _profiles,
        onPetChanged: _onPetChanged,
        onProfileListUpdated: () => StorageService.saveProfiles(_profiles),
      ),
      TrackerScreen(currentPet: _currentPet!),
      EncyclopediaScreen(onNewPetRegistered: _onNewPetRegistered),
      const PlayScreen(),
      const StoreScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_calendar_outlined),
            activeIcon: Icon(Icons.edit_calendar),
            label: '기록',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: '백과·식단',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports_outlined),
            activeIcon: Icon(Icons.sports_esports),
            label: '놀이',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: '스토어',
          ),
        ],
      ),
    );
  }
}
