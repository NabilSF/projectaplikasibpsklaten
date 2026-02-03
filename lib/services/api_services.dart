import 'dart:convert';
import 'package:http/http.dart' as http;
import 'bps_model.dart';

class ApiService {
  final String _baseUrl = "https://webapi.bps.go.id/v1/api";
  final String _apiKey = "ef7be0f3321be69126d2cfaff9e4a67f"; 
  final String _domain = "3310"; // BPS Kabupaten Klaten

  // --- LINK SPREADSHEET (DASHBOARD, POPUP, & RENCANA TERBIT) ---
  static const String _strategicSheetUrl = "https://docs.google.com/spreadsheets/d/e/2PACX-1vTRg49G1-T4EDHcy1NQ9qHs_gCCvlSwwHd6cF750DqoFxOwOhpR0ecciFLgU7tgLnmcDUJr3XIGpxjz/pub?gid=0&single=true&output=csv";
  static const String _popupSheetUrl = "https://docs.google.com/spreadsheets/d/e/2PACX-1vTRg49G1-T4EDHcy1NQ9qHs_gCCvlSwwHd6cF750DqoFxOwOhpR0ecciFLgU7tgLnmcDUJr3XIGpxjz/pub?gid=0&single=true&output=csv";
  
  // Link Baru untuk Rencana Terbit
  static const String _scheduleSheetUrl = "https://docs.google.com/spreadsheets/d/e/2PACX-1vTyrydMkQODm-ZJ5FEWxL4jiHh7iTx3HKdMkrb507gABPvL0qCKMD1F8fRXg7H_bHcKbCgVFoAPnEgE/pub?gid=0&single=true&output=csv";

  // --- 1. DATA STRATEGIS (SPREADSHEET) ---
  Future<List<BpsIndicator>> getStrategicIndicators() async {
    List<BpsIndicator> sheetData = [];
    final List<BpsIndicator> fallbackData = [
      BpsIndicator(id: 1, title: "Indeks Pembangunan Manusia", value: "78.16", unit: "", period: "2024", dataSource: "BPS Klaten"),
      BpsIndicator(id: 2, title: "Penduduk Miskin", value: "11.00", unit: "%", period: "2024", dataSource: "BPS Klaten"),
    ];

    try {
      final response = await http.get(Uri.parse(_strategicSheetUrl));
      if (response.statusCode == 200) {
        List<String> lines = response.body.split('\n');
        for (int i = 1; i < lines.length; i++) {
          String line = lines[i].replaceAll('\r', '').trim();
          if (line.isEmpty) continue;
          List<String> parts = line.split(',');
          if (parts.length >= 6 && parts[1].trim().isNotEmpty) { 
            sheetData.add(BpsIndicator(
              id: int.tryParse(parts[0]) ?? 0,
              title: parts[1].replaceAll('"', '').trim(),
              value: parts[2].replaceAll('"', '').trim(),
              unit: parts[3].replaceAll('"', '').trim(),
              period: parts[4].replaceAll('"', '').trim(),
              dataSource: parts[5].replaceAll('"', '').trim(),
            ));
          }
        }
        if (sheetData.isNotEmpty) return sheetData;
      }
    } catch (e) { print("Error Sheet: $e"); }
    return fallbackData; 
  }

  // --- 2. POPUP IMAGE (SPREADSHEET) ---
  Future<String?> getPopupImage() async {
    try {
      final response = await http.get(Uri.parse(_popupSheetUrl));
      if (response.statusCode == 200) {
        List<String> lines = response.body.split('\n');
        for (int i = 1; i < lines.length; i++) {
          List<String> parts = lines[i].split(',');
          if (parts.length >= 2) {
            String url = parts[0].replaceAll('"', '').trim();
            String status = parts[1].replaceAll('"', '').trim().toUpperCase();
            if (status == 'TRUE' && url.isNotEmpty) return url;
          }
        }
      }
    } catch (e) { print("Error Popup: $e"); }
    return null;
  }

  // --- 3. RENCANA TERBIT (SPREADSHEET BARU) ---
  Future<List<Map<String, dynamic>>> getReleaseSchedule() async {
    try {
      final response = await http.get(Uri.parse(_scheduleSheetUrl));
      if (response.statusCode == 200) {
        List<String> lines = response.body.split('\n');
        List<Map<String, dynamic>> schedule = [];

        // Loop dari index 1 (melewati header)
        for (int i = 1; i < lines.length; i++) {
          String line = lines[i].replaceAll('\r', '').trim();
          if (line.isEmpty) continue;
          List<String> parts = line.split(',');

          // Pastikan ada minimal 6 kolom sesuai format sheet
          if (parts.length >= 6) {
            schedule.add({
              "id": parts[0].replaceAll('"', '').trim(),
              "category": parts[1].replaceAll('"', '').trim(), // Publikasi / BRS
              "title": parts[2].replaceAll('"', '').trim(),
              "date": parts[3].replaceAll('"', '').trim(),     // Format: YYYY-MM-DD
              "status": parts[4].replaceAll('"', '').trim(),   // scheduled / released
              "link": parts[5].replaceAll('"', '').trim(),     // Link PDF / Kosong
            });
          }
        }
        return schedule;
      }
    } catch (e) { print("Error Schedule: $e"); }
    return [];
  }

