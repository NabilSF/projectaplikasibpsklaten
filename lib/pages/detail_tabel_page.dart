import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_services.dart';
import '../services/bps_model.dart';
import '../main.dart'; // Import untuk navigasi persistent

class DetailTabelPage extends StatefulWidget {
  final String tableId;
  final String title; // Judul dari halaman sebelumnya

  const DetailTabelPage({super.key, required this.tableId, required this.title});

  @override
  State<DetailTabelPage> createState() => _DetailTabelPageState();
}

class _DetailTabelPageState extends State<DetailTabelPage> {
  final ApiService _apiService = ApiService();
  BpsDetailTabel? _detailData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  void _fetchDetail() async {
    final data = await _apiService.getDetailTabel(widget.tableId);
    if (mounted) {
      setState(() {
        _detailData = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadFile() async {
    if (_detailData == null || _detailData!.excelUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Link download tidak tersedia")));
      return;
    }
    final Uri url = Uri.parse(_detailData!.excelUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal membuka link")));
    }
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Rincian Tabel", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => closeDetailPage(),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
          : _detailData == null
              ? const Center(child: Text("Gagal memuat detail data"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul Tabel
                      Text(
                        _detailData!.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Terakhir diperbarui: ${_detailData!.updateDate}",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const Divider(height: 30),

                      // Info message
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.table_chart,
                              size: 48,
                              color: Colors.blue[600],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Data tabel tersedia dalam format Excel",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Untuk melihat detail data tabel, silakan unduh file Excel di bawah ini.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Tombol Download - Hanya tampil jika ada link Excel
                      if (_detailData != null && _detailData!.excelUrl.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            onPressed: _downloadFile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 4,
                            ),
                            icon: const Icon(Icons.download_rounded),
                            label: const Text("Unduh Excel", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }
}