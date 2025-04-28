import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/sustainability.dart';

class SupplierMapCard extends StatefulWidget {
  final List<LocalSupplier> suppliers;
  final LatLng? currentLocation;

  const SupplierMapCard({
    super.key,
    required this.suppliers,
    this.currentLocation,
  });

  @override
  State<SupplierMapCard> createState() => _SupplierMapCardState();
}

class _SupplierMapCardState extends State<SupplierMapCard> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _updateMarkers();
  }

  void _updateMarkers() {
    setState(() {
      _markers.clear();
      for (var supplier in widget.suppliers) {
        _markers.add(
          Marker(
            markerId: MarkerId(supplier.id),
            position: LatLng(supplier.latitude, supplier.longitude),
            infoWindow: InfoWindow(
              title: supplier.name,
              snippet: supplier.description,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 300,
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: widget.currentLocation ?? const LatLng(0, 0),
                  zoom: 12,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                onMapCreated: (controller) {
                  _mapController = controller;
                },
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${widget.suppliers.length}',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                        ),
                        const Text('Suppliers'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
