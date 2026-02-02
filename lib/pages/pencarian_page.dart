import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_services.dart';
import '../services/bps_model.dart';

// Import halaman detail
import 'berita_detail_page.dart';
import 'brs_detail_page.dart';
import 'detail_tabel_page.dart'; 

class PencarianPage extends StatefulWidget {
  const PencarianPage({super.key});

  @override
  State<PencarianPage> createState() => _PencarianPageState();
}

class _PencarianPageState extends State<PencarianPage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  // --- DATA SOURCE (MASTER) ---
  List<BpsPublikasi> _allPublikasi = [];
  List<BpsTabel> _allTabel = [];
  List<BpsInfografis> _allInfografis = [];
  List<BpsNews> _allNews = [];
  List<BpsPressRelease> _allPressReleases = [];

  // --- HASIL FILTER ---
  List<BpsPublikasi> _filteredPublikasi = [];
  List<BpsTabel> _filteredTabel = [];
  List<BpsInfografis> _filteredInfografis = [];
  List<BpsNews> _filteredNews = [];
  List<BpsPressRelease> _filteredPressReleases = [];

  bool _isLoading = true;
  String _searchQuery = "";

  // --- STATE FILTER ---
  String? _selectedCategory; 
  int? _selectedYear; 

  // PERBAIKAN NAMA KATEGORI DI SINI
  final List<String> _categories = [
    'Publikasi', 'Tabel', 'Infografis', 'Berita', 'Berita Resmi Statistik'
  ];
  
  final List<int> _years = List.generate(11, (index) => 2026 - index); 

  @override
  void initState() {
    super.initState();
    _fetchAllDataSafely();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filterData();
    });
  }

  Future<void> _fetchAllDataSafely() async {
    setState(() => _isLoading = true);

    try {
      final publikasi = await _apiService.getPublikasi().catchError((_) => <BpsPublikasi>[]);
      final tabel = await _apiService.getTabel().catchError((_) => <BpsTabel>[]);
      final infografis = await _apiService.getInfografis().catchError((_) => <BpsInfografis>[]);
      final newsResponse = await _apiService.getNews().catchError((_) => null);
      final pressReleases = await _apiService.getPressReleases().catchError((_) => <BpsPressRelease>[]);

      if (mounted) {
        setState(() {
          _allPublikasi = publikasi;
          _allTabel = tabel;
          _allInfografis = infografis;
          _allNews = newsResponse?.news ?? [];
          _allPressReleases = pressReleases;
          
          _isLoading = false;
        });
        _filterData(); 
      }
    } catch (e) {
      debugPrint("Global Error fetching data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- LOGIKA FILTER DATA ---
  void _filterData() {
    setState(() {
      // 1. Filter Publikasi
      if (_selectedCategory == null || _selectedCategory == 'Publikasi') {
        _filteredPublikasi = _allPublikasi.where((item) {
          final matchText = item.title.toLowerCase().contains(_searchQuery);
          final matchYear = _selectedYear == null || item.rlDate.contains(_selectedYear.toString());
          return matchText && matchYear;
        }).toList();
      } else {
        _filteredPublikasi = [];
      }

      // 2. Filter Tabel
      if (_selectedCategory == null || _selectedCategory == 'Tabel') {
        _filteredTabel = _allTabel.where((item) {
          final matchText = item.title.toLowerCase().contains(_searchQuery);
          final matchYear = _selectedYear == null || item.updateDate.contains(_selectedYear.toString());
          return matchText && matchYear;
        }).toList();
      } else {
        _filteredTabel = [];
      }

      // 3. Filter Infografis
      if (_selectedCategory == null || _selectedCategory == 'Infografis') {
        _filteredInfografis = _allInfografis.where((item) {
          final matchText = item.title.toLowerCase().contains(_searchQuery) || item.desc.toLowerCase().contains(_searchQuery);
          return matchText; 
        }).toList();
      } else {
        _filteredInfografis = [];
      }

      // 4. Filter Berita
      if (_selectedCategory == null || _selectedCategory == 'Berita') {
        _filteredNews = _allNews.where((item) {
          final matchText = item.title.toLowerCase().contains(_searchQuery);
          final matchYear = _selectedYear == null || item.rlDate.contains(_selectedYear.toString());
          return matchText && matchYear;
        }).toList();
      } else {
        _filteredNews = [];
      }

      // 5. Filter Berita Resmi Statistik (BRS) -> PERBAIKAN LOGIKA DISINI
      if (_selectedCategory == null || _selectedCategory == 'Berita Resmi Statistik') {
        _filteredPressReleases = _allPressReleases.where((item) {
          final matchText = item.title.toLowerCase().contains(_searchQuery);
          final matchYear = _selectedYear == null || item.rlDate.contains(_selectedYear.toString());
          return matchText && matchYear;
        }).toList();
      } else {
        _filteredPressReleases = [];
      }
    });
  }

  // --- MODAL FILTER UI ---
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
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Filter Pencarian", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedCategory = null;
                            _selectedYear = null;
                          });
                        },
                        child: const Text("Reset", style: TextStyle(color: Colors.red)),
                      )
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 10),

                  // Kategori
                  const Text("Kategori Data", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: Theme.of(context).primaryColor,
                        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedCategory = selected ? cat : null;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Tahun
                  const Text("Tahun", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
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
                          onSelected: (selected) {
                            setModalState(() {
                              _selectedYear = selected ? year : null;
                            });
                          },
                        );
                      },
                    ),
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _filterData(); 
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

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal membuka link")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: const Text("Pencarian", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Search Bar & Filter
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                      decoration: const InputDecoration(
                        hintText: "Ketik kata kunci...",
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.tune, color: Colors.white),
                    onPressed: _showFilterModal, 
                  ),
                ),
              ],
            ),
          ),

          // Chip Filter Aktif
          if (_selectedCategory != null || _selectedYear != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
              child: Row(
                children: [
                  const Text("Filter: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  if (_selectedCategory != null)
                    _buildActiveChip(_selectedCategory!),
                  if (_selectedYear != null)
                    _buildActiveChip("Tahun $_selectedYear"),
                  
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = null;
                        _selectedYear = null;
                        _filterData();
                      });
                    },
                    child: const Text("Hapus", style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),

          // List Hasil
          Expanded(
            child: _isLoading
              ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
              : _buildResultsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveChip(String label) {
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

  Widget _buildResultsList() {
    final hasResults = _filteredPublikasi.isNotEmpty ||
                       _filteredTabel.isNotEmpty ||
                       _filteredInfografis.isNotEmpty ||
                       _filteredNews.isNotEmpty ||
                       _filteredPressReleases.isNotEmpty;

    if (!hasResults) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? "Cari data statistik..." : "Tidak ada hasil ditemukan",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        if (_filteredPublikasi.isNotEmpty) _buildSection("Publikasi", _filteredPublikasi, _buildPublikasiItem),
        if (_filteredTabel.isNotEmpty) _buildSection("Tabel Statis", _filteredTabel, _buildTabelItem),
        // PERBAIKAN NAMA SECTION
        if (_filteredPressReleases.isNotEmpty) _buildSection("Berita Resmi Statistik", _filteredPressReleases, _buildPressReleaseItem),
        if (_filteredNews.isNotEmpty) _buildSection("Berita", _filteredNews, _buildNewsItem),
        if (_filteredInfografis.isNotEmpty) _buildSection("Infografis", _filteredInfografis, _buildInfografisItem),
      ],
    );
  }

  Widget _buildSection<T>(String title, List<T> items, Widget Function(T) itemBuilder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            "$title (${items.length})",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...items.map(itemBuilder),
        const Divider(),
      ],
    );
  }

  // --- ITEM WIDGETS ---

  Widget _buildPublikasiItem(BpsPublikasi item) {
    return ListTile(
      leading: Container(
        width: 40, height: 60,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          image: item.cover.isNotEmpty ? DecorationImage(image: NetworkImage(item.cover.startsWith('http') ? item.cover : 'https://webapi.bps.go.id/${item.cover}'), fit: BoxFit.cover) : null,
        ),
        child: item.cover.isEmpty ? const Icon(Icons.book, color: Colors.blue) : null,
      ),
      title: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      subtitle: Text(item.rlDate, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      onTap: () {
        if(item.pdf.isNotEmpty) _launchUrl(item.pdf);
      },
    );
  }

  Widget _buildTabelItem(BpsTabel item) {
    return ListTile(
      leading: const Icon(Icons.table_chart, color: Colors.green),
      title: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      subtitle: Text("Update: ${item.updateDate}", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => DetailTabelPage(tableId: item.tableId, title: item.title)));
      },
    );
  }

  Widget _buildInfografisItem(BpsInfografis item) {
    return ListTile(
      leading: Container(
        width: 50, height: 50,
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          image: item.img.isNotEmpty ? DecorationImage(image: NetworkImage(item.img), fit: BoxFit.cover) : null,
        ),
        child: item.img.isEmpty ? const Icon(Icons.image, color: Colors.purple) : null,
      ),
      title: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      onTap: () {},
    );
  }

  Widget _buildNewsItem(BpsNews item) {
    return ListTile(
      leading: const Icon(Icons.article, color: Colors.orange),
      title: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      subtitle: Text(item.rlDate, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => BeritaDetailPage(newsId: item.newsId)));
      },
    );
  }

  Widget _buildPressReleaseItem(BpsPressRelease item) {
    return ListTile(
      leading: const Icon(Icons.newspaper, color: Colors.red),
      title: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      subtitle: Text(item.rlDate, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => BrsDetailPage(brsId: item.brsId)));
      },
    );
  }
}