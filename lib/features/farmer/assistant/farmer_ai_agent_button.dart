import 'package:flutter/material.dart';
import '../../../services/app_state.dart';
import 'farmer_ai_assistant_modal.dart';

class FarmerAiAgentButton extends StatefulWidget {
  final AppState appState;

  const FarmerAiAgentButton({super.key, required this.appState});

  @override
  State<FarmerAiAgentButton> createState() => _FarmerAiAgentButtonState();
}

class _FarmerAiAgentButtonState extends State<FarmerAiAgentButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: -3.0,
      upperBound: 3.0,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatController.value),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () => FarmerAiAssistantModal.show(context, widget.appState),
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3D15803D),
                blurRadius: 14,
                spreadRadius: 2,
                offset: Offset(0, 4),
              ),
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Real farmer AI image with mic badge asset
                Image.asset(
                  'assets/images/farmer_ai_agent.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF15803D),
                    child: const Icon(
                      Icons.mic_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
