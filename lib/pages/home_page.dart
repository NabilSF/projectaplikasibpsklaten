import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import 'infografis_page.dart';
import 'berita_page.dart';
import 'brs_page.dart'; 
import '../services/api_services.dart';
import '../services/bps_model.dart';

// --- IMPORT HALAMAN DETAIL ---
import 'berita_detail_page.dart';
import 'brs_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// 1. TAMBAHKAN MIXIN INI UNTUK ANIMASI
class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  
  List<BpsPublikasi> _latestPublikasi = [];
  List<BpsIndicator> _strategicIndicators = []; 
  List<BpsInfografis> _recommendedInfografis = [];
  List<BpsNews> _latestNews = []; 
  List<BpsPressRelease> _latestPressReleases = [];
  
  bool _isLoading = true;

  // --- VARIABEL ANIMASI ---
  late AnimationController _animController;
  late Animation<Offset> _menuSlideAnim; // Untuk menu putih geser naik
  late Animation<double> _menuFadeAnim;  // Untuk menu putih muncul pelan
  late Animation<Offset> _contentSlideAnim; // Untuk konten bawah geser naik
  late Animation<double> _contentFadeAnim;  // Untuk konten bawah muncul pelan

  @override
  void initState() {
    super.initState();

    // 2. INISIALISASI ANIMASI (WAJIB DI ATAS _fetchAllData)
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Durasi 1.5 detik biar smooth
    );

    // Animasi Menu Putih (Muncul duluan)
    _menuSlideAnim = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic)),
    );
    _menuFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );

    // Animasi Konten Bawah (Muncul belakangan/Staggered)
    _contentSlideAnim = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic)),
    );
    _contentFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.3, 1.0, curve: Curves.easeOut)),
    );

    // Jalankan Animasi
    _animController.forward();

    // 3. AMBIL DATA
    _fetchAllData();
  }

  @override
  void dispose() {
    _animController.dispose(); // Jangan lupa dispose controller
    super.dispose();
  }

  // --- PERBAIKAN FETCH DATA (ANTI RED SCREEN) ---
  void _fetchAllData() async {
    setState(() => _isLoading = true);

    try {
      // Kita panggil satu-satu dengan await biasa agar lebih aman daripada Future.wait
      // Jika satu error, aplikasi TIDAK AKAN CRASH layar merah.
      
      final publikasi = await _apiService.getPublikasi().catchError((_) => <BpsPublikasi>[]);
      final indikator = await _apiService.getStrategicIndicators().catchError((_) => <BpsIndicator>[]);
      final infografis = await _apiService.getInfografis().catchError((_) => <BpsInfografis>[]);
      final newsResponse = await _apiService.getNews().catchError((_) => null);
      final pressReleases = await _apiService.getPressReleases().catchError((_) => <BpsPressRelease>[]);

      if (mounted) {
        setState(() {
          _latestPublikasi = publikasi.take(3).toList();
          _strategicIndicators = indikator;
          _recommendedInfografis = infografis.take(3).toList();
          _latestNews = newsResponse?.news.take(3).toList() ?? [];
          _latestPressReleases = pressReleases.take(3).toList();
          
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching home data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- HELPER FUNCTIONS ---
  String _constructImageUrl(String imageUrl) {
    if (imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http')) return imageUrl;
    return 'https://webapi.bps.go.id/$imageUrl';
  }

  String _cleanHtmlContent(String htmlContent) {
    if (htmlContent.isEmpty) return "";
    String cleaned = htmlContent
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&#39;', "'");
    final RegExp htmlTagRegex = RegExp(r'<[^>]*>');
    cleaned = cleaned.replaceAll(htmlTagRegex, '');
    return cleaned.trim();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER MODERN (Static) ---
            Stack(
              children: [
                Container(
                  height: 290, 
                  padding: const EdgeInsets.fromLTRB(20, 55, 20, 0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [const Color(0xFF111439), const Color(0xFF0a0f2a)]
                          : [const Color(0xFF111439), const Color(0xFF1a1f4a)],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Lokasi Data", style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))),
                                  const Text("BPS Kab. Klaten", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () => themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark,
                            icon: Icon(isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round, color: Colors.white),
                            style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.1)),
                          )
                        ],
                      ),
                      
                      const SizedBox(height: 30), 

                      // Welcome Message (Fade In Dikit)
                      FadeTransition(
                        opacity: _menuFadeAnim,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Selamat Datang",
                              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, height: 1.1),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 280, 
                              child: Text(
                                "Temukan data statistik terpercaya untuk Kabupaten Klaten",
                                style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.9), height: 1.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // --- MENU GRID FLOATING (ANIMATED: Slide Up & Fade In) ---
            SlideTransition(
              position: _menuSlideAnim,
              child: FadeTransition(
                opacity: _menuFadeAnim,
                child: Transform.translate(
                  offset: const Offset(0, -40), 
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10), 
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25), 
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface, 
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.08), blurRadius: 20, offset: const Offset(0, 10))
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCompactMenuBtn(context, Icons.menu_book_rounded, "Publikasi", const Color(0xFF4CAF50), () {
                            selectedIndexNotifier.value = 3;
                          }),
                          _buildCompactMenuBtn(context, Icons.backup_table_rounded, "Tabel", const Color(0xFF009688), () {
                            selectedIndexNotifier.value = 1;
                          }),
                          _buildCompactMenuBtn(context, Icons.add_circle_outline, "Request Data", const Color(0xFF2196F3), () async {
                            const url = 'https://klatenkab.bps.go.id'; 
                            final Uri uri = Uri.parse(url);
                            if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal membuka link")));
                            }
                          }),
                          _buildCompactMenuBtn(context, Icons.pie_chart_rounded, "Infografis", const Color(0xFF9C27B0), () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const InfografisPage()));
                          }),
                          _buildCompactMenuBtn(context, Icons.article_rounded, "BRS", const Color(0xFFFF9800), () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const BrsPage()));
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // --- KONTEN BAWAH (ANIMATED STAGGERED: Muncul Belakangan) ---
            SlideTransition(
              position: _contentSlideAnim,
              child: FadeTransition(
                opacity: _contentFadeAnim,
                child: Transform.translate(
                  offset: const Offset(0, -20), 
                  child: Column(
                    children: [
                      // --- DASHBOARD INDIKATOR ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Dashboard Klaten", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            
                            SizedBox(
                              height: 150,
                              child: _isLoading 
                                ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
                                : _strategicIndicators.isEmpty 
                                  ? const Center(child: Text("Data Dashboard Tidak Tersedia"))
                                  : ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _strategicIndicators.length,
                                      itemBuilder: (context, index) {
                                        return _buildDashboardCard(context, _strategicIndicators[index]);
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // --- PUBLIKASI ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Publikasi Terbaru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                TextButton(
                                  onPressed: () {
                                    selectedIndexNotifier.value = 3;
                                  },
                                  child: const Text("Lihat Semua", style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            
                            _isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _latestPublikasi.length,
                                    padding: EdgeInsets.zero,
                                    itemBuilder: (context, index) => _buildModernItem(context, _latestPublikasi[index]),
                                  ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --- INFOGRAFIS ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Infografis Pilihan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const InfografisPage()));
                                  },
                                  child: const Text("Lihat Semua", style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            
                            _isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : _recommendedInfografis.isEmpty
                                  ? const Padding(padding: EdgeInsets.all(20), child: Text("Tidak ada infografis"))
                                  : SizedBox(
                                      height: 220,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: _recommendedInfografis.length,
                                        itemBuilder: (context, index) => _buildInfografisItem(context, _recommendedInfografis[index]),
                                      ),
                                    ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --- BERITA BPS ---
                      if (_latestNews.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Berita BPS Klaten", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const BeritaPage()));
                                    },
                                    child: const Text("Lihat Semua", style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _latestNews.length,
                                padding: EdgeInsets.zero,
                                itemBuilder: (context, index) => _buildNewsItem(context, _latestNews[index]),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),

                      // --- PRESS RELEASE ---
                      if (_latestPressReleases.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const BrsPage()));
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Berita Resmi Statistik", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    Text("Lihat Semua", style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _latestPressReleases.length,
                                padding: EdgeInsets.zero,
                                itemBuilder: (context, index) => _buildPressReleaseItem(context, _latestPressReleases[index]),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 80), 
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildDashboardCard(BuildContext context, BpsIndicator data) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    IconData iconData = Icons.analytics_outlined;
    Color iconColor = Colors.blue;
    if (data.title.toLowerCase().contains("miskin")) { iconData = Icons.monetization_on_outlined; iconColor = Colors.red; }
    else if (data.title.toLowerCase().contains("manusia") || data.title.toLowerCase().contains("ipm")) { iconData = Icons.people_outline; iconColor = Colors.orange; }
    else if (data.title.toLowerCase().contains("pengangguran")) { iconData = Icons.work_outline; iconColor = Colors.purple; }
    else if (data.title.toLowerCase().contains("ekonomi")) { iconData = Icons.trending_up; iconColor = Colors.green; }

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12, bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(iconData, color: iconColor, size: 28),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text("Terbaru", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${data.value} ${data.unit}",
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF111439)
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                data.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCompactMenuBtn(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(10), 
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22), 
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label, 
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildModernItem(BuildContext context, BpsPublikasi item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            if (item.pdf.isNotEmpty) {
              final Uri url = Uri.parse(item.pdf);
              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal membuka link")));
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: theme.primaryColor.withOpacity(0.1),
                    image: item.cover.isNotEmpty
                        ? DecorationImage(image: NetworkImage(item.cover), fit: BoxFit.cover)
                        : null,
                  ),
                  child: item.cover.isEmpty
                      ? Icon(Icons.book, color: theme.primaryColor, size: 30)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(item.rlDate, style: TextStyle(fontSize: 10, color: theme.primaryColor, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, height: 1.3),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.download_rounded, size: 16, color: theme.primaryColor),
                          const SizedBox(width: 4),
                          Text("PDF (${item.size})", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.primaryColor)),
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

  Widget _buildInfografisItem(BuildContext context, BpsInfografis item) {
    final theme = Theme.of(context);
    
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                image: item.img.isNotEmpty
                    ? DecorationImage(image: NetworkImage(item.img), fit: BoxFit.cover)
                    : null,
                color: Colors.grey[200],
              ),
              child: item.img.isEmpty ? const Center(child: Icon(Icons.image, color: Colors.grey)) : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsItem(BuildContext context, BpsNews item) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(item.rlDate, style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color)),
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[400]),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BeritaDetailPage(newsId: item.newsId),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPressReleaseItem(BuildContext context, BpsPressRelease item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16), 
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 10, offset: const Offset(0, 4))
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
                builder: (context) => BrsDetailPage(brsId: item.brsId),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80, 
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: item.cover.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _constructImageUrl(item.cover),
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Icon(Icons.bar_chart, color: theme.primaryColor, size: 30),
                          ),
                        )
                      : Icon(Icons.bar_chart, color: theme.primaryColor, size: 30),
                ),
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.rlDate, 
                        style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _cleanHtmlContent(item.title),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}