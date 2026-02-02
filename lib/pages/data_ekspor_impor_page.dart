import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DataEksporImporPage extends StatefulWidget {
  const DataEksporImporPage({super.key});

  @override
  State<DataEksporImporPage> createState() => _DataEksporImporPageState();
}

class _DataEksporImporPageState extends State<DataEksporImporPage> {
  // --- KONFIGURASI API ---
  // Ganti dengan API Key BPS kamu
  final String apiKey = "ef7be0f3321be69126d2cfaff9e4a67f";
  // Domain 3310 adalah kode BPS Klaten (Sesuaikan jika perlu)
  final String domain = "3310"; 
  
  // State untuk Tab (0 = Ekspor, 1 = Impor)
  int _selectedTab = 0; // 0: Ekspor, 1: Impor

  // State Form
  String? _selectedAgregasi;
  String? _selectedTahun;
  String? _selectedBulan;
  
  // Controller untuk input text
  final TextEditingController _kodeHsController = TextEditingController(text: "Semua Kode HS");
  final TextEditingController _negaraController = TextEditingController(text: "Semua Negara");
  final TextEditingController _pelabuhanController = TextEditingController(text: "Semua Pelabuhan");

  // State Data Hasil API
  bool _isLoading = false;
  Map<String, dynamic>? _apiResult;
  String? _errorMessage;

  // --- FUNGSI API ---
  // Mengacu pada Documentation: Dynamic Data (https://webapi.bps.go.id/v1/api/list)
  Future<void> fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _apiResult = null;
    });

    try {
      // Contoh Variable ID (Harus disesuaikan dengan ID variable Ekspor/Impor di domainmu)
      // Kamu bisa mencari ID ini menggunakan endpoint "List Variable"
      String varId = _selectedTab == 0 ? "111" : "222"; // 111 misal ID Ekspor, 222 ID Impor

      // Membangun URL sesuai dokumentasi
      final Uri url = Uri.parse(
        "https://webapi.bps.go.id/v1/api/list"
        "?model=data"
        "&domain=$domain"
        "&var=$varId" // Variable ID (Wajib)
        "&th=${_selectedTahun ?? '1'}" // Tahun (Period Data ID)
        "&turth=${_selectedBulan ?? ''}" // Bulan (Derived Period Data)
        "&key=$apiKey"
      );

      debugPrint("Calling API: $url");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          setState(() {
            _apiResult = data;
          });
        } else {
          setState(() {
            _errorMessage = "Data tidak tersedia atau parameter salah.";
          });
        }
      } else {
        setState(() {
          _errorMessage = "Error ${response.statusCode}: Gagal mengambil data.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Terjadi kesalahan koneksi: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor; // Mengambil warna dari main.dart
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Ekspor Impor", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- TAB SWITCHER (Ekspor / Impor) ---
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton("Ekspor", 0, primaryColor),
                  ),
                  Expanded(
                    child: _buildTabButton("Impor", 1, primaryColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- FORM INPUT ---
            _buildLabel("Agregasi"),
            _buildDropdown(
              value: _selectedAgregasi,
              hint: "Pilih Agregasi",
              items: ["Bulanan", "Tahunan"],
              onChanged: (val) => setState(() => _selectedAgregasi = val),
            ),

            _buildLabel("Tahun"),
            _buildDropdown(
              value: _selectedTahun,
              hint: "Tidak ada Tahun terpilih",
              items: ["2023", "2024", "2025"], // Nanti bisa fetch dari API 'List Period Data'
              onChanged: (val) => setState(() => _selectedTahun = val),
            ),

            _buildLabel("Kode HS"),
            _buildReadOnlyField(_kodeHsController),

            _buildLabel("Negara"),
            _buildReadOnlyField(_negaraController),

            _buildLabel("Pelabuhan"),
            _buildReadOnlyField(_pelabuhanController),

            _buildLabel("Bulan"),
            _buildDropdown(
              value: _selectedBulan,
              hint: "Semua Bulan",
              items: ["Januari", "Februari", "Maret", "April", "Mei"], // Nanti fetch API 'List Derived Period'
              onChanged: (val) => setState(() => _selectedBulan = val),
            ),

            _buildLabel("Urutan Tampilan"),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text("Kode HS, Negara, Pelabuhan, Tahun...", style: TextStyle(fontSize: 14)),
            ),

            const SizedBox(height: 32),

            // --- SUBMIT BUTTON ---
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : fetchData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5), // Warna biru tombol sesuai gambar
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                  : const Text("Submit", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 24),

            // --- HASIL DATA ---
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ),

            if (_apiResult != null)
              _buildResultView(_apiResult!),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildTabButton(String text, int index, Color activeColor) {
    final bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
          border: isSelected ? Border.all(color: Colors.grey.withOpacity(0.2)) : null,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.grey)),
    );
  }

  Widget _buildDropdown({
    required String? value, 
    required String hint, 
    required List<String> items, 
    required Function(String?) onChanged
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: const TextStyle(fontSize: 14)),
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
        ),
      ),
      onTap: () {
        // Logika untuk membuka modal pencarian Kode HS / Negara bisa ditambahkan di sini
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Fitur pencarian detail akan segera hadir!"))
        );
      },
    );
  }

  Widget _buildResultView(Map<String, dynamic> data) {
    // Parsing sederhana data API Dynamic Data
    // Struktur API: data['datacontent'] berisi map ID -> Nilai
    
    final content = data['datacontent'] as Map<String, dynamic>?;
    if (content == null || content.isEmpty) {
      return const Text("Data Kosong");
    }

    // Mengambil metadata label (Contoh sederhana)
    final labelVar = data['var'] != null ? data['var'][0]['label'] : "Data";
    
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Hasil Pencarian:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text("Indikator: $labelVar"),
          const Divider(),
          // Menampilkan list data (Dalam aplikasi nyata, ini harus diparsing lebih rapi berdasarkan vervar/turvar)
          ...content.entries.take(5).map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("ID: ${e.key.substring(0, 4)}..."), // Potong ID agar rapi
                Text("${e.value}", style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}