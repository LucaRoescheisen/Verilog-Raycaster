import sys
import select

from machine import Pin

led = Pin("LED", Pin.OUT)
poll_obj = select.poll()
poll_obj.register(sys.stdin, select.POLLIN)

# Signal that the Pico has rebooted
print("PICO_READY")

while True:
    if poll_obj.poll(100):
        # Read the incoming data
        data = sys.stdin.readline().strip()
        if data:
            led.toggle()
            # Send back the response WITH a newline
            # Using print is the easiest way to ensure \n is sent
            print(f"ECHO:{data}")