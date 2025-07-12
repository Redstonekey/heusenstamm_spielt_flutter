import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/image_service.dart';

class AboutSection extends StatefulWidget {
  const AboutSection({super.key});

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection> with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _cardAnimations;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    
    // Create staggered animations for cards
    _cardAnimations = List.generate(3, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(
          index * 0.2,
          0.8 + (index * 0.2),
          curve: Curves.easeOutBack,
        ),
      ));
    });
    
    // Start animation when widget is built
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
            Color(0xFFFAFAFA),
            Color(0xFFF5F5F5),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // Section Title with animation
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - _controller.value)),
                    child: Opacity(
                      opacity: _controller.value,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1976D2).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'ÜBER UNS',
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1976D2),
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Heusenstamm spielt',
                            style: GoogleFonts.roboto(
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                              letterSpacing: -1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Gemeinsam spielen, gemeinsam lachen',
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              color: Colors.black54,
                              fontWeight: FontWeight.w300,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 80),
              
              // Content Grid with animations
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 768) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AnimatedBuilder(
                            animation: _cardAnimations[0],
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, 50 * (1 - _cardAnimations[0].value)),
                                child: Opacity(
                                  opacity: _cardAnimations[0].value,
                                  child: _buildInfoCard(
                                    icon: Icons.group,
                                    title: 'Gemeinschaft',
                                    description: 'Wir bringen Menschen zusammen und schaffen eine freundliche Atmosphäre für alle Altersgruppen.',
                                    color: const Color(0xFF4CAF50),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 40),
                        Expanded(
                          child: AnimatedBuilder(
                            animation: _cardAnimations[1],
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, 50 * (1 - _cardAnimations[1].value)),
                                child: Opacity(
                                  opacity: _cardAnimations[1].value,
                                  child: _buildInfoCard(
                                    icon: Icons.free_breakfast,
                                    title: 'Kostenlos',
                                    description: 'Alle unsere Events sind vollständig kostenlos. Wir glauben, dass Spaß für jeden zugänglich sein sollte.',
                                    color: const Color(0xFFFF9800),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 40),
                        Expanded(
                          child: AnimatedBuilder(
                            animation: _cardAnimations[2],
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, 50 * (1 - _cardAnimations[2].value)),
                                child: Opacity(
                                  opacity: _cardAnimations[2].value,
                                  child: _buildInfoCard(
                                    icon: Icons.schedule,
                                    title: 'Regelmäßig',
                                    description: 'Wir organisieren regelmäßige Spieleabende und besondere Events für die ganze Familie.',
                                    color: const Color(0xFF9C27B0),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        AnimatedBuilder(
                          animation: _cardAnimations[0],
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, 50 * (1 - _cardAnimations[0].value)),
                              child: Opacity(
                                opacity: _cardAnimations[0].value,
                                child: _buildInfoCard(
                                  icon: Icons.group,
                                  title: 'Gemeinschaft',
                                  description: 'Wir bringen Menschen zusammen und schaffen eine freundliche Atmosphäre für alle Altersgruppen.',
                                  color: const Color(0xFF4CAF50),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 40),
                        AnimatedBuilder(
                          animation: _cardAnimations[1],
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, 50 * (1 - _cardAnimations[1].value)),
                              child: Opacity(
                                opacity: _cardAnimations[1].value,
                                child: _buildInfoCard(
                                  icon: Icons.free_breakfast,
                                  title: 'Kostenlos',
                                  description: 'Alle unsere Events sind vollständig kostenlos. Wir glauben, dass Spaß für jeden zugänglich sein sollte.',
                                  color: const Color(0xFFFF9800),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 40),
                        AnimatedBuilder(
                          animation: _cardAnimations[2],
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, 50 * (1 - _cardAnimations[2].value)),
                              child: Opacity(
                                opacity: _cardAnimations[2].value,
                                child: _buildInfoCard(
                                  icon: Icons.schedule,
                                  title: 'Regelmäßig',
                                  description: 'Wir organisieren regelmäßige Spieleabende und besondere Events für die ganze Familie.',
                                  color: const Color(0xFF9C27B0),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  }
                },
              ),
              
              const SizedBox(height: 80),
              
              // Description with better styling
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - _controller.value)),
                    child: Opacity(
                      opacity: _controller.value,
                      child: Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Unsere Mission',
                              style: GoogleFonts.roboto(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Heusenstamm spielt ist eine lokale Initiative, die sich zum Ziel gesetzt hat, '
                              'die Gemeinschaft durch Brettspiele zu stärken. Wir organisieren regelmäßige '
                              'Events, bei denen Menschen aller Altersgruppen zusammenkommen, um gemeinsam '
                              'zu spielen, zu lachen und neue Freundschaften zu knüpfen. Unsere Veranstaltungen '
                              'sind immer kostenlos und für jeden offen.',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                height: 1.7,
                                color: Colors.black54,
                                fontWeight: FontWeight.w300,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 80),
              
              // Community Gallery Section
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 40 * (1 - _controller.value)),
                    child: Opacity(
                      opacity: _controller.value,
                      child: Column(
                        children: [
                          Text(
                            'Community Impressionen',
                            style: GoogleFonts.roboto(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Einblicke in unsere Spielerunden und Events',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: Colors.black54,
                              fontWeight: FontWeight.w300,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),
                          
                          // Gallery Grid
                          LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth > 768) {
                                return Row(
                                  children: [
                                    Expanded(
                                      child: _buildGalleryImage(
                                        ImageService.getPicsumImage(
                                          width: 400,
                                          height: 250,
                                        ),
                                        'Familienspielabende',
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: _buildGalleryImage(
                                        ImageService.getPicsumImage(
                                          width: 400,
                                          height: 250,
                                        ),
                                        'Strategieturniere',
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: _buildGalleryImage(
                                        ImageService.getPicsumImage(
                                          width: 400,
                                          height: 250,
                                        ),
                                        'Kinderspielzeiten',
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return Column(
                                  children: [
                                    _buildGalleryImage(
                                      ImageService.getPicsumImage(
                                        width: 400,
                                        height: 250,
                                      ),
                                      'Familienspielabende',
                                    ),
                                    const SizedBox(height: 20),
                                    _buildGalleryImage(
                                      ImageService.getPicsumImage(
                                        width: 400,
                                        height: 250,
                                      ),
                                      'Strategieturniere',
                                    ),
                                    const SizedBox(height: 20),
                                    _buildGalleryImage(
                                      ImageService.getPicsumImage(
                                        width: 400,
                                        height: 250,
                                      ),
                                      'Kinderspielzeiten',
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryImage(String imageUrl, String caption) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Image.network(
              imageUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 250,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[200]!,
                        Colors.grey[100]!,
                      ],
                    ),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / 
                            loadingProgress.expectedTotalBytes!
                          : null,
                      color: const Color(0xFF1976D2),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 250,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1976D2).withOpacity(0.1),
                        const Color(0xFF1976D2).withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library,
                          size: 48,
                          color: const Color(0xFF1976D2).withOpacity(0.6),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          caption,
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1976D2).withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            // Overlay with caption
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Text(
                  caption,
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color,
                  color.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: GoogleFonts.roboto(
              fontSize: 14,
              height: 1.6,
              color: Colors.black54,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
