#include "WiFi.h"

esp_netif_t * wifi_init_softap(void){
    // It is recommended firstable initialize the Wi-Fi module with the default configuration
    esp_netif_t *wifi_object= esp_netif_create_default_wifi_ap();   // Creates default WIFI AP
    wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();            // Load default WiFi structure
    esp_wifi_init(&cfg);                                            // Initialize WiFi

    wifi_config_t wifi_config = {                   // WiFi structure configuration
        .ap = {
            .ssid = WIFI_SSID,
            .ssid_len = strlen(WIFI_SSID),
            .channel = WIFI_CHANNEL,
            .password = WIFI_PASS,
            .max_connection = MAX_STA_CONN,
            .authmode = WIFI_AUTH_WPA_WPA2_PSK
        },
    };

    esp_wifi_set_mode(WIFI_MODE_AP);               // Set WiFi mode to Acces Point  
    esp_wifi_set_config(WIFI_IF_AP, &wifi_config); // Set WiFi structure configuration
    esp_wifi_start();                              // Start WiFi

    return wifi_object;
}

esp_netif_t* wifi_init_sta(void){

    // It is recommended firstable initialize the Wi-Fi module with the default configuration
    esp_netif_t *wifi_object = esp_netif_create_default_wifi_sta(); // Creates default WiFi STA
    wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();            // Load default WiFi structure
    ESP_ERROR_CHECK(esp_wifi_init(&cfg));                           // Initialize WiFi
    
    nvs_handle_t my_handle;
    nvs_open("wifi",NVS_READWRITE, &my_handle);             // Open the nvs in read/write mode
    size_t required_size;
    
    nvs_get_str(my_handle, "SSID", NULL, &required_size);   // Get the required size, and value of the SSID from NVS
    char *wifi_ssid = malloc(required_size);
    nvs_get_str(my_handle, "SSID", wifi_ssid, &required_size);
    
    nvs_get_str(my_handle, "PSWD", NULL, &required_size);   // Get the required size, and value of the PSWD from NVS
    char *wifi_pswd = malloc(required_size);
    nvs_get_str(my_handle, "PSWD", wifi_pswd, &required_size);

    wifi_config_t wifi_config = {                           // WiFi structure configuration
        .sta = 
        {            
            .pmf_cfg =
            {
                .capable = true,
                .required = false
            },
        },
    };
    if(*wifi_pswd =='\0'){
        wifi_config.sta.threshold.authmode = WIFI_AUTH_OPEN;
        strcpy((char *)wifi_config.sta.password, "");
    }
    else{
        wifi_config.sta.threshold.authmode = WIFI_AUTH_WPA2_PSK;
        strcpy((char *)wifi_config.sta.password, wifi_pswd);
    }
    strcpy((char *)wifi_config.sta.ssid, wifi_ssid);
    
    esp_wifi_set_mode(WIFI_MODE_STA);                   // Set WiFi mode to Station  
    esp_wifi_set_config(WIFI_IF_STA, &wifi_config);     // Set WiFi structure configuration  
    esp_wifi_start();                                   // Start WiFi
    
    nvs_close(my_handle);
    free(wifi_pswd);
    free(wifi_ssid);
    return wifi_object;
}

void wifi_event_handler(void* arg, esp_event_base_t event_base, int32_t event_id, void* event_data){
    static int retry_conn = 0;
    EventGroupHandle_t *s_wifi_group = (EventGroupHandle_t *)arg;
    EventGroupHandle_t s_wifi_event_group = *s_wifi_group;
    
    if(event_base == WIFI_EVENT){   // If the event is a WiFi event
        switch (event_id){
            case WIFI_EVENT_STA_START:{         // If the ESP started as STA
                    printf("STARTED AS STA...\n");
                    printf("CONNECTING TO WIFI...\n");
                    esp_err_t wifi = esp_wifi_connect();    // Connecting to WiFi
                    if(wifi!=ESP_OK){
                        xEventGroupSetBits(s_wifi_event_group, WIFI_FAIL_BIT);
                        printf("WIFI NOT CONNECTED...\n");
                    }
                    break;
                }
            case WIFI_EVENT_STA_CONNECTED:{     // If the ESP is connected to an AP
                printf("SUCCESSFULLY CONNECTED TO AP!\n");
                printf("WAITING FOR IP...\n");
                break;
            }
            case WIFI_EVENT_STA_DISCONNECTED:{  // If the ESP is disconnected from an AP
                printf("DISCONNECTED FROM AP!\n");
                xEventGroupSetBits(s_wifi_event_group, WIFI_DISCONNECTED_BIT);
                
                if(retry_conn<MAX_RETRY){
                    esp_wifi_connect(); // Trying to reconnect
                    retry_conn++;       // Increment retry counter
                    printf("RETRY CONNECTION N°: %d OF %d\n", retry_conn, MAX_RETRY);
                }
                else{
                    printf("MAX RETRY REACHED! RESETING LOOP...\n");
                    xEventGroupSetBits(s_wifi_event_group, WIFI_FAIL_BIT);  // Flag to reset ESP
                    retry_conn=0;                                           // Reset retry counter
                }
                break;
            }
            case WIFI_EVENT_AP_START:{          // If the ESP started as AP
                printf("STARTED AS AP...\n");
                break;
            }
            case WIFI_EVENT_AP_STOP:{           // If the ESP stopped as AP
                printf("STOPED AS AP...\n");
                break;
            }
            default:{
                break;
            }
        }
    }
    else if(event_base == IP_EVENT){                        // If the event is an IP event
        switch (event_id){
            case IP_EVENT_STA_GOT_IP:{
                xEventGroupClearBits(s_wifi_event_group, WIFI_DISCONNECTED_BIT);
                xEventGroupSetBits(s_wifi_event_group, WIFI_CONNECTED_BIT);
                printf("IP OBTAINED!\n\n");
                retry_conn=0;       // Reset retry counter
                break;
            }
            case IP_EVENT_STA_LOST_IP:{
                xEventGroupSetBits(s_wifi_event_group, WIFI_FAIL_BIT);
                printf("IP LOST!\n");
                break;
            }
            default:{
                break;
            }
        }
    }
}

bool wait_wifi_event(EventGroupHandle_t wifi){
    EventBits_t bits = xEventGroupWaitBits(wifi, WIFI_CONNECTED_BIT | WIFI_FAIL_BIT, pdTRUE, pdFALSE, portMAX_DELAY);
    
    if(bits & WIFI_CONNECTED_BIT){ return true;}
    else{return false;}
}