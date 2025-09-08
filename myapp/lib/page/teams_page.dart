import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../state/team_controller.dart';

class TeamsPage extends StatelessWidget {
  const TeamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<TeamController>();
    return Scaffold(
      appBar: AppBar(title: const Text('My Teams')),
      body: Obx(() {
        if (c.teams.isEmpty) {
          return const Center(child: Text('No teams yet. Create one!'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: c.teams.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final team = c.teams[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(team.name,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Row(
                      children: team.members.map((m) {
                        return Expanded(
                          child: Column(
                            children: [
                              AspectRatio(
                                aspectRatio: 1,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(m.imageUrl,
                                      fit: BoxFit.cover),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(m.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
