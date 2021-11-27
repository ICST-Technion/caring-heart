import sys
import os

pth = fr"{os.path.dirname(os.path.realpath(sys.executable))}\Lib\site-packages\caring_heart.pth"
with open(pth, "w") as f:
	f.write(f"{os.path.dirname(os.path.realpath(__file__))}\\")


