{ writers, /* python3Packages  */ }:

writers.writePython3Bin "rofi-network" { libraries = [ ]; } (builtins.readFile ./network-rofi.py)
