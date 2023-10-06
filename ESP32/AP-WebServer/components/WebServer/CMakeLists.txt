idf_component_register(SRCS "WebServer.c"
                    INCLUDE_DIRS "include"
                    REQUIRES esp_http_server nvs_flash esp_wifi
                    EMBED_FILES "favicon.ico" "homepage.html")