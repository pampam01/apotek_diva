# Graph Report - apotek_diva  (2026-06-03)

## Corpus Check
- 89 files · ~25,272 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 489 nodes · 464 edges · 73 communities (56 shown, 17 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 8 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `0d7e6dc7`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]
- [[_COMMUNITY_Community 12|Community 12]]
- [[_COMMUNITY_Community 13|Community 13]]
- [[_COMMUNITY_Community 14|Community 14]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 24|Community 24]]
- [[_COMMUNITY_Community 25|Community 25]]
- [[_COMMUNITY_Community 26|Community 26]]
- [[_COMMUNITY_Community 27|Community 27]]
- [[_COMMUNITY_Community 28|Community 28]]
- [[_COMMUNITY_Community 29|Community 29]]
- [[_COMMUNITY_Community 30|Community 30]]
- [[_COMMUNITY_Community 31|Community 31]]
- [[_COMMUNITY_Community 32|Community 32]]
- [[_COMMUNITY_Community 33|Community 33]]
- [[_COMMUNITY_Community 34|Community 34]]
- [[_COMMUNITY_Community 35|Community 35]]
- [[_COMMUNITY_Community 36|Community 36]]
- [[_COMMUNITY_Community 37|Community 37]]
- [[_COMMUNITY_Community 38|Community 38]]
- [[_COMMUNITY_Community 39|Community 39]]
- [[_COMMUNITY_Community 40|Community 40]]
- [[_COMMUNITY_Community 41|Community 41]]
- [[_COMMUNITY_Community 42|Community 42]]
- [[_COMMUNITY_Community 43|Community 43]]
- [[_COMMUNITY_Community 44|Community 44]]
- [[_COMMUNITY_Community 45|Community 45]]
- [[_COMMUNITY_Community 46|Community 46]]
- [[_COMMUNITY_Community 47|Community 47]]
- [[_COMMUNITY_Community 48|Community 48]]
- [[_COMMUNITY_Community 49|Community 49]]
- [[_COMMUNITY_Community 50|Community 50]]
- [[_COMMUNITY_Community 51|Community 51]]
- [[_COMMUNITY_Community 52|Community 52]]
- [[_COMMUNITY_Community 53|Community 53]]
- [[_COMMUNITY_Community 54|Community 54]]
- [[_COMMUNITY_Community 55|Community 55]]
- [[_COMMUNITY_Community 56|Community 56]]
- [[_COMMUNITY_Community 57|Community 57]]

## God Nodes (most connected - your core abstractions)
1. `Create()` - 10 edges
2. `MessageHandler()` - 10 edges
3. `WndProc()` - 9 edges
4. `HWND` - 7 edges
5. `WindowClassRegistrar` - 7 edges
6. `Destroy()` - 7 edges
7. `_MyApplication` - 6 edges
8. `MessageHandler()` - 6 edges
9. `Aplikasi Manajemen Stok Obat Apotek Diva` - 6 edges
10. `wWinMain()` - 5 edges

## Surprising Connections (you probably didn't know these)
- `OnCreate()` --calls--> `RegisterPlugins()`  [INFERRED]
  windows/runner/flutter_window.cpp → windows/flutter/generated_plugin_registrant.cc
- `wWinMain()` --calls--> `CreateAndAttachConsole()`  [INFERRED]
  windows/runner/main.cpp → windows/runner/utils.cpp
- `my_application_activate()` --calls--> `fl_register_plugins()`  [INFERRED]
  linux/runner/my_application.cc → linux/flutter/generated_plugin_registrant.cc
- `main()` --calls--> `my_application_new()`  [INFERRED]
  linux/runner/main.cc → linux/runner/my_application.cc
- `OnCreate()` --calls--> `GetClientArea()`  [INFERRED]
  windows/runner/flutter_window.cpp → windows/runner/win32_window.cpp

## Communities (73 total, 17 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.09
Nodes (32): Point, RECT, OnCreate(), Create(), Destroy(), EnableFullDpiSupportIfAvailable(), GetClientArea(), GetHandle() (+24 more)

