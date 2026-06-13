// =====================================================================
// LAB FIRE DETECTOR  (mencakup monitoring kualitas udara)
// PkM IoT STMIK Tazkia x Universitas Pancasila 2026
//
// Fungsi: baca sensor gas/asap (MQ-2), api (flame), suhu & kelembapan
// (DHT11). Kalau gas melewati ambang ATAU api terdeteksi -> bunyikan
// buzzer, nyalakan LED, aktifkan relay (kipas/pompa), kirim status ke
// Blynk. Semua data juga dikirim ke dashboard Blynk tiap 2 detik.
//
// Board   : ESP32 DevKit V1
// Toolchain: Arduino IDE
// Library yang perlu di-install (Sketch > Include Library > Manage Libraries):
//   - "Blynk" by Volodymyr Shymanskyy
//   - "DHT sensor library" by Adafruit  (+ "Adafruit Unified Sensor")
// =====================================================================

// Blynk perlu 3 #define ini SEBELUM #include <BlynkSimpleEsp32.h>.
// Ketiganya ada di secrets.h (lihat secrets.h.example).
#include "secrets.h"

#include <WiFi.h>
#include <BlynkSimpleEsp32.h>
#include <DHT.h>

// ------------------- Pin (lihat tabel wiring di workbook) -------------------
const int PIN_MQ2_AO  = 34;  // MQ-2 analog out -> ADC. GPIO34 input-only.
const int PIN_FLAME   = 35;  // Flame sensor digital out. GPIO35 input-only.
const int PIN_DHT     = 4;   // DHT11 data
const int PIN_BUZZER  = 27;  // Buzzer active (+)
const int PIN_RELAY   = 26;  // Relay IN (kontrol kipas/pompa)
const int PIN_LED     = 25;  // LED indikator bahaya

// ------------------- Ambang batas (kalibrasi saat dry-run) ------------------
// Nilai gas 0..4095 (12-bit ADC). Di udara bersih biasanya rendah; naik saat
// ada asap/gas. Angka 1500 adalah titik awal -> sesuaikan setelah lihat nilai
// "GAS=" di Serial Monitor pada kondisi udara bersih vs didekatkan asap.
const int AMBANG_GAS = 1500;

// Flame sensor: modul umumnya LOW saat api terdeteksi, HIGH saat aman.
const int FLAME_TERDETEKSI = LOW;

#define DHT_TIPE DHT11
DHT dht(PIN_DHT, DHT_TIPE);

BlynkTimer timer;

// Datastream Blynk:
//   V0 = nilai gas (angka)   V1 = suhu (°C)   V2 = kelembapan (%)
//   V3 = status bahaya (1/0)

void kirimSensor() {
  int gas = analogRead(PIN_MQ2_AO);
  bool api = (digitalRead(PIN_FLAME) == FLAME_TERDETEKSI);

  // DHT bisa gagal baca (kabel longgar / timing). JANGAN kirim angka asal-asalan —
  // laporkan error eksplisit dan lewati pengiriman suhu/kelembapan kali ini.
  float suhu = dht.readTemperature();
  float lembap = dht.readHumidity();
  bool dhtOk = !(isnan(suhu) || isnan(lembap));
  if (!dhtOk) {
    Serial.println("ERROR: DHT11 gagal dibaca (cek kabel data & power 3.3V).");
  }

  bool bahaya = (gas > AMBANG_GAS) || api;

  // Aktuasi lokal
  digitalWrite(PIN_BUZZER, bahaya ? HIGH : LOW);
  digitalWrite(PIN_LED,    bahaya ? HIGH : LOW);
  digitalWrite(PIN_RELAY,  bahaya ? HIGH : LOW);

  // Kirim ke Blynk
  Blynk.virtualWrite(V0, gas);
  if (dhtOk) {
    Blynk.virtualWrite(V1, suhu);
    Blynk.virtualWrite(V2, lembap);
  }
  Blynk.virtualWrite(V3, bahaya ? 1 : 0);

  // Log ke Serial Monitor (Tools > Serial Monitor, 115200 baud)
  Serial.print("GAS="); Serial.print(gas);
  Serial.print(" API="); Serial.print(api ? "YA" : "tidak");
  if (dhtOk) {
    Serial.print(" SUHU="); Serial.print(suhu);
    Serial.print(" LEMBAP="); Serial.print(lembap);
  }
  Serial.print(" -> STATUS="); Serial.println(bahaya ? "BAHAYA" : "aman");
}

void setup() {
  Serial.begin(115200);

  pinMode(PIN_FLAME, INPUT);
  pinMode(PIN_BUZZER, OUTPUT);
  pinMode(PIN_RELAY, OUTPUT);
  pinMode(PIN_LED, OUTPUT);
  digitalWrite(PIN_BUZZER, LOW);
  digitalWrite(PIN_RELAY, LOW);
  digitalWrite(PIN_LED, LOW);

  dht.begin();

  // MQ-2 punya elemen pemanas. Pembacaan baru stabil setelah +/- 30-60 detik
  // dinyalakan. Wajar kalau nilai gas tinggi lalu turun di menit pertama.
  Serial.println("MQ-2 warming up... tunggu ~30 detik sebelum kalibrasi ambang.");

  // Blynk.begin() akan connect WiFi + server Blynk. Kalau salah token/SSID,
  // ESP32 akan retry terus dan TIDAK lanjut -> cek Serial Monitor.
  Blynk.begin(BLYNK_AUTH_TOKEN, WIFI_SSID, WIFI_PASS);

  timer.setInterval(2000L, kirimSensor);  // baca + kirim tiap 2 detik
}

void loop() {
  Blynk.run();
  timer.run();
}
