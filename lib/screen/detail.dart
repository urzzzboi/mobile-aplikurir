import 'package:aplikurir/component/custom_color.dart';
import 'package:aplikurir/component/custom_detail.dart';
import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const DetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final mycolor = CustomStyle();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Paket'),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 32,
          color: mycolor.color1,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          style: const ButtonStyle(
            iconSize: WidgetStatePropertyAll(32),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        toolbarHeight: 100,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomContainer(children: [
                  const CustomText1(text: 'No. Resi'),
                  CustomText2(text: '${data['nomor_resi']}'),
                ]),
                CustomContainer(children: [
                  const CustomText1(text: 'Nama Pengirim'),
                  CustomText2(text: '${data['Nama_Pengirim']}'),
                ]),
                CustomContainer(children: [
                  const CustomText1(text: 'No. HP'),
                  CustomText2(text: '${data['No_HP_Penerima']}'),
                ]),
                CustomContainer(children: [
                  const CustomText1(text: 'Deskripsi'),
                  CustomText2(text: '${data['Deskripsi']}'),
                ]),
                CustomContainer(children: [
                  const CustomText1(text: 'Berat'),
                  CustomText2(text: '${data['Berat']} kg'),
                ]),
                CustomContainer(children: [
                  const CustomText1(text: 'Dimensi'),
                  CustomText2(text: '${data['Dimensi']} cm'),
                ]),
                CustomContainer(children: [
                  const CustomText1(text: 'Jumlah_Kiriman'),
                  CustomText2(text: '${data['Jumlah_Kiriman']}'),
                ]),
                const Divider(),
                CustomContainer(children: [
                  const CustomText1(text: 'Nama Penerima'),
                  CustomText2(text: '${data['Nama_Penerima']}'),
                ]),
                CustomContainer(children: [
                  const CustomText1(text: 'No. HP'),
                  CustomText2(text: '${data['No_HP_Penerima']}'),
                ]),
                CustomContainer2(
                  children: [
                    const Text(
                      'Alamat',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      textAlign: TextAlign.justify,
                      '${data['Alamat_Tujuan']}',
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