### Community 1 - "Community 1"
Cohesion: 0.10
Nodes (20): FlPluginRegistry, fl_register_plugins(), GApplication, gboolean, gchar, GObject, GtkApplication, MyApplicationClass (+12 more)

### Community 3 - "Community 3"
Cohesion: 0.10
Nodes (19): class, DartProject, _In_, _In_opt_, MessageHandler(), wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments() (+11 more)

### Community 4 - "Community 4"
Cohesion: 0.18
Nodes (8): Any, FlutterAppDelegate, Bool, AppDelegate, Bool, AppDelegate, NSApplication, UIApplication

### Community 5 - "Community 5"
Cohesion: 0.12
Nodes (15): build, package:apotek_diva/theme/app_theme.dart, package:flutter/material.dart, _incrementCounter, initializeDateFormatting, main, MaterialApp, MyApp (+7 more)

### Community 6 - "Community 6"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 7 - "Community 7"
Cohesion: 0.29
Nodes (4): RegisterGeneratedPlugins(), FlutterPluginRegistry, NSWindow, MainFlutterWindow

### Community 8 - "Community 8"
Cohesion: 0.29
Nodes (3): RunnerTests, RunnerTests, XCTestCase

### Community 9 - "Community 9"
Cohesion: 0.33
Nodes (5): handle_new_rx_page(), __lldb_init_module(), Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages., SBDebugger, SBFrame

### Community 10 - "Community 10"
Cohesion: 0.40
Nodes (4): images, info, author, version

### Community 11 - "Community 11"
Cohesion: 0.40
Nodes (4): images, info, author, version

### Community 12 - "Community 12"
Cohesion: 0.40
Nodes (4): images, info, author, version

### Community 13 - "Community 13"
Cohesion: 0.40
Nodes (4): package:apotek_diva/main.dart, package:flutter_test/flutter_test.dart, package:flutter/material.dart, main

### Community 24 - "Community 24"
Cohesion: 0.06
Nodes (33): ../models/detail_transaksi_model.dart, ../models/obat_model.dart, ../models/transaksi_model.dart, package:flutter/material.dart, package:intl/intl.dart, ../services/obat_service.dart, ../services/transaksi_service.dart, struk_screen.dart (+25 more)

### Community 25 - "Community 25"
Cohesion: 0.08
Nodes (25): ../models/laporan_model.dart, ../models/obat_model.dart, package:apotek_diva/theme/app_theme.dart, package:flutter/material.dart, package:intl/intl.dart, ../services/laporan_service.dart, ../services/transaksi_service.dart, struk_screen.dart (+17 more)

### Community 26 - "Community 26"
Cohesion: 0.10
Nodes (19): ../models/user_model.dart, package:flutter/material.dart, ../theme/app_theme.dart, ../screens/dashboard_screen.dart, ../screens/laporan_screen.dart, ../screens/stok_obat_screen.dart, ../screens/transaksi_screen.dart, BottomNav (+11 more)

### Community 27 - "Community 27"
Cohesion: 0.12
Nodes (15): form_obat_screen.dart, ../models/obat_model.dart, package:flutter/material.dart, ../services/obat_service.dart, ../widgets/custom_text_field.dart, ../widgets/error_message.dart, ../widgets/loading_widget.dart, build (+7 more)

### Community 28 - "Community 28"
Cohesion: 0.12
Nodes (16): ../models/laporan_model.dart, package:flutter/material.dart, package:intl/intl.dart, ../services/laporan_service.dart, ../theme/app_theme.dart, ../widgets/error_message.dart, ../widgets/loading_widget.dart, login_screen.dart (+8 more)

### Community 29 - "Community 29"
Cohesion: 0.12
Nodes (15): package:flutter/material.dart, ../theme/app_theme.dart, ../widgets/custom_button.dart, ../widgets/custom_text_field.dart, build, Icon, _login, LoginScreen (+7 more)

### Community 30 - "Community 30"
Cohesion: 0.15
Nodes (12): ../models/obat_model.dart, package:flutter/material.dart, ../services/obat_service.dart, ../widgets/custom_button.dart, ../widgets/custom_text_field.dart, build, FormObatScreen, _FormObatScreenState (+4 more)

