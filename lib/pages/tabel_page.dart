import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../services/bps_model.dart';
import 'detail_tabel_page.dart';

class TabelPage extends StatefulWidget {
  const TabelPage({super.key, this.initialCategory});

  final String? initialCategory;

  @override
  State<TabelPage> createState() => _TabelPageState();
}

class _TabelPageState extends State<TabelPage> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  
  List<BpsTabel> _listTabel = [];
  bool _isLoading = true;
  String _errorMessage = "";
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  final List<String> _categories = [
    'Semua',
    'Demografi & Sosial',
    'Ekonomi',
    'Lingkungan'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(_handleTabSelection);

    if (widget.initialCategory != null) {
      final index = _categories.indexOf(widget.initialCategory!);
      if (index != -1) {
        _tabController.index = index;
      }
    }

    _fetchDataByTab();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      _fetchDataByTab();
    }
  }

  String _getKeywordForCategory(int index) {
    switch (index) {
      case 0: return ""; // Semua
      case 1: return "penduduk"; // Demografi
      case 2: return "produksi"; // Ekonomi
      case 3: return "luas";     // Lingkungan
      default: return "";
    }
  }

  void _fetchDataByTab() {
    _searchController.clear();
    String autoKeyword = _getKeywordForCategory(_tabController.index);
    _fetchData(keyword: autoKeyword);
  }

  void _fetchData({String keyword = ""}) async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = "";
      _listTabel = [];
    });

    try {
      final data = await _apiService.getTabel(keyword: keyword);

      if (mounted) {
        setState(() {
          _listTabel = data;
          _isLoading = false;
          
          if (data.isEmpty) {
            _errorMessage = "Tidak ada data ditemukan untuk kategori ini.";
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Tabel Statistik",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: theme.brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark ? const Color(0xFF2A2A2A) : Colors.grey[100],
              borderRadius: BorderRadius.circular(25),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicator: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(25),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: theme.brightness == Brightness.dark ? Colors.grey[300] : Colors.grey[700],
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
              padding: EdgeInsets.zero,
              tabs: _categories.map((category) => Tab(
                text: category,
                height: 36,
              )).toList(),
            ),
          ),
        ),
      ),
      body: Container(
        color: theme.brightness == Brightness.dark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        child: Column(
          children: [
            // Search Bar
            Container(
              margin: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark ? const Color(0xFF2A2A2A) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.3 : 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (value) => _fetchData(keyword: value),
                      style: TextStyle(
                        color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: "Cari data spesifik...",
                        hintStyle: TextStyle(
                          color: theme.brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[500],
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: theme.brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[500],
                        ),
                        filled: false,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => _fetchData(keyword: _searchController.text),
                      icon: const Icon(Icons.arrow_forward, color: Colors.white),
                      iconSize: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Content List
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
                  : _listTabel.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.folder_off_outlined, size: 60, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage.isNotEmpty ? _errorMessage : "Data tidak ditemukan",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 20),
                              OutlinedButton.icon(
                                onPressed: () => _fetchDataByTab(),
                                icon: const Icon(Icons.refresh),
                                label: const Text("Muat Ulang"),
                              )
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        // PERBAIKAN: Menambahkan bottom padding agar list terakhir tidak ketutup footer
                        padding: const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 100),
                        itemCount: _listTabel.length,
                        itemBuilder: (context, index) {
                          final item = _listTabel[index];
                          return _buildModernTableItem(context, item);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTableItem(BuildContext context, BpsTabel item) {
    final theme = Theme.of(context);

    IconData getCategoryIcon() {
      final title = item.title.toLowerCase();
      if (title.contains('penduduk') || title.contains('ipm')) return Icons.people_outline;
      if (title.contains('ekonomi') || title.contains('pdrb') || title.contains('produksi')) return Icons.trending_up;
      if (title.contains('pertanian') || title.contains('padi')) return Icons.agriculture_outlined;
      return Icons.table_chart_rounded;
    }

    Color getCategoryColor() {
      final title = item.title.toLowerCase();
      if (title.contains('penduduk')) return Colors.blue;
      if (title.contains('ekonomi') || title.contains('produksi')) return Colors.green;
      if (title.contains('pertanian')) return Colors.orange;
      return theme.primaryColor;
    }

    final categoryColor = getCategoryColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.3 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailTabelPage(
                  tableId: item.tableId,
                  title: item.title,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(getCategoryIcon(), color: categoryColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            "Update: ${item.updateDate}",
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}