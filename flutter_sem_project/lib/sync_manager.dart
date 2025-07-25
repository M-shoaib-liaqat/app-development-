import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'local_db_helper.dart';

class SyncManager {
  static Future<void> syncEventsToFirebase() async {
    final unsyncedEvents = await LocalDbHelper.getUnsyncedEvents();
    for (var event in unsyncedEvents) {
      await FirebaseFirestore.instance.collection('events').add(event);
      await LocalDbHelper.markEventSynced(event['id']);
    }
  }

  static void startSyncListener() {
    Connectivity().onConnectivityChanged.listen((result) async {
      if (result != ConnectivityResult.none) {
        await syncEventsToFirebase();
      }
    });
  }
}
