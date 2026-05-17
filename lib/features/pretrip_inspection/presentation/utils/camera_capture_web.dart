import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

Future<XFile?> captureInspectionPhoto() async {
  if (!_hasCameraApi) return _pickWithCaptureInput();

  html.MediaStream? stream;

  try {
    stream = await html.window.navigator.mediaDevices!
        .getUserMedia({
          'audio': false,
          'video': {
            'facingMode': {'ideal': 'environment'},
            'width': {'ideal': 1280},
            'height': {'ideal': 720},
          },
        })
        .timeout(const Duration(seconds: 5));
  } catch (_) {
    return _pickWithCaptureInput();
  }

  final tracks = stream.getVideoTracks();
  if (tracks.isEmpty) {
    stream.getTracks().forEach((t) => t.stop());
    return _pickWithCaptureInput();
  }

  final completer = Completer<XFile?>();
  bool closed = false;

  final container = html.DivElement();
  container.style
    ..position = 'fixed'
    ..top = '0'
    ..left = '0'
    ..width = '100%'
    ..height = '100%'
    ..zIndex = '999999'
    ..background = 'rgba(0,0,0,0.92)'
    ..display = 'flex'
    ..flexDirection = 'column'
    ..alignItems = 'center'
    ..justifyContent = 'center'
    ..gap = '16px'
    ..padding = '18px'
    ..boxSizing = 'border-box';

  final video = html.VideoElement();
  video
    ..srcObject = stream
    ..autoplay = true
    ..muted = true
    ..setAttribute('playsinline', 'true')
    ..setAttribute('webkit-playsinline', 'true')
    ..setAttribute('crossorigin', 'anonymous'); // ← important pour canvas

  video.style
    ..width = 'min(94vw, 680px)'
    ..maxHeight = '60vh'
    ..borderRadius = '12px'
    ..background = '#000'
    ..objectFit = 'cover'
    ..setProperty('transform', 'translateZ(0)')
    ..setProperty('-webkit-transform', 'translateZ(0)')
    ..setProperty('will-change', 'transform');

  final message = html.DivElement()
    ..text = 'Cadrez la photo puis appuyez sur le bouton.'
    ..style.color = 'white'
    ..style.fontFamily = 'Arial, sans-serif'
    ..style.fontSize = '14px'
    ..style.textAlign = 'center';

  final captureBtn = html.ButtonElement()
    ..text = 'Prendre la photo'
    ..style.padding = '12px 28px'
    ..style.border = 'none'
    ..style.borderRadius = '10px'
    ..style.background = '#22c55e'
    ..style.color = 'white'
    ..style.fontWeight = '700'
    ..style.fontSize = '15px'
    ..style.cursor = 'pointer';

  final cancelBtn = html.ButtonElement()
    ..text = 'Annuler'
    ..style.padding = '12px 18px'
    ..style.border = '1px solid rgba(255,255,255,0.35)'
    ..style.borderRadius = '10px'
    ..style.background = 'transparent'
    ..style.color = 'white'
    ..style.fontWeight = '700'
    ..style.cursor = 'pointer';

  final actions = html.DivElement()
    ..style.display = 'flex'
    ..style.gap = '12px'
    ..style.justifyContent = 'center';

  actions.children.addAll([captureBtn, cancelBtn]);
  container.children.addAll([message, video, actions]);

  final body = html.document.body!;
  final flutterView = body.querySelector('flutter-view') ??
      body.querySelector('flt-glass-pane') ??
      body.firstChild;

  if (flutterView != null) {
    body.insertBefore(container, flutterView);
  } else {
    body.append(container);
  }

  final flutterCanvas = body.querySelector('flutter-view') ??
      body.querySelector('flt-glass-pane');
  if (flutterCanvas != null) {
    (flutterCanvas).style.zIndex = '1';
  }

  void close([XFile? file]) {
    if (closed) return;
    closed = true;
    try {
      stream?.getTracks().forEach((t) => t.stop());
      video.pause();
      video.srcObject = null;
      if (flutterCanvas != null) {
        (flutterCanvas).style.zIndex = '';
      }
    } catch (_) {}
    container.remove();
    if (!completer.isCompleted) completer.complete(file);
  }

  cancelBtn.onClick.listen((_) => close());

  try {
    await video.play();
  } catch (_) {}

  await Future.any([
    video.onPlaying.first,
    video.onLoadedMetadata.first,
    Future.delayed(const Duration(seconds: 4)),
  ]);

  await Future.delayed(const Duration(milliseconds: 500));

  // ── Capture avec ImageCapture API (évite canvas noir) ────────────
  captureBtn.onClick.listen((_) async {
    try {
      // Méthode 1 : ImageCapture API (meilleure qualité, pas de canvas noir)
      final imageCapture = js.JsObject(
        js.context['ImageCapture'] as js.JsFunction,
        [tracks.first],
      );

      final blobCompleter = Completer<html.Blob>();
      imageCapture.callMethod('takePhoto', []).callMethod(
        'then',
        [
          (blob) => blobCompleter.complete(blob as html.Blob),
        ],
      ).callMethod('catch', [
        (err) {
          // Méthode 2 : fallback canvas si ImageCapture échoue
          blobCompleter.completeError(err);
        },
      ]);

      try {
        final blob = await blobCompleter.future
            .timeout(const Duration(seconds: 5));
        final arrayBuffer = await _blobToBytes(blob);
        close(XFile.fromData(
          arrayBuffer,
          name: 'inspection_${DateTime.now().millisecondsSinceEpoch}.jpg',
          mimeType: 'image/jpeg',
        ));
        return;
      } catch (_) {
        // ImageCapture a échoué → fallback canvas
      }
    } catch (_) {
      // ImageCapture API non disponible → fallback canvas
    }

    // ── Méthode 2 : Canvas classique ─────────────────────────────
    await Future.delayed(const Duration(milliseconds: 200));

    final w = video.videoWidth > 0 ? video.videoWidth : 1280;
    final h = video.videoHeight > 0 ? video.videoHeight : 720;

    final canvas = html.CanvasElement(width: w, height: h);
    final ctx = canvas.context2D;

    // Désactiver alpha pour éviter canvas noir
    ctx.globalAlpha = 1.0;
    ctx.fillStyle = '#000000';
    ctx.fillRect(0, 0, w.toDouble(), h.toDouble());
    ctx.drawImageScaled(video, 0, 0, w.toDouble(), h.toDouble());

    final dataUrl = canvas.toDataUrl('image/jpeg', 0.92);

    if (dataUrl.length < 1500) {
      // Canvas toujours noir → utiliser input file comme dernier recours
      close();
      final fallback = await _pickWithCaptureInput();
      if (!completer.isCompleted) completer.complete(fallback);
      return;
    }

    final comma = dataUrl.indexOf(',');
    final bytes = base64Decode(dataUrl.substring(comma + 1));
    close(XFile.fromData(
      Uint8List.fromList(bytes),
      name: 'inspection_${DateTime.now().millisecondsSinceEpoch}.jpg',
      mimeType: 'image/jpeg',
    ));
  });

  return completer.future;
}

