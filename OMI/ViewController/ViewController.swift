//
//  ViewController.swift
//  OMI
//
//  Created by simyo on 2021/10/25.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation
import RealmSwift

class ViewController: UIViewController {
    var lat = Double()
    var lon = Double()
    
    var units = String()
    var unit_of_units = String()
    
    var manager = CLLocationManager()
    
    let realm = try! Realm()
    
    var min_temp = Int()
    var max_temp = Int()
    var average_temp = Int()
    
    
    @IBOutlet weak var clothIcon: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var feelsLikeTempLabel: UILabel!
    @IBOutlet weak var feelsLikeTempIcon: UIImageView!
    @IBOutlet weak var cloudsLabel: UILabel!
    @IBOutlet weak var cloudsIcon: UIImageView!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var windSpeedIcon: UIImageView!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var humidityIcon: UIImageView!
    
    
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var averageTempLabel: UILabel!
    @IBOutlet weak var minTempIcon: UIImageView!
    @IBOutlet weak var maxTempIcon: UIImageView!
    @IBOutlet weak var averageTempIcon: UIImageView!
    
    
    @IBOutlet var max_min_ave_stackview: UIStackView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        manager.startUpdatingLocation()
        
        changeUnits(UserDefaults.standard.integer(forKey: "tempUnit"))
        showWeatherIcon()
        
        let size: CGFloat = 20
        let distance: CGFloat = 25
        let rect = CGRect(
            x: -size,
            y: max_min_ave_stackview.frame.height - (size * 0.4) + distance,
            width: max_min_ave_stackview.frame.width + size * 2,
            height: size
        )

        max_min_ave_stackview.layer.shadowColor = UIColor.black.cgColor
        max_min_ave_stackview.layer.shadowRadius = 10
        max_min_ave_stackview.layer.shadowOpacity = 0.1
        
        max_min_ave_stackview.layer.shadowPath = UIBezierPath(ovalIn: rect).cgPath


    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
//        UserDefaults.standard.set("97240930f69215cf4fa8a94c713651d7", forKey: "apiKey")
        
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    @IBAction func actSendMinTemp(_ sender: Any) {
        sendTemp(min_temp)
    }
    
    @IBAction func actSendMaxTemp(_ sender: Any) {
        sendTemp(max_temp)
    }
    
    @IBAction func actSendAveTemp(_ sender: Any) {
        sendTemp(average_temp)
    }
    
    
    func sendTemp(_ temp:Int){
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        
        vc.tempText = String(temp)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func changeUnits(_ segIndex:Int){
        print(segIndex)
        if segIndex == 0 {
            units = "metric"
            unit_of_units = "°C"
        }
        else if segIndex == 1 {
            units = "imperial"
            unit_of_units = "°F"
        }
        else {
            units = "standard"
            unit_of_units = "K"
        }
    }
    
    func showWeatherIcon() {
        feelsLikeTempIcon.image = UIImage(named: "u_temperature-half")
        cloudsIcon.image = UIImage(named: "u_clouds")
        windSpeedIcon.image = UIImage(named: "fi_wind")
        humidityIcon.image = UIImage(named: "u_raindrops-alt")
    }
    
    private func getWeatherAPI(_ unit:String) {
        
        
        let strURL = "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(lon)&appid=\(Bundle.main.infoDictionary["OPEN_WEATHER_API_APP_KEY"])&units=\(unit)"
        
        let alamo = AF.request(strURL, method: .get, parameters: nil)
//            .validate(statusCode: 200 ..< 300)
            .responseJSON { response in
                let result = response.result
                
                switch result {
                case .success(let value):
                    let json = JSON(value)
                    let timezone = json["timezone"].stringValue
                    let current = json["current"]
                    let current_temp = current["temp"].intValue
                    print(type(of: current_temp), current_temp)
                    let weather = current["weather"][0]
                    let description = weather["description"].stringValue
                    let icon = weather["icon"].stringValue
                    
                    
                    let feels_like_temp = current["feels_like"].stringValue
                    let clouds = current["clouds"].stringValue
                    let wind_speed = current["wind_speed"].stringValue
                    let humidity = current["humidity"].stringValue
                    print(feels_like_temp, clouds, wind_speed, humidity)
                    
                    
                    let daily = json["daily"][0]
                    let daily_temp = daily["temp"]
                    self.min_temp = daily_temp["min"].intValue
                    self.max_temp = daily_temp["max"].intValue
                    self.average_temp = (self.min_temp+self.max_temp)/2
                    
                    let hourly = json["hourly"].arrayValue
                    print("hourly type \(type(of: hourly)), \(hourly)")
                    
                    let clothes_name = self.getClothesImage(current_temp)
                    let min_temp_icon = self.getWeatherIcon(hourly, self.min_temp)
                    let max_temp_icon = self.getWeatherIcon(hourly, self.max_temp)
                    let average_temp_icon = daily["weather"][0]["icon"].stringValue
                    
                    DispatchQueue.main.async {
                        self.descriptionLabel.text = description
                        self.temperatureLabel.text = String(current_temp) + self.unit_of_units
                        self.locationLabel.text = timezone
                        self.clothIcon.image = UIImage(named: clothes_name)
                        
                        
                        self.feelsLikeTempLabel.text = feels_like_temp.dropLast(3)+self.unit_of_units
                        self.cloudsLabel.text = clouds
                        self.windSpeedLabel.text = wind_speed
                        self.humidityLabel.text = humidity
                        
                        self.minTempLabel.text = String(self.min_temp)+self.unit_of_units
                        self.maxTempLabel.text = String(self.max_temp)+self.unit_of_units
                        self.averageTempLabel.text = String(self.average_temp)+self.unit_of_units
                        self.minTempIcon.image = UIImage(named: min_temp_icon)
                        self.maxTempIcon.image = UIImage(named: max_temp_icon)
                        self.averageTempIcon.image = UIImage(named: average_temp_icon)
                    }
                    
                case .failure(let err):
                    print(err.localizedDescription)
                }
            }
        
        
        
    }

    // MARK: - choose clothing
    private func getClothesImage(_ temp:Int) -> String {
        switch temp{
        case 28...:
            return "t-shirt"
        case 23...27:
            return "shirts"
        case 20...22:
            return "blouse"
        case 17...19:
            return "man-to-man"
        case 12...16:
            return "cardigan"
        case 9...11:
            return "knit"
        case 5...8:
            return "wool-coat"
        default:
            return "down-jacket"
        }
    }
    
    
    func getWeatherIcon(_ hourly:Array<JSON>, _ min_temp: Int) -> String{
        for index in 0...hourly.count-1{
            print(hourly[index]["temp"])
            var temp = hourly[index]["temp"].intValue
            if min_temp == temp {
                print(hourly[index]["weather"][0]["icon"])
                return hourly[index]["weather"][0]["icon"].stringValue
            }
        }
        return ""
    }
    

}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        
        if let location = locations.last {
            lat = location.coordinate.latitude
            lon = location.coordinate.longitude
            print(lat, lon)
            
            getWeatherAPI(units)
        }
        
    }
}
