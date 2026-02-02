import 'dart:convert';
import 'package:http/http.dart' as http;
import 'bps_model.dart';

class ApiService {
  // --- VARIABEL UTAMA (JANGAN DIHAPUS) ---
  final String _baseUrl = "https://webapi.bps.go.id/v1/api";
  final String _apiKey = "ef7be0f3321be69126d2cfaff9e4a67f"; 
  final String _domain = "3310"; // BPS Kabupaten Klaten

  // --- LINK GOOGLE SHEET (Untuk Data Strategis) ---
  static const String _googleSheetUrl = "https://docs.google.com/spreadsheets/d/e/2PACX-1vTRg49G1-T4EDHcy1NQ9qHs_gCCvlSwwHd6cF750DqoFxOwOhpR0ecciFLgU7tgLnmcDUJr3XIGpxjz/pub?gid=0&single=true&output=csv";

  // 1. FETCH PUBLIKASI
  Future<List<BpsPublikasi>> getPublikasi({String keyword = "", int? year}) async {
    try {
      String url = "$_baseUrl/list/model/publication/lang/ind/domain/$_domain/page/1/key/$_apiKey/";
      if (year != null) url += "year/$year/";
      if (keyword.isNotEmpty) url += "keyword/${Uri.encodeComponent(keyword)}/";

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == "OK" && 
            jsonResponse['data-availability'] == "available" && 
            jsonResponse['data'].length > 1) {
          
          final List<dynamic> rawList = jsonResponse['data'][1];
          return rawList.map((item) => BpsPublikasi.fromJson(item)).toList();
        }
      }
    } catch (e) {
      print("Error Pub: $e");
    }
    return [];
  }

  // 2. FETCH LIST TABEL
  Future<List<BpsTabel>> getTabel({String keyword = "", int? year}) async {
    try {
      String url = "$_baseUrl/list/model/statictable/lang/ind/domain/$_domain/page/1/key/$_apiKey/";
      if (year != null) url += "year/$year/";
      if (keyword.isNotEmpty) url += "keyword/${Uri.encodeComponent(keyword)}/";

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == "OK" && 
            jsonResponse['data-availability'] == "available" && 
            jsonResponse['data'].length > 1) {
          
          final List<dynamic> rawList = jsonResponse['data'][1];
          return rawList.map((item) => BpsTabel.fromJson(item)).toList();
        }
      }
    } catch (e) {
      print("Error Tabel: $e");
    }
    return [];
  }

  // 3. FETCH INFOGRAFIS
  Future<List<BpsInfografis>> getInfografis({String keyword = "", int? year}) async {
    try {
      String url = "$_baseUrl/list/model/infographic/lang/ind/domain/$_domain/page/1/key/$_apiKey/";
      if (year != null) url += "year/$year/";
      if (keyword.isNotEmpty) url += "keyword/${Uri.encodeComponent(keyword)}/";

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == "OK" && 
            jsonResponse['data-availability'] == "available" && 
            jsonResponse['data'].length > 1) {
          
          final List<dynamic> rawList = jsonResponse['data'][1];
          return rawList.map((item) => BpsInfografis.fromJson(item)).toList();
        }
      }
    } catch (e) {
      print("Error Info: $e");
    }
    return [];
  }

  // 4. FETCH DETAIL TABEL
  Future<BpsDetailTabel?> getDetailTabel(String id) async {
    try {
      String url = "https://webapi.bps.go.id/v1/api/view/model/statictable/lang/ind/domain/$_domain/id/$id/key/$_apiKey/";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == "OK" && jsonResponse['data-availability'] == "available") {
          return BpsDetailTabel.fromJson(jsonResponse['data']);
        }
      }
    } catch (e) {
      print("Error Detail: $e");
    }
    return null;
  }

  // 5. FETCH NEWS LIST
  Future<NewsListResponse?> getNews({
    String lang = 'ind',
    int page = 1,
    String? newscat,
    int? month,
    int? year,
    String? keyword,
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
    } catch (e) {
      print("Error News: $e");
    }
    return null;
  }

  // 6. FETCH NEWS DETAIL
  Future<BpsNewsDetail?> getNewsDetail(int newsId, {String lang = 'ind'}) async {
    try {
      String url = "$_baseUrl/view/model/news/lang/$lang/domain/$_domain/id/$newsId/key/$_apiKey/";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == "OK" && jsonResponse['data-availability'] == "available") {
          return BpsNewsDetail.fromJson(jsonResponse['data']);
        }
      }
    } catch (e) {
      print("Error News Detail: $e");
    }
    return null;
  }

  // 7. FETCH PRESS RELEASE LIST
  Future<List<BpsPressRelease>> getPressReleases({
    int page = 1, 
    String keyword = "", 
    int? year, 
    int? month
  }) async {
    try {
      String url = "$_baseUrl/list/model/pressrelease/lang/ind/domain/$_domain/page/$page/key/$_apiKey/";
      if (month != null) url += "month/$month/";
      if (year != null) url += "year/$year/";
      if (keyword.isNotEmpty) url += "keyword/${Uri.encodeComponent(keyword)}/";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == "OK" && 
            jsonResponse['data-availability'] == "available" && 
            jsonResponse['data'].length > 1) {
          
          final List<dynamic> rawList = jsonResponse['data'][1];
          return rawList.map((item) => BpsPressRelease.fromJson(item)).toList();
        }
      }
    } catch (e) {
      print("Error Press Release: $e");
    }
    return [];
  }

  // 9. FETCH STRATEGIC INDICATORS (DARI SPREADSHEET)
  Future<List<BpsIndicator>> getStrategicIndicators() async {
    // Data cadangan jika internet mati
    final List<BpsIndicator> fallbackData = [
      BpsIndicator(id: 1, title: "Indeks Pembangunan Manusia", value: "78.16", unit: "", period: "2024", dataSource: "BPS Klaten"),
      BpsIndicator(id: 2, title: "Penduduk Miskin", value: "11.00", unit: "%", period: "2024", dataSource: "BPS Klaten"),
    ];

    try {
      final response = await http.get(Uri.parse(_googleSheetUrl));

      if (response.statusCode == 200) {
        List<BpsIndicator> sheetData = [];
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

        if (sheetData.isNotEmpty) {
          return sheetData;
        }
      }
    } catch (e) {
      print("Error Fetching Sheet: $e");
    }
    return fallbackData; 
  }

  // 10. FETCH POPUP PROMO (DARI API BPS - INFOGRAFIS TERBARU)
  // Perbaikan: Fungsi ini sekarang berada DI DALAM class ApiService
  Future<BpsInfografis?> getPopupPromo() async {
    try {
      // Mengambil 1 halaman infografis (terbaru)
      String url = "$_baseUrl/list/model/infographic/lang/ind/domain/$_domain/page/1/key/$_apiKey/";
      
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        // Cek apakah data tersedia
        if (jsonResponse['status'] == "OK" && 
            jsonResponse['data-availability'] == "available" && 
            jsonResponse['data'].length > 1) {
          
          final List<dynamic> rawList = jsonResponse['data'][1];
          
          // Jika ada datanya, ambil yang PERTAMA (Paling Baru)
          if (rawList.isNotEmpty) {
            return BpsInfografis.fromJson(rawList[0]);
          }
        }
      }
    } catch (e) {
      print("Error fetching popup: $e");
    }
    return null;
  }

} // <--- KURUNG KURAWAL INI PENTING! (Menutup Class ApiService)