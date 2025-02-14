import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:coffee_mapper_web/utils/responsive_utils.dart';

class TicketSuccessOverlay extends StatefulWidget {
  final String ticketID;
  final VoidCallback onClose;

  const TicketSuccessOverlay({
    super.key,
    required this.ticketID,
    required this.onClose,
  });

  @override
  State<TicketSuccessOverlay> createState() => _TicketSuccessOverlayState();
}

class _TicketSuccessOverlayState extends State<TicketSuccessOverlay> {
  bool _showCopiedTooltip = false;

  void _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.ticketID));
    setState(() {
      _showCopiedTooltip = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showCopiedTooltip = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = ResponsiveUtils.isMobile(screenWidth);
    final iconSize = screenWidth * (isMobile ? 0.08 : 0.05);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle_outline,
          size: iconSize,
          color: Theme.of(context).colorScheme.error,
        ),
        SizedBox(height: isMobile ? 20 : 24),
        const Text(
          'Reference Ticket ID:',
          style: TextStyle(
            fontFamily: 'Gilroy-Medium',
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          clipBehavior: Clip.none,
          children: [
            InkWell(
              onTap: _copyToClipboard,
              child: Text(
                widget.ticketID,
                style: TextStyle(
                  fontFamily: 'Gilroy-SemiBold',
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
            // Copied tooltip
            Positioned(
              bottom: -40,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _showCopiedTooltip ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error.withAlpha(230),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Copied to clipboard',
                      style: TextStyle(
                        color: Theme.of(context).cardColor,
                        fontFamily: 'Gilroy-Medium',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 70),
        const Text(
          'Please save this ticket ID for future reference',
          style: TextStyle(
            fontFamily: 'Gilroy-Medium',
            fontSize: 14,
          ),
        ),
        SizedBox(height: isMobile ? 25 : 30),
        SizedBox(
          height: 48,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              padding: const EdgeInsets.symmetric(horizontal: 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onPressed: widget.onClose,
            child: Text(
              'Close',
              style: TextStyle(
                fontFamily: 'Gilroy-SemiBold',
                color: Theme.of(context).cardColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
