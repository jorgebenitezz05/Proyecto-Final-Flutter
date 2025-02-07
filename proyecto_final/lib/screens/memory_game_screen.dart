import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'screens.dart';

class MemoryGameScreen extends StatefulWidget {
  // Tamaño de la cuadrícula
  final int gridSize;
   // Usuario autenticado
  final User? user;

  const MemoryGameScreen({super.key, required this.gridSize, this.user});

  @override
  // ignore: library_private_types_in_public_api
  _MemoryGameScreenState createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  List<String> images = [];
  List<bool> flipped = [];
  List<int> selectedCards = [];
  List<bool> matched = [];
  int moves = 0;
  late Timer timer;
  int elapsedTime = 0;

  String difficultyTitle = "";

  @override
  void initState() {
    super.initState();
    // Establecer el título del nivel
    difficultyTitle = getDifficultyString();
    fetchCardImages();
    // Iniciar el temporizador
    startTimer();
  }

  @override
  void dispose() {
    // Detener el temporizador al salir de la pantalla
    timer.cancel();
    super.dispose();
  }

  // Método para iniciar el temporizador
  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          elapsedTime++;
        });
      }
    });
  }

  // Método para obtener las imágenes de las cartas desde una API externa
  Future<void> fetchCardImages() async {
    int totalCards;
    // Determinar la cantidad de cartas según el nivel de dificultad
    if (widget.gridSize == 4) {
      // Fácil
      totalCards = 16;
    } else if (widget.gridSize == 6) {
      // Normal
      totalCards = 20;
    } else {
      // Difícil
      totalCards = 30;
    }

    // Petición a la API para obtener cartas aleatorias
    final response = await http.get(Uri.parse(
        'https://deckofcardsapi.com/api/deck/new/draw/?count=$totalCards'));

    // Verificar si la respuesta es correcta (código 200)
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Extraer las imágenes de las cartas de la respuesta JSON
      List<String> fetchedImages =
          List<String>.from(data['cards'].map((card) => card['image']));

      // Seleccionar la mitad de las imágenes y duplicarlas para hacer pares
      List<String> selectedImages =
          List<String>.from(fetchedImages.take(totalCards ~/ 2));

      // Duplicar las imágenes para formar los pares
      selectedImages.addAll(List.from(selectedImages));
      // Mezclar las cartas para que aparezcan en orden aleatorio
      selectedImages.shuffle();

      setState(() {
        images = selectedImages;
        flipped = List.generate(images.length, (index) => false);
        matched = List.generate(images.length, (index) => false);
      });
    }
  }

// Método para voltear una carta cuando el usuario la selecciona
  void flipCard(int index) {
    // Verificar si la carta ya está volteada, emparejada o si ya hay dos cartas seleccionadas
    if (flipped[index] || matched[index] || selectedCards.length >= 2) return;

    setState(() {
      // Voltear la carta
      flipped[index] = true; 
      // Agregar la carta seleccionada a la lista
      selectedCards.add(index); 
    });

    // Si se han seleccionado dos cartas, esperar 1 segundo y verificar si hay coincidencia
    if (selectedCards.length == 2) {
      Future.delayed(Duration(seconds: 1), () {
        checkMatch(); // Comprobar si las cartas coinciden
        moves++; // Incrementar el número de movimientos
      });
    }
  }

