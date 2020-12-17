//
//  ViewController.swift
//  MyCovidApp
//
//  Created by Mac6 on 16/12/20.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var cityTextField: UITextField!
    @IBOutlet var flagImageView: UIImageView!
    @IBOutlet var casesLabel: UILabel!
    @IBOutlet var deathsLabel: UILabel!
    @IBOutlet var recoveredLabel: UILabel!
    @IBOutlet var errorLabel: UILabel!
    
    var covidManagerObj = CovidManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        covidManagerObj.delegate = self
    }

    @IBAction func searchButton(_ sender: UIButton) {
        if cityTextField.text != "" {
            covidManagerObj.fetchCovidStatisticsByCountryName(countryName: cityTextField.text!)
            return
        }
        
        cityTextField.placeholder = "Type some city..."
    }
    
}


extension ViewController: CovidManagerDelegate {
    func updateCovidStatistics(result: [String : Any?]) {
        DispatchQueue.main.async {
            self.errorLabel.text = ""
            self.casesLabel.text = String(result["cases"] as! Int)
            self.deathsLabel.text = String(result["deaths"] as! Int)
            self.recoveredLabel.text = String(result["recovered"] as! Int)
            self.flagImageView.myLoadFromURL(urlString: result["flagImageUrl"] as! String)
        }
    }
    
    func handleError(errorMessage: String) {
        DispatchQueue.main.async {
            self.cleanInputsAndOutputs()
            self.errorLabel.text = errorMessage
        }
    }
    
    func cleanInputsAndOutputs() {
        casesLabel.text = ""
        deathsLabel.text = ""
        recoveredLabel.text = ""
        flagImageView.image = nil
    }
}

extension UIImageView {
    func myLoadFromURL(urlString: String) {
        guard let url = URL(string: urlString) else {return}

        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
