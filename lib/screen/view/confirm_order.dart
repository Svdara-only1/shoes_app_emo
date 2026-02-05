import 'package:computer_store/screen/view/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' show cos, sqrt, asin;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

/* =========================
   SHOP MODEL
========================= */
class Shop {
  final String id;
  final String name;
  final String address;
  final LatLng location;
  final String type;
  final String image;
  final double rating;

  Shop({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    required this.type,
    required this.image,
    required this.rating,
  });
}

/* =========================
   CONFIRM ORDER PAGE
========================= */
class ConfirmOrder extends StatefulWidget {
 final double total;
  const ConfirmOrder({super.key, required this.total});

  @override
  State<ConfirmOrder> createState() => _ConfirmOrderState();
}

class _ConfirmOrderState extends State<ConfirmOrder> {
  String selectedAddress = "";
  LatLng? selectedLatLng;
  Shop? selectedShop;
  double distanceToShop = 0.0;
  int deliveryTime = 0;

  // Sample shops data - In real app, fetch from API
  final List<Shop> shops = [
    Shop(
      id: '1',
      name: 'Central Market Store',
      address: 'St 130, Phnom Penh',
      location: LatLng(11.5614, 104.9224),
      type: 'Supermarket',
      image: '🏪',
      rating: 4.5,
    ),
    Shop(
      id: '2',
      name: 'Royal Plaza Shop',
      address: 'St 154, Phnom Penh',
      location: LatLng(11.5534, 104.9312),
      type: 'Mall',
      image: '🏬',
      rating: 4.7,
    ),
    Shop(
      id: '3',
      name: 'Riverside Market',
      address: 'Sisowath Quay, Phnom Penh',
      location: LatLng(11.5689, 104.9289),
      type: 'Market',
      image: '🛒',
      rating: 4.3,
    ),
    Shop(
      id: '4',
      name: 'Downtown Store',
      address: 'St 63, Phnom Penh',
      location: LatLng(11.5498, 104.9201),
      type: 'Store',
      image: '🏪',
      rating: 4.6,
    ),
  ];

  // Calculate distance between two points (Haversine formula)
  double calculateDistance(LatLng from, LatLng to) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((to.latitude - from.latitude) * p) / 2 +
        c(from.latitude * p) *
            c(to.latitude * p) *
            (1 - c((to.longitude - from.longitude) * p)) /
            2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  // Find nearest shop
  Shop? findNearestShop(LatLng userLocation) {
    if (shops.isEmpty) return null;

    Shop? nearest;
    double minDistance = double.infinity;

    for (var shop in shops) {
      double distance = calculateDistance(userLocation, shop.location);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = shop;
      }
    }

