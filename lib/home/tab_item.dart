import 'package:flutter/material.dart';

enum TabItem { jobs, account }

class TabItemData {
  const TabItemData({required this.title, required this.icon});

  final String title;
  final IconData icon;

  static const Map<TabItem, TabItemData> allTabs = {
    TabItem.jobs: TabItemData(title: 'Jobs', icon: Icons.work),
    TabItem.account: TabItemData(title: 'Account', icon: Icons.person),
  };
}
