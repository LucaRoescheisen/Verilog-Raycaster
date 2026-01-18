import sys
import select
import utime
from machine import Pin
from machine import SPI
led = Pin("LED", Pin.OUT)

#Setup polling, to read keyboard commands sent over COM4
poll_obj = select.poll()
poll_obj.register(sys.stdin, select.POLLIN)

#SPI Setup
cs = Pin(17, Pin.OUT)
spi = SPI(0, baudrate=1000000, polarity=0 ,phase= 0, bits= 8, firstbit=SPI.LSB, sck=Pin(18), mosi=Pin(19), miso=Pin(16))

# Signal that the Pico has rebooted
print("PICO_READY")
command = bytearray()
while True:
    if poll_obj.poll(100): 
        data = sys.stdin.readline().strip()
        if data:                   #If there is information in fifo extract it
            led.toggle()
            print(f"ECHO: {data}") #Echo data back to terminal on PC for debugging

            if data == 'w':
                command.append(0x01)
            elif data == 's':
                command.append(0x02)
            elif data == 'a':
                command.append(0x03)
            elif data == 'd':
                command.append(0x04)

            cs.value(0)
            spi.write(command)
            cs.value(1)
            command.clear()
    utime.sleep(0.05)  