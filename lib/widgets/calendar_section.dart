import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/event.dart';
import '../services/image_service.dart';

class CalendarSection extends StatefulWidget {
  const CalendarSection({super.key});

  @override
  State<CalendarSection> createState() => _CalendarSectionState();
}

class _CalendarSectionState extends State<CalendarSection> with TickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late List<GameEvent> _events;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _events = _generateSampleEvents();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Start animation when widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<GameEvent> _generateSampleEvents() {
    final now = DateTime.now();
    return [
      GameEvent(
        id: '1',
        title: 'Familien-Spieleabend',
        description: 'Ein entspannter Abend mit klassischen Brettspielen für die ganze Familie.',
        date: now.add(const Duration(days: 7)),
        time: '18:00 - 22:00',
        location: 'Gemeindehaus Heusenstamm',
        latitude: 50.0336,
        longitude: 8.8002,
        games: ['Monopoly', 'Scrabble', 'Uno', 'Catan'],
        maxParticipants: 30,
        isHighlighted: true,
      ),
      GameEvent(
        id: '2',
        title: 'Strategiespiele-Turnier',
        description: 'Für erfahrene Spieler: Taktische Brettspiele und Strategiespiele.',
        date: now.add(const Duration(days: 14)),
        time: '19:00 - 23:00',
        location: 'Bürgerzentrum Heusenstamm',
        latitude: 50.0310,
        longitude: 8.8015,
        games: ['Risiko', 'Schach', 'Carcassonne', 'Ticket to Ride'],
        maxParticipants: 20,
      ),
      GameEvent(
        id: '3',
        title: 'Kinder-Spieletag',
        description: 'Spezielle Veranstaltung für Kinder von 6-12 Jahren mit altersgerechten Spielen.',
        date: now.add(const Duration(days: 21)),
        time: '14:00 - 17:00',
        location: 'Jugendhaus Heusenstamm',
        latitude: 50.0320,
        longitude: 8.7985,
        games: ['Mensch ärgere dich nicht', 'Memory', 'Looping Louie', 'Dobble'],
        maxParticipants: 25,
      ),
      GameEvent(
        id: '4',
        title: 'Retro-Spieleabend',
        description: 'Nostalgische Brettspiele aus vergangenen Jahrzehnten.',
        date: now.add(const Duration(days: 28)),
        time: '18:30 - 22:30',
        location: 'Gemeindehaus Heusenstamm',
        latitude: 50.0336,
        longitude: 8.8002,
        games: ['Trivial Pursuit', 'Tabu', 'Pictionary', 'Backgammon'],
        maxParticipants: 35,
      ),
    ];
  }

  List<GameEvent> _getEventsForDay(DateTime day) {
    return _events.where((event) => isSameDay(event.date, day)).toList();
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
            Color(0xFFF8F9FA),
            Color(0xFFFFFFFF),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
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
                    // Section Title with enhanced styling
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1976D2).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'TERMINE',
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
                          'Kommende Termine',
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
                          'Entdecke unsere nächsten Events und spiele mit!',
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            color: Colors.black54,
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 80),
                    
                    // Calendar and Events
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 768) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildCalendar(),
                              ),
                              const SizedBox(width: 40),
                              Expanded(
                                flex: 3,
                                child: _buildEventsList(),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              _buildCalendar(),
                              const SizedBox(height: 40),
                              _buildEventsList(),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: TableCalendar<GameEvent>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: _getEventsForDay,
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: GoogleFonts.roboto(
            color: const Color(0xFFFF6B35),
            fontWeight: FontWeight.w600,
          ),
          holidayTextStyle: GoogleFonts.roboto(
            color: const Color(0xFFFF6B35),
            fontWeight: FontWeight.w600,
          ),
          selectedDecoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1976D2),
                Color(0xFF1565C0),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1976D2).withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          todayDecoration: BoxDecoration(
            color: const Color(0xFF1976D2).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: Color(0xFFFF6B35),
            shape: BoxShape.circle,
          ),
          defaultTextStyle: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          cellMargin: const EdgeInsets.all(6),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
          leftChevronIcon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.chevron_left,
              color: Color(0xFF1976D2),
            ),
          ),
          rightChevronIcon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.chevron_right,
              color: Color(0xFF1976D2),
            ),
          ),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }

  Widget _buildEventsList() {
    final selectedEvents = _selectedDay != null 
        ? _getEventsForDay(_selectedDay!)
        : _events.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedDay != null 
              ? 'Events am ${DateFormat('dd.MM.yyyy').format(_selectedDay!)}'
              : 'Nächste Events',
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 20),
        
        if (selectedEvents.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Center(
              child: Text(
                'Keine Events an diesem Tag',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
          )
        else
          ...selectedEvents.map((event) => _buildEventCard(event)),
      ],
    );
  }

  Widget _buildEventCard(GameEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: event.isHighlighted 
            ? Border.all(color: const Color(0xFF1976D2), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event header with gradient
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: event.isHighlighted 
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1976D2),
                          Color(0xFF1565C0),
                        ],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.grey[100]!,
                          Colors.grey[50]!,
                        ],
                      ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (event.isHighlighted)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '★ HIGHLIGHT',
                            style: GoogleFonts.roboto(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: event.isHighlighted 
                              ? Colors.white.withOpacity(0.2)
                              : const Color(0xFF1976D2).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          DateFormat('dd.MM.yyyy').format(event.date),
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: event.isHighlighted 
                                ? Colors.white
                                : const Color(0xFF1976D2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    event.title,
                    style: GoogleFonts.roboto(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: event.isHighlighted 
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    event.description,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      height: 1.5,
                      color: event.isHighlighted 
                          ? Colors.white.withOpacity(0.9)
                          : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            
            // Event Image Section
            Container(
              height: 200,
              width: double.infinity,
              child: Image.network(
                ImageService.getPicsumImage(width: 400, height: 200),
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[100],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                        color: const Color(0xFF1976D2),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[100],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Image not available',
                            style: GoogleFonts.roboto(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Event details
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1976D2).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.access_time,
                          size: 16,
                          color: const Color(0xFF1976D2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        event.time,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1976D2).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.location_on,
                          size: 16,
                          color: const Color(0xFF1976D2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          event.location,
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _openGoogleMaps(event.latitude, event.longitude),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.directions,
                            size: 16,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Location Map Preview
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          // Flutter Map Widget
                          FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(event.latitude, event.longitude),
                              initialZoom: 15.0,
                              interactionOptions: const InteractionOptions(
                                flags: InteractiveFlag.none, // Disable interaction
                              ),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                subdomains: const ['a', 'b', 'c'],
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    width: 40.0,
                                    height: 40.0,
                                    point: LatLng(event.latitude, event.longitude),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1976D2),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.location_on,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Map overlay with location info
                          Positioned(
                            bottom: 12,
                            left: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.place,
                                    size: 16,
                                    color: const Color(0xFF1976D2),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      event.location,
                                      style: GoogleFonts.roboto(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _openGoogleMaps(event.latitude, event.longitude),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1976D2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(
                                        Icons.directions,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Tap overlay to open maps
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => _openGoogleMaps(event.latitude, event.longitude),
                                child: Container(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Games tags
                  Text(
                    'Spiele:',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: event.games.map((game) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF1976D2).withOpacity(0.1),
                            const Color(0xFF1976D2).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF1976D2).withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        game,
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1976D2),
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Method to open Google Maps with the event location
  void _openGoogleMaps(double latitude, double longitude) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    final uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Fallback - copy coordinates to clipboard or show dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Koordinaten: $latitude, $longitude'),
            action: SnackBarAction(
              label: 'Kopieren',
              onPressed: () {
                // Copy to clipboard functionality would go here
              },
            ),
          ),
        );
      }
    }
  }

  // Helper method to get event-specific images
  String _getEventImage(GameEvent event) {
    // Use different image sources based on event type
    if (event.title.toLowerCase().contains('familie')) {
      return ImageService.getPicsumImage(
        width: 600,
        height: 200,
      );
    } else if (event.title.toLowerCase().contains('strategie')) {
      return ImageService.getPicsumImage(
        width: 600,
        height: 200,
      );
    } else if (event.title.toLowerCase().contains('kinder')) {
      return ImageService.getPicsumImage(
        width: 600,
        height: 200,
      );
    } else if (event.title.toLowerCase().contains('retro')) {
      return ImageService.getPicsumImage(
        width: 600,
        height: 200,
      );
    } else if (event.games.isNotEmpty) {
      return ImageService.getPicsumImage(
        width: 600,
        height: 200,
      );
    } else {
      return ImageService.getPicsumImage(
        width: 600,
        height: 200,
      );
    }
  }
}
