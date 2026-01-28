import 'package:exness_clone/config/flavor_assets.dart';
import 'package:exness_clone/constant/app_vector.dart';
import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/provider/theme_provider.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/widget/simple_appbar.dart';
import 'package:exness_clone/widget/slidepage_navigate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/flavor_config.dart';
import '../../services/balance_masked.dart';
import '../app_auth/widget/reset_pin_dialog.dart';
import 'secure_my_account.dart';
import 'setting_language.dart';
import 'setting_notification.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isBiometric = true;
  bool isDisableScreenshot = false;
  bool isHideBalance = false;

  final List<String> themeTitles = [
    'Device setting',
    'Always light',
    'Always dark'
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final selectedThemeIndex = themeProvider.selectedIndex;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: SimpleAppbar(title: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // Preferences Section
          _buildSectionHeader('Preferences'),
          const SizedBox(height: 12),
          _buildPreferencesCard(context, selectedThemeIndex, themeProvider),

          const SizedBox(height: 24),

          // Security Section
          _buildSectionHeader('Security'),
          const SizedBox(height: 12),
          _buildSecurityCard(context),

          const SizedBox(height: 24),

          // Danger Zone
          // _buildDangerZoneCard(context),
          // const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppFlavorColor.headerText,
        ),
      ),
    );
  }

  Widget _buildPreferencesCard(BuildContext context, int selectedThemeIndex,
      ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppFlavorColor.primary.withOpacity(0.05),
            AppFlavorColor.primary.withOpacity(0.02),
            // context.appBarGradientColor,
            // context.appBarGradientColorSecond
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppFlavorColor.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildModernTile(
            icon: Icons.notifications_outlined,
            iconColor: Colors.orange,
            title: 'Notifications',
            onTap: () {
              Navigator.push(
                  context, SlidePageRoute(page: SettingNotification()));
            },
            isFirst: true,
          ),
          _buildDivider(),
          _buildModernTile(
            icon: Icons.language_outlined,
            iconColor: Colors.blue,
            title: 'Language',
            onTap: () {
              Navigator.push(context, SlidePageRoute(page: SettingLanguage()));
            },
          ),
          _buildDivider(),
          _buildModernTile(
            icon: Icons.palette_outlined,
            iconColor: Colors.purple,
            title: 'Appearance',
            trailingText: themeTitles[selectedThemeIndex],
            onTap: () async {
              final selectedIndex = await showModalBottomSheet<int>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) =>
                    ThemePickerBottomSheet(selectedIndex: selectedThemeIndex),
              );

              if (selectedIndex != null) {
                Provider.of<ThemeProvider>(context, listen: false)
                    .setIndex(selectedIndex);
              }
            },
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppFlavorColor.primary.withOpacity(0.05),
            AppFlavorColor.primary.withOpacity(0.02),

            // context.appBarGradientColor,
            // context.appBarGradientColorSecond
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppFlavorColor.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildModernTile(
            icon: Icons.security_outlined,
            iconColor: Colors.green,
            title: 'Security type',
            trailingText: 'Phone',
            onTap: () {
              // Navigator.push(context, SlidePageRoute(page: SecurityType()));
            },
            isFirst: true,
          ),
          _buildDivider(),
          _buildModernTile(
            icon: Icons.lock_outline,
            iconColor: Colors.teal,
            title: 'Change passcode',
            onTap: () {
              AppAuthResetPinDialog.showAuthPinResetDialog(context);
            },
          ),
          _buildDivider(),
          _buildModernSwitchTile(
            icon: Icons.fingerprint,
            iconColor: Colors.indigo,
            title: 'Sign-in with biometrics',
            value: isBiometric,
            onChanged: (val) => setState(() => isBiometric = val),
          ),
          // _buildDivider(),
          // _buildModernSwitchTile(
          //   icon: Icons.screenshot_outlined,
          //   iconColor: Colors.red,
          //   title: 'Disable screenshots',
          //   value: isDisableScreenshot,
          //   onChanged: (val) => setState(() => isDisableScreenshot = val),
          // ),
          _buildDivider(),
          ValueListenableBuilder<bool>(
            valueListenable: globalBalanceMaskController,
            builder: (context, isHidden, _) {
              return _buildModernSwitchTile(
                icon: Icons.visibility_off_outlined,
                iconColor: Colors.deepPurple,
                title: 'Hide balances with a flip gesture',
                subtitle:
                    'Flip your device screen down to quickly hide and show balances',
                value: isHidden,
                onChanged: (val) {
                  globalBalanceMaskController.value = val;
                },
                isLast: true,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZoneCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Account Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppFlavorColor.headerText,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.red.withOpacity(0.05),
                Colors.orange.withOpacity(0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.red.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _buildDangerTile(
                icon: Icons.shield_outlined,
                title: 'Secure my account',
                subtitle: 'Log out from all devices except this one',
                onTap: () {
                  Navigator.push(
                      context, SlidePageRoute(page: SecureMyAccount()));
                },
                isFirst: true,
              ),
              _buildDivider(),
              _buildDangerTile(
                icon: Icons.delete_outline,
                title: 'Terminate ${FlavorAssets.appName} Personal Area',
                subtitle: 'This action cannot be undone',
                onTap: () {},
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(16) : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    // color: FlavorConfig.isEnzo4Ex
                    //     ? Colors.white
                    //     : (context.themeColor),

                    // color: AppFlavorColor.text,
                  ),
                ),
              ),
              if (trailingText != null) ...[
                Text(
                  trailingText,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColor.greyColor,
                    fontWeight: FontWeight.w500,
                    // color: FlavorConfig.isEnzo4Ex
                    //     ? Colors.white
                    //     : (context.themeColor),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColor.greyColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(16) : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        // color: FlavorConfig.isEnzo4Ex
                        //     ? Colors.white
                        //     : (context.themeColor),

                        // color: AppFlavorColor.text,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: FlavorConfig.isEnzo4Ex
                              ? Colors.white
                              : AppColor.greyColor,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => onChanged(!value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  width: 50,
                  height: 28,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    gradient: value
                        ? LinearGradient(
                            colors: AppFlavorColor.buttonGradient,
                          )
                        : null,
                    color: value ? null : AppColor.mediumGrey,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: value
                        ? [
                            BoxShadow(
                              color: AppFlavorColor.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    alignment:
                        value ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDangerTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(16) : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.red, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        // color: AppFlavorColor.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColor.greyColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColor.greyColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 60),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: AppColor.greyColor.withOpacity(0.2),
      ),
    );
  }
}

// Enhanced Theme Picker Bottom Sheet
class ThemePickerBottomSheet extends StatefulWidget {
  final int selectedIndex;

  const ThemePickerBottomSheet({super.key, required this.selectedIndex});

  @override
  State<ThemePickerBottomSheet> createState() => _ThemePickerBottomSheetState();
}

class _ThemePickerBottomSheetState extends State<ThemePickerBottomSheet> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  void _onSelect(int index) {
    setState(() {
      _selectedIndex = index;
    });

    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.setIndex(index);

    Future.delayed(const Duration(milliseconds: 300), () {
      Navigator.pop(context, index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 100),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.grey.shade400,
              ),
            ),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  'Choose appearance',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppFlavorColor.headerText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildThemeOption(
                  index: 0,
                  image: AppVector.auto,
                  label: 'Device\nsettings',
                ),
                _buildThemeOption(
                  index: 1,
                  image: AppVector.light1,
                  label: 'Always\nlight',
                ),
                _buildThemeOption(
                  index: 2,
                  image: AppVector.dark,
                  label: 'Always\ndark',
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required int index,
    required String image,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onSelect(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppFlavorColor.primary.withOpacity(0.1),
                      AppFlavorColor.primary.withOpacity(0.05),
                    ],
                  )
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppFlavorColor.primary
                  : Colors.grey.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Image.asset(image, height: 120),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color:
                      isSelected ? AppFlavorColor.primary : AppFlavorColor.text,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isSelected
                      ? LinearGradient(colors: AppFlavorColor.buttonGradient)
                      : null,
                  border: Border.all(
                    color: isSelected
                        ? AppFlavorColor.primary
                        : AppColor.greyColor,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Icon(Icons.check, size: 12, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
import 'package:exness_clone/constant/app_vector.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/view/app_auth/app_auth_screen.dart';
import 'package:exness_clone/view/app_auth/widget/reset_pin_dialog.dart';
import 'package:exness_clone/view/profile/change_passcode.dart';
import 'package:exness_clone/view/profile/secure_my_account.dart';
import 'package:exness_clone/view/profile/setting_language.dart';
import 'package:exness_clone/view/profile/setting_notification.dart';
import 'package:exness_clone/widget/color.dart';
import 'package:exness_clone/widget/message_appbar.dart';
import 'package:exness_clone/widget/simple_appbar.dart';
import 'package:exness_clone/widget/slidepage_navigate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/flavor_assets.dart';
import '../../provider/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  bool isBiometric = true;
  bool isDisableScreenshot = false;
  bool isHideBalance = false;

  final List<String> themeTitles = ['Device setting','Always light', 'Always dark'];

  @override
  Widget build(BuildContext context) {

    final themeProvider = Provider.of<ThemeProvider>(context);
    final selectedThemeIndex = themeProvider.selectedIndex;

    return Scaffold(
      appBar: SimpleAppbar(title: 'Setting'),

      body: ListView(

        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: const Text('Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 10),
          _buildTile(title: 'Notifications',onTap: (){
            Navigator.push(context, SlidePageRoute(page: SettingNotification()));
          }),
          _buildTile(title: 'Language',onTap: (){
            Navigator.push(context, SlidePageRoute(page: SettingLanguage()));

          }),
          _buildTile(
            title: 'Appearance',
            trailingText: themeTitles[selectedThemeIndex],
            onTap: () async {
              final selectedIndex = await showModalBottomSheet<int>(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) => ThemePickerBottomSheet(selectedIndex: selectedThemeIndex),
              );

              if (selectedIndex != null) {
                Provider.of<ThemeProvider>(context, listen: false).setIndex(selectedIndex);
              }
            },
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: const Text('Security', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 10),
          _buildTile(title: 'Security type', trailingText: 'Phone',onTap: (){
            Navigator.push(context, SlidePageRoute(page: SecurityType()));

          }),
          _buildTile(title: 'Change passcode',onTap: (){
            AppAuthResetPinDialog.showAuthPinResetDialog(context);
          }),
          _buildSwitchTile(title: 'Sign-in with biometrics', value: isBiometric, onChanged: (val) => setState(() => isBiometric = val),onTap: (){
            setState(() {
              isBiometric = !isBiometric;
            });
          }),
          _buildSwitchTile(title: 'Disable screenshots', value: isDisableScreenshot, onChanged: (val) => setState(() => isDisableScreenshot = val),onTap: (){
            setState(() {
              isDisableScreenshot = !isDisableScreenshot;
            });
          }),
          _buildSwitchTile(
            title: 'Hide balances with a flip gesture',
            subtitle: 'Flip your device screen down to quickly hide and show balances',
            value: isHideBalance,
              onChanged: (val) => setState(() => isHideBalance = val),
              onTap: (){
                setState(() {
                  isHideBalance = !isHideBalance;
                });
              }

          ),

          ListTile(
            onTap: (){
              Navigator.push(context, SlidePageRoute(page: SecureMyAccount()));

            },
            leading: CircleAvatar(backgroundColor: Colors.red.shade50,child: Icon(Icons.logout, color: AppColor.redColor,size: 20,)),
            title: Text(
              'Secure my account',

              style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14),
            ),
            subtitle:Text('Log out from all devices except this one',style: TextStyle(fontSize: 11,color: AppColor.greyColor),),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColor.greyColor),

          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
            child: Divider(color: AppColor.mediumGrey,),
          ),
          ListTile(
            leading: CircleAvatar(backgroundColor: Colors.red.shade50,child: Icon(Icons.logout, color: AppColor.redColor,size: 20,)),
              title: Text(
                'Terminate ${FlavorAssets.appName} Personal Area',

                style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14),
              ),
            subtitle:Text('This action cannot ',style: TextStyle(fontSize: 11,color: AppColor.greyColor),),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColor.greyColor),

          ),

          SizedBox(height: 20,)
        ],
      ),
    );
  }

  Widget _buildTile({required String title, String? trailingText,required Function() onTap}) {
    return ListTile(



      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 14)),
      trailing: trailingText != null
          ? Row(
        mainAxisSize: MainAxisSize.min,
            children: [
              Text(trailingText, style:  TextStyle(color:AppColor.greyColor,fontSize: 13)),
              SizedBox(width: 10,),
               Icon(Icons.arrow_forward_ios, size: 16,color: AppColor.greyColor,),
            ],
          )
          :  Icon(Icons.arrow_forward_ios, size: 16,color: AppColor.greyColor,),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required Function() onTap,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(

      onTap: onTap,
      title: Text(title, style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w500)),
      trailing: GestureDetector(
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 50,
          height: 32,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: value ? AppColor.blueGrey : AppColor.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: value ? AppColor.transparent : AppColor.greyColor,
              width: 0.6, // ✅ Control the outline width here
            ),
          ),
          child: Align(
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: value ? AppColor.whiteColor : AppColor.blueGrey,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
      subtitle:subtitle != null?
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 10),
            child: Text(subtitle, style:  TextStyle(fontSize: 11, color: AppColor.greyColor)),
          ):null,
    );
  }
}






