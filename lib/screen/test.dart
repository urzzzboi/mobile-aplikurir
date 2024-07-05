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

          return ListView(
            children: [
              Column(
                children: [
                  Text(
                    'Perhitungan Algoritma A-Star',
                    style: TextStyle(
                        color: mycolor.color1,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 300, child: const Divider()),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alamat',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    ...List.generate(provider.titikTujuan.length, (index) {
                      var latLng = provider.titikTujuan[index];
                      var data = provider.dataPengantaran.firstWhere(
                        (item) {
                          bool match = item['latitude'] == latLng.latitude &&
                              item['longitude'] == latLng.longitude;
                          return match;
                        },
                        orElse: () => null,
                      );
                      // print(index);

                      return data != null
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  color: mycolor.color1,
                                  child: Text('$index',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: mycolor.color2,
                                      )),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: mycolor.color1, width: 3)),
                                    child: Text('${data['Alamat_Tujuan']}',
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Proses Perhitungan Algoritma A-Star',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      provider.textPerhitungan,
                      style: TextStyle(
                          color: mycolor.color1,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
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
