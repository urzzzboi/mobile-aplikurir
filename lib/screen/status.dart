import 'package:aplikurir/component/custom_color.dart';
import 'package:aplikurir/providers/provider.dart';
import 'package:aplikurir/screen/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const StatusScreen({super.key, required this.user});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          OSMScreenProvider(_scaffoldKey, context, widget.user['kurir_id']),
      child: Scaffold(
        key: _scaffoldKey,
        body: Consumer<OSMScreenProvider>(
          builder: (context, provider, _) {
            final mycolor = CustomStyle();
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail Pengantaran',
                    style: TextStyle(
                      color: mycolor.color1,
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Pengantaran Paket Sekarang',
                    style: TextStyle(
                      color: mycolor.color1,
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FilledButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(mycolor.color4),
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              shadowColor:
                                  const WidgetStatePropertyAll(Colors.black),
                              elevation: const WidgetStatePropertyAll(5)),
                          onPressed: () {},
                          child: Text(
                            "Gagal",
                            style: TextStyle(
                              color: mycolor.color2,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                      FilledButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(mycolor.color1),
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              shadowColor:
                                  const WidgetStatePropertyAll(Colors.black),
                              elevation: const WidgetStatePropertyAll(5)),
                          onPressed: () {},
                          child: Text(
                            "Selesai",
                            style: TextStyle(
                              color: mycolor.color2,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.album_rounded,
                        color: mycolor.color5,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Lokasi Awal',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              provider.prediksiAlamat,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: mycolor.color1,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Lokasi Selanjutnya',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ...provider.titikTujuan.map((latLng) {
                              print('LatLng: $latLng');
                              var data = provider.dataPengantaran.firstWhere(
                                (item) {
                                  bool match =
                                      item['latitude'] == latLng.latitude &&
                                          item['longitude'] == latLng.longitude;
                                  print(
                                      'Checking: ${item['latitude']}, ${item['longitude']} with $latLng => Match: $match');
                                  return match;
                                },
                                orElse: () => null,
                              );

                              return data != null
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('${data['Alamat_Tujuan']}'),
                                        Row(
                                          children: [
                                            Text('Penerima: ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: mycolor.color1)),
                                            Text('${data['Nama_Penerima']}'),
                                            Text(' | No. HP: ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: mycolor.color1)),
                                            Text('${data['No_HP_Penerima']}'),
                                          ],
                                        ),
                                      ],
                                    )
                                  : const SizedBox();
                            }).toList(),
                            Text(
                              'Jarak: ${provider.totalJarak1.toStringAsFixed(1)} km',
                              style: TextStyle(
                                color: mycolor.color1,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Text(
                    'Pengantaran Paket Selanjutnya',
                    style: TextStyle(
                      color: mycolor.color1,
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.album_rounded,
                        color: mycolor.color5,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Lokasi Awal',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ...provider.titikTujuan.map((latLng) {
                              print('LatLng: $latLng');
                              var data = provider.dataPengantaran.firstWhere(
                                (item) {
                                  bool match =
                                      item['latitude'] == latLng.latitude &&
                                          item['longitude'] == latLng.longitude;
                                  print(
                                      'Checking: ${item['latitude']}, ${item['longitude']} with $latLng => Match: $match');
                                  return match;
                                },
                                orElse: () => null,
                              );

                              return data != null
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('${data['Alamat_Tujuan']}'),
                                      ],
                                    )
                                  : const SizedBox();
                            }).toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: mycolor.color1,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Lokasi Selanjutnya',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ...provider.titikTujuan2.map((latLng) {
                              print('LatLng: $latLng');
                              var data = provider.dataPengantaran.firstWhere(
                                (item) {
                                  bool match =
                                      item['latitude'] == latLng.latitude &&
                                          item['longitude'] == latLng.longitude;
                                  print(
                                      'Checking: ${item['latitude']}, ${item['longitude']} with $latLng => Match: $match');
                                  return match;
                                },
                                orElse: () => null,
                              );

                              return data != null
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('${data['Alamat_Tujuan']}'),
                                        Row(
                                          children: [
                                            Text('Penerima: ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: mycolor.color1)),
                                            Text('${data['Nama_Penerima']}'),
                                            Text(' | No. HP: ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: mycolor.color1)),
                                            Text('${data['No_HP_Penerima']}'),
                                          ],
                                        ),
                                      ],
                                    )
                                  : const SizedBox();
                            }).toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              const WidgetStatePropertyAll(Colors.white),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              side: BorderSide(
                                color: mycolor.color4,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        onPressed: () {
                          provider.cancelDelivery();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ScreenRoute(user: widget.user),
                            ),
                          );
                        },
                        child: Text(
                          "Pembatalan Pengiriman",
                          style: TextStyle(
                            color: mycolor.color4,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