    distanceToShop = minDistance;
    return nearest;
  }

  // Get shops sorted by distance
  List<Map<String, dynamic>> getShopsWithDistance(LatLng userLocation) {
    List<Map<String, dynamic>> shopsWithDistance = shops.map((shop) {
      double distance = calculateDistance(userLocation, shop.location);
      return {
        'shop': shop,
        'distance': distance,
      };
    }).toList();

    shopsWithDistance.sort((a, b) {
      double distA = a['distance'] as double;
      double distB = b['distance'] as double;
      return distA.compareTo(distB);
    });

    return shopsWithDistance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Confirm Order",
            style: TextStyle(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[700]!, Colors.blue[500]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.location_on,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Delivery Address",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Select your delivery location",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Address Selection Card
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push<Map<String, dynamic>>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LocationPicker(
                            shops: shops,
                            calculateDistance: calculateDistance,
                            getShopsWithDistance: getShopsWithDistance,
                          ),
                        ),
                      );
                      if (result != null && mounted) {
                        setState(() {
                          selectedAddress = result["address"];
                          selectedLatLng = LatLng(result["lat"], result["lng"]);
                          selectedShop = result["shop"];
                          distanceToShop = result["distance"] ?? 0.0;
                          deliveryTime = result["duration"] ?? 0;
                        });
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selectedAddress.isNotEmpty
                              ? Colors.blue[700]!
                              : Colors.grey[300]!,
                          width: selectedAddress.isNotEmpty ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: selectedAddress.isNotEmpty ? 12 : 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                            color: Colors.black.withOpacity(
                                selectedAddress.isNotEmpty ? 0.15 : 0.08),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: selectedAddress.isNotEmpty
                                      ? Colors.blue[50]
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  selectedAddress.isNotEmpty
                                      ? Icons.check_circle
                                      : Icons.add_location,
                                  color: selectedAddress.isNotEmpty
                                      ? Colors.blue[700]
                                      : Colors.grey[600],
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedAddress.isNotEmpty
                                          ? "Delivery Location"
                                          : "Add Address",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      selectedAddress.isNotEmpty
                                          ? selectedAddress
                                          : "Tap to select your delivery address",
                                      style: TextStyle(
                                        fontSize:
                                            selectedAddress.isNotEmpty ? 15 : 16,
                                        fontWeight: selectedAddress.isNotEmpty
                                            ? FontWeight.w500
                                            : FontWeight.w400,
                                        color: selectedAddress.isNotEmpty
                                            ? Colors.black87
                                            : Colors.grey[500],
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 18,
                                color: Colors.grey[400],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Nearest Shop Info
                  if (selectedShop != null)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green[200]!),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                            color: Colors.black.withOpacity(0.05),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  selectedShop!.image,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedShop!.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            size: 16, color: Colors.amber),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${selectedShop!.rating}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[50],
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            selectedShop!.type,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.blue[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(Icons.route,
                                        size: 20, color: Colors.blue[700]),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Distance',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          '${distanceToShop.toStringAsFixed(1)} km',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.grey[300],
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(Icons.schedule,
                                        size: 20, color: Colors.green[700]),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Est. Time',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          '${deliveryTime > 0 ? deliveryTime : (distanceToShop * 5).ceil()} min',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  // Mini Map Preview with Real Route
                  if (selectedLatLng != null)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: selectedLatLng!,
                          zoom: 13,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId("selected"),
                            position: selectedLatLng!,
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueBlue),
                          ),
                          if (selectedShop != null)
                            Marker(
                              markerId: const MarkerId("shop"),
                              position: selectedShop!.location,
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueGreen),
                            ),
                        },
                        zoomControlsEnabled: false,
                        myLocationButtonEnabled: false,
                        mapToolbarEnabled: false,
                        scrollGesturesEnabled: false,
                        zoomGesturesEnabled: false,
                        tiltGesturesEnabled: false,
                        rotateGesturesEnabled: false,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, -4),
              color: Colors.black.withOpacity(0.05),
            )
          ],
        ),
        child: ElevatedButton(
          onPressed: selectedAddress.isNotEmpty
              ? () {
                  // Navigate to PaymentMethodd - Replace with your actual navigation
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PaymentScreen(totalAmount: widget.total,),
                    ),
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            disabledBackgroundColor: Colors.grey[300],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            "Continue to Payment",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: selectedAddress.isNotEmpty ? Colors.white : Colors.grey[500],
            ),
          ),
        ),
      ),
    );
  }
}

/* =========================
   LOCATION PICKER PAGE
========================= */
class LocationPicker extends StatefulWidget {
  final List<Shop> shops;
  final double Function(LatLng, LatLng) calculateDistance;
  final List<Map<String, dynamic>> Function(LatLng) getShopsWithDistance;

