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
                backgroundImage: AssetImage('assets/images/logo-icon.png'),
                radius: 60,
              ),
            ),
            Text(
              user['nama'].toString(),
              style: const TextStyle(
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
                user['nama'],
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
                user['handphone'],
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
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: ButtonStyle(
                                  side: const WidgetStatePropertyAll(BorderSide(
                                    width: 2.0,
                                    color: Colors.black,
                                    style: BorderStyle.solid,
                                    strokeAlign: BorderSide.strokeAlignCenter,
                                  )),
                                  shape: WidgetStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  backgroundColor: const WidgetStatePropertyAll(
                                      Colors.transparent)),
                              child: const Text(
                                "Batal",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            TextButton(
                              onPressed: () {
                                Route tampilanRoute = MaterialPageRoute(
                                    builder: (context) => const LoginScreen());
                                Navigator.pushAndRemoveUntil(
                                    context, tampilanRoute, (route) => false);
                              },
                              style: ButtonStyle(
                                  side: WidgetStatePropertyAll(BorderSide(
                                    width: 2.0,
                                    color: mycolor.color4,
                                    style: BorderStyle.solid,
                                    strokeAlign: BorderSide.strokeAlignCenter,
                                  )),
                                  shape: WidgetStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  backgroundColor:
                                      WidgetStatePropertyAll(mycolor.color4)),
                              child: const Text(
                                "Keluar",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                          actionsAlignment: MainAxisAlignment.center,
                          content: const Text(
                            'Apakah Anda yakin ingin keluar?',
                            textAlign: TextAlign.center,
                          ),
                          contentTextStyle: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                          contentPadding: const EdgeInsets.all(15),
                        );
                      });
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