class ThemePickerBottomSheet extends StatefulWidget {
  final int selectedIndex;

  const ThemePickerBottomSheet({super.key, required this.selectedIndex});

  @override
  State<ThemePickerBottomSheet> createState() => _ThemePickerBottomSheetState();
}

class _ThemePickerBottomSheetState extends State<ThemePickerBottomSheet> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  void _onSelect(int index) {
    setState(() {
      _selectedIndex = index;
    });

    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.setIndex(index);

    Navigator.pop(context, index);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      // initialChildSize: 0.5,
      // maxChildSize: 0.5,
      // minChildSize: 0.5,
      expand: false,

      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          decoration: const BoxDecoration(

            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'Choose appearance',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 30),

              Row(
                children: [
                  _buildOption(
                    index: 0,
                    image: AppVector.auto,
                    label: 'Device\nsettings',
                  ),

                  _buildOption(
                    index: 1,
                    image: AppVector.light1,
                    label: 'Always\nlight',
                  ),

                  _buildOption(
                    index: 2,
                    image: AppVector.dark,
                    label: 'Always\ndark',
                  ),

                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption({
    required int index,
    required String image,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onSelect(index),
        child: Column(
          children: [
            Image.asset(image, height: 150),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            Icon(
              isSelected ? Icons.radio_button_on_sharp : Icons.radio_button_off,
              color: isSelected ? AppColor.blueGrey : AppColor.greyColor,
            ),
          ],
        ),
      ),
    );
  }
}


class SecurityType extends StatefulWidget {
  const SecurityType({super.key});