  const LocationPicker({
    super.key,
    required this.shops,
    required this.calculateDistance,
    required this.getShopsWithDistance,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late GoogleMapController mapController;
  LatLng selectedPoint = const LatLng(11.5564, 104.9282); // Phnom Penh
  String address = "Loading location...";
  bool isLoading = false;
  bool isLoadingCurrentLocation = false;
  bool isLoadingRoute = false;
  bool showNearbyShops = false;
  TextEditingController searchController = TextEditingController();
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  Shop? nearestShop;
  List<Map<String, dynamic>> nearbyShops = [];
  List<LatLng> routeCoordinates = [];
  double routeDistance = 0.0;
  int routeDuration = 0;

  // ⚠️ SECURITY WARNING: Replace with your actual API key
  // DO NOT commit this to public repositories!
  // Use environment variables or secure storage in production
  final String googleApiKey = "AIzaSyBTzZVtm0j7PyCGPy7xKlHG0R5W_4dHAX0";

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    await _updateLocation(selectedPoint);
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  /// Main location update - triggers route fetching
  Future<void> _updateLocation(LatLng position) async {
    setState(() {
      selectedPoint = position;
      isLoadingRoute = true;
    });

    // Update address
    await _getAddress(position);

    // Find nearby shops
    _findNearbyShops(position);

    // Fetch real route to nearest shop
    if (nearestShop != null) {
      await _getDirections(position, nearestShop!.location);
    } else {
      _updateMarkers();
    }

    if (mounted) {
      setState(() => isLoadingRoute = false);
    }
  }

  /// Fetch real street directions from Google Directions API
  Future<void> _getDirections(LatLng origin, LatLng destination) async {
    print(
        '🚗 Fetching route from ${origin.latitude},${origin.longitude} to ${destination.latitude},${destination.longitude}');

    String url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&mode=driving'
        '&key=$googleApiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          // Extract encoded polyline
          String encodedPolyline =
              data['routes'][0]['overview_polyline']['points'];

          // Decode to get actual street coordinates
          List<PointLatLng> result =
              PolylinePoints.decodePolyline(encodedPolyline);

          // Convert to LatLng
          routeCoordinates = result
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();

          // Get accurate distance and duration from API
          routeDistance =
              data['routes'][0]['legs'][0]['distance']['value'] / 1000; // km
          routeDuration = data['routes'][0]['legs'][0]['duration']['value'] ~/
              60; // minutes

          print(
              '✅ Route loaded: ${routeCoordinates.length} points, ${routeDistance.toStringAsFixed(1)}km, ${routeDuration}min');

          _updateMarkersWithRoute();
          _fitBoundsToRoute();
        } else if (data['status'] == 'REQUEST_DENIED') {
          print('❌ API Error: ${data['error_message']}');
          _showApiError();
          _fallbackToStraightLine(origin, destination);
        } else {
          print('⚠️ API returned status: ${data['status']}');
          _fallbackToStraightLine(origin, destination);
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        _fallbackToStraightLine(origin, destination);
      }
    } catch (e) {
      print('❌ Error fetching directions: $e');
      _fallbackToStraightLine(origin, destination);
    }
  }

  /// Fallback to straight line if API fails
  void _fallbackToStraightLine(LatLng origin, LatLng destination) {
    if (mounted) {
      setState(() {
        routeCoordinates = [origin, destination];
        routeDistance = widget.calculateDistance(origin, destination);
        routeDuration = (routeDistance * 5).ceil();
      });
    }
    _updateMarkersWithRoute();
  }

  /// Show API error message
  void _showApiError() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enable Directions API in Google Cloud Console'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  /// Update markers with route polyline
  void _updateMarkersWithRoute() {
    Set<Marker> newMarkers = {
      // User location
      Marker(
        markerId: const MarkerId("selected"),
        position: selectedPoint,
        draggable: true,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: "Your Location"),
        onDragEnd: (newPosition) {
          _updateLocation(newPosition);
        },
      ),
    };

