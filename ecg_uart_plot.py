import serial
import numpy as np
import matplotlib.pyplot as plt
from collections import deque

# ---------------- UART SETTINGS ----------------

PORT = "COM3"        # 🔴 Change this (Linux: /dev/ttyUSB0)
BAUD = 115200

ser = serial.Serial(PORT, BAUD, timeout=1)

print("Reading ECG data... Press Ctrl+C to stop")

# ---------------- BUFFER ----------------

BUFFER_SIZE = 500
ecg_buffer = deque([0]*BUFFER_SIZE, maxlen=BUFFER_SIZE)

# ---------------- PLOT SETUP ----------------

plt.ion()   # interactive mode

fig, ax = plt.subplots()
line, = ax.plot(ecg_buffer)

ax.set_ylim(-500000, 500000)
ax.set_title("Real-Time ECG")
ax.set_xlabel("Samples")
ax.set_ylabel("Amplitude")

# ---------------- READ LOOP ----------------

try:
while True:

```
    data = ser.read(4)   # 32-bit sample

    if len(data) == 4:

        # Convert bytes → signed int
        sample = int.from_bytes(data, byteorder='big', signed=True)

        ecg_buffer.append(sample)

        # Update plot
        line.set_ydata(ecg_buffer)
        plt.pause(0.001)
```

except KeyboardInterrupt:
print("\nStopped by user")

finally:
ser.close()
