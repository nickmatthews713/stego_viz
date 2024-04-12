import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'storage_keys.dart';
import 'save_objects/stegoviz_save.dart';

/// {@template stegoviz_storage_exception}
/// Exception thrown when an error occurs in the StegoVizStorage class
/// {@endtemplate}
class StegoVizStorageException implements Exception {
  StegoVizStorageException(this.message);
  final String message;
}

/// {@template stegoviz_storage}
/// storage repository which exposes an api for storing data to the devices disk
/// {@endtemplate}
class StegoVizStorage {
  /// {@macro stegoviz_storage}
  StegoVizStorage();

  final StreamController<List<StegoVizSave>> _stegoVizSavesController = StreamController<List<StegoVizSave>>();

  /// Getter for the stegoVizSaves stream
  Stream<List<StegoVizSave>> get stegoVizSavesStream => _stegoVizSavesController.stream;

  /// Returns a list of steogviz saves from storage
  /// If no saves are found, returns an empty list
  Future<List<StegoVizSave>> getStegoVizSaves() async {
    final instance = await SharedPreferences.getInstance();
    final List<String>? stegoVizSaves = instance.getStringList(storageKeys[1]);
    if(stegoVizSaves != null) {
      return stegoVizSaves.map((e) => StegoVizSave.fromJson(jsonDecode(e))).toList();
    } else {
      return [];
    }
  }

  /// Save a StegoVizSave object to storage
  /// If the save already exists, it will be overwritten
  /// If the save does not exist, it will be added to the list
  /// Returns true if save was successful
  Future<bool> saveStegoVizSave(StegoVizSave save) async {
    final instance = await SharedPreferences.getInstance();
    final List<StegoVizSave> stegoVizSaves = await getStegoVizSaves();
    final List<String> saveStrings = stegoVizSaves.map((e) => jsonEncode(e.toJson())).toList();
    final String saveString = jsonEncode(save.toJson());
    final id = save.id;
    final index = stegoVizSaves.indexWhere((element) => element.id == id);
    if(index != -1) {
      saveStrings[index] = saveString;
    } else {
      saveStrings.add(saveString);
    }
    final res = await instance.setStringList(storageKeys[1], saveStrings);
    if(res) {
      _stegoVizSavesController.add(await getStegoVizSaves());
      return true;
    } else {
      throw StegoVizStorageException('Failed to save StegoVizSave');
    }
  }

  /// Removes a StegoVizSave object from storage
  /// Returns true if save was removed
  Future<bool> removeStegoVizSave(String id) async {
    final instance = await SharedPreferences.getInstance();
    final List<StegoVizSave> stegoVizSaves = await getStegoVizSaves();
    final List<String> saveStrings = stegoVizSaves.map((e) => jsonEncode(e.toJson())).toList();
    final index = stegoVizSaves.indexWhere((element) => element.id == id);
    if(index != -1) {
      saveStrings.removeAt(index);
      final res = await instance.setStringList(storageKeys[1], saveStrings);
      if(res) {
        _stegoVizSavesController.add(await getStegoVizSaves());
        return true;
      } else {
        throw StegoVizStorageException('Failed to remove StegoVizSave');
      }
    } else {
      throw StegoVizStorageException('StegoVizSave with index $index not found');
    }
  }

  /// Returns false if user has tried to authenticate yet
  /// Otherwise returns true and sets storage value to true
  Future<bool> firstTimeUser() async {
    final instance = await SharedPreferences.getInstance();
    if(instance.getBool(storageKeys[0]) != null) {
      await instance.setBool(storageKeys[0], true);
      return true;
    } else {
      return false;
    }
  }
}
