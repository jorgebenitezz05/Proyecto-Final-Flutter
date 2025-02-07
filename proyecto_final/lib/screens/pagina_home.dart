import 'package:flutter/material.dart'; 
import 'memory_game_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'screens.dart'; 

class DifficultySelectionScreen extends StatelessWidget {
  // Usuario autenticado
  final User? user;

  // Constructor con un parámetro opcional para el usuario
  const DifficultySelectionScreen({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Selecciona la dificultad"), 
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/fondoArriba.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        elevation: 0,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 24), 
      ),
      // Drawer con el usuario autenticado
      drawer: CustomDrawer(user: user), 
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fondoPagina.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          // Centramos todos los botones en la pantalla
          child: Column(
            // Centra los elementos verticalmente
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [
              // Primer botón para seleccionar la dificultad "Fácil"
              ElevatedButton(
                // Navega a la pantalla de juego con 4x4 cartas
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MemoryGameScreen(gridSize: 4, user: user)) 
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow, 
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: TextStyle(fontSize: 18, color: Colors.black),
                ),
                child: Text("Fácil 16 cartas"),
              ),
              SizedBox(height: 20),
              // Segundo botón para seleccionar la dificultad "Normal"
              ElevatedButton(
                // Navega a la pantalla de juego con 4x6 cartas
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MemoryGameScreen(gridSize: 6, user: user)) 
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow, 
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: TextStyle(fontSize: 18, color: Colors.black),
                ),
                child: Text("Normal 20 cartas"),
              ),
              SizedBox(height: 20),
              // Tercer botón para seleccionar la dificultad "Diícil"
              ElevatedButton(
                // Navega a la pantalla de juego con 5x6 cartas
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MemoryGameScreen(gridSize: 8, user: user)) 
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), 
                  textStyle: TextStyle(fontSize: 18, color: Colors.black), 
                ),
                child: Text("Difícil 30 cartas"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
