import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_services.dart';
import '../services/bps_model.dart';

class RencanaTerbitPage extends StatefulWidget {
  const RencanaTerbitPage({super.key});

  @override
  State<RencanaTerbitPage> createState() => _RencanaTerbitPageState();
}

class _RencanaTerbitPageState extends State<RencanaTerbitPage> {
  final ApiService _apiService = ApiService();
  
  int _selectedTypeIndex = 0; 
  int _selectedMonthIndex = DateTime.now().month; 
  int _selectedYear = DateTime.now().year; 

  List<dynamic> _dataList = [];
  bool _isLoading = true;

  final List<String> _months = [
    "Jan", "Feb", "Mar", "Apr", "Mei", "Jun", 
    "Jul", "Agu", "Sep", "Okt", "Nov", "Des"
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _dataList.clear();
    });

    try {
      if (_selectedTypeIndex == 0) {
        final result = await _apiService.getPublikasi(month: _selectedMonthIndex, year: _selectedYear);
        if(mounted) setState(() => _dataList = result);
      } else {
        final result = await _apiService.getPressReleases(month: _selectedMonthIndex, year: _selectedYear);
        if(mounted) setState(() => _dataList = result);
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _launchUrl(String urlString) async {
    if (urlString.isEmpty) return;
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal membuka link")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FD); 

    // Warna background header (mengambil dari tema AppBar)
    final Color headerColor = Theme.of(context).appBarTheme.backgroundColor ?? primaryColor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Rencana Terbit", style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        backgroundColor: headerColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // BAGIAN HEADER (BIRU)
          Container(
            color: headerColor,
            padding: const EdgeInsets.only(bottom: 15),
            child: Column(
              children: [
                // 1. TYPE SELECTOR (Publikasi / BRS)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 45,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1), // Transparan Putih di atas Biru
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _buildSegmentButton("Publikasi", 0),
                        const SizedBox(width: 4),
                        _buildSegmentButton("BRS", 1),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 15),

                // 2. MONTH SELECTOR (Horizontal)
                SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: _months.length,
                    itemBuilder: (context, index) {
                      final int monthNum = index + 1;
                      final bool isSelected = monthNum == _selectedMonthIndex;
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedMonthIndex = monthNum);
                          _fetchData();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            // PERBAIKAN: Jika dipilih -> Putih, Tidak -> Transparan
                            color: isSelected ? Colors.white : Colors.transparent, 
                            borderRadius: BorderRadius.circular(20),
                            border: isSelected ? null : Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Text(
                            _months[index],
                            style: TextStyle(
                              // PERBAIKAN: Jika dipilih -> Warna Primary (Biru), Tidak -> Putih
                              color: isSelected ? primaryColor : Colors.white.withOpacity(0.7), 
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 13
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 3. CONTENT LIST (PUTIH/ABU)
          Expanded(
            child: _isLoading
              ? Center(child: CircularProgressIndicator(color: primaryColor))
              : _dataList.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    itemCount: _dataList.length,
                    itemBuilder: (context, index) {
                      final item = _dataList[index];
                      return _buildReleaseCard(item, context);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: Segment Button (Switch Publikasi/BRS) ---
  Widget _buildSegmentButton(String label, int index) {
    final bool isSelected = _selectedTypeIndex == index;
    // Warna teks saat aktif mengikuti warna background header (biasanya biru tua)
    final Color activeTextColor = Theme.of(context).primaryColor; 
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTypeIndex = index;
            _dataList.clear(); 
          });
          _fetchData();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected 
              ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))] 
              : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              // PERBAIKAN WARNA TEKS
              color: isSelected ? activeTextColor : Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET: Kartu Rilis ---
  Widget _buildReleaseCard(dynamic item, BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = Theme.of(context).primaryColor;

    String title = "";
    String dateFull = "";
    String url = "";
    String typeLabel = "";

    if (item is BpsPublikasi) {
      title = item.title;
      dateFull = item.rlDate;
      url = item.pdf;
      typeLabel = "Publikasi";
    } else if (item is BpsPressRelease) {
      title = item.title;
      dateFull = item.rlDate;
      url = item.pdf;
      typeLabel = "BRS";
    }

    String dayStr = "?";
    try {
      if (dateFull.isNotEmpty) {
        dayStr = dateFull.split(' ')[0]; 
        if (int.tryParse(dayStr) == null) dayStr = "?";
      }
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _launchUrl(url),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // DATE BADGE FIXED WIDTH
                SizedBox(
                  width: 60, 
                  child: Column(
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dayStr,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: primaryColor,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _months[_selectedMonthIndex - 1],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: primaryColor.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),

                // KONTEN
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        typeLabel.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10, 
                          color: Colors.grey[500], 
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Text(
                        title,
                        maxLines: 2, 
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Icon(Icons.check_circle, size: 14, color: Colors.green[400]),
                          const SizedBox(width: 6),
                          Text(
                            "Telah Rilis",
                            style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                          ),
                          const Spacer(), 
                          Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey[400]),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.calendar_today_rounded, size: 60, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text(
          "Jadwal Kosong",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          "Tidak ada rilis pada bulan ini",
          style: TextStyle(color: Colors.grey[500]),
        ),
      ],
    );
  }
}