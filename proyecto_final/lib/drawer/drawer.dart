import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_final/screens/pagina_login.dart';

class CustomDrawer extends StatelessWidget {
  // Usuario actual que está logueado
  final User? user;

  // Constructor que recibe el usuario
  const CustomDrawer({super.key, this.user});

  // Función para mostrar las estadísticas del jugador
  void _showStatistics(BuildContext context) async {
    if (user == null) {
      // Si el usuario no está logueado, mostrar un mensaje indicando que debe iniciar sesión
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Por favor, inicie sesión para ver las estadísticas."),
      ));
      return;
    }

    try {
      // Obtener los datos del usuario desde Firestore
      var userRef =
          FirebaseFirestore.instance.collection('user_data').doc(user!.uid);
      var userDoc = await userRef.get();

      if (userDoc.exists) {
        // Recuperar las estadísticas del usuario para las tres dificultades
        int movesFacil = userDoc['moves_facil'] ?? 0;
        int gameDurationFacil = userDoc['game_duration_facil'] ?? 0;
        int movesNormal = userDoc['moves_normal'] ?? 0;
        int gameDurationNormal = userDoc['game_duration_normal'] ?? 0;
        int movesDificil = userDoc['moves_dificil'] ?? 0;
        int gameDurationDificil = userDoc['game_duration_dificil'] ?? 0;

        // Mostrar un cuadro de diálogo con las estadísticas
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Mejor partida del jugador"),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mostrar las estadísticas de cada dificultad
                  Text(
                      "Fácil: Movimientos: $movesFacil, Tiempo: $gameDurationFacil segundos\n"),
                  Text(
                      "Normal: Movimientos: $movesNormal, Tiempo: $gameDurationNormal segundos\n"),
                  Text(
                      "Difícil: Movimientos: $movesDificil, Tiempo: $gameDurationDificil segundos"),
                ],
              ),
              actions: [
                // Botón para cerrar el diálogo
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cerrar"),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Si ocurre un error al obtener las estadísticas, mostrar un mensaje de error
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Hubo un error al obtener las estadísticas."),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fondoPagina.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.transparent,
                image: DecorationImage(
                  image: AssetImage('assets/images/fondoArriba.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Text(
                    // Nombre del usuario, o 'Usuario' si no está disponible
                    user?.displayName ?? 'Usuario',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    // Correo del usuario, o 'Correo no disponible' si no está disponible
                    user?.email ?? 'Correo no disponible',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            ListTile(
              // Icono de estadística
              leading: Icon(Icons.bar_chart, color: Colors.white),
              title: Text(
                "Estadísticas",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              // Llamada a la función para mostrar las estadísticas
              onTap: () => _showStatistics(context),
            ),
            Divider(color: Colors.white),
            ListTile(
              // Icono de cierre de sesión
              leading: Icon(Icons.logout, color: Colors.white),
              title: Text(
                "Cerrar sesión",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              onTap: () async {
                // Cerrar sesión en Firebase
                await FirebaseAuth.instance.signOut();
                // Navegar de vuelta a la pantalla de inicio de sesión
                Navigator.pushReplacement(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
