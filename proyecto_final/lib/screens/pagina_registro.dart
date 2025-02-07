import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});

  @override
  State createState() {
    return _CreateUserState();
  }
}

class _CreateUserState extends State<CreateUserPage> {
  late String email, password;
  final _formKey = GlobalKey<FormState>();
  // Variable para mostrar errores en el registro
  String error = ""; 

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
                    "Crea tu Cuenta",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 4,
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
                  child: formulario(),
                ),
                botonCrearUsuario(),
                regresarLogin(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget que contiene los campos de email y password
  Widget formulario() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildEmail(),
          const SizedBox(height: 12),
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
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Color.fromRGBO(102, 51, 153, 0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Colors.yellowAccent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Colors.greenAccent),
        ),
        prefixIcon: const Icon(
          Icons.email,
          color: Colors.yellowAccent,
        ),
      ),
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.emailAddress,
       // Guardar email
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
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Color.fromRGBO(102, 51, 153, 0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Colors.yellowAccent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Colors.greenAccent),
        ),
        prefixIcon: const Icon(
          Icons.lock,
          color: Colors.yellowAccent,
        ),
      ),
      // Para ocultar la contraseña
      obscureText: true, 
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        // Validación de campo vacío
        if (value!.isEmpty) {
          return "Este campo es obligatorio"; 
        }
        return null;
      },
      onSaved: (String? value) {
        // Guardar contraseña
        password = value!; 
      },
    );
  }

  // Botón para crear usuario
  Widget botonCrearUsuario() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              UserCredential? credenciales = await crear(email, password);
              if (credenciales != null && credenciales.user != null) {
                await credenciales.user!.sendEmailVerification();
                // Si el registro es exitoso, enviar correo de verificación
                 // Regresar a la pantalla anterior
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
          ),
          child: const Text(
            "Registrarse",
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

  // Botón para regresar a la pantalla de inicio de sesión
  Widget regresarLogin() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "¿Ya tienes una cuenta?",
          style: TextStyle(color: Colors.white),
        ),
        TextButton(
          onPressed: () {
            // Regresar a la pantalla de login
            Navigator.pop(context); 
          },
          child: Text(
            "Inicia sesión",
            style: TextStyle(color: Colors.yellowAccent),
          ),
        ),
      ],
    );
  }

  // Función para crear usuario en Firebase
  Future<UserCredential?> crear(String email, String passwd) async {
    try {
      // Crear usuario con Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Si el usuario fue creado exitosamente, guardar datos en Firestore
      if (userCredential.user != null) {
        String userId = userCredential.user!.uid; // Obtener ID del usuario

        // Guardar información adicional del usuario en Firestore
        await FirebaseFirestore.instance
            .collection('user_data')
            .doc(userId)
            .set({
          'email': email,
          'created_at': FieldValue.serverTimestamp(),
          'last_played': null,
          'moves_facil': 0,
          'game_duration_facil': 0,
          'moves_normal': 0,
          'game_duration_normal': 0,
          'moves_dificil': 0,
          'game_duration_dificil': 0,
          'user_name': email.split('@')[0],
        });

        // Enviar correo de verificación
        await userCredential.user!.sendEmailVerification();

        return userCredential;
      }
    } on FirebaseAuthException catch (e) {
      // Manejo de errores comunes durante el registro
      if (e.code == 'email-already-in-use') {
        setState(() {
           // Error de email duplicado
          error = "El correo ya se encuentra en uso";
        });
      } else if (e.code == 'weak-password') {
        setState(() {
          // Error de contraseña débil
          error = "La contraseña es demasiado débil"; 
        });
      }
    }
    return null;
  }
}
