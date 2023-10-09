""" wifi-manager-rofi.py
desc:   rofi wifi connection manager for i3
usage:  python wifi-manager-rofi.py
i3:     bindsym $mod+m exec --no-startup-id sh -c 'python wifi-manager-rofi.py'
"""

import subprocess


# function to run a shell command
def run_command(cmd):
    try:
        subprocess.run(cmd, shell=True)
    except subprocess.CalledProcessError as e:
        return f"Command execution failed: {e.output.decode().strip()}"


# function to get list of SSIDs
def get_wifi_networks():
    try:
        output = subprocess.check_output(
          ["nmcli", "-t", "-f"] +
          ["IN-USE,SSID,Signal,Security,Bars", "device", "wifi"]
        )
        networks = output.decode().strip().split("\n")
        wifi_networks = []
        for network in networks:
            in_use, ssid, signal, security, bars = network.split(":")
            if ssid:  # Ignore SSIDs with no name
                bars = bars.rstrip('_')  # Remove trailing underscore
                wifi_networks.append(
                    {
                        "in_use": in_use,
                        "ssid": ssid,
                        "signal": signal,
                        "security": security,
                        "bars": bars,
                    }
                )
        print(wifi_networks)
        return wifi_networks
    except subprocess.CalledProcessError:
        return []


# function to connect to a wifi network
def connect_to_wifi(ssid):
    subprocess.run(["nmcli", "device", "wifi",
                    "connect", ssid], check=True)


# function to show list of SSIDs in a rofi menu
def show_wifi_menu():

    networks = get_wifi_networks()
    menu_items = []
    for network in networks:
        ssid = network["ssid"]
        signal = network["signal"]
        security = network["security"]
        bars = network["bars"]
        if network["in_use"] == "*":
            ssid += " "
        ssid_menu_item = f"{bars} {signal}% [{security}] {ssid}"
        menu_items.append(ssid_menu_item)

    menu_items_str = "\n".join(menu_items)

    rofi_cmd = [
        "rofi", "-dmenu", "-i", "-p", "  ", "-lines", str(
            len(menu_items))
        ]

    process = subprocess.Popen(
        rofi_cmd, stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        encoding="utf-8"
    )

    selected_network, _ = process.communicate(input=menu_items_str)
    selected_network = selected_network.strip().split(
        " ")[-1]  # Get the last element

    if selected_network:
        # check locked and ask for pass
        connect_to_wifi(selected_network)


def main():
    show_wifi_menu()


# main
if __name__ == "__main__":
    main()
