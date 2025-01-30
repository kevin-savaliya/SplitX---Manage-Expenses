import 'package:cloud_firestore/cloud_firestore.dart';

class FTimestamp {
  // Get current server timestamp
  static FieldValue get serverTimestamp => FieldValue.serverTimestamp();

  // Convert Firestore Timestamp to DateTime
  static DateTime fromFirestoreTimestamp(String isoString) {
    return DateTime.parse(isoString);
  }

  // Convert DateTime to Firestore Timestamp
  static Timestamp? toFirestoreTimestamp(DateTime? dateTime) {
    if (dateTime == null) {
      return null;
    }
    return Timestamp.fromDate(dateTime);
  }
}
