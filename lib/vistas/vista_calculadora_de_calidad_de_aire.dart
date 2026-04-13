import 'package:flutter/material.dart';
import '../controladores/calidad_aire_controlador.dart';

class VistaCalculadoraDeCalidadDeAire extends StatefulWidget {
  const VistaCalculadoraDeCalidadDeAire({super.key});

  @override
  State<StatefulWidget> createState() => _VistaCalculadoraState(); //Crea un state para cada widget (los separa)
}

class _VistaCalculadoraState extends State<VistaCalculadoraDeCalidadDeAire> {
  final _estadoFormulario = GlobalKey<FormState>();
  final CalidadAireControlador _controlador =
      CalidadAireControlador(); //Controlador para determinar el riesgo

  //Variables de estado:
  String? _ciudadSeleccionada;
  String _fecha = "";
  String _horasExposicion = "";
  String _resultado = "";

  final _fechaController = TextEditingController(); //Controla el input de fecha
  final _horasController = TextEditingController(); //Controla el input de horas

  //Metodo que se activara cuando se active el boton "calcular interface"

  Future<void> _calcularRiesgo() async {
    // Validaciones básicas
    if (_ciudadSeleccionada == null ||
        _ciudadSeleccionada!.isEmpty ||
        _fecha.isEmpty ||
        _horasExposicion.isEmpty) {
      setState(() {
        _resultado = "Por favor, complete todos los campos.";
      });
      return;
    }

    try {
      // Llamada asíncrona al controlador
      final resultado = await _controlador.calcularRiesgo(
        ciudad: _ciudadSeleccionada!,
        fecha: _fecha,
        horasExposicion: double.parse(_horasExposicion),
      );

      //Resultado
      setState(() {
        _resultado =
            "Indice de exposicion: ${resultado.indiceExposicion.toStringAsFixed(1)}\n"
            "Nivel de riesgo: ${resultado.nivelRiesgo}";
      });
    } catch (e) {
      setState(() {
        _resultado = "Error: $e";
      });
    }
  }

  //Interfaz
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Scaffold
      appBar: AppBar(
        //Appbar
        title: const Text("Calculadora Calidad del Aire"),
        centerTitle: true,
        foregroundColor: Colors.blue[300],
      ),

      body: SingleChildScrollView(
        //Body con SingleChildScrollView
        child: Form(
          //Form
          key: _estadoFormulario,
          child: Column(
            //Column
            children: [
              const SizedBox(height: 20),
              //Lista desplegable para poder ver las ciudades
              DropdownButtonFormField<String>(
                initialValue: _ciudadSeleccionada,
                hint: const Text("Seleccione una ciudad"),
                items: const [
                  DropdownMenuItem(value: "Medellin", child: Text("Medellin")),
                  DropdownMenuItem(value: "Bogota", child: Text("Bogota")),
                  DropdownMenuItem(value: "Cali", child: Text("Cali")),
                  DropdownMenuItem(
                    value: "Barranquilla",
                    child: Text("Barranquilla"),
                  ),
                  DropdownMenuItem(
                    value: "Cartagena",
                    child: Text("Cartagena"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _ciudadSeleccionada =
                        value; //Guarda la ciudad que se selecciono
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Ciudad",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20), //SizedBox
              //Campo de texto para la fecha
              TextFormField(
                controller: _fechaController,
                keyboardType: TextInputType.datetime,
                decoration: const InputDecoration(
                  labelText: "Fecha (YYYY-MM-DD)",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _fecha = value;
                  });
                },

                //Validaciones para la fecha
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "La fecha es obligatoria";
                  }
                  final partes = value.split('-');
                  final mes = int.parse(
                    partes[1],
                  ); //Identifica que parte es del mes
                  final dia = int.parse(
                    partes[2],
                  ); //Identifica que parte es del dia
                  if (mes < 1 || mes > 12) {
                    return "Mes invalido";
                  }
                  if (dia < 1 || dia > 31) {
                    return "Dia invalido";
                  }
                  return null;
                },
              ),

              //SizedBox
              const SizedBox(height: 20),

              //Campo de texto para la hora de exposicion
              TextFormField(
                controller: _horasController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Horas de exposicion diaria",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _horasExposicion = value;
                  });
                },
                //Validaciones para la hora de exposicion
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Las horas de exposicion son obligatorias";
                  }

                  final double? horas = double.tryParse(value);
                  if (horas == null) {
                    return "Debe ingresar un numero valido";
                  }

                  if (horas <= 0) {
                    return "las horas deben ser mayores a 0";
                  }
                  if (horas > 24) {
                    return "las horas no pueden superar 24";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20), //SizedBox

              ElevatedButton(
                onPressed: () {
                  if (_estadoFormulario.currentState!.validate()) {
                    _calcularRiesgo();
                  }
                },
                child: const Text("Calcular el nivel de riesgo"),
              ),

              const SizedBox(height: 20),

              Text(
                _resultado,
                style: const TextStyle(color: Colors.green, fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
