# TODO: Fix Flutter Analyze Issues

## Warnings to Fix
- [ ] Remove unused variable `isDarkMode` in `lib/main.dart` (line 27)
- [ ] Remove unused variable `isDarkMode` in `lib/pages/lainnya_page.dart` (line 23)
- [ ] Remove unused variable `isDark` in `lib/pages/publikasi_page.dart` (line 71)
- [ ] Remove unused variable `isDark` in `lib/pages/tabel_page.dart` (line 297)
- [ ] Remove unused import `tabel_page.dart` in `lib/pages/home_page.dart` (line 6)
- [ ] Remove unused import `url_launcher` in `lib/pages/press_release_page.dart` (line 2)

## Infos to Consider (Optional)
- Replace `withOpacity` with `withValues` for precision (many instances)
- Remove `print` statements in production code
- Fix `use_build_context_synchronously` warnings
- Fix `library_private_types_in_public_api` in main.dart
- Fix `depend_on_referenced_packages` in database_helper.dart
