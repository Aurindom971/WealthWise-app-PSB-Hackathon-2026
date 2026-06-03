// findatm_screen.dart
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// ⚠️ Use a Google Cloud API key with BOTH enabled:
//    • "Maps SDK for Android" (and "Maps SDK for iOS")
//    • "Places API (New)"
const String kGoogleApiKey = 'AIzaSyCva3C1uMfDaH4AubCeHWG1IjlJqZabnjI'
;

const Color _primary = Color(0xFF1F5D3A);
const Color _primaryLight = Color(0xFF2E7D5B);

class Atm {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final double distanceMeters;

  Atm({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.distanceMeters,
  });
}

class FindAtmScreen extends StatefulWidget {
  const FindAtmScreen({super.key});

  @override
  State<FindAtmScreen> createState() => _FindAtmScreenState();
}

class _FindAtmScreenState extends State<FindAtmScreen> {
  GoogleMapController? _mapController;
  Position? _position;
  List<Atm> _atms = [];
  Set<Marker> _markers = {};

  String _status = 'locating'; // locating | loading | done | error
  String _error = '';

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() {
      _status = 'locating';
      _error = '';
    });

    try {
      final pos = await _determinePosition();
      if (!mounted) return;
      setState(() {
        _position = pos;
        _status = 'loading';
      });
      await _fetchAtms(pos.latitude, pos.longitude);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = 'error';
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<Position> _determinePosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please turn them on.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permission permanently denied. Enable it in settings.');
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _fetchAtms(double lat, double lng) async {
    final uri = Uri.parse('https://places.googleapis.com/v1/places:searchNearby');
    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': kGoogleApiKey,
        'X-Goog-FieldMask':
            'places.id,places.displayName,places.formattedAddress,places.location',
      },
      body: jsonEncode({
        'includedTypes': ['atm'],
        'maxResultCount': 20,
        'rankPreference': 'DISTANCE',
        'locationRestriction': {
          'circle': {
            'center': {'latitude': lat, 'longitude': lng},
            'radius': 5000.0,
          }
        }
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Places API error ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final places = (data['places'] as List?) ?? [];

    final atms = <Atm>[];
    for (final p in places) {
      final loc = p['location'];
      if (loc == null) continue;
      final aLat = (loc['latitude'] as num).toDouble();
      final aLng = (loc['longitude'] as num).toDouble();
      atms.add(Atm(
        id: p['id']?.toString() ?? '$aLat,$aLng',
        name: (p['displayName']?['text'] ?? 'ATM').toString(),
        address: (p['formattedAddress'] ?? '').toString(),
        lat: aLat,
        lng: aLng,
        distanceMeters: _haversine(lat, lng, aLat, aLng),
      ));
    }

    atms.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('me'),
        position: LatLng(lat, lng),
        infoWindow: const InfoWindow(title: 'You are here'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
      ...atms.map((a) => Marker(
            markerId: MarkerId(a.id),
            position: LatLng(a.lat, a.lng),
            infoWindow: InfoWindow(title: a.name, snippet: a.address),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed),
          )),
    };

    if (!mounted) return;
    setState(() {
      _atms = atms;
      _markers = markers;
      _status = 'done';
    });
  }

  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0;
    double toRad(double d) => d * math.pi / 180;
    final dLat = toRad(lat2 - lat1);
    final dLon = toRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(toRad(lat1)) *
            math.cos(toRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  String _formatDistance(double m) {
    if (m < 1000) return '${m.round()} m away';
    return '${(m / 1000).toStringAsFixed(1)} km away';
  }

  Future<void> _openDirections(Atm a) async {
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${a.lat},${a.lng}');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open maps')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_primary, _primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Find Nearby ATMs',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 2),
              Text('ATMs from all banks near you',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_status == 'locating' || _status == 'loading') {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: _primary),
            const SizedBox(height: 12),
            Text(
              _status == 'locating'
                  ? 'Getting your location…'
                  : 'Finding nearby ATMs…',
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      );
    }

    if (_status == 'error') {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 12),
              Text(_error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: _primary),
                onPressed: _start,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    // done
    final me = _position!;
    return Column(
      children: [
        // ---- MAP (this is the part that was missing) ----
        SizedBox(
          height: 240,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(me.latitude, me.longitude),
              zoom: 14,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            onMapCreated: (c) => _mapController = c,
          ),
        ),
        // ---- COUNT ----
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Text('${_atms.length} ATMs nearby · nearest first',
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600)),
          ),
        ),
        // ---- LIST ----
        Expanded(
          child: _atms.isEmpty
              ? const Center(
                  child: Text('No ATMs found nearby.',
                      style: TextStyle(color: Colors.black54)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  itemCount: _atms.length,
                  itemBuilder: (_, i) => _atmCard(_atms[i]),
                ),
        ),
      ],
    );
  }

  Widget _atmCard(Atm a) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.location_on, color: _primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.name,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(a.address,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54, height: 1.4)),
                    const SizedBox(height: 4),
                    Text(_formatDistance(a.distanceMeters),
                        style: const TextStyle(
                            fontSize: 12,
                            color: _primary,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _openDirections(a),
              icon: const Icon(Icons.navigation, size: 16),
              label: const Text('Get Directions',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
