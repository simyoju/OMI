//
//  WeatherInfo.swift
//  OMI
//
//  Created by simyo on 2021/11/09.
//

import Foundation
import RealmSwift

class WeatherInfo: Object {
    @objc dynamic var weather_description:String = ""
    @objc dynamic var temp:Float = 0.0
    @objc dynamic var feels_like:Float = 0.0
    @objc dynamic var clouds:Int = 0
    @objc dynamic var wind_speeds:Float = 0.0
    @objc dynamic var humidity:Int = 0
    @objc dynamic var max_temp:Float = 0.0
    @objc dynamic var min_temp:Float = 0.0
    @objc dynamic var average_temp:Float = 0.0
    
    
}
