//
//  ViewController.swift
//  Weather
//
//  Created by Элина Рупова on 02.02.2022.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var feelsLikeTemperatureLabel: UILabel!
    @IBOutlet weak var background: UIImageView!
    
    lazy var locationManager: CLLocationManager = {
        let lm = CLLocationManager()
        lm.delegate = self
        lm.desiredAccuracy = kCLLocationAccuracyKilometer
        lm.requestWhenInUseAuthorization()
        return lm
    }()
    var networkWeatherManager = NetworkWeatherManager()
    
    @IBAction func searchPressed(_ sender: UIButton) {
        self.presentSearchAlertController(withTitle: "Enter city name", message: nil, style: .alert) {cityName in
            self.networkWeatherManager.fetchCurrentWeather(forRequestType: .cityName(city: cityName))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
        }
        networkWeatherManager.onCompletion = {currentWeather in
            guard let currentWeather = currentWeather else { self.showError(); return }
            self.updateWeather(currentWeather: currentWeather)
        }

    }

    func updateWeather(currentWeather: CurrentWeather) {
        DispatchQueue.main.async {
            let city = "\(currentWeather.cityname), \(self.countryName(countryCode: currentWeather.country))"
            self.cityLabel.text = self.removeSpecialCharsFromString(text: city)
            self.temperatureLabel.text = currentWeather.temperatureString
            self.feelsLikeTemperatureLabel.text = currentWeather.feelsLikeString
            self.weatherIconImageView.image = UIImage(named: currentWeather.iconNameString)
            self.background.image = UIImage(named: currentWeather.backgroundNameString)
        }

    }
    
    func removeSpecialCharsFromString(text: String) -> String {
        let okayChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ-,")
        return text.filter { okayChars.contains($0) }
    }
    
    func countryName(countryCode: String) -> String {
        let current = Locale(identifier: "en_US")
        let country = current.localizedString(forRegionCode: countryCode)
        guard let country = country else {
            return ""
        }
        return country
    }
    
}

extension ViewController {
    
    func presentSearchAlertController(withTitle title: String?, message: String?, style: UIAlertController.Style, complitionHandler: @escaping (String) -> Void) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: style)
        
        ac.addTextField { tf in
            let cities = ["Saint-Petersburg", "Moscow", "New York", "Istanbul", "Rome"]
            tf.placeholder = cities.randomElement()
        }
        let search = UIAlertAction(title: "Search", style: .default) { action in
            let textField = ac.textFields?.first
            guard let cityName = textField?.text else { return }
            if cityName != "" {
                let city = cityName.split(separator: " ").joined(separator: "%20")
                complitionHandler(city)
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        ac.addAction(search)
        ac.addAction(cancel)
        present(ac, animated: true, completion: nil)
    }
    
    func showError() {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "Error", message: "Incorrect city", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            ac.addAction(cancel)
            self.present(ac, animated: true, completion: nil)
        }
    }
}


extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        networkWeatherManager.fetchCurrentWeather(forRequestType: .coordinate(lat: lat, lon: lon))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
