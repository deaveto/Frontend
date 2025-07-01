import 'package:geolocator/geolocator.dart';

Stream<Position> obtenerUbicacionContinua() {
  return Geolocator.getPositionStream(
    locationSettings: LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 1, // Solo emite si se mueve al menos 1 metro
    ),
  );
}
