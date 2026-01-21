# Integración con `sherpa_onnx` y el modelo Whisper (sherpa-onnx-whisper-small)

Este documento explica únicamente cómo integrar el paquete de Flutter `sherpa_onnx` con el modelo Whisper suministrado en la release oficial. Contiene el enlace de descarga, los archivos exactos requeridos y un ejemplo de extracción usando el paquete `archive` en Dart.

**Paquete Flutter:** sherpa_onnx

**Enlace de descarga (automática):**

https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-whisper-small.tar.bz2

**Archivos exactos requeridos (EXACTO — obligatorio):**

- `small-encoder.int8.onnx`  (Encoder)
- `small-decoder.int8.onnx`  (Decoder)
- `small-tokens.txt`         (Tokens)

Ignorar las versiones no-int8 (`small-encoder.onnx`, `small-decoder.onnx`) para ahorrar memoria — use únicamente los archivos `*.int8.onnx` listados arriba.

Estructura típica dentro del archivo comprimido:

- El archive es un `.tar.bz2` que contiene una carpeta raíz (por ejemplo `sherpa-onnx-whisper-small/`) y dentro de ella los archivos mencionados.

Requisitos en `pubspec.yaml` (dependencias mínimas para el ejemplo de descarga/extracción):

```yaml
dependencies:
  http: any
  archive: any
  path: any
```

Ejemplo en Dart: descargar y extraer robustamente usando `archive`.

Notas:
- Este ejemplo detecta y maneja `.tar.bz2` (bzip2 + tar). Si el asset viene en `.zip`, sustituir la parte de descompresión por `ZipDecoder().decodeBytes`.
- Verificar el tamaño y la integridad del archivo antes de cargar el modelo en memoria en producción.

```dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

/// Descarga y extrae un .tar.bz2 remoto en [outDir].
Future<void> downloadAndExtractTarBz2(String url, String outDir) async {
  final res = await http.get(Uri.parse(url));
  if (res.statusCode != 200) {
    throw Exception('Failed to download model: \\${res.statusCode}');
  }

  final bytes = res.bodyBytes;

  // Descomprime bzip2
  final decompressed = BZip2Decoder().decodeBytes(bytes);

  // Extrae tar
  final archive = TarDecoder().decodeBytes(decompressed);

  for (final file in archive) {
    final name = file.name; // ruta relativa dentro del tar

    // Solo guardar los archivos de interés
    final base = p.basename(name);
    if (base == 'small-encoder.int8.onnx' ||
        base == 'small-decoder.int8.onnx' ||
        base == 'small-tokens.txt') {
      final outPath = p.join(outDir, base);
      final outFile = File(outPath);
      outFile.createSync(recursive: true);
      outFile.writeAsBytesSync(file.content as List<int>);
    }
  }
}

// Uso simple:
// await downloadAndExtractTarBz2(
//   'https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-whisper-small.tar.bz2',
//   'models/sherpa-onnx-whisper-small'
// );
```

Sugerencias de integración con `sherpa_onnx`:

- Coloque `small-encoder.int8.onnx`, `small-decoder.int8.onnx` y `small-tokens.txt` en una carpeta de modelos dentro de su app (por ejemplo `assets/models/sherpa-onnx-whisper-small/`) o en un directorio privado gestionado por la app.
- Si usa assets empaquetados, actualice `pubspec.yaml` para incluir los archivos; para descargas dinámicas, almacénelos en `getApplicationDocumentsDirectory()` y cargue desde ruta absoluta.
- Al inicializar `sherpa_onnx`, provea las rutas exactas a los archivos `*.int8.onnx` y al `small-tokens.txt`.

Limitaciones y recomendaciones:

- Los modelos INT8 son más ligeros pero asegúrese de que la runtime y la librería ONNX que use soporten modelos int8 en el dispositivo objetivo.
- Pruebe primero en un dispositivo de desarrollo para confirmar consumo de memoria y latencia.
- Mantenga las versiones del modelo y del paquete sincronizadas con las releases oficiales.

Fin del documento: este archivo solo trata la implementación con `sherpa_onnx` y el paquete de modelo Whisper indicado.
