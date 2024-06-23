import 'package:aplikurir/component/custom_button.dart';
import 'package:aplikurir/screen/login.dart';
import 'package:aplikurir/screen/status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:aplikurir/providers/provider.dart';
import 'package:aplikurir/component/custom_color.dart';

class MapScreen extends StatefulWidget {
  final dynamic user;

  const MapScreen({super.key, this.user});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late String storedEmail;
  late String storedPassword;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    storedEmail = widget.user['email'];
    storedPassword = widget.user['password'];
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: ChangeNotifierProvider(
        create: (context) =>
            OSMScreenProvider(_scaffoldKey, context, widget.user['id_kurir']),
        child: Scaffold(
          key: _scaffoldKey,
          body: Consumer<OSMScreenProvider>(builder: (context, provider, _) {
            if (provider.dataPengantaran.isEmpty) {
              return AlertDialog(
                title: const Text('Pengantaran Selesai'),
                content: const SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text('Anda telah menyelesaikan pengantaran.'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      provider.cancelDelivery();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScreenRoute(user: widget.user),
                        ),
                      );
                    },
                  ),
                ],
              );
            } else {
              return provider.isloading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Tunggu Sebentar..."),
                          SizedBox(
                            width: 200,
                            child: LinearProgressIndicator(),
                          )
                        ],
                      ),
                    )
                  : _buildMapWidget(context, provider);
            }
          }),
        ),
      ),
    );
  }

  Widget _buildMapWidget(BuildContext context, OSMScreenProvider provider) {
    final mycolor = CustomStyle();
    return Stack(
      children: [
        FlutterMap(
          mapController: provider.mapController,
          options: MapOptions(
            initialCenter: provider.titikAwal,
            initialZoom: 18,
            interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag),
            onPositionChanged: provider.handlePositionChange,
          ),
          children: [
            openStreetMapTileLayer,
            if (provider.jalurRute != null || provider.titikTujuan.length == 1)
              PolylineLayer(
                polylines: [provider.jalurRute!],
              ),
            MarkerLayer(
              markers: [
                ...provider.titikTujuan
                    .sublist(1)
                    .map(
                      (latLng) => Marker(
                        width: 60,
                        height: 60,
                        point: latLng,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 50,
                        ),
                      ),
                    )
                    .toList(),
                Marker(
                  width: 40,
                  height: 40,
                  point: provider.titikAwal,
                  child: Image.asset('assets/images/logo-icon.png'),
                ),
              ],
            ),
          ],
        ),
        Positioned(
          bottom: 50,
          left: 60,
          right: 60,
          child: CustomElevatedButton1(
            onPressed: () => _bottomSheetMap(context),
            text: "Status Pengiriman",
            textStyle: TextStyle(
              color: mycolor.color2,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _bottomSheetMap(BuildContext context) {
    final mycolor = CustomStyle();
    showModalBottomSheet(
      scrollControlDisabledMaxHeightRatio: 9.0,
      showDragHandle: true,
      backgroundColor: mycolor.color1,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        Map<String, dynamic> userData = widget.user as Map<String, dynamic>;
        return SizedBox(
          width: double.infinity,
          height: 650,
          child: StatusScreen(
            user: userData,
          ),
        );
      },
    );
  }
}

TileLayer get openStreetMapTileLayer => TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
    );
