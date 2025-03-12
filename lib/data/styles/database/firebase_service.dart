
// Firebase implementation of DatabaseService
import 'database_interface.dart';

class FirebaseService implements DatabaseInterface {
    @override
  void storeData() {
  // TODO: Implement Firebase logic to store data
  print('Storing data in Firebase');
  }
  
  @override
  void loadData() {
    // TODO: Implement Firebase data retrieval logic
    print('Loading data from Firebase');
  } 
}
