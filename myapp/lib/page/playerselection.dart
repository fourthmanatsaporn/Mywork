import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../state/team_controller.dart';


class PlayerSelection extends StatefulWidget {
  const PlayerSelection({super.key});


  @override
  State<PlayerSelection> createState() => _PlayerSelectionState();
}


class _PlayerSelectionState extends State<PlayerSelection> {
  final c = Get.find<TeamController>();


  @override
  void initState() {
    super.initState();
    if (c.all.isEmpty) c.fetchPlayers();
  }


  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;


    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Builder (Pick 3)'),
       
        actions: [
              // 2. ย้าย Obx ที่แสดงชื่อผู้เล่นมาไว้ตรงนี้
    Center(
      child: Obx(() => Text(c.playerName.value)),
    ),
    const SizedBox(width: 8),
                    IconButton( // ✅ ปุ่มแก้ไขชื่อ เพิ่มตรงนี้ได้เลย
            tooltip: 'Edit Name',
            onPressed: () => Get.toNamed('/edit-name'),
            icon: const Icon(Icons.edit),
          ),
         
          IconButton(
           
            tooltip: 'My Teams',
            onPressed: () => Get.toNamed('/teams'),
            icon: const Icon(Icons.groups_2_outlined),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(58),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: _SearchField(onChanged: (v) => c.query.value = v),
          ),
        ),
      ),
      body: Obx(() {
        if (c.loading.value) return const Center(child: CircularProgressIndicator());
        if (c.error.isNotEmpty) return Center(child: Text(c.error.value));


        final players = c.filtered;


        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --------- แถบทีมแบบชิปกลม (เลือกได้ 3) ----------
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
              child: Row(
                children: [
                  Text('Your Team', style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  Text('${c.selected.length}/3 selected',
                      style: TextStyle(color: cs.onSurfaceVariant)),
                ],
              ),
            ),
            SizedBox(
              height: 92,
              child: Obx(() {
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  itemCount: c.selected.isEmpty ? 1 : c.selected.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    if (c.selected.isEmpty) {
                      return _EmptyTeamHint(color: cs.secondaryContainer);
                    }
                    final p = c.selected[i];
                    return _SelectedChip(
                      name: p.name,
                      imageUrl: p.imageUrl,
                      onRemove: () => c.toggle(p),
                    );
                  },
                );
              }),
            ),


            const SizedBox(height: 8),


            // --------- รายการทั้งหมด (การ์ดแนวตั้ง) ----------
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,             // desktop; มือถือจะปรับเป็น 2-3 ได้เองถ้าปรับที่นี่
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: .78,
                ),
                itemCount: players.length,
                itemBuilder: (context, index) {
                  final p = players[index];
                  final isSel = c.selected.contains(p);
                  return Card(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        // อวาตาร์วงกลม + contain ไม่ครอป
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: cs.secondaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: ClipOval(
                              child: Image.network(p.imageUrl, fit: BoxFit.contain),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            p.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => c.toggle(p),
                              icon: Icon(
                                isSel ? Icons.remove_circle_outline : Icons.add_circle_outline,
                              ),
                              label: Text(isSel ? 'Remove' : 'Add'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isSel ? cs.error : cs.primary,
                                side: BorderSide(color: isSel ? cs.error : cs.primary),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),


            // --------- ปุ่ม Create Team ----------
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: Obx(() => FilledButton.icon(
                        onPressed: c.selected.length == 3
                            ? () async {
                                final name = await _askTeamName(context);
                                if (name != null && name.trim().isNotEmpty) {
                                  c.createTeam(name.trim());
                                }
                              }
                            : null,
                        icon: const Icon(Icons.save),
                        label: Text(
                          c.selected.length == 3
                              ? 'Create Team'
                              : 'Pick ${3 - c.selected.length} more',
                        ),
                      )),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }


  Future<String?> _askTeamName(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Team name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'e.g. Aqua Trio'),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Get.back(result: controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}


class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchField({required this.onChanged});


  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'Search Pokémon...',
        filled: true,
        fillColor: cs.surfaceVariant.withOpacity(.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      ),
    );
  }
}


class _EmptyTeamHint extends StatelessWidget {
  final Color color;
  const _EmptyTeamHint({required this.color});


  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: color.withOpacity(.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: const Center(
        child: Text('Pick 3 to build a team'),
      ),
    );
  }
}


class _SelectedChip extends StatelessWidget {
  final String name;
  final String imageUrl;
  final VoidCallback onRemove;
  const _SelectedChip({required this.name, required this.imageUrl, required this.onRemove});


  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: cs.primaryContainer,
        border: Border.all(color: cs.primary),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: cs.secondaryContainer,
            child: ClipOval(child: Image.network(imageUrl, fit: BoxFit.contain)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Remove',
            onPressed: onRemove,
            icon: Icon(Icons.close, color: cs.onPrimaryContainer),
          ),
        ],
      ),
    );
  }
}



