// tool/generate_products.dart
import 'package:pocketbase/pocketbase.dart';
import 'package:faker/faker.dart';

const adminEmail = 'admin@gmail.com';
const adminPassword = '123456789@';

Future<void> main() async {
  final pb = PocketBase('http://127.0.0.1:8090');

  // admin login
  await pb.admins.authWithPassword(adminEmail, adminPassword);
  print('✅ Admin authenticated');

  final faker = Faker();
  final shopNames = List.generate(10, (_) => faker.company.name());

  for (int i = 1; i <= 100; i++) {
    final name = faker.lorem.words(2).join(' ');
    final imageurl =
        'https://picsum.photos/seed/${faker.randomGenerator.integer(10000)}/400/400';
    final nameshop = shopNames[faker.randomGenerator.integer(shopNames.length)];
    final price = faker.randomGenerator.integer(900, min: 99);

    try {
      await pb.collection('products').create(body: {
        'name': name,
        'nameshop': nameshop,
        'imageurl': imageurl,
        'price': price,
      });

      print('✅ Created product $i: $name | $nameshop | ฿$price');
    } catch (e) {
      print('❌ Error creating product $i: $e');
    }
  }

  pb.authStore.clear();
  print('🎉 Seeding completed.');
}
