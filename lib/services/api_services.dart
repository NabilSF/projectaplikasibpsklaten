import 'dart:convert';
import 'package:http/http.dart' as http;
import 'bps_model.dart';

class ApiService {
  final String _baseUrl = "https://webapi.bps.go.id/v1/api";
  final String _apiKey = "ef7be0f3321be69126d2cfaff9e4a67f"; 
  final String _domain = "3310"; // BPS Kabupaten Klaten

  // 1. FETCH PUBLIKASI (Update: Tambah Parameter Year)
  Future<List<BpsPublikasi>> getPublikasi({String keyword = "", int? year}) async {
    try {
      String url = "$_baseUrl/list/model/publication/lang/ind/domain/$_domain/page/1/key/$_apiKey/";
      
      // Tambahkan filter Tahun
      if (year != null) url += "year/$year/";
      // Tambahkan filter Keyword
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

  // 2. FETCH LIST TABEL (Update: Tambah Parameter Year)
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

  // 3. FETCH INFOGRAFIS (Update: Tambah Parameter Year)
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

  // 5. FETCH NEWS LIST (Update: Parameter Type)
  Future<NewsListResponse?> getNews({
    String lang = 'ind',
    int page = 1,
    String? newscat,
    int? month, // Ubah ke int agar konsisten
    int? year,  // Ubah ke int agar konsisten
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

  // 7. FETCH PRESS RELEASE LIST (Update: Parameter Type)
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

  // 9. FETCH STRATEGIC INDICATORS (DASHBOARD)
  Future<List<BpsIndicator>> getStrategicIndicators() async {
    try {
      String url = "$_baseUrl/list/model/indicators/lang/ind/domain/$_domain/key/$_apiKey/";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == "OK" && jsonResponse['data-availability'] == "available") {
          if (jsonResponse['data'].length > 1) {
            final List<dynamic> rawList = jsonResponse['data'][1];
            List<BpsIndicator> apiData = rawList
                .map((item) => BpsIndicator.fromJson(item))
                .where((item) {
                  final t = item.title.toLowerCase();
                  return t.contains('kemiskinan') || 
                         t.contains('ipm') || 
                         t.contains('manusia') || 
                         t.contains('pengangguran') || 
                         t.contains('pertumbuhan');
                }).toList();
            if (apiData.isNotEmpty) return apiData;
          }
        }
      }
    } catch (e) {
      print("Error Indicators: $e");
    }

    // Fallback Data (Jika API Gagal/Kosong)
    return [
      BpsIndicator(title: "Indeks Pembangunan Manusia (IPM)", value: "78.16", unit: "", change: "+0.57", isPositive: true),
      BpsIndicator(title: "Persentase Penduduk Miskin", value: "11.00", unit: "%", change: "-1.04", isPositive: true),
      BpsIndicator(title: "Tingkat Pengangguran Terbuka (TPT)", value: "3.97", unit: "%", change: "-0.23", isPositive: true),
      BpsIndicator(title: "Laju Pertumbuhan Ekonomi", value: "4.93", unit: "%", change: "+0.01", isPositive: true),
      BpsIndicator(title: "Umur Harapan Hidup (UHH)", value: "77.31", unit: "Tahun", change: "+0.28", isPositive: true),
    ];
  }
}