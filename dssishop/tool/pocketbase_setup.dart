// tool/pocketbase_setup.dart
import 'package:pocketbase/pocketbase.dart';
import 'package:pocketbase/src/dtos/collection_model.dart'; // ✅ เพิ่ม import ให้ชัดเจน

/// ปรับให้ตรงกับ admin ของคุณ
const adminEmail = 'admin@gmail.com';
const adminPassword = '123456789@';

Future<void> main() async {
  final pb = PocketBase('http://127.0.0.1:8090');

  // 1) admin login
  await pb.admins.authWithPassword(adminEmail, adminPassword);
  print('✅ Admin authenticated');

  // 2) ตรวจว่ามี collection 'products' หรือยัง
  const colName = 'products';
  CollectionModel? existing; // ✅ แก้ชนิดข้อมูล
  try {
    existing = await pb.collections.getOne(colName); // รับได้ทั้ง id หรือชื่อ
  } catch (_) {
    existing = null;
  }

  // schema fields ที่ต้องใช้
  final schema = [
    {
      "name": "name",
      "type": "text",
      "required": true,
      "unique": false,
      "options": {"min": 1, "max": 120}
    },
    {
      "name": "nameshop",
      "type": "text",
      "required": true,
      "unique": false,
      "options": {"min": 1, "max": 120}
    },
    {
      "name": "imageurl",
      "type": "url",
      "required": true,
      "unique": false,
      "options": {}
    },
    {
      "name": "price",
      "type": "number",
      "required": true,
      "unique": false,
      "options": {"min": 0}
    },
    // (ออปชัน) owner ไว้ใช้โหมด Secure ภายหลัง
    {
      "name": "owner",
      "type": "relation",
      "required": false,
      "unique": false,
      "options": {
        "collectionId": "_pb_users_auth_",
        "cascadeDelete": false,
        "minSelect": 0,
        "maxSelect": 1,
        "displayFields": []
      }
    },
  ];

  // Dev rules (public): เว้นว่างทั้งหมด
  const devListRule = "";
  const devViewRule = "";
  const devCreateRule = "";
  const devUpdateRule = "";
  const devDeleteRule = "";

  if (existing == null) {
    // 3) สร้าง collection ใหม่
    await pb.collections.create(body: {
      "name": colName,
      "type": "base",
      "schema": schema,
      "listRule": devListRule,
      "viewRule": devViewRule,
      "createRule": devCreateRule,
      "updateRule": devUpdateRule,
      "deleteRule": devDeleteRule,
      "options": {"query": ""}
    });
    print('✅ Created collection "$colName" with DEV public rules');
  } else {
    // 4) อัปเดต collection เดิม
    await pb.collections.update(existing.id, body: {
      "name": colName,
      "type": "base",
      "schema": schema,
      "listRule": devListRule,
      "viewRule": devViewRule,
      "createRule": devCreateRule,
      "updateRule": devUpdateRule,
      "deleteRule": devDeleteRule,
    });
    print('✅ Updated collection "$colName" with DEV public rules');
  }

  pb.authStore.clear();
  print('🎉 Setup completed.');
}