### Community 31 - "Community 31"
Cohesion: 0.12
Nodes (16): ../models/detail_transaksi_model.dart, package:flutter/material.dart, package:intl/intl.dart, ../theme/app_theme.dart, ../widgets/custom_button.dart, AlertDialog, build, Center (+8 more)

### Community 32 - "Community 32"
Cohesion: 0.22
Nodes (8): Akun Default, Aplikasi Manajemen Stok Obat Apotek Diva, code:bash (flutter pub get), code:bash (flutter run), Fitur, Instalasi Backend (PHP & MySQL), Instalasi Frontend (Flutter), Persyaratan

### Community 33 - "Community 33"
Cohesion: 0.22
Nodes (8): ../models/obat_model.dart, package:flutter/material.dart, package:intl/intl.dart, ../theme/app_theme.dart, build, Card, ObatCard, SizedBox

### Community 34 - "Community 34"
Cohesion: 0.22
Nodes (8): package:flutter/material.dart, ../theme/app_theme.dart, build, Center, Column, Row, SimpleBarChart, SizedBox

### Community 35 - "Community 35"
Cohesion: 0.25
Nodes (7): ../config/api_config.dart, dart:convert, ../models/laporan_model.dart, ../models/obat_model.dart, package:http/http.dart, Exception, LaporanService

### Community 36 - "Community 36"
Cohesion: 0.29
Nodes (6): ../config/api_config.dart, dart:convert, ../models/user_model.dart, package:http/http.dart, AuthService, Exception

### Community 37 - "Community 37"
Cohesion: 0.29
Nodes (6): ../config/api_config.dart, dart:convert, ../models/obat_model.dart, package:http/http.dart, Exception, ObatService

### Community 38 - "Community 38"
Cohesion: 0.29
Nodes (6): ../config/api_config.dart, dart:convert, package:http/http.dart, ../models/pelanggan_model.dart, Exception, PelangganService

### Community 39 - "Community 39"
Cohesion: 0.29
Nodes (6): ../config/api_config.dart, dart:convert, ../models/transaksi_model.dart, package:http/http.dart, Exception, TransaksiService

### Community 40 - "Community 40"
Cohesion: 0.29
Nodes (6): package:flutter/material.dart, build, Center, ErrorMessage, Icon, SizedBox

### Community 41 - "Community 41"
Cohesion: 0.29
Nodes (6): package:flutter/material.dart, ../theme/app_theme.dart, build, Card, InfoCard, SizedBox

### Community 42 - "Community 42"
Cohesion: 0.29
Nodes (6): package:flutter/material.dart, build, Center, CircularProgressIndicator, LoadingWidget, SizedBox

### Community 43 - "Community 43"
Cohesion: 0.40
Nodes (4): package:flutter/material.dart, build, CustomButton, SizedBox

### Community 44 - "Community 44"
Cohesion: 0.40
Nodes (4): package:flutter/material.dart, build, CustomTextField, Padding

### Community 46 - "Community 46"
Cohesion: 0.50
Nodes (3): package:flutter/material.dart, AppTheme, ThemeData

## Knowledge Gaps
- **321 isolated node(s):** `flutter_export_environment.sh script`, `SBFrame`, `SBDebugger`, `UIApplication`, `Any` (+316 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **17 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `OnCreate()` connect `Community 0` to `Community 3`, `Community 45`?**
  _High betweenness centrality (0.005) - this node is a cross-community bridge._
- **What connects `flutter_export_environment.sh script`, `SBFrame`, `SBDebugger` to the rest of the system?**
  _322 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.09388335704125178 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.1 - nodes in this community are weakly interconnected._
- **Should `Community 3` be split into smaller, more focused modules?**
  _Cohesion score 0.09846153846153846 - nodes in this community are weakly interconnected._
- **Should `Community 5` be split into smaller, more focused modules?**
  _Cohesion score 0.125 - nodes in this community are weakly interconnected._
- **Should `Community 24` be split into smaller, more focused modules?**
  _Cohesion score 0.058823529411764705 - nodes in this community are weakly interconnected._