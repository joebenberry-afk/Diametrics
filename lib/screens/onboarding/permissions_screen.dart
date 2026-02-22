import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../theme.dart';
import '../../widgets/onboarding_layout.dart';
import '../personal_info_screen.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  int _step = 0; // 0 = AV, 1 = Fitness

  Future<void> _requestAVPermissions(bool allow) async {
    if (allow) {
      await [Permission.camera, Permission.microphone].request();
    }
    setState(() {
      _step = 1;
    });
  }

  Future<void> _requestFitnessPermissions(bool allow) async {
    if (allow) {
      // Setup health/fitness permissions later if needed
      await Permission.activityRecognition.request();
    }
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const PersonalInfoScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      cardTitle: 'Permissions',
      onBack: _step == 0
          ? null
          : () {
              setState(() => _step = 0);
            },
      // No continue button needed, they tap Allow/Deny
      child: Column(
        children: [
          Text(
            _step == 0
                ? 'Allow Diametrics to access your microphone and camera?'
                : 'Allow Diametrics to access your fitness app?',
            textAlign: TextAlign.center,
            style: SeniorTheme.bodyStyle,
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _step == 0
                      ? _requestAVPermissions(true)
                      : _requestFitnessPermissions(true),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: Colors.grey.shade400,
                          width: 1,
                        ),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text('Allow', style: SeniorTheme.bodyStyle),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => _step == 0
                      ? _requestAVPermissions(false)
                      : _requestFitnessPermissions(false),
                  child: Container(
                    height: 56,
                    alignment: Alignment.center,
                    child: Text('Deny', style: SeniorTheme.bodyStyle),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
