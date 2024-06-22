import 'package:aplikurir/api/api_service.dart';
import 'package:aplikurir/component/custom_color.dart';
import 'package:aplikurir/providers/provider.dart';
import 'package:aplikurir/screen/detail.dart';
import 'package:aplikurir/screen/maps.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BerandaScreen extends StatefulWidget {
  final dynamic user;
  const BerandaScreen({super.key, this.user});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  late Future<List<dynamic>> dataList;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool canPop = true;

  String? storedEmail;
  String? storedPassword;
  @override
  void initState() {
    super.initState();
    storedEmail = widget.user['email'];
    storedPassword = widget.user['password'];
    final userId = widget.user['kurir_id'];
    dataList = ApiService().fetchDataPengantaran(userId);
  }

  @override
  Widget build(BuildContext context) {
    final mycolor = CustomStyle();
    return PopScope(
      canPop: canPop,
      onPopInvoked: (bool value) {
        setState(() {
          canPop = !value;
        });

        if (canPop) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Click once more to go back"),
              duration: Duration(milliseconds: 1500),
            ),
          );
        }
      },
      child: ChangeNotifierProvider(
        create: (context) =>
            OSMScreenProvider(_scaffoldKey, context, widget.user['kurir_id']),
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 100,
            shadowColor: mycolor.color3,
            elevation: 3,
            backgroundColor: mycolor.color1,
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: Size.zero,
              child: Text(
                "Beranda",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: mycolor.color2,
                ),
              ),
            ),
            excludeHeaderSemantics: false,
          ),
          body: Consumer<OSMScreenProvider>(
            builder: (context, provider, _) {
              return FutureBuilder<List<dynamic>>(
                future: dataList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Text('Tunggu Sebentar ...'),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Admin ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child:
                            Text('Tidak Ada Paket Yang Dikirimkan Hari Ini!'));
                  } else {
                    List<dynamic> dataList = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.all(15),
                          child: Text(
                            "Daftar Alamat Pengantaran",
                            style: TextStyle(
                              color: mycolor.color1,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            itemCount: dataList.length,
                            itemBuilder: (BuildContext context, int index) {
                              final data = dataList[index];
                              return ListTile(
                                title: Container(
                                  color: mycolor.color2,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 10,
                                              bottom: 5,
                                              left: 10,
                                            ),
                                            child: Text(
                                              data['nomor_resi'].toString(),
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 10,
                                              left: 10,
                                            ),
                                            child: Row(
                                              children: [
                                                const Text(
                                                  'Pengirim : ',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  data['Nama_Pengirim']
                                                      .toString(),
                                                  style: const TextStyle(
                                                      fontSize: 15),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.only(
                                              bottom: 10,
                                              left: 10,
                                            ),
                                            child: Text(
                                              ' | Penerima : ',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            data['Nama_Penerima'].toString(),
                                            style:
                                                const TextStyle(fontSize: 15),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                pageBuilder: (context,
                                                        animation,
                                                        secondaryAnimation) =>
                                                    DetailScreen(data: data),
                                                transitionsBuilder: (context,
                                                    animation,
                                                    secondaryAnimation,
                                                    child) {
                                                  const begin =
                                                      Offset(1.0, 0.0);
                                                  const end = Offset.zero;
                                                  const curve =
                                                      Curves.easeInOut;

                                                  var tween = Tween(
                                                          begin: begin,
                                                          end: end)
                                                      .chain(CurveTween(
                                                          curve: curve));

                                                  return SlideTransition(
                                                    position:
                                                        animation.drive(tween),
                                                    child: child,
                                                  );
                                                },
                                              ));
                                        },
                                        icon: const Icon(
                                          Icons.list_alt,
                                          size: 25,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: 60,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          child: FilledButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStatePropertyAll(mycolor.color1),
                                  shape: WidgetStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  shadowColor: const WidgetStatePropertyAll(
                                      Colors.black),
                                  elevation: const WidgetStatePropertyAll(5)),
                              onPressed: () {
                                provider.startDelivery();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MapScreen(user: widget.user),
                                  ),
                                );
                              },
                              child: Text(
                                "Mulai Pengantaran",
                                style: TextStyle(
                                  color: mycolor.color2,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                        )
                      ],
                    );
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