  // --- 4. PUBLIKASI (FILTER LENGKAP: KEYWORD, BULAN, TAHUN) ---
  Future<List<BpsPublikasi>> getPublikasi({String keyword = "", int? year, int? month}) async {
    try {
      String url = "$_baseUrl/list/model/publication/lang/ind/domain/$_domain/page/1/key/$_apiKey/";
      if (year != null) url += "year/$year/";
      if (month != null) url += "month/$month/";
      if (keyword.isNotEmpty) url += "keyword/${Uri.encodeComponent(keyword)}/";

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == "OK" && jsonResponse['data-availability'] == "available" && jsonResponse['data'].length > 1) {
          final List<dynamic> rawList = jsonResponse['data'][1];
          return rawList.map((item) => BpsPublikasi.fromJson(item)).toList();
        }
      }
    } catch (e) { print("Error Pub: $e"); }
    return [];
  }

  // --- 5. PRESS RELEASE / BRS (FILTER LENGKAP) ---
  Future<List<BpsPressRelease>> getPressReleases({int page = 1, String keyword = "", int? year, int? month}) async {
    try {
      String url = "$_baseUrl/list/model/pressrelease/lang/ind/domain/$_domain/page/$page/key/$_apiKey/";
      if (year != null) url += "year/$year/";
      if (month != null) url += "month/$month/";
      if (keyword.isNotEmpty) url += "keyword/${Uri.encodeComponent(keyword)}/";

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == "OK" && jsonResponse['data-availability'] == "available" && jsonResponse['data'].length > 1) {
          final List<dynamic> rawList = jsonResponse['data'][1];
          return rawList.map((item) => BpsPressRelease.fromJson(item)).toList();
        }
      }
    } catch (e) { print("Error BRS: $e"); }
    return [];
  }

  // --- 6. BERITA ---
  Future<NewsListResponse?> getNews({
    String lang = 'ind', 
    int page = 1, 
    String? newscat, 
    int? month, 
    int? year, 
    String? keyword 
  }) async {
    try {
      String url = "$_baseUrl/list/model/news/lang/$lang/domain/$_domain/page/$page/key/$_apiKey/";
      if (newscat != null) url += "newscat/${Uri.encodeComponent(newscat)}/";
      if (month != null) url += "month/$month/";
      if (year != null) url += "year/$year/";
      if (keyword != null && keyword.isNotEmpty) url += "keyword/${Uri.encodeComponent(keyword)}/";

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == "OK" && jsonResponse['data-availability'] == "available") {
          return NewsListResponse.fromJson(jsonResponse);
        }
      }
    } catch (e) { print("Error News: $e"); }
    return null;
  }

  // --- 7. INFOGRAFIS ---
  Future<List<BpsInfografis>> getInfografis({String keyword = "", int? year}) async {
    try {
      String url = "$_baseUrl/list/model/infographic/lang/ind/domain/$_domain/page/1/key/$_apiKey/";
      if (year != null) url += "year/$year/";
      if (keyword.isNotEmpty) url += "keyword/${Uri.encodeComponent(keyword)}/";

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == "OK" && json['data-availability'] == "available" && json['data'].length > 1) {
          return (json['data'][1] as List).map((e) => BpsInfografis.fromJson(e)).toList();
        }
      }
    } catch (e) { print("Error Info: $e"); }
    return [];
  }

  // --- 8. TABEL STATIS ---
  Future<List<BpsTabel>> getTabel({String keyword = "", int? year}) async {
    try {
      String url = "$_baseUrl/list/model/statictable/lang/ind/domain/$_domain/page/1/key/$_apiKey/";
      if (year != null) url += "year/$year/";
      if (keyword.isNotEmpty) url += "keyword/${Uri.encodeComponent(keyword)}/";
      
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == "OK" && json['data-availability'] == "available" && json['data'].length > 1) {
          return (json['data'][1] as List).map((e) => BpsTabel.fromJson(e)).toList();
        }
      }
    } catch (e) { print("Error Tabel: $e"); }
    return [];
  }

  // --- 9. DETAIL DATA ---
  Future<BpsDetailTabel?> getDetailTabel(String id) async {
    try {
      String url = "https://webapi.bps.go.id/v1/api/view/model/statictable/lang/ind/domain/$_domain/id/$id/key/$_apiKey/";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == "OK" && json['data-availability'] == "available") return BpsDetailTabel.fromJson(json['data']);
      }
    } catch (e) { print("Error Detail: $e"); }
    return null;
  }

  Future<BpsNewsDetail?> getNewsDetail(int newsId, {String lang = 'ind'}) async {
    try {
      String url = "$_baseUrl/view/model/news/lang/$lang/domain/$_domain/id/$newsId/key/$_apiKey/";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == "OK" && json['data-availability'] == "available") return BpsNewsDetail.fromJson(json['data']);
      }
    } catch (e) { print("Error News Detail: $e"); }
    return null;
  }
}