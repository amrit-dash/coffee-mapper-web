import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class Footer extends StatefulWidget {
  const Footer({super.key});

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  bool _switch = false;
  String _name = 'Amrit Dash';
  String _url = 'https://www.about.me/amritdash';
  String _verb = 'Developed';
  String _currentTime = '';

  // This will be set during build time
  static const String _buildEnv =
      String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');

  @override
  void initState() {
    super.initState();

    if (_buildEnv == 'production') {
      _updateTime();
      // Update time every second
      Timer.periodic(const Duration(seconds: 1), (timer) => _updateTime());
    }
  }

  void _updateTime() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, MMMM dd, yyyy hh:mm a');
    if (!mounted) return;
    setState(() {
      _currentTime = formatter.format(now);
    });
  }

  Future<void> _launchURL() async {
    String url = _url;
    try {
      if (!await url_launcher.launchUrl(Uri.parse(url))) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: 44,
              color: Theme.of(context).colorScheme.primary.withAlpha(90),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 30),
                    child: (_buildEnv == 'production')
                        ? Text(
                            _currentTime,
                            style: TextStyle(
                              color: Theme.of(context).highlightColor,
                              fontSize: 14,
                              fontFamily: 'Gilroy-SemiBold',
                            ),
                          )
                        : Row(
                            children: [
                              Text(
                                '$_verb with',
                                style: TextStyle(
                                  color: Theme.of(context).highlightColor,
                                  fontSize: 14,
                                  fontFamily: 'Gilroy-SemiBold',
                                ),
                              ),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () => {
                                    setState(() {
                                      _switch = !_switch;

                                      if (_switch) {
                                        _name = 'Manish Rath';
                                        _verb = 'Designed';
                                        _url = 'https://about.me/manishrath';
                                      } else {
                                        _name = 'Amrit Dash';
                                        _verb = 'Developed';
                                        _url = 'https://about.me/amritdash';
                                      }
                                    })
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: SvgPicture.asset(
                                      'assets/icons/coffeeBeanOutline.svg',
                                      height: 20,
                                      colorFilter: ColorFilter.mode(
                                        Theme.of(context).highlightColor,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                'by ',
                                style: TextStyle(
                                  color: Theme.of(context).highlightColor,
                                  fontSize: 14,
                                  fontFamily: 'Gilroy-SemiBold',
                                ),
                              ),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: _launchURL,
                                  child: Text(
                                    _name,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontSize: 14,
                                      fontFamily: 'Gilroy-SemiBold',
                                      decoration: TextDecoration.underline,
                                      decorationColor:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                '.',
                                style: TextStyle(
                                  color: Theme.of(context).highlightColor,
                                  fontSize: 14,
                                  fontFamily: 'Gilroy-SemiBold',
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
