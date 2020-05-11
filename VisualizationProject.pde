
import java.text.SimpleDateFormat;
import java.text.ParseException;
import java.util.*;
import java.util.stream.*;

String renderer = P2D;

float mapX1, mapY1;
float mapX2, mapY2;

Float latUpperLimit = 40.915816;
Float latLowerLimit = 40.655750;
Float longLeftLimit = -74.041943;
Float longRightLimit = -73.701028;

PShape map;

int totalCount; // total number of trips
int tripCount;
Trip[] data;
List<Station> stations = new ArrayList<Station>();
Set<Integer> noRepeatedStations  = new HashSet<Integer>();
Map<Integer,Integer> frecuencies = new HashMap<Integer,Integer>();
List<Integer> stationsAux = new ArrayList<Integer>();
Integer maxFrecuency;
Integer minFrecuency;

void setup() {
  PFont font = loadFont("AgencyFB-Reg-14.vlw");
  textFont(font);
  
  size(1050, 1050);
  mapX1 = 50;
  mapX2 = width - mapX1;
  mapY1 = 50;
  mapY2 = height - mapY1;
  
  map = loadShape("map.svg");
  data = readData();
  noRepeatedStations = getStations();
  frecuencies = getFrecuencies(noRepeatedStations, stationsAux);  
  maxFrecuency = Collections.max(frecuencies.values());
  minFrecuency = Collections.min(frecuencies.values());
} 

void draw(){
  background(0);  
  map.disableStyle();  
  fill(0);   
  stroke(255);     
//shape(map, mapX1, mapY1, 1050,1050); 
  drawStations(frecuencies, stations);  
}

Trip[] readData() {
  Trip[] data;
  String[] lines = loadStrings("JC-201912-citibike-tripdata.csv");
  data = new Trip[lines.length-1];
  for (int i = 1; i < lines.length; i++) {
    data[tripCount] = parseTrip(lines[i]);
    tripCount++;
  }
  return data;
}

Trip parseTrip(String line) {
  String pieces[] = split(line, ',');    
  int duration = int(pieces[0]);
  Date startTime = parseDate(pieces[1].replace("\"", ""));
  Date stopTime = parseDate(pieces[2].replace("\"", ""));
  int startStationId = int(pieces[3]);
  String startStationName = pieces[4].replace("\"", "");
  Float startStationLatitude = float(pieces[5]);
  Float startStationLongitude = float(pieces[6]);
  int endStationId = int(pieces[7]);
  String endStationName = pieces[8].replace("\"", "");
  Float endStationLatitude = float(pieces[9]);
  Float endStationLongitude = float(pieces[10]);
  int bikeId = int(pieces[11]);
  String userType = pieces[12].replace("\"", "");
  int birthYear = int(pieces[13]);
  int gender= int(pieces[14]);
  return new Trip(duration, startTime, stopTime, startStationId, startStationName, startStationLatitude, startStationLongitude, 
        endStationId, endStationName, endStationLatitude, endStationLongitude, bikeId, userType, birthYear, gender);
}

Date parseDate(String stringDate) {
  Date date = new Date();
  try {
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSSSSS");
    date = dateFormat.parse(stringDate);    
  }catch(ParseException e) {
    println(e.getMessage());
  }
  return date;
}

Set<Integer> getStations(){    
  for (int i = 0; i < data.length; i++) {
/*     if (data[i].startStationLatitude > latLowerLimit && data[i].startStationLatitude < latUpperLimit && data[i].startStationLongitude > longLeftLimit
    && data[i].startStationLongitude < longRightLimit){
      stationsAux.add(data[i].startStationId);      
      if(noRepeatedStations.add(data[i].startStationId)){
        Station station = new Station(data[i].startStationId,  data[i].startStationName, data[i].startStationLatitude,  data[i].startStationLongitude);
        stations.add(station);
      }
    }
    if (data[i].endStationLatitude > latLowerLimit && data[i].endStationLatitude < latUpperLimit && data[i].endStationLongitude > longLeftLimit
    && data[i].endStationLongitude < longRightLimit){      
      stationsAux.add(data[i].endStationId);
      if(noRepeatedStations.add(data[i].endStationId)){
        Station station = new Station(data[i].endStationId,  data[i].endStationName, data[i].endStationLatitude,  data[i].endStationLongitude);
        stations.add(station);
      }
    } */
    stationsAux.add(data[i].startStationId);      
    if(noRepeatedStations.add(data[i].startStationId)){
      Station station = new Station(data[i].startStationId,  data[i].startStationName, data[i].startStationLatitude,  data[i].startStationLongitude);
      stations.add(station);
    }
    stationsAux.add(data[i].endStationId);
    if(noRepeatedStations.add(data[i].endStationId)){
      Station station = new Station(data[i].endStationId,  data[i].endStationName, data[i].endStationLatitude,  data[i].endStationLongitude);
      stations.add(station);
    }
  }
return noRepeatedStations;
}

Map<Integer,Integer> getFrecuencies(Set<Integer> noRepeatedStations, List<Integer> stationsAux){
  //Map<Integer,Long> frecuencies = stationsAux.stream().collect(Collectors.groupingBy(Function.identity(), Collectors.counting()));  
  for (Integer id : noRepeatedStations) {
    Integer frecuency = Collections.frequency(stationsAux,id);    
    frecuencies.put(id,frecuency);    
  }
  return frecuencies;
}


Float coordinateYmapper(Float latitude){
  Float y = 0.0; 
  Float minY = latLowerLimit;
  Float maxY = latUpperLimit;
  y = map(latitude, minY, maxY, mapY1, mapY2);
  return y;
}

Float coordinateXmapper(Float longitude){
  Float x = 0.0; 
  Float minX = longLeftLimit;
  Float maxX = longRightLimit;
  x = map(longitude, minX, maxX, mapX1, mapX2);
  return x;
}

void drawStations(Map<Integer,Integer> frecuencies, List<Station> stations){
  for (Station station : stations) {
    Integer value = frecuencies.get(station.id);    
    float percent = norm(value, minFrecuency, maxFrecuency);
    color between = lerpColor(#296F34, #61E2F0, percent, HSB);
    Float diameter = map(value, minFrecuency, maxFrecuency, 4, 35);
    Float x = coordinateXmapper(station.longitude);
    Float y = coordinateYmapper(station.latitude);
    pushStyle();
    fill(between); 
    ellipseMode(RADIUS);
    ellipse(x, y, diameter/2, diameter/2);
    popStyle();
    if (dist(x, y, mouseX, mouseY) < (diameter/2)+2) {
      pushStyle();
      fill(255);
      textAlign(CENTER);      
      text(station.name, x, y-(diameter/2)-4);
      popStyle();
    }    
  }
}
  
