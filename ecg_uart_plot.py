import sys
sys.path.append(r"C:\Users\User\AppData\Roaming\Python\Python39\site-packages")

import serial
import matplotlib.pyplot as plt
from collections import deque

# --------------------------------------------------
# UART SETTINGS
# --------------------------------------------------

PORT = "COM4"        # Change if needed
BAUD = 115200

ser = serial.Serial(PORT, BAUD, timeout=1)
ser.reset_input_buffer()

print("Streaming ECG... Press Ctrl+C to stop")

# --------------------------------------------------
# BUFFER SETTINGS
# --------------------------------------------------

BUFFER_SIZE = 500
ecg_buffer = deque([0]*BUFFER_SIZE, maxlen=BUFFER_SIZE)

# --------------------------------------------------
# REALTIME PLOT SETUP
# --------------------------------------------------

plt.ion()

fig, ax = plt.subplots()
line, = ax.plot(ecg_buffer, linewidth=1)

ax.set_title("Real-Time ECG Waveform")
ax.set_xlabel("Samples")
ax.set_ylabel("Amplitude")

# Adjust scale as tuned
ax.set_ylim(-100000, 100000)

plt.show(block=False)

# --------------------------------------------------
# DATA READ + PLOT LOOP
# --------------------------------------------------

try:
    while True:

        # Read 32-bit ECG sample from UART
        data = ser.read(4)

        if len(data) == 4:

            sample = int.from_bytes(
                data,
                byteorder='big',
                signed=True
            )

            ecg_buffer.append(sample)

            # Update plot
            line.set_ydata(ecg_buffer)
            line.set_xdata(range(len(ecg_buffer)))

            fig.canvas.draw()
            fig.canvas.flush_events()

except KeyboardInterrupt:
    print("Stopped by user")

finally:
    ser.close()
