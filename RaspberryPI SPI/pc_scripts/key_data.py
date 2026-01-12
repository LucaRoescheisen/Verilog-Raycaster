import keyboard
import serial
import time


BAUD_RATE = 115200
COM_PORT = 'COM4'

try:
    ser = serial.Serial(COM_PORT, BAUD_RATE, timeout=0.1)
    time.sleep(2)
    ser.reset_input_buffer()
    if ser.is_open:
        print("Port Open")
    else:
        print("Port initialised but not open.")

        
    
    message = "hello\n"
    ser.write(message.encode('utf-8'))
    print(f"Sent: {message.strip()}")

    time.sleep(0.7)
    while True:
        if keyboard.is_pressed('w'):
            ser.write(b'w\n')
        elif keyboard.is_pressed('a'):
            ser.write(b'a\n')
        elif keyboard.is_pressed('s'):
            ser.write(b's\n')
        elif keyboard.is_pressed('d'):
            ser.write(b'd\n')
        elif keyboard.is_pressed('q'):
            break

        if ser.in_waiting > 0:
            raw_data = ser.read_all()
            decoded_data = raw_data.decode('utf-8').strip()
            print(f"Response: {decoded_data}")
        #else:
            #print("No response received.")
        time.sleep(0.1)
    ser.close()
except Exception as e:
    print(f"{e}")