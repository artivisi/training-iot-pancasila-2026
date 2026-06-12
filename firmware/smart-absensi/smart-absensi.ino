// =====================================================================
// LAB SMART ABSENSI
// PkM IoT STMIK Tazkia x Universitas Pancasila 2026
//
// Fungsi: baca kartu RFID (RC522) lewat SPI. Saat kartu ditempel, tampilkan
// UID kartu di OLED, bunyikan buzzer + LED hijau, lalu kirim UID + nomor urut
// tap ke dashboard Blynk. Kartu tidak terbaca / error -> LED merah.
//
// Board   : ESP32 DevKit V1
// Toolchain: Arduino IDE
// Library yang perlu di-install (Sketch > Include Library > Manage Libraries):
//   - "MFRC522" by GithubCommunity
//   - "Adafruit SSD1306"  (+ "Adafruit GFX Library")
//   - "Blynk" by Volodymyr Shymanskyy
// =====================================================================

#include "secrets.h"

#include <WiFi.h>
#include <BlynkSimpleEsp32.h>
#include <SPI.h>
#include <MFRC522.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

// ------------------- Pin RC522 (SPI) --------------------
// PENTING: RC522 HANYA boleh diberi 3.3V. 5V akan merusak modul.
const int PIN_RC522_SS  = 5;   // SDA/SS
const int PIN_RC522_RST = 4;   // RST
// SCK=18, MOSI=23, MISO=19 -> pin SPI default ESP32, tidak perlu di-set manual.

// ------------------- Pin OLED (I2C) ---------------------
// SDA=21, SCL=22 -> pin I2C default ESP32.
const int OLED_W = 128;
const int OLED_H = 64;
const int OLED_ADDR = 0x3C;   // alamat I2C umum SSD1306 0.96"

// ------------------- Pin output -------------------------
const int PIN_LED_HIJAU = 25;
const int PIN_LED_MERAH = 26;
const int PIN_BUZZER    = 27;

MFRC522 rfid(PIN_RC522_SS, PIN_RC522_RST);
Adafruit_SSD1306 oled(OLED_W, OLED_H, &Wire, -1);

int nomorTap = 0;

// Datastream Blynk: V0 = UID kartu (string), V1 = nomor urut tap (angka)

void tampilOled(const String &baris1, const String &baris2) {
  oled.clearDisplay();
  oled.setTextColor(SSD1306_WHITE);
  oled.setTextSize(1);
  oled.setCursor(0, 0);
  oled.println(baris1);
  oled.setTextSize(2);
  oled.setCursor(0, 24);
  oled.println(baris2);
  oled.display();
}

void beep(int ms) {
  digitalWrite(PIN_BUZZER, HIGH);
  delay(ms);
  digitalWrite(PIN_BUZZER, LOW);
}

void setup() {
  Serial.begin(115200);

  pinMode(PIN_LED_HIJAU, OUTPUT);
  pinMode(PIN_LED_MERAH, OUTPUT);
  pinMode(PIN_BUZZER, OUTPUT);

  // OLED. Kalau gagal (alamat I2C salah / kabel SDA-SCL tertukar) -> stop
  // dengan error eksplisit, jangan lanjut diam-diam.
  if (!oled.begin(SSD1306_SWITCHCAPVCC, OLED_ADDR)) {
    Serial.println("ERROR: OLED tidak terdeteksi di 0x3C (cek SDA=21, SCL=22).");
    while (true) { delay(1000); }
  }
  tampilOled("Smart Absensi", "Mulai...");

  // RC522 lewat SPI
  SPI.begin();
  rfid.PCD_Init();

  // Cek RC522 benar-benar terhubung. Versi 0x00 / 0xFF = tidak terdeteksi
  // (biasanya salah kabel atau diberi 5V, bukan 3.3V).
  byte v = rfid.PCD_ReadRegister(MFRC522::VersionReg);
  if (v == 0x00 || v == 0xFF) {
    Serial.println("ERROR: RC522 tidak terdeteksi. Cek wiring SPI & power 3.3V.");
    tampilOled("RC522 error", "Cek wiring");
    digitalWrite(PIN_LED_MERAH, HIGH);
  } else {
    Serial.print("RC522 OK, versi 0x");
    Serial.println(v, HEX);
  }

  Blynk.begin(BLYNK_AUTH_TOKEN, WIFI_SSID, WIFI_PASS);
  tampilOled("Siap.", "Tempel kartu");
}

void loop() {
  Blynk.run();

  // Tidak ada kartu baru -> keluar cepat.
  if (!rfid.PICC_IsNewCardPresent() || !rfid.PICC_ReadCardSerial()) {
    return;
  }

  // Susun UID jadi string hex, mis. "A1B2C3D4".
  String uid = "";
  for (byte i = 0; i < rfid.uid.size; i++) {
    if (rfid.uid.uidByte[i] < 0x10) uid += "0";
    uid += String(rfid.uid.uidByte[i], HEX);
  }
  uid.toUpperCase();

  nomorTap++;
  Serial.print("Tap #"); Serial.print(nomorTap);
  Serial.print(" UID="); Serial.println(uid);

  digitalWrite(PIN_LED_HIJAU, HIGH);
  tampilOled("Tap #" + String(nomorTap), uid);
  beep(120);

  Blynk.virtualWrite(V0, uid);
  Blynk.virtualWrite(V1, nomorTap);

  delay(800);
  digitalWrite(PIN_LED_HIJAU, LOW);

  rfid.PICC_HaltA();      // hentikan komunikasi dengan kartu ini
  rfid.PCD_StopCrypto1();
}
