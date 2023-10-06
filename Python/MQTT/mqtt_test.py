import paho.mqtt.client as mqtt

# Configurar los detalles del servidor MQTT
broker_address = "192.168.0.170"
port = 1883

# Crear un cliente MQTT
client = mqtt.Client()

# Conectar al servidor MQTT
# client.username_pw_set(username, password)
client.connect(broker_address, port)

# Publicar un mensaje en un tema
topic = "topic"
message = "Hola, mundo!"
client.publish(topic, message)

# Desconectar del servidor MQTT
client.disconnect()
