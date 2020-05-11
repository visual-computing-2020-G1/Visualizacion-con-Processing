import java.util.Date;
class Trip {

  int duration;
  Date startTime;
  Date stopTime;
  int startStationId;
  String startStationName;
  Float startStationLatitude;
  Float startStationLongitude;
  int endStationId;
  String endStationName;
  Float endStationLatitude;
  Float endStationLongitude;
  int bikeId;
  String userType;
  int birthYear;
  int gender;
  
  public Trip(int duration, Date startTime, Date stopTime, int startStationId, String startStationName, Float startStationLatitude, Float startStationLongitude, int endStationId, String endStationName, Float endStationLatitude, Float endStationLongitude, int bikeId, String userType, int birthYear, int gender) {
    
    this.duration = duration;
    this.startTime = startTime;
    this.stopTime = stopTime;
    this.startStationId = startStationId;
    this.startStationName = startStationName;
    this.startStationLatitude = startStationLatitude;
    this.startStationLongitude = startStationLongitude;
    this.endStationId = endStationId;
    this.endStationName = endStationName;
    this.endStationLatitude = endStationLatitude;
    this.endStationLongitude = endStationLongitude;
    this.bikeId = bikeId;
    this.userType = userType;
    this.birthYear = birthYear;
    this.gender = gender;    
    
  }


}
