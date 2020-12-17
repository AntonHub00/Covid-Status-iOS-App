//
//  CovidManager.swift
//  MyCovidApp
//
//  Created by Mac6 on 17/12/20.
//

import Foundation

protocol CovidManagerDelegate {
    func updateCovidStatistics(result: [String: Any?])
    func handleError(errorMessage: String)
}

struct CovidManager {
    
    var delegate: CovidManagerDelegate?
    
    let baseUrl = "https://corona.lmao.ninja/v3/covid-19/countries/"
    
    
    func fetchCovidStatisticsByCountryName(countryName: String){
        let url = "\(baseUrl)\(countryName)"
        makeRequest(url: url)
    }
    
    
    func makeRequest(url: String) {
        // Create url
        if let url = URL(string: url) {
            // Create  URLSessio object
            let session = URLSession(configuration: .default)
            
            // Assign task to seesion
            let task = session.dataTask(with: url, completionHandler: handle(data:response:error:))
            
            // Start task
            task.resume()
        }
    }
    
    
    func handle(data: Data?, response: URLResponse?, error: Error?) {
        if error != nil {
            delegate?.handleError(errorMessage: error!.localizedDescription)
            return
        }
        
        if let secureData = data {
            // Decode API JSON response
            let response = self.parseJSON(covidData: secureData)
            
            if response["errorMessage"] == nil {
                // Whoever is the delegated needs to implement the updateCovidStatistics method
                delegate?.updateCovidStatistics(result: response)
            } else {
                delegate?.handleError(errorMessage: response["errorMessage"] as! String)
            }
        }
    }
    
    
    func parseJSON(covidData: Data) -> [String: Any?] {
        do {
            let data = try JSONSerialization.jsonObject(with: covidData, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
            
            if let cases = data["cases"] as? Int, let deaths = data["deaths"] as? Int, let recovered = data["recovered"] as? Int {
                let countryInfo = data["countryInfo"] as AnyObject
                
                if let flagImageUrl = countryInfo["flag"] as? String {
                    return ["cases": cases, "deaths": deaths, "recovered": recovered, "flagImageUrl": flagImageUrl, "erroMessage": nil]
                }
            }
            
            if let errorMessage = data["message"] as? String {
                return ["errorMessage": errorMessage]
            }
            
            return ["errorMessage": "Server error"]
        } catch {
            return ["errorMessage": "Server error"]
        }
    }
}
