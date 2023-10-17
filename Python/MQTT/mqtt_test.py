import paho.mqtt.client as mqtt

# Configurar los detalles del servidor MQTT
broker_address = "mqtt.eclipseprojects.io"
port = 1883

# Crear un cliente MQTT
client = mqtt.Client()

# Conectar al servidor MQTT
# client.username_pw_set(username, password)
client.connect(broker_address, port)

# Publicar un mensaje en un tema
topic = "topic/fire_alarm"
message = "1"
client.publish(topic, message)

# Desconectar del servidor MQTT
client.disconnect()
