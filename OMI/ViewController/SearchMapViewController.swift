//
//  SearchMapViewController.swift
//  OMI
//
//  Created by simyo on 2021/10/27.
//

import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift

class SearchMapViewController: UIViewController {
    let apiKey = "KakaoAK 26116c6a522766fadb2273f7cf2008d3"
    var query:String?
    var lat = String()
    var lon = String()
    var unit:String?
    var current_temp:String?
    var min_temp:String?
    var max_temp:String?
    var bookmarks:[Bookmarks] = []
    let realm = try! Realm()
    
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var weatherIcon: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - searchController
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search"
        self.navigationItem.searchController = searchController
        self.navigationItem.title = "추가하고 싶은 동네를 검색해주세요."
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.searchBar.delegate = self

        // MARK: - Change Temp Unit
        changeUnits(UserDefaults.standard.integer(forKey: "tempUnit"))
        
    }
    
    
    func getCoordinate(_ query:String){
        let strURL = "https://dapi.kakao.com/v2/local/search/address.json?"
        let params:Parameters = ["query":query]
        let headers:HTTPHeaders = ["Authorization":apiKey]
        
        let alamo = AF.request(strURL, method: .get, parameters: params, headers: headers)
        alamo.responseJSON { response in
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                print(json)
                if json["documents"].count == 0 {
                    let alert = UIAlertController(title: "다시 입력해주세요", message: "00동으로 입력하면 더 정확합니다.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "확인", style: .default)
                    
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    print("00동으로 입력해주세요")
                } else {
                    self.lat = json["documents"].arrayValue[0]["y"].stringValue
                    self.lon = json["documents"].arrayValue[0]["x"].stringValue
                    self.getWeatherAPI(self.lat, self.lon)
                    print(self.lat, self.lon)
                }
                
            case .failure(let err):
                print("SearchMapController:\(err.localizedDescription)")
            }
        }
        
        
    }
    
    @IBAction func actAdd(_ sender: Any) {
//        let prevVC = self.navigationController?.viewControllers[1]
//        print(prevVC)
//        
//        guard let vc = prevVC as? SettingViewController else { print("err")
//            return }
//        vc.location = self.query
//        vc.lat = self.lat
//        vc.lon = self.lon
//        vc.min_temp = self.min_temp
//        vc.max_temp = self.max_temp
//        vc.bookmarks = self.bookmarks
        self.navigationController?.popViewController(animated: true)
    }
    
    func changeUnits(_ segIndex:Int){
        print(segIndex)
        if segIndex == 0 {
            unit = "metric"
//            unit_of_units = "°C"
        }
        else if segIndex == 1 {
            unit = "imperial"
//            unit_of_units = "°F"
        }
        else {
            unit = "standard"
//            unit_of_units = "K"
        }
    }
    
    func getWeatherAPI(_ lat:String,_ lon:String) {
        let strURL = "https://api.openweathermap.org/data/2.5/onecall?lat=\(self.lat)&lon=\(self.lon)&appid=\(Bundle.main.infoDictionary!["OPEN_WEATHER_API_APP_KEY"]))&units=\(unit!)"
        print("check \(self.lat), \(self.lon)")
        
        let alamo = AF.request(strURL, method: .get, parameters: nil)
            .responseJSON { response in
                let result = response.result
                
                switch result {
                case .success(let value):
                    
                    let json = JSON(value)
                    print("json: \(json)")
                    let current = json["current"]
                    self.current_temp = String( current["temp"].intValue)
                    let weather = current["weather"][0]
                    let description = weather["description"].stringValue
                    let icon = weather["icon"].stringValue
                    
                    
                    let daily = json["daily"][0]
                    let daily_temp = daily["temp"]
                    self.min_temp = String(daily_temp["min"].intValue)
                    self.max_temp = String(daily_temp["max"].intValue)
                    
                    let bookmark = Bookmarks()
                    bookmark.location = self.query ?? ""
                    bookmark.icon_name = icon ?? ""
                    bookmark.cur_temp = self.current_temp ?? ""
                    bookmark.min_temp = self.min_temp ?? ""
                    bookmark.max_temp = self.max_temp ?? ""
                    
                    DispatchQueue.main.async {
                        self.weatherIcon.image = UIImage(named: icon)
                        self.temperatureLabel.text = self.current_temp
                        self.descriptionLabel.text = description
                    }
                    
                    
                    try! self.realm.write {
                        self.realm.add(bookmark, update: .modified)
                    }
        
                case .failure(let err):
                    print(err.localizedDescription)
                }
            }
    }
    
}

extension SearchMapViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else { return }
        self.query = query
        getCoordinate(query)
        
        locationLabel.text = "\(query)의 날씨"
        
    }
}
