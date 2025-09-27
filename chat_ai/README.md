# Flutter AI Chat App

แอปพลิเคชัน Flutter สำหรับพูดคุยกับ AI ผ่าน API ที่รองรับ OpenAI-compatible (เช่น OpenAI และ Groq)
รองรับการเลือกผู้ให้บริการหลัก–สำรอง และมีระบบ fallback อัตโนมัติเมื่อ provider หลักล้มเหลว

## คุณสมบัติ

- สนทนากับ AI ผ่าน UI ที่ใช้งานง่าย
- เก็บประวัติการสนทนา (user/assistant) ภายใน `AIService`
- ปุ่ม **Clear Chat** สำหรับล้างประวัติการคุย
- รองรับการเลือก **Primary/Secondary AI Provider** ผ่านไฟล์ `.env`
- ปรับแต่ง model, temperature, max_tokens ได้ง่าย

## โครงสร้างโฟลเดอร์หลัก

```
lib/
 ├─ services/
 │   └─ ai_service.dart   # จัดการ API และประวัติการสนทนา
 ├─ screens/
 │   └─ chat_screen.dart  # UI สำหรับการแชท
 └─ main.dart             # จุดเริ่มต้นของแอป
.env                      # เก็บคีย์และการตั้งค่า
```

## การตั้งค่าและใช้งาน

### 1. Clone โปรเจ็กต์

```bash
git clone https://github.com/your-username/flutter_ai_chat.git
cd flutter_ai_chat
```

### 2. ติดตั้ง dependencies

```bash
flutter pub get
```

### 3. ตั้งค่า `.env`

สร้างไฟล์ `.env` ไว้ที่ root ของโปรเจ็กต์ และใส่ค่าดังนี้

```env
# เลือกผู้ให้บริการหลัก และสำรอง
AI_PROVIDER_PRIMARY=openai
AI_PROVIDER_SECONDARY=groq

# ค่าเสริม
SYSTEM_PROMPT=You are a helpful assistant.
TEMPERATURE=0.7
MAX_TOKENS=1024

# OpenAI
OPENAI_API_KEY=sk-xxxx
OPENAI_MODEL=gpt-4o-mini
# OPENAI_BASE_URL=https://api.openai.com   # ถ้าใช้ proxy/custom endpoint ใส่ได้

# Groq
GROQ_API_KEY=gsk_xxxx
GROQ_MODEL=llama-3.1-70b-versatile
# GROQ_BASE_URL=https://api.groq.com/openai
```

### 4. เพิ่ม .env ใน pubspec.yaml

```yaml
flutter:
  assets:
    - .env
```

### 5. รันแอป

```bash
flutter run
```

## วิธีการใช้งาน

1. พิมพ์ข้อความในช่องข้อความด้านล่าง
2. กดปุ่ม **ส่ง** หรือกด Enter→ ระบบจะส่งข้อความไปยัง provider หลัก (OpenAI หรือ Groq)→ หากล้มเหลว จะสลับไปใช้อีก provider โดยอัตโนมัติ
3. สามารถกดปุ่ม **ล้าง (Clear)** เพื่อลบประวัติแชททั้งหมดได้

## ตัวอย่างหน้าจอ

- **หน้าหลัก**: แสดงข้อความผู้ใช้ทางขวา และข้อความจาก AI ทางซ้าย
- **ปุ่ม Clear**: อยู่บน AppBar ด้านบนขวา

## เทคโนโลยีที่ใช้

- [Flutter](https://flutter.dev/) (Dart)
- [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) สำหรับโหลดค่าจาก `.env`
- [http](https://pub.dev/packages/http) สำหรับเชื่อมต่อ API
- [OpenAI API](https://platform.openai.com/) และ [Groq API](https://groq.com/)

## License

MIT License
