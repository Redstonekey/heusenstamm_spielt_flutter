import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/image_service.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));
    
    _controller.forward();
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
      height: MediaQuery.of(context).size.height * 0.9,
      child: Stack(
        children: [
          // Background Image with parallax effect
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_controller.value * 0.1),
                  child: Stack(
                    children: [
                      // Background image
                      Image.network(
                        ImageService.getPicsumImage(width: 1200, height: 800),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF1976D2),
                                  Color(0xFF1565C0),
                                  Color(0xFF0D47A1),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      // Overlay gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF1976D2).withOpacity(0.8),
                              const Color(0xFF1565C0).withOpacity(0.9),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Animated background pattern
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: BackgroundPatternPainter(_controller.value),
                );
              },
            ),
          ),
          
          // Dark overlay with gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),
          
          // Content
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo/Icon with bounce animation
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.elasticOut,
                            builder: (context, scale, child) {
                              return Transform.scale(
                                scale: scale,
                                child: Hero(
                                  tag: 'logo',
                                  child: Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(28),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 30,
                                          offset: const Offset(0, 15),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.casino,
                                      size: 70,
                                      color: Color(0xFF1976D2),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 50),
                          
                          // Title with typing effect
                          Text(
                            'Heusenstamm spielt',
                            style: GoogleFonts.roboto(
                              fontSize: MediaQuery.of(context).size.width > 600 ? 54 : 42,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -1,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Subtitle with fade-in effect
                          Text(
                            'Kostenlose Brettspiel-Events für die ganze Familie',
                            style: GoogleFonts.roboto(
                              fontSize: MediaQuery.of(context).size.width > 600 ? 22 : 18,
                              color: Colors.white.withOpacity(0.95),
                              fontWeight: FontWeight.w300,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                          
                          const SizedBox(height: 50),
                          
                          // CTA Button with hover effect
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Opacity(
                                  opacity: value,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Add scroll functionality
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF1976D2),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 40,
                                        vertical: 20,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(35),
                                      ),
                                      elevation: 12,
                                      shadowColor: Colors.black.withOpacity(0.3),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.calendar_today,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Nächste Termine ansehen',
                                          style: GoogleFonts.roboto(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                      ],
                                    ),
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
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for background pattern
class BackgroundPatternPainter extends CustomPainter {
  final double animationValue;

  BackgroundPatternPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw floating geometric shapes
    for (int i = 0; i < 12; i++) {
      final x = (size.width * (i % 4) / 4) + (animationValue * 50);
      final y = (size.height * (i ~/ 4) / 3) + (animationValue * 30);
      
      if (i % 2 == 0) {
        // Draw circles
        canvas.drawCircle(
          Offset(x, y),
          20 + (animationValue * 10),
          paint..color = Colors.white.withOpacity(0.05),
        );
      } else {
        // Draw squares
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(x, y),
            width: 30 + (animationValue * 15),
            height: 30 + (animationValue * 15),
          ),
          paint..color = Colors.white.withOpacity(0.03),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
