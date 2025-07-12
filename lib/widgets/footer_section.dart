import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class FooterSection extends StatefulWidget {
  const FooterSection({super.key});

  @override
  State<FooterSection> createState() => _FooterSectionState();
}

class _FooterSectionState extends State<FooterSection> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A1A2E),
            Color(0xFF16213E),
            Color(0xFF0F1419),
          ],
        ),
      ),
      child: Column(
        children: [
          // Main footer content
          Container(
            padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          // Main Footer Content
                          LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth > 768) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: _buildBrandSection(),
                                    ),
                                    const SizedBox(width: 60),
                                    Expanded(
                                      child: _buildContactSection(),
                                    ),
                                    const SizedBox(width: 60),
                                    Expanded(
                                      child: _buildQuickLinksSection(),
                                    ),
                                  ],
                                );
                              } else {
                                return Column(
                                  children: [
                                    _buildBrandSection(),
                                    const SizedBox(height: 40),
                                    _buildContactSection(),
                                    const SizedBox(height: 40),
                                    _buildQuickLinksSection(),
                                  ],
                                );
                              }
                            },
                          ),
                          
                          const SizedBox(height: 60),
                          
                          // Newsletter section
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Bleib auf dem Laufenden!',
                                  style: GoogleFonts.roboto(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Erhalte Benachrichtigungen über neue Events und Spieleabende.',
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () {
                                    // Handle newsletter subscription
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1976D2),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.notifications_active),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Benachrichtigungen erhalten',
                                        style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          
          // Bottom section with gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
            child: Column(
              children: [
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    '© 2024 Heusenstamm spielt. Alle Rechte vorbehalten.',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Hero(
              tag: 'logo',
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1976D2),
                      Color(0xFF1565C0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1976D2).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.casino,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Heusenstamm spielt',
              style: GoogleFonts.roboto(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Eine lokale Initiative für kostenlose Brettspiel-Events in Heusenstamm. '
          'Wir bringen Menschen zusammen und schaffen unvergessliche Spielerlebnisse für alle Altersgruppen.',
          style: GoogleFonts.roboto(
            fontSize: 14,
            height: 1.6,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 24),
        // Social media icons (placeholder)
        Row(
          children: [
            _buildSocialIcon(Icons.facebook, () => _launchURL('https://facebook.com/heusenstammspielt')),
            const SizedBox(width: 12),
            _buildSocialIcon(Icons.email, () => _launchURL('mailto:info@heusenstamm-spielt.de')),
            const SizedBox(width: 12),
            _buildSocialIcon(Icons.phone, () => _launchURL('tel:+4961041234567')),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 18,
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kontakt',
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        _buildContactItem(
          icon: Icons.email_outlined,
          text: 'info@heusenstamm-spielt.de',
        ),
        const SizedBox(height: 16),
        _buildContactItem(
          icon: Icons.phone_outlined,
          text: '+49 6104 123456',
        ),
        const SizedBox(height: 16),
        _buildContactItem(
          icon: Icons.location_on_outlined,
          text: 'Heusenstamm, Hessen',
        ),
        const SizedBox(height: 16),
        _buildContactItem(
          icon: Icons.schedule_outlined,
          text: 'Mo-Fr: 18:00-22:00',
        ),
      ],
    );
  }

  Widget _buildQuickLinksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schnellzugriff',
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        _buildQuickLink('Nächste Termine', Icons.calendar_today),
        const SizedBox(height: 16),
        _buildQuickLink('Über uns', Icons.info_outline),
        const SizedBox(height: 16),
        _buildQuickLink('Mitmachen', Icons.group_add),
        const SizedBox(height: 16),
        _buildQuickLink('Spiele-Bibliothek', Icons.library_books),
        const SizedBox(height: 16),
        _buildQuickLink('Impressum', Icons.description),
      ],
    );
  }

  Widget _buildContactItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF1976D2).withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 14,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickLink(String text, IconData icon) {
    return GestureDetector(
      onTap: () {
        // Handle navigation
      },
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.white.withOpacity(0.6),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  // Method to launch URLs
  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
