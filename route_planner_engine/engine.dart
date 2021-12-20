import 'dart:convert';
import 'dart:math';
import 'package:trotter/trotter.dart';

int main(){
  List<Point<double>> map = [Point<double>(0,1),Point<double>(0,2),Point<double>(0,2),Point<double>(0,3),Point<double>(0,4)];

  pickClosestLocations(map, 2);
  return 0;
  
}

/**
 * This function receives a List of coordinates 
 * and outputs the n coordinates closest to eachother
 */
List<Point<double>> routePlanningEngine(List<Point<double>> map, int n){
  int pointsAmount = map.length;
  List<List<double>> distance_matrix = new List<List<double>>.filled(pointsAmount, new List<double>.filled(pointsAmount, 0));

  for (int i = 0; i < pointsAmount; i++){
    for (int j = 0; j < pointsAmount; j++){
      distance_matrix[i][j] = map[i].distanceTo(map[j]);
    } 
  }

}
 /**
  * 
  * This function finds the n closets dots to eachother from a matrix of distances.
  * 
  * algorithm: go through all combinations of size n of indexes of map, and find the group of points with lowest maximum length.
  * 
  */
List<Point<double>> FindNClosestPoints(List<Point<double>> map, int n){
  final List<int> range = new List.generate(n, (i) => i);
  final combos = trotter.combinations // TODO: make this function work.

}
