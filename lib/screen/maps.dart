import 'package:aplikurir/component/custom_button.dart';
import 'package:aplikurir/screen/login.dart';
import 'package:aplikurir/screen/status.dart';
import 'package:aplikurir/screen/test.dart';
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
    final mycolor = CustomStyle();
    return PopScope(
      canPop: false,
      child: ChangeNotifierProvider(
        create: (context) =>
            OSMScreenProvider(_scaffoldKey, context, widget.user['id_kurir']),
        child: Scaffold(
          key: _scaffoldKey,
          body: Consumer<OSMScreenProvider>(
            builder: (context, provider, _) {
              if (provider.titikTujuan.isNotEmpty) {
                return _buildMapWidget(context, provider);
              } else if (provider.dataPengantaran.isEmpty) {
                return _buildCompletionDialog(context, mycolor, provider);
              } else {
                return Text("Tak Muncul PETA");
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen(CustomStyle mycolor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Tunggu Sebentar",
            style: TextStyle(color: mycolor.color1),
          ),
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              color: mycolor.color1,
              minHeight: 5,
              borderRadius: BorderRadius.circular(5),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCompletionDialog(
      BuildContext context, CustomStyle mycolor, OSMScreenProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo-icon.png',
            width: 100,
          ),
          Text(
            'Pengantaran Selesai!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              color: mycolor.color1,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Anda telah menyelesaikan pengantaran paket di hari ini.',
            textAlign: TextAlign.center,
          ),
          Text(
            'Well Done!!!',
            textAlign: TextAlign.center,
          ),
          TextButton(
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
            style: ButtonStyle(
              padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 5)),
              backgroundColor: WidgetStateProperty.all(mycolor.color1),
            ),
            child: Text(
              'Selesai',
              style: TextStyle(
                color: mycolor.color2,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapWidget(BuildContext context, OSMScreenProvider provider) {
    final mycolor = CustomStyle();
    return provider.isloading
        ? _buildLoadingScreen(mycolor)
        : Stack(
            children: [
              FlutterMap(
                mapController: provider.mapController,
                options: MapOptions(
                  initialCenter: provider.titikAwal,
                  initialZoom: 17,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                  ),
                  onPositionChanged: (position, hasGesture) {
                    if (provider.lokasiAwal != position.center) {
                      provider.handlePositionChange(position, hasGesture);
                    }
                  },
                ),
                children: [
                  openStreetMapTileLayer,
                  if (provider.jalurRute != null ||
                      provider.titikTujuan.length == 1)
                    PolylineLayer(
                      polylines: [provider.jalurRute!],
                    ),
                  MarkerLayer(
                    markers: [
                      if (provider.titikTujuan1.length > 1)
                        ...provider.titikTujuan1
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
                      // if (provider.titikTujuan.length > 1)
                      //   ...List.generate(provider.titikTujuan.length - 1, (index) {
                      //     LatLng latLng = provider.titikTujuan[index + 1];
                      //     return Marker(
                      //       width: 60,
                      //       height: 60,
                      //       point: latLng,
                      //       child: Stack(
                      //         children: [
                      //           Icon(
                      //             Icons.location_pin,
                      //             color: mycolor.color4,
                      //             size: 40,
                      //           ),
                      //           Positioned(
                      //             top: 4,
                      //             left: 13,
                      //             child: Container(
                      //               padding: const EdgeInsets.all(3),
                      //               decoration: BoxDecoration(
                      //                 color: mycolor.color4,
                      //                 borderRadius: BorderRadius.circular(20),
                      //               ),
                      //               child: Text(
                      //                 '${index + 2}',
                      //                 textAlign: TextAlign.center,
                      //                 style: const TextStyle(
                      //                   color: Colors.white,
                      //                   fontWeight: FontWeight.bold,
                      //                   fontSize: 14,
                      //                 ),
                      //               ),
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     );
                      //   }).toList(),
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
              // Positioned(
              //   bottom: 50,
              //   right: 10,
              //   child: IconButton(
              //     onPressed: () {
              //       provider.cancelDelivery();
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (context) => MapScreen(user: widget.user),
              //         ),
              //       );
              //     },
              //     style: ButtonStyle(
              //       backgroundColor: WidgetStatePropertyAll(mycolor.color2),
              //       side: WidgetStatePropertyAll(
              //           BorderSide(color: mycolor.color1, width: 2)),
              //     ),
              //     icon: Icon(Icons.refresh),
              //   ),
              // ),
              // Positioned(
              //   bottom: 100,
              //   left: 60,
              //   right: 60,
              //   child: ElevatedButton(
              //     onPressed: () => _testAlgoritmaAstar(context),
              //     style: ButtonStyle(
              //       backgroundColor: WidgetStatePropertyAll(mycolor.color2),
              //       side: WidgetStatePropertyAll(
              //           BorderSide(color: mycolor.color1, width: 2)),
              //     ),
              //     child: Text(
              //       'Test Algoritma A-Star',
              //       style: TextStyle(
              //         color: mycolor.color1,
              //         fontSize: 16,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //   ),
              // ),
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

  void _testAlgoritmaAstar(BuildContext context) {
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
          child: TestAlgoAstar(
            user: userData,
          ),
        );
      },
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