// Método para verificar si las dos cartas seleccionadas son iguales
  void checkMatch() {
    if (images[selectedCards[0]] == images[selectedCards[1]]) {
      // Si las cartas coinciden, marcarlas como emparejadas
      setState(() {
        matched[selectedCards[0]] = true;
        matched[selectedCards[1]] = true;
      });
    } else {
      // Si no coinciden, voltearlas nuevamente después de la espera
      setState(() {
        flipped[selectedCards[0]] = false;
        flipped[selectedCards[1]] = false;
      });
    }
    // Limpiar la lista de cartas seleccionadas para la próxima jugada
    selectedCards.clear();
    // Verificar si el juego ha finalizado
    checkGameEnd();
  }

  // Método para verificar si el jugador ha completado el juego
  void checkGameEnd() {
    if (matched.every((e) => e)) {
      // Detener el temporizador
      timer.cancel();

      // Guardar los datos del juego en Firebase
      saveGameData();

      // Mostrar un diálogo indicando que el juego ha terminado
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("¡Juego terminado!"),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Tiempo: $elapsedTime segundos"),
                Text("Movimientos: $moves"),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    // Reiniciar la partida correctamente
                    images.clear();
                    flipped = [];
                    matched = [];
                    selectedCards.clear();
                    moves = 0;
                    elapsedTime = 0;
                    // Iniciar el temporizador
                    startTimer();
                    // Volver a cargar las cartas
                    fetchCardImages();
                  });
                },
                child: Text("Reiniciar partida"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            DifficultySelectionScreen(user: widget.user)),
                  );
                },
                child: Text("Volver al inicio"),
              ),
            ],
          );
        },
      );
    }
  }

  // Método para guardar los datos de la partida en Firestore
  Future<void> saveGameData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Referencia al documento del usuario en Firestore
        var userRef =
            FirebaseFirestore.instance.collection('user_data').doc(user.uid);
        // Obtener el nivel de dificultad
        String difficulty = getDifficultyString();

        // Obtener datos actuales del usuario
        var userDoc = await userRef.get();

        // Si el usuario no tiene datos guardados, inicializar sus estadísticas
        if (!userDoc.exists) {
          await userRef.set({
            'email': user.email,
            'created_at': FieldValue.serverTimestamp(),
            'last_played': null,
            'moves_facil': 0,
            'game_duration_facil': 0,
            'moves_normal': 0,
            'game_duration_normal': 0,
            'moves_dificil': 0,
            'game_duration_dificil': 0,
            'user_name': user.email?.split('@')[0],
          });
        }

        // Campos específicos para guardar el tiempo y los movimientos según la dificultad
        var gameDurationField = 'game_duration_$difficulty';
        var movesField = 'moves_$difficulty';

        int storedGameDuration =
            userDoc.exists ? userDoc[gameDurationField] ?? 0 : 0;
        int storedMoves = userDoc.exists ? userDoc[movesField] ?? 0 : 0;

        // Comprobar si el nuevo tiempo es mejor que el guardado anteriormente
        bool isBetterTime =
            elapsedTime < storedGameDuration || storedGameDuration == 0;

        // Guardar el mejor tiempo o actualizar si es necesario
        if (isBetterTime) {
          await userRef.update({
            gameDurationField: elapsedTime,
            movesField: moves,
            'last_played': FieldValue.serverTimestamp(),
          });
        } else if (elapsedTime == storedGameDuration) {
          // Si el tiempo es igual al mejor, guardar si el número de movimientos es menor
          if (moves < storedMoves || storedMoves == 0) {
            await userRef.update({
              movesField: moves,
              'last_played': FieldValue.serverTimestamp(),
            });
          }
        }
      // ignore: empty_catches
      } catch (e) {
      }
    }
  }

  // Método para obtener la dificultad como texto
  String getDifficultyString() {
    if (widget.gridSize == 4) {
      return 'facil';
    } else if (widget.gridSize == 6) {
      return 'normal';
    } else if (widget.gridSize == 8) {
      return 'dificil';
    }
    return 'facil';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nivel $difficultyTitle"),
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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fondoPagina.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: images.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      padding: EdgeInsets.all(10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: widget.gridSize == 4
                            ? 4
                            : widget.gridSize == 6
                                ? 4
                                : 5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: widget.gridSize == 4
                            ? 1 / 1.4
                            : widget.gridSize == 6
                                ? 1 / 1.4
                                : 1 / 1.4,
                      ),
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return matched[index]
                            ? SizedBox.shrink()
                            : GestureDetector(
                                onTap: () => flipCard(index),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.white,
                                    border: Border.all(
                                        color: Colors.black, width: 2),
                                  ),
                                  child: flipped[index]
                                      ? Image.network(images[index],
                                          fit: BoxFit.cover)
                                      : Image.asset(
                                          'assets/images/fondoCarta.png',
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              );
                      },
                    ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color.fromRGBO(0, 0, 0, 0.5),
                borderRadius: BorderRadius.only(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tiempo: $elapsedTime s",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  Text(
                    "Movimientos: $moves",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