    // Add shop markers
    for (var shop in widget.shops) {
      bool isNearest = shop == nearestShop;
      newMarkers.add(
        Marker(
          markerId: MarkerId(shop.id),
          position: shop.location,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isNearest ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueOrange,
          ),
          infoWindow: InfoWindow(
            title: shop.name,
            snippet: isNearest ? '⭐ Nearest Shop' : shop.type,
          ),
          onTap: () => _showShopDetails(shop),
        ),
      );
    }

    // Create professional route polyline
    Set<Polyline> newPolylines = {};
    if (nearestShop != null && routeCoordinates.length >= 2) {
      newPolylines = {
        // White border (outer line)
        Polyline(
          polylineId: const PolylineId("route_border"),
          points: routeCoordinates,
          color: Colors.white,
          width: 8,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
        // Blue route (inner line)
        Polyline(
          polylineId: const PolylineId("route"),
          points: routeCoordinates,
          color: const Color(0xFF4285F4), // Google Maps blue
          width: 5,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          patterns: routeCoordinates.length == 2
              ? [
                  PatternItem.dash(10),
                  PatternItem.gap(5)
                ] // Dashed for straight line
              : [], // Solid for real route
        ),
      };
    }

    if (mounted) {
      setState(() {
        markers = newMarkers;
        polylines = newPolylines;
      });
    }
  }

  /// Fit camera to show entire route
  void _fitBoundsToRoute() {
    if (routeCoordinates.length < 2) return;

    LatLngBounds bounds = _createBounds(routeCoordinates);
    Future.delayed(const Duration(milliseconds: 300), () {
      try {
        mapController.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 80),
        );
      } catch (e) {
        print('Error fitting bounds: $e');
      }
    });
  }

  /// Create bounds from coordinates
  LatLngBounds _createBounds(List<LatLng> positions) {
    double south = positions.first.latitude;
    double west = positions.first.longitude;
    double north = positions.first.latitude;
    double east = positions.first.longitude;

    for (LatLng pos in positions) {
      if (pos.latitude < south) south = pos.latitude;
      if (pos.longitude < west) west = pos.longitude;
      if (pos.latitude > north) north = pos.latitude;
      if (pos.longitude > east) east = pos.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );
  }

  /// Update basic markers without route
  void _updateMarkers() {
    Set<Marker> newMarkers = {
      Marker(
        markerId: const MarkerId("selected"),
        position: selectedPoint,
        draggable: true,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: "Your Location"),
        onDragEnd: (newPosition) {
          _updateLocation(newPosition);
        },
      ),
    };

    // Add shop markers
    for (var shop in widget.shops) {
      newMarkers.add(
        Marker(
          markerId: MarkerId(shop.id),
          position: shop.location,
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: shop.name,
            snippet: shop.type,
          ),
          onTap: () => _showShopDetails(shop),
        ),
      );
    }

    if (mounted) {
      setState(() {
        markers = newMarkers;
      });
    }
  }

  /// Find nearby shops sorted by distance
  void _findNearbyShops(LatLng userLocation) {
    nearbyShops = widget.getShopsWithDistance(userLocation);
    if (nearbyShops.isNotEmpty) {
      nearestShop = nearbyShops.first['shop'];
    }
  }

  /// Show shop details bottom sheet
  void _showShopDetails(Shop shop) {
    double distance;
    int deliveryTime;

    if (shop == nearestShop && routeDistance > 0) {
      distance = routeDistance;
      deliveryTime = routeDuration;
    } else {
      distance = widget.calculateDistance(selectedPoint, shop.location);
      deliveryTime = (distance * 5).ceil();
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(shop.image, style: const TextStyle(fontSize: 32)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text('${shop.rating}'),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              shop.type,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      shop.address,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.route, color: Colors.blue[700]),
                        const SizedBox(height: 4),
                        Text(
                          '${distance.toStringAsFixed(1)} km',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        Text(
                          'Distance',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.schedule, color: Colors.green[700]),
                        const SizedBox(height: 4),
                        Text(
                          '$deliveryTime min',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        Text(
                          'Est. Time',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Get current location
  Future<void> _getCurrentLocation() async {
    setState(() => isLoadingCurrentLocation = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        LatLng currentLocation = LatLng(position.latitude, position.longitude);

        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(currentLocation, 15),
        );
        await _updateLocation(currentLocation);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enable location permission'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not get current location'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoadingCurrentLocation = false);
      }
    }
  }

  /// Search location
  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    setState(() => isLoading = true);

    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        LatLng newPoint = LatLng(location.latitude, location.longitude);

        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(newPoint, 15),
        );
        await _updateLocation(newPoint);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not find the location'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  /// Get address from coordinates
  Future<void> _getAddress(LatLng point) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(point.latitude, point.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        if (mounted) {
          setState(() {
            address = [
              place.street,
              place.subLocality,
              place.locality,
              place.administrativeArea,
              place.country,
            ].where((e) => e != null && e.isNotEmpty).join(", ");

            if (address.isEmpty) {
              address =
                  "Location: ${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}";
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          address = "Address not available";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Location",
            style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(showNearbyShops ? Icons.map : Icons.list),
            onPressed: () {
              setState(() => showNearbyShops = !showNearbyShops);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: selectedPoint,
              zoom: 14,
            ),
            markers: markers,
            polylines: polylines,
            onTap: (position) {
              _updateLocation(position);
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            mapType: MapType.normal,
          ),

          // Search Bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black.withOpacity(0.15),
                  )
                ],
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search location...",
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
                onChanged: (value) => setState(() {}),
                onSubmitted: _searchLocation,
              ),
            ),
          ),

          // Nearby Shops List
          if (showNearbyShops && nearbyShops.isNotEmpty)
            Positioned(
              top: 80,
              left: 16,
              right: 16,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 300),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8,
                      color: Colors.black.withOpacity(0.15),
                    )
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(8),
                  itemCount: nearbyShops.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    Shop shop = nearbyShops[index]['shop'];
                    double distance = nearbyShops[index]['distance'];
                    int time = (distance * 5).ceil();
                    bool isNearest = index == 0;

                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isNearest
                              ? Colors.green[50]
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(shop.image,
                            style: const TextStyle(fontSize: 24)),
                      ),
                      title: Row(
                        children: [
                          Text(shop.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          if (isNearest) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'NEAREST',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text(
                          '${distance.toStringAsFixed(1)} km • $time min'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        mapController.animateCamera(
                          CameraUpdate.newLatLngZoom(shop.location, 15),
                        );
                        _showShopDetails(shop);
                      },
                    );
                  },
                ),
              ),
            ),

          // Route Loading Indicator
          if (isLoadingRoute)
            Positioned(
              top: showNearbyShops && nearbyShops.isNotEmpty ? 400 : 80,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Finding best route...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Current Location Button
          Positioned(
            right: 16,
            bottom: 180,
            child: FloatingActionButton(
              heroTag: "current_location",
              onPressed: isLoadingCurrentLocation ? null : _getCurrentLocation,
              backgroundColor: Colors.white,
              elevation: 4,
              child: isLoadingCurrentLocation
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.my_location, color: Colors.blue[700]),
            ),
          ),

          // Zoom Controls
          Positioned(
            right: 16,
            bottom: 260,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: "zoom_in",
                  onPressed: () {
                    mapController.animateCamera(CameraUpdate.zoomIn());
                  },
                  backgroundColor: Colors.white,
                  elevation: 4,
                  child: Icon(Icons.add, color: Colors.blue[700]),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: "zoom_out",
                  onPressed: () {
                    mapController.animateCamera(CameraUpdate.zoomOut());
                  },
                  backgroundColor: Colors.white,
                  elevation: 4,
                  child: Icon(Icons.remove, color: Colors.blue[700]),
                ),
              ],
            ),
          ),

          // Address Display Bottom Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                    color: Colors.black.withOpacity(0.1),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.location_on,
                            color: Colors.blue[700], size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Your Location",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              address,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (nearestShop != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          Text(nearestShop!.image,
                              style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nearest: ${nearestShop!.name}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (routeCoordinates.length > 2)
                                  Text(
                                    'Via street route',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                routeDistance > 0
                                    ? '${routeDistance.toStringAsFixed(1)} km'
                                    : '${widget.calculateDistance(selectedPoint, nearestShop!.location).toStringAsFixed(1)} km',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                              if (routeDuration > 0)
                                Text(
                                  '$routeDuration min',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                          label: const Text("Cancel"),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop({
                              "lat": selectedPoint.latitude,
                              "lng": selectedPoint.longitude,
                              "address": address,
                              "shop": nearestShop,
                              "distance": routeDistance > 0
                                  ? routeDistance
                                  : (nearestShop != null
                                      ? widget.calculateDistance(
                                          selectedPoint, nearestShop!.location)
                                      : 0.0),
                              "duration": routeDuration,
                            });
                          },
                          icon: const Icon(Icons.check),
                          label: const Text("Confirm Location"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Loading Overlay
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Searching location...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

/* =========================
   PAYMENT METHOD PAGE (Placeholder)
========================= */
class PaymentMethodd extends StatelessWidget {
  final int productId;

  const PaymentMethodd({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Method'),
      ),
      body: Center(
        child: Text('Payment page for product ID: $productId'),
      ),
    );
  }
}