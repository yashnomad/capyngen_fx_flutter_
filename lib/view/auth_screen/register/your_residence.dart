import 'package:country_picker/country_picker.dart';
import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/view/auth_screen/register/enter_email.dart';
import 'package:exness_clone/view/auth_screen/register/enter_name.dart';
import 'package:exness_clone/widget/color.dart';
import 'package:exness_clone/widget/simple_appbar.dart';
import 'package:exness_clone/widget/button/premium_app_button.dart'; // Import the premium button
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/flavor_assets.dart';
import '../../../config/flavor_config.dart';
import '../../../theme/app_colors.dart';

class YourResidence extends StatefulWidget {
  const YourResidence({super.key});

  @override
  State<YourResidence> createState() => _YourResidenceState();
}

class _YourResidenceState extends State<YourResidence> with TickerProviderStateMixin {
  Country selectedCountry = Country(
    phoneCode: '91',
    countryCode: 'IN',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'India',
    example: '9123456789',
    displayName: 'India',
    displayNameNoCountryCode: 'India',
    e164Key: '',
  );

  bool isChecked = true;

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();

    // Quick entrance animation
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
      _slideController.forward();
    });
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _selectCountry() {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      onSelect: (Country country) {
        setState(() {
          selectedCountry = country;
        });
      },
      countryListTheme: CountryListThemeData(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        inputDecoration: InputDecoration(
          labelText: 'Search',
          hintText: 'Start typing to search',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: const Color(0xFF8C98A8).withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.shade100,
                          Colors.blue.shade100,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: Colors.green.shade600,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Residence 🌍',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: context.profileIconColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Where are you located?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.green.shade600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountrySelector() {

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select your country of residence',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.profileIconColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.appBarGradientColor,
                    context.appBarGradientColorSecond,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _selectCountry,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            selectedCountry.flagEmoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedCountry.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: context.profileIconColor,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Country of residence',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: Colors.blue.shade600,
                          ),
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
    );
  }

  Widget _buildDeclarationSection() {

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange.shade50.withOpacity(0.7),
                Colors.red.shade50.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.orange.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: isChecked,
                    activeColor: Colors.orange.shade600,
                    checkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: (val) {
                      setState(() {
                        isChecked = val ?? false;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.gavel_rounded,
                          color: Colors.orange.shade600,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tax Declaration',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'I declare and confirm that I am not a citizen or resident of the US for tax purposes.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange.shade800,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartnerCodeSection() {

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.groups_outlined,
                        size: 18,
                        color: Colors.blue.shade600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Partner code (Optional)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.blue.shade600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Colors.blue.shade600,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsSection() {

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Terms & Conditions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: context.residenceRichTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    letterSpacing: 0.2,
                  ),
                  children: [
                    TextSpan(
                        text:
                        'Based on the selected country of residence, you are registering with ${FlavorAssets.appName}, regulated by the Seychelles FSA.\n\nBy clicking Continue, you confirm that you have read, understood, and agree with all the information in the '),
                    _linkText('Client Agreement'),
                    const TextSpan(
                        text:
                        ' and the service terms and conditions listed in the following documents: '),
                    _linkText('General Business Terms'),
                    const TextSpan(text: ', '),
                    _linkText('Partnership Agreement'),
                    const TextSpan(text: ', '),
                    _linkText('Privacy Policy'),
                    const TextSpan(text: ', '),
                    _linkText('Risk Disclosure and Warning Notice'),
                    const TextSpan(text: ' and '),
                    _linkText('Key Facts Statement'),
                    const TextSpan(
                        text:
                        '.\n\nYou also confirm that you fully understand the nature and the risks of the services and products envisaged. Trading CFDs is not suitable for everyone; it should be done by traders with a high risk tolerance and who can afford potential losses.'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextSpan _linkText(String text) {
    return TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.blue.shade600,
        decoration: TextDecoration.underline,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: context.profileScaffoldColor,
      appBar: AppBar(
        title: Text(
          'Your Residence',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.appBarGradientColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: context.profileIconColor,
              size: 18,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Header Section
                  _buildHeader(),

                  // Country Selector
                  _buildCountrySelector(),

                  const SizedBox(height: 32),

                  // Declaration Section
                  _buildDeclarationSection(),

                  const SizedBox(height: 24),

                  // Partner Code Section
                  _buildPartnerCodeSection(),

                  const SizedBox(height: 24),

                  // Terms Section
                  _buildTermsSection(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Bottom Button Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.profileScaffoldColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: PremiumAppButton(
                  text: 'Continue Registration',
                  icon: Icons.arrow_forward_rounded,
                  showIcon: true,
                  isDisabled: !isChecked,
                  onPressed: isChecked
                      ? () {
                    context.pushNamed('register');
                  }
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*
import 'package:country_picker/country_picker.dart';
import 'package:exness_clone/view/auth_screen/register/enter_email.dart';
import 'package:exness_clone/view/auth_screen/register/enter_name.dart';
import 'package:exness_clone/widget/color.dart';
import 'package:exness_clone/widget/simple_appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/flavor_assets.dart';
import '../../../config/flavor_config.dart';
import '../../../theme/app_colors.dart';

class YourResidence extends StatefulWidget {
  const YourResidence({super.key});

  @override
  State<YourResidence> createState() => _YourResidenceState();
}

class _YourResidenceState extends State<YourResidence> {
  Country selectedCountry = Country(
    phoneCode: '91',
    countryCode: 'IN',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'India',
    example: '9123456789',
    displayName: 'India',
    displayNameNoCountryCode: 'India',
    e164Key: '',
  );

  bool isChecked = true;

  void _selectCountry() {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      onSelect: (Country country) {
        setState(() {
          selectedCountry = country;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppbar(title: 'Your residence'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select your residence',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _selectCountry,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      selectedCountry.flagEmoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedCountry.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
            Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Checkbox(
                  value: isChecked,
                  activeColor: AppColor.blueGrey,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (val) {
                    setState(() {
                      isChecked = val ?? false;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    'I declare and confirm that I am not a citizen or resident of the US for tax purposes.',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isChecked
                    ? () {
                        context.pushNamed('register');
                        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EnterNameScreen()));
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: FlavorConfig.appFlavor == Flavor.nestpip
                      ? AppColor.nestPipColor
                      : FlavorConfig.appFlavor == Flavor.ellitefx
                          ? AppColor.elliteFxColor
                          : AppColor.yellowColor,
                  foregroundColor: FlavorConfig.appFlavor == Flavor.nestpip
                      ? AppColor.whiteColor
                      : FlavorConfig.appFlavor == Flavor.ellitefx
                          ? AppColor.whiteColor
                          : AppColor.blackColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.groups_outlined, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Partner code (Optional)',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColor.whiteColor
                            : AppColor.blackColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.4),
                    children: [
                      TextSpan(
                          text:
                              'Based on the selected country of residence, you are registering with ${FlavorAssets.appName}, regulated by the Seychelles FSA.\n\nBy clicking Continue, you confirm that you have read, understood, and agree with all the information in the '),
                      _linkText('Client Agreement'),
                      const TextSpan(
                          text:
                              ' and the service terms and conditions listed in the following documents: '),
                      _linkText('General Business Terms'),
                      const TextSpan(text: ', '),
                      _linkText('Partnership Agreement'),
                      const TextSpan(text: ', '),
                      _linkText('Privacy Policy'),
                      const TextSpan(text: ', '),
                      _linkText('Risk Disclosure and Warning Notice'),
                      const TextSpan(text: ' and '),
                      _linkText('Key Facts Statement'),
                      const TextSpan(
                          text:
                              '.\n\nYou also confirm that you fully understand the nature and the risks of the services and products envisaged. Trading CFDs is not suitable for everyone; it should be done by traders with a high risk tolerance and who can afford potential losses.'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextSpan _linkText(String text) {
    return TextSpan(
      text: text,
      style: TextStyle(
          color: AppColor.blueColor,
          decoration: TextDecoration.underline,
          fontSize: 12,
          fontWeight: FontWeight.w500),
    );
  }
}
*/
