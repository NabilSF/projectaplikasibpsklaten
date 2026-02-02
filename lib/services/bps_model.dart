class BpsIndicator {
  final int id;
  final String title;
  final String value;
  final String unit;
  final String period; // Kita ganti 'change' dengan 'period' (Tahun/Bulan) karena API menyediakan periode
  final String dataSource;

  BpsIndicator({
    required this.id,
    required this.title,
    required this.value,
    required this.unit,
    required this.period,
    required this.dataSource,
  });

  factory BpsIndicator.fromJson(Map<String, dynamic> json) {
    return BpsIndicator(
      id: int.tryParse(json['indicator_id'].toString()) ?? 0,
      title: json['title'] ?? "",
      value: json['value']?.toString() ?? "-",
      unit: json['unit'] ?? "",
      period: json['period'] ?? "", // Contoh: "2024", "Agustus 2024"
      dataSource: json['data_source'] ?? "",
    );
  }
}

class BpsPublikasi {
  final String pubId;
  final String title;
  final String cover;
  final String pdf;
  final String rlDate;
  final String size;

  BpsPublikasi({
    required this.pubId,
    required this.title,
    required this.cover,
    required this.pdf,
    required this.rlDate,
    required this.size,
  });

  factory BpsPublikasi.fromJson(Map<String, dynamic> json) {
    return BpsPublikasi(
      pubId: json['pub_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      cover: json['cover']?.toString() ?? '',
      pdf: json['pdf']?.toString() ?? '',
      rlDate: json['rl_date']?.toString() ?? '-',
      size: json['size']?.toString() ?? '',
    );
  }
}

class BpsTabel {
  final String tableId;    // Sesuai doc: table_id
  final String title;      // Sesuai doc: title
  final String updateDate; // Sesuai doc: updt_date
  final String excel;      // Sesuai doc: excel
  final String size;       // Sesuai doc: size

  BpsTabel({
    required this.tableId,
    required this.title,
    required this.updateDate,
    required this.excel,
    required this.size,
  });

  factory BpsTabel.fromJson(Map<String, dynamic> json) {
    return BpsTabel(
      tableId: json['table_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Tanpa Judul',
      updateDate: json['updt_date']?.toString() ?? '-',
      excel: json['excel']?.toString() ?? '',
      size: json['size']?.toString() ?? '',
    );
  }
}

class BpsDetailTabel {
  final String tableId;
  final String title;
  final String contentHtml; // Sesuai doc: table (HTML content)
  final String excelUrl;
  final String updateDate;

  BpsDetailTabel({
    required this.tableId,
    required this.title,
    required this.contentHtml,
    required this.excelUrl,
    required this.updateDate,
  });

  factory BpsDetailTabel.fromJson(Map<String, dynamic> json) {
    return BpsDetailTabel(
      tableId: json['table_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      // Field 'table' berisi HTML tabel murni dari BPS
      contentHtml: json['table']?.toString() ?? '<p>Data tidak tersedia</p>',
      excelUrl: json['excel']?.toString() ?? '',
      updateDate: json['updt_date']?.toString() ?? '-',
    );
  }
}

class BpsInfografis {
  final String infId;
  final String title;
  final String img;
  final String dl;
  final String desc;

  BpsInfografis({
    required this.infId,
    required this.title,
    required this.img,
    required this.dl,
    required this.desc,
  });

  factory BpsInfografis.fromJson(Map<String, dynamic> json) {
    return BpsInfografis(
      infId: json['inf_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      img: json['img']?.toString() ?? '',
      dl: json['dl']?.toString() ?? '',
      desc: json['desc']?.toString() ?? '',
    );
  }
}

// News Models
class BpsNews {
  final int newsId;
  final String newscatId;
  final String newscatName;
  final String title;
  final String news;
  final String rlDate;

  BpsNews({
    required this.newsId,
    required this.newscatId,
    required this.newscatName,
    required this.title,
    required this.news,
    required this.rlDate,
  });

  factory BpsNews.fromJson(Map<String, dynamic> json) {
    return BpsNews(
      newsId: json['news_id'] ?? 0,
      newscatId: json['newscat_id']?.toString() ?? '',
      newscatName: json['newscat_name']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      news: json['news']?.toString() ?? '',
      rlDate: json['rl_date']?.toString() ?? '',
    );
  }
}

class BpsNewsDetail {
  final String newsId;
  final String newscatId;
  final String title;
  final String news;
  final String rlDate;
  final String picture;

  BpsNewsDetail({
    required this.newsId,
    required this.newscatId,
    required this.title,
    required this.news,
    required this.rlDate,
    required this.picture,
  });

  factory BpsNewsDetail.fromJson(Map<String, dynamic> json) {
    return BpsNewsDetail(
      newsId: json['news_id']?.toString() ?? '',
      newscatId: json['newscat_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      news: json['news']?.toString() ?? '',
      rlDate: json['rl_date']?.toString() ?? '',
      picture: json['picture']?.toString() ?? '',
    );
  }
}

class BpsNewsCategory {
  final String newscatId;
  final String newscatName;

  BpsNewsCategory({
    required this.newscatId,
    required this.newscatName,
  });

  factory BpsNewsCategory.fromJson(Map<String, dynamic> json) {
    return BpsNewsCategory(
      newscatId: json['newscat_id']?.toString() ?? '',
      newscatName: json['newscat_name']?.toString() ?? '',
    );
  }
}

class NewsListResponse {
  final int page;
  final int pages;
  final int perPage;
  final int count;
  final int total;
  final List<BpsNews> news;

  NewsListResponse({
    required this.page,
    required this.pages,
    required this.perPage,
    required this.count,
    required this.total,
    required this.news,
  });

  factory NewsListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List;
    final meta = data[0] as Map<String, dynamic>;
    final newsList = (data[1] as List).map((item) => BpsNews.fromJson(item)).toList();

    return NewsListResponse(
      page: meta['page'] ?? 0,
      pages: meta['pages'] ?? 0,
      perPage: meta['per_page'] ?? 0,
      count: meta['count'] ?? 0,
      total: meta['total'] ?? 0,
      news: newsList,
    );
  }
}

class BpsPressRelease {
  final String brsId;
  final String title;
  final String abstract;
  final String rlDate;
  final String? updtDate;
  final String pdf;
  final String size;
  final String cover;

  BpsPressRelease({
    required this.brsId,
    required this.title,
    required this.abstract,
    required this.rlDate,
    this.updtDate,
    required this.pdf,
    required this.size,
    required this.cover,
  });

  factory BpsPressRelease.fromJson(Map<String, dynamic> json) {
    return BpsPressRelease(
      brsId: json['brs_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      abstract: json['abstract']?.toString() ?? '',
      rlDate: json['rl_date']?.toString() ?? '',
      updtDate: json['updt_date']?.toString(),
      pdf: json['pdf']?.toString() ?? '',
      size: json['size']?.toString() ?? '',
      cover: json['cover']?.toString() ?? '',
    );
  }
}
