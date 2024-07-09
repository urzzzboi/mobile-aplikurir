import 'package:aplikurir/component/custom_color.dart';
import 'package:aplikurir/providers/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TestAlgoAstar extends StatefulWidget {
  final Map<String, dynamic> user;
  const TestAlgoAstar({super.key, required this.user});

  @override
  State<TestAlgoAstar> createState() => _TestAlgoAstarState();
}

class _TestAlgoAstarState extends State<TestAlgoAstar> {
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
    return Provider(
      create: (_) =>
          OSMScreenProvider(_scaffoldKey, context, widget.user['id_kurir']),
      child: Scaffold(
        key: _scaffoldKey,
        body: Consumer<OSMScreenProvider>(builder: (context, provider, child) {
          final mycolor = CustomStyle();

          return provider.loadPerhitungan
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RefreshProgressIndicator(
                        strokeWidth: 3,
                        color: mycolor.color1,
                      ),
                      const Text('Menghitung Algoritma A-Star'),
                    ],
                  ),
                )
              : ListView(
                  children: [
                    Column(
                      children: [
                        const SizedBox(
                          height: 40,
                        ),
                        Text(
                          'Perhitungan Algoritma A-Star',
                          style: TextStyle(
                              color: mycolor.color1,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 300, child: Divider()),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'Alamat',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    // if (provider.prediksiAlamat.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            color: mycolor.color1,
                            child: Text('1',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: mycolor.color2,
                                )),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: mycolor.color1, width: 3)),
                              child: Text(provider.prediksiAlamat,
                                  style: const TextStyle(
                                    fontSize: 18,
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...List.generate(provider.titikTujuan.length,
                              (index) {
                            var latLng = provider.titikTujuan[index];
                            print('ambil text: ${provider.textPerhitungan}');
                            var data = provider.dataPengantaran.firstWhere(
                              (item) {
                                bool match =
                                    item['latitude'] == latLng.latitude &&
                                        item['longitude'] == latLng.longitude;
                                return match;
                              },
                              orElse: () => null,
                            );
                            // print(index);

                            return data != null
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        color: mycolor.color1,
                                        child: Text('${index + 1}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: mycolor.color2,
                                            )),
                                      ),
                                      Expanded(
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 10),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: mycolor.color1,
                                                  width: 3)),
                                          child:
                                              Text('${data['Alamat_Tujuan']}',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                  )),
                                        ),
                                      ),
                                    ],
                                  )
                                : const SizedBox();
                          }),
                        ],
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Proses Perhitungan Algoritma A-Star',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.all(10),
                            color: mycolor.color1,
                            child: Text(
                              provider.textPerhitungan,
                              style: TextStyle(
                                  color: mycolor.color2,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mengambil Jarak yang Terdekat',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.all(10),
                            color: mycolor.color2,
                            child: Text(
                              provider.textPerhitungan2,
                              style: TextStyle(
                                  color: mycolor.color1,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
        }),
      ),
    );
  }
}
