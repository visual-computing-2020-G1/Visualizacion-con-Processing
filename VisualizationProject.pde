
import java.text.SimpleDateFormat;
import java.text.ParseException;
import java.util.*;
import java.util.stream.*;

String renderer = P2D;

float mapX1, mapY1;
float mapX2, mapY2;

Float latUpperLimit,latLowerLimit,longLeftLimit,longRightLimit;
Float mxLongitude,mnLongitude,mxLatitude,mnLatitude;

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
Map<Integer,Integer> maxFrecPerHour = new HashMap<Integer,Integer>();
Map<Integer,Integer> minFrecPerHour = new HashMap<Integer,Integer>();
ArrayList<Map<Integer,Integer>> frecuenciesPerHour = new ArrayList<Map<Integer,Integer>>();


boolean viewFrecuencyPerHour = false;
int hour;

void setup() {
  PFont font = loadFont("AgencyFB-Reg-14.vlw");
  textFont(font);
  
//  map = loadShape("map.svg");
  data = readData();
  noRepeatedStations = getStations();
  frecuencies = getFrecuencies(noRepeatedStations, stationsAux);  
  maxFrecuency = Collections.max(frecuencies.values());
  minFrecuency = Collections.min(frecuencies.values());
  getFrecuenciesPerHour(data,stations);
  mxLongitude = getMaxLongitude(stations);
  mnLongitude = getMinLongitude(stations);
  mxLatitude = getMaxLatitude(stations);
  mnLatitude = getMinLatitude(stations);
  latUpperLimit = mxLatitude;
  latLowerLimit = mnLatitude;
  longLeftLimit = mnLongitude;
  longRightLimit = mxLongitude;
  
  hour = 0;
  
  size(1050, 1050);
  mapX1 = 50;
  mapX2 = width - mapX1;
  mapY1 = 50;
  mapY2 = height - mapY1;
} 

void draw(){
  if(!viewFrecuencyPerHour){
    background(0);
    fill(0);
    stroke(255);
    drawStations(frecuencies, stations);
  }else{
    if(hour>=0 && hour<=23){      
      if(frameCount%180==0){
        background(0);        
        drawStationsPerHour(stations, hour);
        hour++;
      }      
    }
  }  
  
//  map.disableStyle();       
//shape(map, mapX1, mapY1, 1050,1050); 
}

void keyPressed() {  
  if (key == 'h') {
    viewFrecuencyPerHour = true;    
  }
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

void getFrecuenciesPerHour(Trip[] trips, List<Station> stations){  
  for (int i = 0; i < 24; i++) {
    Map<Integer,Integer> frecuencies = new HashMap<Integer,Integer>();
    List<Integer> stationsPerHour = new ArrayList<Integer>();
    for (Trip trip : trips) {
      int hourStart = (int)(trip.startTime.getTime() % 86400000) / 3600000;      
      int hourEnd = (int)(trip.startTime.getTime() % 86400000) / 3600000;
      if (hourStart == i){
        stationsPerHour.add(trip.startStationId);
      }
      if (hourEnd == i){
        stationsPerHour.add(trip.endStationId);
      }          
    }
    for (Station station : stations) {
      Integer frecuency = Collections.frequency(stationsPerHour,station.id);    
      frecuencies.put(station.id,frecuency);       
    }
    frecuenciesPerHour.add(frecuencies);    
    int maxFrecuency = Collections.max(frecuencies.values());
    maxFrecPerHour.put(i,maxFrecuency);
    int minFrecuency = Collections.min(frecuencies.values());
    minFrecPerHour.put(i,minFrecuency);
  }    
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
    pushStyle();
    fill(255);
    textAlign(CENTER);      
    text(station.name, x, y-(diameter/2)-4);
    popStyle();
    /*
    if (dist(x, y, mouseX, mouseY) < (diameter/2)+2) {
      pushStyle();
      fill(255);
      textAlign(CENTER);      
      text(station.name, x, y-(diameter/2)-4);
      popStyle();
    }  
    */
  }
}

void drawStationsPerHour(List<Station> stations, int hour){  
  int i = hour;
   pushStyle();
   fill(255);
   textAlign(LEFT);
   textSize(26);
   text("Hora: "+ hour + " Hrs", (mapX2 - mapX1)/2, 30);
   popStyle();         
        for (Station station : stations) {
          Integer value = frecuenciesPerHour.get(i).get(station.id);          
          Float opacity = map(value, minFrecPerHour.get(i), maxFrecPerHour.get(i), 0, 255);
          Float diameter = map(value, minFrecPerHour.get(i), maxFrecPerHour.get(i), 4, 35);
          Float x = coordinateXmapper(station.longitude);
          Float y = coordinateYmapper(station.latitude);
          pushStyle();
          fill(255,0,0,opacity); 
          stroke(255,0,0,opacity);
          ellipseMode(RADIUS);
          ellipse(x, y, diameter/2, diameter/2); 
          textAlign(CENTER);      
          text(station.name, x, y-(diameter/2)-4);
          popStyle();               
        
  }
}

Float getMaxLatitude(List<Station> stations){
  Float maxLatitude = Float.MIN_VALUE;
  for (Station station : stations) {
    if (station.latitude > maxLatitude){
      maxLatitude = station.latitude;
    }
  }
  return maxLatitude;
}

Float getMinLatitude(List<Station> stations){
  Float minLatitude = Float.MAX_VALUE;
  for (Station station : stations) {
    if (station.latitude < minLatitude){
      minLatitude = station.latitude;
    }
  }
  return minLatitude;
}

Float getMaxLongitude(List<Station> stations){
  Float maxLongitude = -100.0;
  for (Station station : stations) {
    if (station.longitude > maxLongitude){
      maxLongitude = station.longitude;
    }
  }
  return maxLongitude;
}

Float getMinLongitude(List<Station> stations){
  Float minLongitude = Float.MAX_VALUE;
  for (Station station : stations) {
    if (station.longitude < minLongitude){
      minLongitude = station.longitude;
    }
  }
  return minLongitude;  
}