  @override
  State<SecurityType> createState() => _SecurityTypeState();
}

class _SecurityTypeState extends State<SecurityType> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: MessageAppbar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "2-Step verification",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "2-step verification ensures that all sensitive transactions are authorized by you.\nWe encourage you to enter verification codes to confirm these transactions.",
              style: TextStyle(fontSize: 13, height: 1.6, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 25),
             Divider(color: AppColor.mediumGrey,),
            const SizedBox(height: 10),
            const Text(
              "Security type",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 5),
            const Text(
              "+91 ••• 8702",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, SlidePageRoute(page: ChangeTwoStepVerificationScreen()));
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColor.blackColor,
                  backgroundColor: AppColor.lightGrey,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text("Change",style: TextStyle(fontSize: 13),),
              ),
            ),
          ],
        ),
      ),
    );



  }
}



class ChangeTwoStepVerificationScreen extends StatefulWidget {
  const ChangeTwoStepVerificationScreen({super.key});

  @override
  State<ChangeTwoStepVerificationScreen> createState() =>
      _ChangeTwoStepVerificationScreenState();
}

class _ChangeTwoStepVerificationScreenState
    extends State<ChangeTwoStepVerificationScreen> {
  String? selectedOption;

  final options = [
    {'label': 'Email', 'sub': 'ab••••••••xn@gmail.com'},
    {'label': 'Phone', 'sub': '+91 •• 8702'},
    {'label': 'New phone number'},
    {'label': 'Authentication app'},
    {'label': 'Push notifications', 'badge': 'Recommended'},
    {'label': "I can't access my device"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MessageAppbar(),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back_ios_new_outlined, size: 20),
                    SizedBox(width: 8),
                    Text("Back", style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "Change 2-Step verification",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 25),
          ...options.map((item) {
            String label = item['label']!;
            bool isSelected = selectedOption == label;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      selectedOption = label;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: isSelected ? AppColor.blueGrey : AppColor.greyColor,
                        ),

                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [

                                  Expanded(
                                    child: Text(
                                      label,
                                      style: const TextStyle(
                                          fontSize: 14, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  if (item['badge'] != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Text(
                                        item['badge']!,
                                        style: TextStyle(
                                          color: AppColor.greenColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),


                                ],
                              ),
                              if (item['sub'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    item['sub']!,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppColor.greyColor,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            );
          }).toList(),

          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedOption != null ? () {
                Navigator.pop(context);
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedOption != null
                    ? AppColor.yellowColor
                    : AppColor.mediumGrey,
                foregroundColor:  AppColor.blackColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: const Text("Next"),
            ),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}





*/
