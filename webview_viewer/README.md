# WebView Viewer

Энэ Flutter апп нь ганц дэлгэц дээр paste хийсэн эсвэл clipboard-с уншсан URL-ийг WebView дээр ачаалж харуулдаг.

## Шаардлага

- Flutter SDK 3.19.0 ба түүнээс дээш
- Android SDK (APK бүтэц хийхэд)

## Ашиглах заавар

1. Репог клон эсвэл татаж авна.
2. Flutter SDK-ийнхаа замыг `android/local.properties` файлын `flutter.sdk` талбарт тохируулна. (`flutter pub get` гэх мэт командыг ажиллуулахад файл автоматаар үүснэ).
3. Сангуудыг татах:

   ```bash
   flutter pub get
   ```

4. Апп-ыг ажиллуулах:

   ```bash
   flutter run
   ```

## APK бүтээх

Flutter болон Android SDK суусан орчинд дараах командыг ажиллуулна:

```bash
flutter build apk --release
```

Үүссэн APK нь `build/app/outputs/flutter-apk/app-release.apk` замд байрлана.

> ⚠️ Тэмдэглэл: Энэ ажлын орчинд Gradle wrapper файлуудыг багтаах боломжгүй байсан. Анх удаа төсөл дээр ажиллахдаа дараах командыг ажиллуулж wrapper-ыг дахин үүсгэнэ үү:

```bash
cd android
gradle wrapper
```

Ингэснээр `gradlew` болон холбогдох wrapper файлууд үүсэж, `flutter build apk` команд хэвийн ажиллана.

## Онцлог

- Clipboard-оос шууд URL уншиж WebView-д ачаалдаг товчтой
- URL текст талбараас гараар URL оруулж, баталгаажуулж ачаална
- Буцах/Урагшлах/Дахин ачаалах удирдлагатай AppBar
- Гадаад браузерт линк нээх боломжтой
- Ачаалалтын явцыг харуулах progress bar
