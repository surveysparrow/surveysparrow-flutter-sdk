import 'package:flutter/material.dart';

class WorkBench with ChangeNotifier{
    Map<dynamic, dynamic> _workBench = {};

    Map<dynamic, dynamic> get getWorkBenchData => _workBench;

    void setWorkBenchData(newWorkBenchData){
      _workBench = newWorkBenchData;
    } 
}