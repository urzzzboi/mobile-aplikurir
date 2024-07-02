import 'package:aplikurir/component/custom_color.dart';
import 'package:aplikurir/providers/provider.dart';
import 'package:aplikurir/screen/login.dart';
import 'package:aplikurir/screen/maps.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StatusScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const StatusScreen({super.key, required this.user});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  late String storedEmail;
  late String storedPassword;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _waktu = '';
  String _tanggal = '';

  @override
  void initState() {
    super.initState();
    storedEmail = widget.user['email'];
    storedPassword = widget.user['password'];
  }

  void _addTime() {
    setState(() {
      DateTime now = DateTime.now();
      _waktu = DateFormat('HH:mm:ss').format(now);
      _tanggal = DateFormat('yyyy-MM-dd').format(now);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          OSMScreenProvider(_scaffoldKey, context, widget.user['id_kurir']),
      child: Scaffold(
        key: _scaffoldKey,
        body: Consumer<OSMScreenProvider>(
          builder: (context, provider, _) {
            final mycolor = CustomStyle();
            return ListView(children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                      'Pilih Status Pengiriman',
                      style: TextStyle(
                        color: mycolor.color1,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
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
                            onPressed: () {
                              _addTime();
                              provider.updateStatus('Gagal', _waktu, _tanggal,
                                  provider.titikTujuan, context);
                              Navigator.pushReplacement<void, void>(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) => MapScreen(
                                    user: widget.user,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              "Gagal",
                              style: TextStyle(
                                color: mycolor.color2,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                        ElevatedButton(
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
                            onPressed: () {
                              _addTime();
                              provider.updateStatus(
                                'Selesai',
                                _waktu,
                                _tanggal,
                                provider.titikTujuan,
                                context,
                              );
                              Navigator.pushReplacement<void, void>(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) => MapScreen(
                                    user: widget.user,
                                  ),
                                ),
                              );
                            },
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
                    const Divider(),
                    Text(
                      'Pengantaran Sekarang',
                      style: TextStyle(
                          color: mycolor.color1,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(2),
                          child: Icon(
                            Icons.album_rounded,
                            color: mycolor.color5,
                            size: 25,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Lokasi Awal',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              provider.isloading1
                                  ? const Text('Sedang mencari lokasi...')
                                  : Text(
                                      provider.prediksiAlamat,
                                      style: const TextStyle(fontSize: 18),
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
                        Padding(
                          padding: const EdgeInsets.all(2),
                          child: Icon(
                            Icons.location_on_rounded,
                            color: mycolor.color4,
                            size: 25,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Lokasi Selanjutnya',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ...provider.titikTujuan.map((latLng) {
                                print('LatLng: $latLng');
                                var data = provider.dataPengantaran.firstWhere(
                                  (item) {
                                    bool match = item['latitude'] ==
                                            latLng.latitude &&
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
                                          Text('${data['Alamat_Tujuan']}',
                                              style: const TextStyle(
                                                fontSize: 18,
                                              )),
                                          Text('${data['Deskripsi']}',
                                              style: const TextStyle(
                                                fontSize: 18,
                                              )),
                                          const Divider(),
                                          Text('Penerima : ',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: mycolor.color1)),
                                          Text(
                                            '${data['Nama_Penerima']}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                          Text('No. HP     : ',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: mycolor.color1)),
                                          Text(
                                            '${data['No_HP_Penerima']}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          )
                                        ],
                                      )
                                    : const SizedBox();
                              }).toList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(2),
                          child: Icon(
                            Icons.map,
                            color: mycolor.color1,
                            size: 25,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          provider.isloading1
                              ? 'Jarak Tempuh'
                              : 'Jarak ${provider.totalJarak.toStringAsFixed(1)} km',
                          style: TextStyle(
                            color: mycolor.color1,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(2),
                          child: Icon(
                            Icons.watch_later_outlined,
                            color: mycolor.color1,
                            size: 25,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          provider.isloading1
                              ? 'Waktu Tempuh'
                              : 'Waktu ${provider.waktuTempuh} menit',
                          style: TextStyle(
                            color: mycolor.color1,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    if (provider.listTitikTujuan2.isNotEmpty)
                      Text(
                        'Pengantaran Selanjutnya',
                        style: TextStyle(
                            color: mycolor.color1,
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ),
                    if (provider.listTitikTujuan2.isNotEmpty)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 5,
                          ),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...provider.listTitikTujuan2.map((latLng) {
                                print('LatLng: $latLng');
                                var data = provider.dataPengantaran.firstWhere(
                                  (item) {
                                    bool match = item['latitude'] ==
                                            latLng.latitude &&
                                        item['longitude'] == latLng.longitude;
                                    print(
                                        'Checking: ${item['latitude']}, ${item['longitude']} with $latLng => Match: $match');
                                    return match;
                                  },
                                  orElse: () => null,
                                );

                                return data != null
                                    ? Column(
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(2),
                                                child: Icon(
                                                  Icons.location_on_rounded,
                                                  color: mycolor.color4,
                                                  size: 25,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Expanded(
                                                  child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Rencana Lokasi Pengiriman',
                                                    style: TextStyle(
                                                      fontSize: 25,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                      '${data['Alamat_Tujuan'] ?? '-'}',
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                      )),
                                                ],
                                              )),
                                            ],
                                          ),
                                        ],
                                      )
                                    : const SizedBox();
                              }).toList(),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: Icon(
                                      Icons.map,
                                      color: mycolor.color1,
                                      size: 25,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    provider.isloading1
                                        ? 'Jarak Tempuh'
                                        : 'Jarak ${provider.totalJarak2.toStringAsFixed(1)} km',
                                    style: TextStyle(
                                      color: mycolor.color1,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: Icon(
                                      Icons.watch_later_outlined,
                                      color: mycolor.color1,
                                      size: 25,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    provider.isloading1
                                        ? 'Waktu Tempuh'
                                        : 'Waktu ${provider.waktuTempuh2} menit',
                                    style: TextStyle(
                                      color: mycolor.color1,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                            ],
                          )),
                        ],
                      ),
                    if (provider.listTitikTujuan3.isNotEmpty)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 5,
                          ),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...provider.listTitikTujuan3.map((latLng) {
                                print('LatLng: $latLng');
                                var data = provider.dataPengantaran.firstWhere(
                                  (item) {
                                    bool match = item['latitude'] ==
                                            latLng.latitude &&
                                        item['longitude'] == latLng.longitude;
                                    print(
                                        'Checking: ${item['latitude']}, ${item['longitude']} with $latLng => Match: $match');
                                    return match;
                                  },
                                  orElse: () => null,
                                );

                                return data != null
                                    ? Column(
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(2),
                                                child: Icon(
                                                  Icons.location_on_rounded,
                                                  color: mycolor.color4,
                                                  size: 25,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Expanded(
                                                  child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Rencana Lokasi Pengiriman',
                                                    style: TextStyle(
                                                      fontSize: 25,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                      '${data['Alamat_Tujuan'] ?? '-'}',
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                      )),
                                                ],
                                              )),
                                            ],
                                          ),
                                        ],
                                      )
                                    : const SizedBox();
                              }).toList(),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: Icon(
                                      Icons.map,
                                      color: mycolor.color1,
                                      size: 25,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    provider.isloading1
                                        ? 'Jarak Tempuh'
                                        : 'Jarak ${provider.totalJarak3.toStringAsFixed(1)} km',
                                    style: TextStyle(
                                      color: mycolor.color1,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: Icon(
                                      Icons.watch_later_outlined,
                                      color: mycolor.color1,
                                      size: 25,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    provider.isloading1
                                        ? 'Waktu Tempuh'
                                        : 'Waktu ${provider.waktuTempuh3} menit',
                                    style: TextStyle(
                                      color: mycolor.color1,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                            ],
                          )),
                        ],
                      ),
                    if (provider.listTitikTujuan4.isNotEmpty)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 5,
                          ),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...provider.listTitikTujuan4.map((latLng) {
                                print('LatLng: $latLng');
                                var data = provider.dataPengantaran.firstWhere(
                                  (item) {
                                    bool match = item['latitude'] ==
                                            latLng.latitude &&
                                        item['longitude'] == latLng.longitude;
                                    print(
                                        'Checking: ${item['latitude']}, ${item['longitude']} with $latLng => Match: $match');
                                    return match;
                                  },
                                  orElse: () => null,
                                );

                                return data != null
                                    ? Column(
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(2),
                                                child: Icon(
                                                  Icons.location_on_rounded,
                                                  color: mycolor.color4,
                                                  size: 25,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Expanded(
                                                  child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Rencana Lokasi Pengiriman',
                                                    style: TextStyle(
                                                      fontSize: 25,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                      '${data['Alamat_Tujuan'] ?? '-'}',
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                      )),
                                                ],
                                              )),
                                            ],
                                          ),
                                        ],
                                      )
                                    : const SizedBox();
                              }).toList(),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: Icon(
                                      Icons.map,
                                      color: mycolor.color1,
                                      size: 25,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    provider.isloading1
                                        ? 'Jarak Tempuh'
                                        : 'Jarak ${provider.totalJarak4.toStringAsFixed(1)} km',
                                    style: TextStyle(
                                      color: mycolor.color1,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: Icon(
                                      Icons.watch_later_outlined,
                                      color: mycolor.color1,
                                      size: 25,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    provider.isloading1
                                        ? 'Waktu Tempuh'
                                        : 'Waktu ${provider.waktuTempuh4} menit',
                                    style: TextStyle(
                                      color: mycolor.color1,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                            ],
                          )),
                        ],
                      ),
                    if (provider.listTitikTujuan5.isNotEmpty)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 5,
                          ),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...provider.listTitikTujuan5.map((latLng) {
                                print('LatLng: $latLng');
                                var data = provider.dataPengantaran.firstWhere(
                                  (item) {
                                    bool match = item['latitude'] ==
                                            latLng.latitude &&
                                        item['longitude'] == latLng.longitude;
                                    print(
                                        'Checking: ${item['latitude']}, ${item['longitude']} with $latLng => Match: $match');
                                    return match;
                                  },
                                  orElse: () => null,
                                );

                                return data != null
                                    ? Column(
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(2),
                                                child: Icon(
                                                  Icons.location_on_rounded,
                                                  color: mycolor.color5,
                                                  size: 25,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Expanded(
                                                  child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Rencana Lokasi Pengiriman',
                                                    style: TextStyle(
                                                      fontSize: 25,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                      '${data['Alamat_Tujuan'] ?? '-'}',
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                      )),
                                                ],
                                              )),
                                            ],
                                          ),
                                        ],
                                      )
                                    : const SizedBox();
                              }).toList(),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: Icon(
                                      Icons.map,
                                      color: mycolor.color1,
                                      size: 25,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    provider.isloading1
                                        ? 'Jarak Tempuh'
                                        : 'Jarak ${provider.totalJarak5.toStringAsFixed(1)} km',
                                    style: TextStyle(
                                      color: mycolor.color1,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: Icon(
                                      Icons.watch_later_outlined,
                                      color: mycolor.color1,
                                      size: 25,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    provider.isloading1
                                        ? 'Waktu Tempuh'
                                        : 'Waktu ${provider.waktuTempuh5} menit',
                                    style: TextStyle(
                                      color: mycolor.color1,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                            ],
                          )),
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
                    ),
                  ],
                ),
              ),
            ]);
          },
        ),
      ),
    );
  }
}
