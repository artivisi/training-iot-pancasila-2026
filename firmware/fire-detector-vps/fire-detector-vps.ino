// =====================================================================
// FIRE DETECTOR -> VPS SENDIRI (bukan Blynk)
// PkM IoT STMIK Tazkia x Universitas Pancasila 2026
//
// Versi ini mengirim data sensor ke server Python (FastAPI) milik sendiri di
// VPS, lewat HTTP POST (JSON). Server menyimpannya ke database Postgres di
// Supabase (lihat folder server/). Sensor & wiring sama dengan Lab Fire Detector.
//
// Board    : ESP32 DevKit V1
// Toolchain: Arduino IDE
// Library  : tidak ada tambahan — WiFi.h & HTTPClient.h ikut paket board ESP32.
//            (DHT butuh "DHT sensor library" by Adafruit, seperti lab utama.)
// =====================================================================

#include "secrets.h"

#include <WiFi.h>
#include <HTTPClient.h>
#include <DHT.h>

const int PIN_MQ2_AO = 34;   // gas (analog) lewat pembagi tegangan
const int PIN_FLAME  = 35;   // api (digital)
const int PIN_DHT    = 4;    // DHT11

const int FLAME_TERDETEKSI = LOW;

#define DHT_TIPE DHT11
DHT dht(PIN_DHT, DHT_TIPE);

const unsigned long INTERVAL_MS = 5000;   // kirim tiap 5 detik
unsigned long terakhirKirim = 0;

void konekWifi() {
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  Serial.print("Konek WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.print(" OK, IP="); Serial.println(WiFi.localIP());
}

void kirimKeVps() {
  int gas = analogRead(PIN_MQ2_AO);
  bool api = (digitalRead(PIN_FLAME) == FLAME_TERDETEKSI);

  // DHT bisa gagal. JANGAN kirim angka asal-asalan -> kirim null (JSON) supaya
  // server tahu pembacaan ini tidak ada, bukan menyimpan nilai bohong.
  float suhu = dht.readTemperature();
  float lembap = dht.readHumidity();
  bool dhtOk = !(isnan(suhu) || isnan(lembap));
  if (!dhtOk) Serial.println("ERROR: DHT11 gagal dibaca (kirim suhu/lembap = null).");

  // Susun body JSON.
  String body = "{";
  body += "\"device\":\"" + String(DEVICE_ID) + "\",";
  body += "\"kind\":\"fire\",";
  body += "\"data\":{";
  body += "\"gas\":" + String(gas) + ",";
  body += "\"api\":" + String(api ? "true" : "false") + ",";
  if (dhtOk) {
    body += "\"suhu\":" + String(suhu, 1) + ",";
    body += "\"lembap\":" + String(lembap, 1);
  } else {
    body += "\"suhu\":null,\"lembap\":null";
  }
  body += "}}";

  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("ERROR: WiFi putus, tidak mengirim. Mencoba konek ulang.");
    konekWifi();
    return;
  }

  HTTPClient http;
  http.begin(VPS_URL);
  http.addHeader("Content-Type", "application/json");
  http.addHeader("X-API-Key", VPS_API_KEY);

  int code = http.POST(body);
  if (code == 200 || code == 201) {
    Serial.println("Terkirim: " + http.getString());
  } else if (code > 0) {
    // Server membalas tapi menolak (mis. 401 token salah, 400 body salah).
    Serial.printf("Server menolak (HTTP %d): %s\n", code, http.getString().c_str());
  } else {
    // Tidak sampai ke server (URL salah, VPS mati, firewall).
    Serial.printf("Gagal konek VPS: %s\n", http.errorToString(code).c_str());
  }
  http.end();
}

void setup() {
  Serial.begin(115200);
  pinMode(PIN_FLAME, INPUT);
  dht.begin();
  konekWifi();
  Serial.println("MQ-2 warming up ~30 detik sebelum nilai gas stabil.");
}

void loop() {
  if (millis() - terakhirKirim >= INTERVAL_MS) {
    terakhirKirim = millis();
    kirimKeVps();
  }
}
