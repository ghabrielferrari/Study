//
//  ViewController.swift
//  TesteIOS
//
//  Created by Gabriel Ferrari on 14/10/25.
//

import UIKit
import FirebaseFirestore

class ViewController: UIViewController {
    
    var db: Firestore!
    
    override func viewDidLoad() {
        // super = acessa totalmente a classe pai (herdados); self = acessa parcialmente a classe pai (locais)
        super.viewDidLoad()
        
        // cria uma conexao com o db/cria uma referencia ao db (ponto de entrada para manipular os dados do banco, CRUD)
        db = Firestore.firestore()
        
        
    }
    
}
