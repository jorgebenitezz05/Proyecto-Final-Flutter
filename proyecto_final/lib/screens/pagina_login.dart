import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'screens.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State createState() {
    return _LoginState();
  }
}

class _LoginState extends State<LoginPage> {
  late String email, password;
  final _formKey = GlobalKey<FormState>();
  // Variable para mostrar mensajes de error
  String error = ""; 

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fondo con imagen de cartas
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/fondoPagina.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Iniciar sesión",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(3, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
                // Mostrar error si existe
                Offstage(
                  offstage: error.isEmpty,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      error,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child:
                      formulario(),
                ),
                butonLogin(),
                nuevoAqui(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget que contiene el enlace para los nuevos usuarios
  Widget nuevoAqui() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "¿Nuevo aquí?",
          style: TextStyle(color: Colors.white),
        ),
        TextButton(
          onPressed: () {
            // Navegar a la página de registro
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateUserPage()),
            );
          },
          child: Text(
            "Regístrate",
            style: TextStyle(color: Colors.yellowAccent),
          ),
        ),
      ],
    );
  }

  // Widget que contiene el formulario de login
  Widget formulario() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildEmail(), 
          const Padding(padding: EdgeInsets.only(top: 12)),
          buildPassword(), 
        ],
      ),
    );
  }

  // Campo de texto para ingresar el email
  Widget buildEmail() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Email",
        labelStyle: TextStyle(color: Colors.white),
        filled: true,
        fillColor: Color.fromRGBO(102, 51, 153, 0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: Colors.yellowAccent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: Colors.greenAccent),
        ),
         // Icono de email
        prefixIcon: Icon(
          Icons.email,
          color: Colors.yellowAccent,
        ),
      ),
      style: TextStyle(color: Colors.white),
      keyboardType: TextInputType.emailAddress,
       // Guardar el email en la variable
      onSaved: (String? value) {
        email = value!;
      },
      validator: (value) {
        // Validación de campo vacío
        if (value!.isEmpty) {
          return "Este campo es obligatorio"; 
        }
        return null;
      },
    );
  }

  // Campo de texto para ingresar la contraseña
  Widget buildPassword() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Password",
        labelStyle: TextStyle(color: Colors.white),
        filled: true,
        fillColor: Color.fromRGBO(102, 51, 153, 0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: Colors.yellowAccent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: Colors.greenAccent),
        ),
        // Icono de candado
        prefixIcon: Icon(
          Icons.lock,
          color: Colors.yellowAccent,
        ),
      ),
      // Para ocultar la contraseña
      obscureText: true, 
      style: TextStyle(color: Colors.white),
      validator: (value) {
         // Validación de campo vacío
        if (value!.isEmpty) {
          return "Este campo es obligatorio";
        }
        return null;
      },
       // Guardar la contraseña en la variable
      onSaved: (String? value) {
        password = value!;
      },
    );
  }

  // Botón para iniciar sesión
  Widget butonLogin() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: ElevatedButton(
          onPressed: () async {
            // Verificar que el formulario sea válido
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save(); // Guardar los valores
              UserCredential? credenciales = await login(email, password);
              if (credenciales != null) {
                if (credenciales.user != null) {
                  if (credenciales.user!.emailVerified) {
                    // Si el email está verificado, ir a la página principal
                    Navigator.pushAndRemoveUntil(
                      // ignore: use_build_context_synchronously
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              DifficultySelectionScreen(user: credenciales.user)),
                      (Route<dynamic> route) => false,
                    );
                  } else {
                    setState(() {
                      // Mensaje de error si no está verificado
                      error = "Debes verificar tu correo antes de acceder";
                    });
                    // Mostrar snackbar indicando que el correo no ha sido verificado
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Debes verificar tu correo")),
                    );
                  }
                }
              }
            }
          },
          // Estilos del botón
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            padding: EdgeInsets.symmetric(vertical: 16.0),
          ),
          child: const Text(
            "Iniciar sesión",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // Función para autenticar al usuario con Firebase
  Future<UserCredential?> login(String email, String passwd) async {
    try {
      // Intentar iniciar sesión con email y contraseña
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Manejo de errores si el login falla
      if (e.code == 'user-not-found') {
        setState(() {
          error = "Usuario no encontrado. Por favor verifica tu email.";
        });
      } else if (e.code == 'wrong-password') {
        setState(() {
          error = "Contraseña incorrecta. Intenta nuevamente.";
        });
      } else if (e.code == 'invalid-email') {
        setState(() {
          error = "El email ingresado no es válido.";
        });
      } else {
        setState(() {
          error = "Email o contraseña incorrecta";
        });
      }
    }
    return null;
  }
}
