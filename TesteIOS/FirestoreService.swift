//
//  FirestoreService.swift
//  TesteIOS
//
//  Created by Gabriel Ferrari on 15/10/25.
//

import FirebaseFirestore

final class FirestoreService {
    static let shared = FirestoreService()
    private init() {}
    
    let db = Firestore.firestore()
    
    // CRUDs basicos
    
    func addAdaLovelace() async {
        do {
            let ref = try await db.collection("users").addDocument(data: [
                "first": "Ada", "last": "Lovelace", "born": 1815
            ])
        } catch {
            print("Error adding document: \(error)")
        }
    }
    
    func addAlanTuring() async {
      do {
        let ref = try await db.collection("users").addDocument(data: [
          "first": "Alan", "middle": "Mathison", "last": "Turing", "born": 1912
        ])
      } catch {
        print("Error adding document: \(error)")
      }
    }
    
    func getUsersCollection() async {
      do {
        let snap = try await db.collection("users").getDocuments()
        for doc in snap.documents {
          print("\(doc.documentID) => \(doc.data())")
        }
      } catch {
        print("Error getting documents: \(error)")
      }
    }
    
    @discardableResult
    func listenForUsersBornBefore1900() -> ListenerRegistration {
      db.collection("users")
        .whereField("born", isLessThan: 1900)
        .addSnapshotListener { qs, err in
          guard let qs = qs else { print("Error retreiving snapshots \(err!)"); return }
          print("Current users born before 1900: \(qs.documents.map { $0.data() })")
        }
    }
    
    // save, update, delete
    
    func setCityLA() async {
      do {
        try await db.collection("cities").document("LA").setData([
          "name": "Los Angeles", "state": "CA", "country": "USA"
        ])
        print("Document successfully written!")
      } catch {
        print("Error writing document: \(error)")
      }
    }
    
    func dataTypesOne() async {
      let docData: [String: Any] = [
        "stringExample": "Hello world!",
        "booleanExample": true,
        "numberExample": 3.14159265,
        "dateExample": Timestamp(date: Date()),
        "arrayExample": [5, true, "hello"],
        "nullExample": NSNull(),
        "objectExample": [ "a": 5, "b": [ "nested": "foo" ] ]
      ]
      do {
        try await db.collection("data").document("one").setData(docData)
        print("Document successfully written!")
      } catch {
        print("Error writing document: \(error)")
      }
    }
    
    func addCityTokyo() async {
      do {
        let ref = try await db.collection("cities").addDocument(data: [
          "name": "Tokyo", "country": "Japan"
        ])
        print("Document added with ID: \(ref.documentID)")
      } catch {
        print("Error adding document: \(error)")
      }
    }
    
    func updateCityDC() async {
      do {
        try await db.collection("cities").document("DC").updateData(["capital": true])
        print("Document successfully updated")
      } catch {
        print("Error updating document: \(error)")
      }
    }

    func deleteCityDC() async {
      do {
        try await db.collection("cities").document("DC").delete()
        print("Document successfully removed!")
      } catch {
        print("Error removing document: \(error)")
      }
    }
    
    func deleteCollection(named name: String) {
      db.collection(name).getDocuments { snap, err in
        if let err = err { print("Error getting documents: \(err)"); return }
        snap?.documents.forEach { doc in
          print("Deleting \(doc.documentID) => \(doc.data())")
          doc.reference.delete()
        }
      }
    }
    
    // queries
    
    func simpleQueries() {
      let citiesRef = db.collection("cities")
      let _ = citiesRef.whereField("state", isEqualTo: "CA")
      let _ = citiesRef.whereField("capital", isNotEqualTo: false)
      print("simpleQueries prepared")
    }

    func orderAndLimit() {
      let citiesRef = db.collection("cities")
      let _ = citiesRef.order(by: "name").limit(to: 3)
      print("orderAndLimit prepared")
    }
    
    // offline/network toggle
    
    func listenToOffline() {
      db.collection("cities").whereField("state", isEqualTo: "CA")
        .addSnapshotListener(includeMetadataChanges: true) { qs, err in
          guard let qs = qs else { print("Error retreiving snapshot: \(err!)"); return }
          for diff in qs.documentChanges where diff.type == .added {
            print("New city: \(diff.document.data())")
          }
          let source = qs.metadata.isFromCache ? "local cache" : "server"
          print("Metadata: Data fetched from \(source)")
        }
    }

    func toggleOffline() {
      Firestore.firestore().disableNetwork { _ in
        // offline things...
      }
      Firestore.firestore().enableNetwork { _ in
        // back online...
      }
    }
}
