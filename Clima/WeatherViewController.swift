

import UIKit
import CoreLocation
import Alamofire
import SVProgressHUD
import SwiftyJSON

class WeatherViewController: UIViewController,CLLocationManagerDelegate,changecitydelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    

    //TODO: Declare instance variables here
    let locationmanager=CLLocationManager()
    let weatherdatamodel=WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationmanager.delegate=self
        //TODO:Set up the location manager here.
        locationmanager.desiredAccuracy=kCLLocationAccuracyHundredMeters
        locationmanager.requestWhenInUseAuthorization()
        locationmanager.startUpdatingLocation()
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getweatherdata(url:String,param:[String:String]){
        Alamofire.request(url, method: .get, parameters: param).responseJSON{
            response in
            if response.result.isSuccess{
                print("Succesful")
                self.cityLabel.text="Succesful"
                let WeatherJSON:JSON = JSON(response.result.value!)
                self.updateWeatherdata(json: WeatherJSON)
                print(WeatherJSON)
            }
            else{
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text="Connection Error"
            }
        }
    }
 
   
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherdata(json:JSON){
        let tempresult=json["main"]["temp"].doubleValue
        let cityname=json["name"].string
        let weathercond=json["weather"][0]["id"].intValue
        weatherdatamodel.temp=Int(tempresult-273.15)
        weatherdatamodel.city=cityname!
        weatherdatamodel.cond=weathercond
        updateUIWithWeatherData(condtion: weathercond)
    }

    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData(condtion:Int){
        cityLabel.text=String("\(weatherdatamodel.city)")
        temperatureLabel.text=String(weatherdatamodel.temp)
        weatherIcon.image=UIImage(named: weatherdatamodel.updateWeatherIcon(condition: condtion))
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count-1]
        if location.horizontalAccuracy>0{
            locationmanager.stopUpdatingLocation()
            let latitude=String(location.coordinate.latitude)
            let longitude=String(location.coordinate.longitude)
            let param:[String:String]=["lat" : latitude,"lon" : longitude,"appid" : APP_ID]
            getweatherdata(url: WEATHER_URL, param: param)
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        cityLabel.text="Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    
    func userenterednewcity(city:String){
        let param:[String:String] = ["q":city,"appid":APP_ID]
        getweatherdata(url: WEATHER_URL, param: param)
    }
    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName"{
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate=self
        }
    }
}


