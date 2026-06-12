# Config / Credential files (ไม่อยู่ใน git)

ไฟล์ credential ถูก **gitignore** ไว้ ไม่ขึ้น repo — คนที่ build ต้องเตรียมเองในเครื่อง
(โฟลเดอร์นี้เก็บ "ต้นแบบ" ให้รู้โครงสร้าง)

## ต้องมีไฟล์เหล่านี้ก่อน build

| ไฟล์จริง (gitignored) | ได้มาจาก | ต้นแบบ |
|----------------------|----------|--------|
| `lib/config/line_config.dart` | copy จาก `line_config.dart.example` แล้วใส่ Channel ID (LINE Developers Console) | `line_config.dart.example` |
| `android/app/src/main/res/values/strings.xml` | copy จาก `strings.xml.example` แล้วใส่ค่า Facebook (Meta for Developers) | `strings.xml.example` |
| `android/app/google-services.json` | ดาวน์โหลดจาก Firebase Console (Android app) | — |
| `ios/Runner/GoogleService-Info.plist` | ดาวน์โหลดจาก Firebase Console (iOS app) | — |

## หมายเหตุ
- ของลับ "ตัวจริง" (App Secret / Channel Secret) อยู่ใน Firebase/Meta/LINE console เท่านั้น ไม่อยู่ในโค้ด
- iOS: ต้องลาก `GoogleService-Info.plist` เข้า Runner target ใน Xcode + `pod install` (ทำบน Mac)
