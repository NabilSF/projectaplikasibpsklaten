import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../services/bps_model.dart';
import 'brs_detail_page.dart';

class BrsPage extends StatefulWidget {
  const BrsPage({super.key});

  @override
  State<BrsPage> createState() => _BrsPageState();
}

class _BrsPageState extends State<BrsPage> {
  final ApiService _apiService = ApiService();
  
  List<BpsPressRelease> _pressReleases = [];
  bool _isLoading = true;
  String _errorMessage = "";
  
  final TextEditingController _searchController = TextEditingController();
  
  // --- STATE FILTER ---
  int? _selectedYear;
  int? _selectedMonth;

  // --- PERUBAHAN DI SINI: TAHUN 2026 SAMPAI 2016 ---
  // List.generate(11) artinya membuat 11 item.
  // Rumus (2026 - index) akan menghasilkan: 2026, 2025, 2024 ... 2016.
  final List<int> _years = List.generate(11, (index) => 2026 - index);
  
  // Data Bulan
  final List<String> _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  @override
  void initState() {
    super.initState();
    _fetchPressReleases();
  }

  // Fungsi Fetch Data dengan Filter
  void _fetchPressReleases({String keyword = ""}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      // Panggil API dengan parameter filter
      final pressReleases = await _apiService.getPressReleases(
        keyword: keyword,
        year: _selectedYear,
        month: _selectedMonth
      );

      if (mounted) {
        setState(() {
          _pressReleases = pressReleases;
          _isLoading = false;
          if (pressReleases.isEmpty) {
            _errorMessage = "Tidak ada berita ditemukan.";
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Gagal memuat data. Periksa koneksi internet.";
        });
      }
    }
  }

  // --- TAMPILAN MODAL FILTER ---
  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              height: MediaQuery.of(context).size.height * 0.75, 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle Bar
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Filter Berita", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedYear = null;
                            _selectedMonth = null;
                          });
                        },
                        child: const Text("Reset", style: TextStyle(color: Colors.red)),
                      )
                    ],
                  ),
                  const Divider(),
                  
                  // --- PILIH TAHUN (SCROLL HORIZONTAL) ---
                  const SizedBox(height: 10),
                  const Text("Pilih Tahun", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _years.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final year = _years[index];
                        final isSelected = _selectedYear == year;
                        return ChoiceChip(
                          label: Text("$year"),
                          selected: isSelected,
                          selectedColor: Theme.of(context).primaryColor,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                          backgroundColor: Colors.grey[100],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
                          onSelected: (selected) {
                            setModalState(() => _selectedYear = selected ? year : null);
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- PILIH BULAN (GRID) ---
                  const Text("Pilih Bulan", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: GridView.builder(
                      itemCount: _monthNames.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, 
                        childAspectRatio: 2.5,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        final monthNum = index + 1;
                        final isSelected = _selectedMonth == monthNum;
                        return ChoiceChip(
                          label: Text(_monthNames[index], style: const TextStyle(fontSize: 12)),
                          selected: isSelected,
                          selectedColor: Theme.of(context).primaryColor,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                          backgroundColor: Colors.grey[100],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide.none),
                          onSelected: (selected) {
                            setModalState(() => _selectedMonth = selected ? monthNum : null);
                          },
                        );
                      },
                    ),
                  ),

                  // --- TOMBOL TERAPKAN ---
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); 
                        _fetchPressReleases(keyword: _searchController.text); 
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Terapkan Filter", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, 
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Berita Resmi Statistik",
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  "BPS Kabupaten Klaten",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search & Filter Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (value) => _fetchPressReleases(keyword: value),
                      decoration: InputDecoration(
                        hintText: "Cari BRS...",
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // TOMBOL FILTER
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _showFilterModal, 
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Text("Filter", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            SizedBox(width: 4),
                            Icon(Icons.tune, color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // FILTER AKTIF INDICATOR
          if (_selectedYear != null || _selectedMonth != null)
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Text("Filter Aktif: ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    if (_selectedMonth != null)
                      _buildChip("Bulan: ${_monthNames[_selectedMonth! - 1]}"),
                    if (_selectedYear != null)
                      _buildChip("Tahun: $_selectedYear"),
                    
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedYear = null;
                          _selectedMonth = null;
                        });
                        _fetchPressReleases();
                      },
                      child: const Text("Hapus Semua", style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            ),

          // List Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage, textAlign: TextAlign.center))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: _pressReleases.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final item = _pressReleases[index];
                          return _buildNewsCard(context, item);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.blue)),
    );
  }

  Widget _buildNewsCard(BuildContext context, BpsPressRelease item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BrsDetailPage(brsId: item.brsId),
            ),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                image: item.cover.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(item.cover.startsWith('http') ? item.cover : 'https://webapi.bps.go.id/${item.cover}'),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: item.cover.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bar_chart, color: Colors.orange, size: 30),
                        const SizedBox(height: 4),
                        Text("BRS", style: TextStyle(fontSize: 10, color: Colors.orange[800], fontWeight: FontWeight.bold)),
                      ],
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.rlDate,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}