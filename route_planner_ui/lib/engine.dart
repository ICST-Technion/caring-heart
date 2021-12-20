import 'dart:convert';
import 'dart:core';
import 'dart:math';
import "package:tuple/tuple.dart";
import 'package:google_maps/google_maps.dart';

class Logic{

 

  static List<MyPoint> routePlanningEngine(List<MyPoint> map, int k) {
    int pointsAmount = map.length;
    // Compute a distance matrix. This defines a graph in which each edge's value is the distance between the nodes.
    List<List<double>> distanceMatrix = _computeDistanceMatrix(pointsAmount, map);

    // From current graph, find k nodes that the maximal distance between them is minimal.
    var routePointsIndexes = _findMinCluster(distanceMatrix, k);
    assert(routePointsIndexes.length == k);


    var routePoints =
    List<MyPoint>.generate(k, (i) => map[routePointsIndexes[i]]);

    return routePoints;
  }

  static List<List<double>> _computeDistanceMatrix(int pointsAmount, List<MyPoint> map) {
    List<List<double>> distanceMatrix = List<List<double>>.generate(map.length, (i) => List<double>.filled(map.length, 0));
    for (int i = 0; i < pointsAmount; i++) {
      for (int j = 0; j < pointsAmount; j++) {

        distanceMatrix[i][j] = map[i].distanceTo(map[j]);
      }
    }
    return distanceMatrix;
  }

  static List<int> _findKClosestNodes(List<double> distancesArray, int k) {
    // TODO: exceptions

    assert(distancesArray.every((element) => element >= 0));
    // List<Pair<int, double>>
    // List<int> l = new List<int>.empty();
    int len = distancesArray.length;

    // If we have less than k nodes, return al n < k nodes.
    if (k > len) {
      print("error: k is larger than the number of locations");
      return List<int>.generate(len, (i) => i);
    }

    // Saving every distance from current origin to it's related node.
    var enumeratedArray = List<Tuple2<int, double>>.generate(
        len, (i) => Tuple2<int, double>(i, distancesArray[i]));

    //Sort the enumerated array by the distance
    enumeratedArray.sort((a, b) => (a.item2.compareTo(b.item2)));

    //Extract only the indexes of sorted (i, dist) pairs
    List<int> sortedIndexes =
    enumeratedArray.map((pair) => (pair.item1)).toList();

    //Return the k closest nodes to origin (includes origin)
    return sortedIndexes.sublist(0, k);
  }

  /// Returns the maximal distance between two points in cluster.
  /// Acts as a metric that defines cluster's size
  static double _computeClusterDistanceFactor(
      List<int> indexes, List<List<double>> graph) {
    double maxDistance = 0;
    // Iterate through every set of two points in indexes.
    // Find the maximal distance between two points.
    for (var i in indexes) {
      for (var j in indexes) {
        maxDistance = (maxDistance > graph[i][j]) ? maxDistance : graph[i][j];
      }
    }
    return maxDistance;
  }

  /// Finds the cluster smallest distance factor by area on a map.
  /// size Is defined in this function by ComputeClusterDistance function.
  static List<int> _findMinCluster(List<List<double>> graph, int k) {
    // Initiate min value
    double minSize = double.maxFinite;
    List<int> minCluster = [];
    for (int i = 0; i < graph.length; i++) {
      // Find the k closest nodes to current node graph[i]. This is a cluster.
      List<int> kClosestNodes = _findKClosestNodes(graph[i], k);

      //Find the size of current cluster.
      double clusterDistanceFactor =
      _computeClusterDistanceFactor(kClosestNodes, graph);

      // If this cluster is minimal, save it.
      if (clusterDistanceFactor < minSize) {
        minSize = clusterDistanceFactor;
        minCluster = kClosestNodes;
      }
    }
    return minCluster;
  }
}

class MyPoint{
  double _x;
  double _y;


  MyPoint(this._x, this._y);

  double get x => _x;
  double get y => _y;

  set y(double value) {
    _y = value;
  }
  set x(double value) {
    _x = value;
  }

  double distanceTo(MyPoint other){
    return sqrt(pow(_x - other.x, 2) + pow(_y - other.y, 2)).toDouble();
  }



}





