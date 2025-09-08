import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

// --------- Models ----------
class Player {
  final int id;
  final String name;
  final String imageUrl;
  const Player({required this.id, required this.name, required this.imageUrl});

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Player && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Team {
  final String name;
  final List<Player> members; // ต้องมี 3 คนพอดี
  Team({required this.name, required this.members});
}

// --------- Controller (GetX) ----------
class TeamController extends GetxController {
    var playerName = "Player 1".obs;

  final RxList<Player> all = <Player>[].obs;          // สมาชิกทั้งหมดจาก API
  final RxList<Player> selected = <Player>[].obs;     // สมาชิกที่ถูกเลือก (สูงสุด 3)
  final RxList<Team> teams = <Team>[].obs;            // ทีมที่ถูกสร้าง
  final RxString query = ''.obs;                      // ข้อความค้นหา
  final RxBool loading = false.obs;
  final RxString error = ''.obs;

  List<Player> get filtered {
    final q = query.value.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all.where((p) => p.name.toLowerCase().contains(q)).toList();
  }

  // โหลดจาก PokéAPI (>= 20 รายการ — ใช้ 100)
  Future<void> fetchPlayers() async {
    loading.value = true;
    error.value = '';
    try {
      final uri = Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=100');
      final res = await http.get(uri);
      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}');
      }
      final data = json.decode(res.body) as Map<String, dynamic>;
      final results = (data['results'] as List).cast<Map<String, dynamic>>();

      final list = <Player>[];
      for (final item in results) {
        final url = item['url'] as String;              // .../pokemon/{id}/
        final id = _extractId(url);
        final name = (item['name'] as String).toUpperCase();
        final image =
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
        list.add(Player(id: id, name: name, imageUrl: image));
      }
      all.assignAll(list);
    } catch (e) {
      error.value = 'Load failed: $e';
    } finally {
      loading.value = false;
    }
  }

  void toggle(Player p) {
    if (selected.contains(p)) {
      selected.remove(p);
    } else {
      if (selected.length >= 3) {
        Get.snackbar('Limit', 'Team must have exactly 3 members.',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      selected.add(p);
    }
  }

  void createTeam(String name) {
    if (selected.length != 3) {
      Get.snackbar('Invalid', 'Please select exactly 3 members.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    teams.add(Team(name: name, members: List<Player>.from(selected)));
    selected.clear();
    Get.snackbar('Success', 'Team "$name" created.',
        snackPosition: SnackPosition.BOTTOM);
  }

  int _extractId(String url) {
    final parts = url.split('/');
    for (var i = parts.length - 1; i >= 0; i--) {
      final n = int.tryParse(parts[i]);
      if (n != null) return n;
    }
    return 1;
  }
}
