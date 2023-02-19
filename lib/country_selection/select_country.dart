import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:geojson/geojson.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectDestination extends StatefulWidget {
  const SelectDestination({Key? key}) : super(key: key);

  @override
  State<SelectDestination> createState() => _SelectDestinationState();
}

class _SelectDestinationState extends State<SelectDestination> {
  var list = [];
  var boolList = [];
  var tempCountryList = [];
  late GoogleMapController _mapController;

  // on below line we have set the camera position
  static const CameraPosition _kGoogle = CameraPosition(
    target: LatLng(19.0759837, 72.8776559),
    zoom: 4,
  );

  Set<Polygon> _polygon = HashSet<Polygon>();
  List<GeoJsonFeature> features = [];
  bool loading = true;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    parseAndDrawAssetsOnMap();
  }

  Future<void> parseAndDrawAssetsOnMap() async {
    final geo = GeoJson();

    final data =
        await rootBundle.loadString('lib/assets/json_data/countries.geojson');
    await geo.parse(data, verbose: true);

    features = geo.features;
    print("features ....${features.length}");
    boolList = List.filled(features.length, false);
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
              appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  toolbarHeight: 60,
                  title: const Text(
          "Select Destination",
          style: TextStyle(fontSize: 17.0, color: Colors.black),
        ),
                  centerTitle: true,
      ),
              body: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   Container  (
                      color: Colors.grey,
                      padding: const EdgeInsets.only(top: 1),
                      child: Container(
                        height: size.height * 0.350,
                        color: Colors.white,
                          child: GoogleMap(
                            mapType: MapType.normal,
                            initialCameraPosition: _kGoogle,
                            zoomControlsEnabled: true,
                            polygons: _polygon,
                            onMapCreated: (GoogleMapController controller) {
                            _mapController = controller;},),),),
                    const SizedBox(height: 15.0),
                    Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                              child: loading
                                ? const Center(
                                    child: CupertinoActivityIndicator(),
                                  )
                                : features.isEmpty
                                    ? const Center(
                                        child: Text("Data not found."),
                                      )
                                    : ListView.builder(
                                        itemCount: features.length,
                                        itemBuilder: (BuildContext context, int index) {
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 15.0),
                                            child: Container(
                                              height: 55.0,
                                              padding: const EdgeInsets.symmetric(horizontal: 5),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.black45, width: 1),
                                                  borderRadius: BorderRadius.circular(10.0)),
                                              child: CheckboxListTile(
                                                contentPadding: EdgeInsets.zero,
                                                value: boolList[index],
                                                onChanged: (bool? value) {
                                                  log('click');
                                                  log('features = ${features[index].geometry}');

                                                  print("va.......$value");
                                                  if (value == null) {
                                                    return;
                                                  }

                                                  if (value == true) {
                                                    boolList[index] = true;
                                                    if (features[index].geometry
                                                        is GeoJsonPolygon) {
                                                      GeoJsonPolygon polygon =
                                                          features[index].geometry;
                                                      List<LatLng> latlng = [];

                                                      polygon.geoSeries.forEach((element) {
                                                        element.geoPoints.forEach((e) {
                                                          latlng.add(
                                                              LatLng(e.latitude, e.longitude));
                                                        });
                                                      });
                                                      // _marker.add(Marker(markerId: MarkerId('$index'),position: latlng.first));
                                                      _polygon.add(Polygon(
                                                        // given polygonId
                                                        polygonId: PolygonId('$index'),
                                                        // initialize the list of points to display polygon
                                                        points: latlng,
                                                        // given color to polygon
                                                        fillColor:
                                                            Colors.green.withOpacity(0.3),
                                                        // given border color to polygon
                                                        strokeColor: Colors.green,
                                                        geodesic: true,
                                                        // given width of border
                                                        strokeWidth: 4,
                                                      ));
                                                      _mapController.animateCamera(
                                                          CameraUpdate.newCameraPosition(
                                                              CameraPosition(
                                                                  target: latlng.first,
                                                                  zoom: 4)));
                                                    } else {
                                                      GeoJsonMultiPolygon polygon =
                                                          features[index].geometry;
                                                      List<LatLng> latlng = [];

                                                      polygon.polygons.forEach((element) {
                                                        element.geoSeries.forEach((e) {
                                                          e.geoPoints.forEach((e1) {
                                                            latlng.add(LatLng(
                                                                e1.latitude, e1.longitude));
                                                          });
                                                        });
                                                      });

                                                      _mapController.animateCamera(
                                                          CameraUpdate.newCameraPosition(
                                                              CameraPosition(
                                                                  target: latlng.first,
                                                                  zoom: 4)));
                                                      // _marker.add(Marker(markerId: MarkerId('$index'),position: latlng[0]));
                                                      _polygon.add(Polygon(
                                                        // given polygonId
                                                        polygonId: PolygonId('$index'),
                                                        // initialize the list of points to display polygon
                                                        points: latlng,
                                                        // given color to polygon
                                                        fillColor:
                                                            Colors.green.withOpacity(0.3),
                                                        // given border color to polygon
                                                        strokeColor: Colors.green,
                                                        geodesic: true,
                                                        // given width of border
                                                        strokeWidth: 4,
                                                      ));
                                                      setState(() {});
                                                    }

                                                    setState(() {});
                                                  } else {
                                                    boolList[index] = false;

                                                    if (features[index].geometry
                                                        is GeoJsonPolygon) {
                                                      List<LatLng> latlng = [];

                                                      GeoJsonPolygon polygon =
                                                          features[index].geometry;
                                                      polygon.geoSeries.forEach((element) {
                                                        element.geoPoints.forEach((e) {
                                                          latlng.add(
                                                              LatLng(e.latitude, e.longitude));
                                                        });
                                                      });

                                                      //  _marker.remove(Marker(markerId: MarkerId('$index'),position: latlng[0]));

                                                      _polygon.remove(Polygon(
                                                        // given polygonId
                                                        polygonId: PolygonId('$index'),
                                                        // initialize the list of points to display polygon
                                                        points: latlng,
                                                        // given color to polygon
                                                        fillColor:
                                                            Colors.green.withOpacity(0.3),
                                                        // given border color to polygon
                                                        strokeColor: Colors.green,
                                                        geodesic: true,
                                                        // given width of border
                                                        strokeWidth: 4,
                                                      ));
                                                    } else {
                                                      List<LatLng> latlng = [];

                                                      GeoJsonMultiPolygon polygon =
                                                          features[index].geometry;
                                                      polygon.polygons.forEach((element) {
                                                        element.geoSeries.forEach((e) {
                                                          e.geoPoints.forEach((e1) {
                                                            latlng.add(LatLng(
                                                                e1.latitude, e1.longitude));
                                                          });
                                                        });
                                                      });
                                                      //  _marker.remove(Marker(markerId: MarkerId('$index'),position: latlng[0]));

                                                      _polygon.remove(Polygon(
                                                        // given polygonId
                                                        polygonId: PolygonId('$index'),
                                                        // initialize the list of points to display polygon
                                                        points: latlng,
                                                        // given color to polygon
                                                        fillColor:
                                                            Colors.green.withOpacity(0.3),
                                                        // given border color to polygon
                                                        strokeColor: Colors.green,
                                                        geodesic: true,
                                                        // given width of border
                                                        strokeWidth: 4,
                                                      ));
                                                    }
                                                    setState(() {});

                                                    return;
                                                  }
                                                },
                                                title: Text(
                                                  features[index].properties!['ADMIN'] ?? '',
                                                  style: const TextStyle(
                                                      fontSize: 17.0, color: Colors.black),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),)),
        ],
      ),
    ));
  }
}
