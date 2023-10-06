#include <string.h>
#include <stdio.h>
#include "esp_wifi.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"
#include "esp_event.h"
#include "esp_netif.h"
#include "nvs_flash.h"
#include "nvs.h"
#include "esp_system.h"
#include "lwip/err.h"
#include "lwip/sys.h"

#define MAX_RETRY     20        // Number of retry to connect to WiFi

#define WIFI_CONNECTED_BIT      BIT0 // WiFi connected bit
#define WIFI_DISCONNECTED_BIT   BIT1 // WiFi disconnected bit
#define WIFI_FAIL_BIT           BIT2 // WiFi fail bit

#define WIFI_SSID       "Smart Alarm"
#define WIFI_PASS       "kevo_coki"
#define WIFI_CHANNEL    1
#define MAX_STA_CONN    1

void wifi_event_handler(void* arg, esp_event_base_t event_base, int32_t event_id, void* event_data);

esp_netif_t* wifi_init_softap(void);

esp_netif_t* wifi_init_sta(void);

bool wait_wifi_event(EventGroupHandle_t);