// ── Helper : Blob → Uint8List ─────────────────────────────────────
Future<Uint8List> _blobToBytes(html.Blob blob) async {
  final reader = html.FileReader();
  reader.readAsArrayBuffer(blob);
  await reader.onLoad.first;
  final result = reader.result;
  if (result is ByteBuffer) return Uint8List.view(result);
  return Uint8List.fromList((result as List<int>?) ?? const []);
}

bool get _hasCameraApi => html.window.navigator.mediaDevices != null;

Future<XFile?> _pickWithCaptureInput() async {
  final input = html.FileUploadInputElement()
    ..accept = 'image/*'
    ..setAttribute('capture', 'environment')
    ..style.display = 'none';

  html.document.body?.append(input);
  final completer = Completer<XFile?>();

  input.onChange.first.then((_) async {
    final file = input.files?.first;
    if (file == null) {
      completer.complete(null);
      input.remove();
      return;
    }
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;
    final result = reader.result;
    final bytes = result is ByteBuffer
        ? Uint8List.view(result)
        : Uint8List.fromList((result as List<int>?) ?? const []);
    completer.complete(XFile.fromData(
      bytes,
      name: file.name,
      mimeType: file.type.isEmpty ? 'image/jpeg' : file.type,
    ));
    input.remove();
  });

  input.click();
  return completer.future;
}