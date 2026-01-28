import 'package:exness_clone/constant/app_vector.dart';
import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/view/profile/user_profile/bloc/user_profile_bloc.dart';
import 'package:exness_clone/view/profile/user_profile/bloc/user_profile_state.dart';
import 'package:exness_clone/widget/simple_appbar.dart';
import 'package:exness_clone/widget/slidepage_navigate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'edit_bio.dart';
import 'edit_nickname.dart';

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          color:context.backgroundColor,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, size: 20),
        ),
      ),
      body: BlocBuilder<UserProfileBloc, UserProfileState>(
        builder: (context, state) {
          if (state is UserProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserProfileLoaded) {
            final user = state.profile.profile;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      backgroundImage: AssetImage(AppVector.appIconLogo),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context, SlidePageRoute(page: EditNickname()));
                      },
                      child: Text(
                        '${user?.fullName ?? 'No name'} ✏️',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Divider(height: 30, color: AppColor.lightGrey),
                    InfoTile(
                        label: 'UID',
                        value: user?.accountId?.toString() ?? '-',
                        copyIcon: true),
                    InfoTile(
                        label: 'Bio',
                        value: 'Add bio here',
                        // value: user?.id?.isNotEmpty == true
                        //     ? user!.id!
                        //     : 'Edit',
                        hasArrow: true,
                        onTap: () {
                          Navigator.push(
                              context, SlidePageRoute(page: EditBioScreen()));
                        }),
                    InfoTile(label: 'Phone', value: '0123456789' ?? '-'),
                    InfoTile(label: 'Email', value: user?.email ?? '-'),
                    InfoTile(label: 'Name', value: user?.fullName ?? '-'),
                    InfoTile(label: 'Date of Birth', value: '1-1-2000' ?? '-'),
                    InfoTile(
                        label: 'Place of residence', value: 'New Delhi' ?? '-'),
                    InfoTile(label: 'Address', value: 'Address' ?? '-'),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text("Failed to load profile"));
          }
        },
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final bool hasArrow;
  final bool copyIcon;
  final Icon? icon;
  final Function()? onTap;

  const InfoTile({
    super.key,
    required this.label,
    required this.value,
    this.hasArrow = false,
    this.copyIcon = false,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title:
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      subtitle: Row(
        children: [
          if (icon != null) icon!,
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          if (copyIcon) const Icon(Icons.copy, size: 16, color: Colors.grey),
        ],
      ),
      trailing: hasArrow ? const Icon(Icons.arrow_forward_ios, size: 14) : null,
    );
  }
}
