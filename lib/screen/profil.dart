import 'package:aplikurir/screen/login.dart';
import 'package:flutter/material.dart';
import 'package:aplikurir/component/custom_color.dart';

class ProfilScreen extends StatelessWidget {
  final dynamic user;

  const ProfilScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final mycolor = CustomStyle();
    return Scaffold(
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
            "Profil",
            style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: mycolor.color2),
          ),
        ),
        excludeHeaderSemantics: false,
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 20, bottom: 5),
              child: const CircleAvatar(
                backgroundImage: NetworkImage(
                    "https://cdn0-production-images-kly.akamaized.net/r54nW4zkx08SZbVManHo1Ekxm9g=/500x500/smart/filters:quality(75):strip_icc():format(webp)/kly-media-production/medias/4504937/original/019897000_1689582125-7680241_3697355.jpg"),
                radius: 60,
              ),
            ),
            Text(
              user['nama_kurir'],
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              width: 370,
              child: Divider(
                thickness: 3,
                height: 30,
                color: mycolor.color1,
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Text(
                "Nama Pengguna",
                style: TextStyle(
                  color: mycolor.color1,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Text(
                user['nama_kurir'],
                style: TextStyle(
                  color: mycolor.color1,
                  fontSize: 25,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Text(
                "Nomor Handphone",
                style: TextStyle(
                  color: mycolor.color1,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Text(
                user['handphone_kurir'],
                style: TextStyle(
                  color: mycolor.color1,
                  fontSize: 25,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Text(
                "Email",
                style: TextStyle(
                  color: mycolor.color1,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Text(
                user['email'],
                style: TextStyle(
                  color: mycolor.color1,
                  fontSize: 25,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(top: 25, left: 15, right: 15),
              child: ElevatedButton(
                style: ButtonStyle(
                  shape: const WidgetStatePropertyAll(
                    BeveledRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(2),
                      ),
                    ),
                  ),
                  backgroundColor: WidgetStatePropertyAll(mycolor.color4),
                ),
                onPressed: () {
                  Route tampilanRoute = MaterialPageRoute(
                      builder: (context) => const LoginScreen());
                  Navigator.pushAndRemoveUntil(
                      context, tampilanRoute, (route) => false);
                },
                child: Text(
                  "Keluar",
                  style: TextStyle(
                    color: mycolor.color2,
                    fontSize: 25,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
