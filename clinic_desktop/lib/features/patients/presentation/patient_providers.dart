import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/patient.dart';

/// Holds the active patient loaded into consultation
final activePatientProvider = StateProvider<Patient?>((ref) => null);
