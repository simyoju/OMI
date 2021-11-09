//
//  SettingViewController.swift
//  OMI
//
//  Created by simyo on 2021/10/25.
//

import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift


class SettingViewController: UIViewController {
    var bookmarks:[Bookmarks] = []
    var location:String?
    var lat:String?
    var lon:String?
    var apiKey:String?
    var units:String?
    var current_temp:String?
    var max_temp:String?
    var min_temp:String?
//    var units = String()
    var unit_of_units = String()
    
//    var realm:Realm?
    let realm = try! Realm()
    var notificationToken: NotificationToken?
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tempUnitSegmentControl: UISegmentedControl!
    
    override func viewWillAppear(_ animated: Bool) {
        print("Setting \(lat), \(lon), \(location)")
//        realm = try! Realm()
        tableView.reloadData()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.tableView.reloadData()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let nibName = UINib(nibName: "BookmarkCellTableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "bookmarkCell")
        
        apiKey = Bundle.main.infoDictionary["OPEN_WEATHER_API_APP_KEY"]
        
        tempUnitSegmentControl.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "tempUnit")
        
        changeUnits(UserDefaults.standard.integer(forKey: "tempUnit"))
        
        let bookmarks = realm.objects(Bookmarks.self)
        notificationToken = bookmarks.observe { (changes) in
                    self.tableView.reloadData()
                }
        
        
    }
    
    
    // MARK: - 위치 관리 파트
    @IBAction func actPlusLocation(_ sender: Any) {
        print(self.bookmarks.count)
//        self.tableView.reloadData()
        
    }
    
    // MARK: - 온도 단위 선택
    @IBAction func actChangeUnitOfTemp(_ sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex)
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "tempUnit")
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
    
    
    
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        if let realm = realm {
//            print("numberOfRowsInSection",realm.objects(Bookmarks.self).count)
//            return realm.objects(Bookmarks.self).count
//        }
//        return 1
        
        print("numberOfRowsInSection",realm.objects(Bookmarks.self).count)
        return realm.objects(Bookmarks.self).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        realm.objects(Bookmarks.self)
//            .sorted(byKeyPath: "location")
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookmarkCell", for: indexPath) as? BookmarkCellTableViewCell
        
//        if let realm = realm {
//            let savedBookmark = realm.objects(Bookmarks.self)
//            cell?.locationLabel.text = savedBookmark[indexPath.row].location+unit_of_units
//            cell?.curTempLabel.text = savedBookmark[indexPath.row].cur_temp+unit_of_units
//            cell?.minTempLabel.text = savedBookmark[indexPath.row].min_temp+unit_of_units
//            cell?.maxTempLabel.text = savedBookmark[indexPath.row].max_temp+unit_of_units
//        }
        let savedBookmark = realm.objects(Bookmarks.self)
        cell?.locationLabel.text = savedBookmark[indexPath.row].location
        cell?.weatherIcon.image = UIImage(named: savedBookmark[indexPath.row].icon_name)
        cell?.curTempLabel.text = savedBookmark[indexPath.row].cur_temp+unit_of_units
        cell?.minTempLabel.text = savedBookmark[indexPath.row].min_temp+unit_of_units
        cell?.maxTempLabel.text = savedBookmark[indexPath.row].max_temp+unit_of_units
        return cell ?? UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let savedBookmark = realm.objects(Bookmarks.self)
        
        if editingStyle == .delete {
            try! realm.write{
                realm.delete(savedBookmark[indexPath.row])
                print(savedBookmark)
            }
        }
//        if let realm = realm {
//            let savedBookmark = realm.objects(Bookmarks.self)
//
//            if editingStyle == .delete {
//                try! realm.write{
//                    realm.delete(savedBookmark[indexPath.row])
//                    print(savedBookmark)
//                }
//            }
//        }
        
        
        tableView.reloadData()
    }
}
