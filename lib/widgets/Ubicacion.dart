import 'package:geolocator/geolocator.dart';

Future<Position> obtenerUbicacionActual() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('El servicio de ubicación está desactivado.');

    LocationPermission permission = await Geolocator.checkPermission();
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
     if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) throw Exception('Permiso de ubicación denegado');
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception('Los permisos de ubicación están permanentemente denegados');
  }

  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.bestForNavigation, // Esto fuerza la mejor precisión posible
  );
}