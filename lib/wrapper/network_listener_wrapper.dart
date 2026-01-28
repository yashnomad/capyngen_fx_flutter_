import 'package:exness_clone/utils/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/network/network_cubit.dart';
import '../cubit/network/network_state.dart';

class NetworkListenerWrapper extends StatelessWidget {
  final Widget child;

  const NetworkListenerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<NetworkCubit, NetworkState>(
      listener: (context, state) {
        if (state is NetworkDisconnected) {
          _showSnackBar(
            context,
            message: "No Internet Connection",
            icon: Icons.wifi_off_rounded,
            isError: true,
          );
        } else if (state is NetworkConnected) {

          _showSnackBar(
            context,
            message: "Back Online",
            icon: Icons.wifi_rounded,
            isError: false,
          );
        }
      },
      child: child,
    );
  }

  void _showSnackBar(BuildContext context,
      {required String message, required IconData icon, required bool isError}) {

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isError ? Colors.red.shade900 : Colors.green.shade900,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isError ? "Connection Lost" : "Connection Restored",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: isError ? const Color(0xFF1E1E1E) : const Color(0xFF1E1E1E),
      duration: isError ? const Duration(days: 1) : const Duration(seconds: 3), // Error stays until fixed
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      action: isError
          ? SnackBarAction(
        label: "SETTINGS",
        textColor: Colors.redAccent,
        onPressed: () {
          // Optional: Open phone settings
        },
      )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}