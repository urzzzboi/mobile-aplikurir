import 'package:aplikurir/api/api_service.dart';
import 'package:aplikurir/component/custom_color.dart';
import 'package:aplikurir/providers/provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RiwayatScreen extends StatefulWidget {
  final dynamic user;
  const RiwayatScreen({super.key, this.user});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  late Future<List<dynamic>> dataList = Future.value([]);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool canPop = true;
  bool pesanTitle = true;
  bool selectFilter = false;
  String? storedEmail;
  String? storedPassword;
  DateTime _selectedDate = DateTime.now();
  List<dynamic> _originalDataList = [];

  String formatTanggalWaktu(String tanggal, String waktu) {
    String dateTimeString = "$tanggal $waktu";
    DateTime dateTime = DateTime.parse(dateTimeString);

    String formattedDate = DateFormat('dd MMMM yyyy', 'id').format(dateTime);
    String formattedTime = DateFormat('HH:mm').format(dateTime);

    return "$formattedTime - $formattedDate";
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id', null).then((_) {
      setState(() {
        storedEmail = widget.user['email'];
        storedPassword = widget.user['password'];
      });
    });
    final userId = widget.user['id_kurir'];
    dataList = ApiService().fetchDataRiwayat(userId);
    dataList.then((dataList) {
      dataList.sort((a, b) {
        final tanggalPengirimanA = a['tanggal_pengiriman'];
        final tanggalPengirimanB = b['tanggal_pengiriman'];
        return DateTime.parse(tanggalPengirimanA)
            .compareTo(DateTime.parse(tanggalPengirimanB));
      });
    });
  }

  void _filterListByDate() {
    dataList.then((dataList) {
      _originalDataList = dataList;
      dataList = dataList.where((element) {
        final tanggalPengiriman = element['tanggal_pengiriman'];
        final dateFormat = DateFormat('yyyy-MM-dd');
        final tanggalPengirimanDate = dateFormat.parse(tanggalPengiriman);
        return tanggalPengirimanDate.day == _selectedDate.day &&
            tanggalPengirimanDate.month == _selectedDate.month &&
            tanggalPengirimanDate.year == _selectedDate.year;
      }).toList();
      selectFilter = true;
      if (dataList.isEmpty) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                insetPadding: const EdgeInsets.all(5),
                content: Text(
                    'Tidak ada pengiriman paket pada tanggal ${DateFormat('dd MMMM yyyy', 'id').format(_selectedDate)}'),
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ]);
          },
        );
      } else {
        setState(() {
          this.dataList = Future.value(dataList);
        });
      }
    });
  }

  void _cancelFilter() {
    setState(() {
      selectFilter = false;
      dataList = Future.value(_originalDataList);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mycolor = CustomStyle();
    return ChangeNotifierProvider(
      create: (context) =>
          OSMScreenProvider(_scaffoldKey, context, widget.user['id_kurir']),
      child: Scaffold(
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
              "Riwayat",
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: mycolor.color2),
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
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('Riwayat Pengiriman Kosong!'));
                } else {
                  List<dynamic> dataList = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                FilledButton(
                                  style: selectFilter
                                      ? ButtonStyle(
                                          backgroundColor:
                                              WidgetStatePropertyAll(
                                                  mycolor.color1))
                                      : ButtonStyle(
                                          side: WidgetStatePropertyAll(
                                              BorderSide(
                                                  width: 2,
                                                  color: mycolor.color1)),
                                          backgroundColor:
                                              const WidgetStatePropertyAll(
                                                  Colors.transparent)),
                                  onPressed: () async {
                                    final DateTime? pickedDate =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: _selectedDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2030),
                                    );
                                    if (pickedDate != null) {
                                      setState(() {
                                        _selectedDate = pickedDate;
                                      });
                                      _filterListByDate();
                                    }
                                  },
                                  child: Text(
                                    'Filter Tanggal',
                                    style: TextStyle(
                                        color: selectFilter
                                            ? mycolor.color2
                                            : mycolor.color1,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ),
                                selectFilter
                                    ? IconButton(
                                        onPressed: _cancelFilter,
                                        icon: const Icon(Icons.cancel_outlined),
                                        color: mycolor.color4,
                                      )
                                    : const Center(),
                              ],
                            ),
                            Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: selectFilter
                                  ? Divider()
                                  : Text(
                                      "Pengiriman paket hari ini",
                                      style: TextStyle(
                                          color: mycolor.color1,
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ],
                        ),
                      ),
                      selectFilter
                          ? Expanded(
                              child: ListView.builder(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  itemCount: dataList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final data = dataList[index];
                                    String tanggalPengiriman =
                                        data['tanggal_pengiriman'].toString();
                                    String waktuPengiriman =
                                        data['waktu_pengiriman'].toString();
                                    String tanggalPengirimanFormat =
                                        formatTanggalWaktu(
                                            tanggalPengiriman, waktuPengiriman);
                                    Color statusColor;
                                    if (data['status_pengiriman'] == 'Gagal') {
                                      statusColor = mycolor.color4;
                                    } else if (data['status_pengiriman'] ==
                                        'Selesai') {
                                      statusColor = mycolor.color1;
                                    } else {
                                      statusColor = mycolor.color3;
                                    }
                                    return Container(
                                      margin: const EdgeInsets.only(
                                          bottom: 10, left: 10, right: 10),
                                      decoration: BoxDecoration(
                                          color: mycolor.color2,
                                          border: Border.all(
                                              width: 2, color: mycolor.color2),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: ListTile(
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Alamat: ',
                                              textAlign: TextAlign.justify,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              data['Alamat_Tujuan'],
                                              textAlign: TextAlign.justify,
                                            ),
                                          ],
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(tanggalPengirimanFormat,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: mycolor.color1,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Divider(
                                              color: mycolor.color1,
                                            ),
                                            Row(
                                              children: [
                                                const Text(
                                                  'Status Pengiriman: ',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                                  decoration: BoxDecoration(
                                                      color: statusColor,
                                                      border: Border.all(
                                                          width: 1,
                                                          color:
                                                              mycolor.color2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Text(
                                                    '${data['status_pengiriman'].toString().toUpperCase()}',
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            )
                          : Expanded(
                              child: ListView.builder(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  itemCount: dataList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final data = dataList[index];
                                    String tanggalPengiriman =
                                        data['tanggal_pengiriman'].toString();
                                    String waktuPengiriman =
                                        data['waktu_pengiriman'].toString();
                                    String tanggalPengirimanFormat =
                                        formatTanggalWaktu(
                                            tanggalPengiriman, waktuPengiriman);
                                    Color statusColor;
                                    if (data['status_pengiriman'] == 'Gagal') {
                                      statusColor = mycolor.color4;
                                    } else if (data['status_pengiriman'] ==
                                        'Selesai') {
                                      statusColor = mycolor.color1;
                                    } else {
                                      statusColor = mycolor.color3;
                                    }
                                    return Container(
                                      margin: const EdgeInsets.only(
                                          bottom: 10, left: 10, right: 10),
                                      decoration: BoxDecoration(
                                          color: mycolor.color2,
                                          border: Border.all(
                                              width: 2, color: mycolor.color2),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: ListTile(
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Alamat: ',
                                              textAlign: TextAlign.justify,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              data['Alamat_Tujuan'],
                                              textAlign: TextAlign.justify,
                                            ),
                                          ],
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(tanggalPengirimanFormat,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: mycolor.color1,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Divider(
                                              color: mycolor.color1,
                                            ),
                                            Row(
                                              children: [
                                                const Text(
                                                  'Status Pengiriman: ',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                                  decoration: BoxDecoration(
                                                      color: statusColor,
                                                      border: Border.all(
                                                          width: 1,
                                                          color:
                                                              mycolor.color2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Text(
                                                    '${data['status_pengiriman'].toString().toUpperCase()}',
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            )
                    ],
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
