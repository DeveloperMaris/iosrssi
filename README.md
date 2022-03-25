# iOSRSSI

A command line tool for parsing iOS sysdiagnose Wi-Fi information and retrieving the RSSI information.

## Installation

### Homebrew

Using Homebrew is the suggested way of installing this tool.

```
brew install developermaris/brew/iosrssi
```

### Manually

To build and install the command line tool yourself, clone the repository and run `make install`:

```bash
git clone https://github.com/DeveloperMaris/iosrssi.git
cd iOSRSSI
make install
```

Optionally, if you wish to uninstall this tool, run `make clean`.

If you see the `Permission denied` error, please use `sudo` in front of the `make`, for example: `sudo make install`.

## Usage

First you need to retrieve the Wi-Fi network information from the sysdiagnose log files.

Please download and install the **Wi-Fi Profile** on your device and follow the instructions on how to collect the logs:
[Apple Profiles and Logs](https://developer.apple.com/bug-reporting/profiles-and-logs/?platform=ios).

After collecting the sysdiagnose log files, search for the Wi-Fi log file. It should be located here:
```
/path/to/sysdiagnose_2022.03.11_12-13-58+0200_iPhone-OS_iPhone_18A8395/WiFi/wifimanager-03-11-2022__11/24/56.log.tgz
```

*Note: the path will contain different date and time values, as well as the device identifier.

Extract the log file from the compressed `wifimanager-03-11-2022__11/24/56.log.tgz` file and use this log file to get the necessary information.

* `iosrssi parse /path/to/wifimanager.log /path/to/output/rssi.csv` parses the log file and produces the output of RSSI information into the output CSV file.
* `iosrssi parse /path/to/wifimanager.log /path/to/output/rssi.csv --since "03/11/2022 11:40:13.277"` parses the log file after the starting date and produces the output of RSSI information into the output CSV file.
* `iosrssi parse /path/to/wifimanager.log /path/to/output/rssi.csv --till "03/11/2022 11:42:13.277"` parses the log file till the ending date and produces the output of RSSI information into the output CSV file.
* `iosrssi parse /path/to/wifimanager.log /path/to/output/rssi.csv --since "03/11/2022 11:40:13.277" --till "03/11/2022 11:42:13.277"` parses the log file in the provided date range and produces the output of RSSI information into the output CSV file.

## Example 

Command-line tool will generate a `.csv` file output, like this:

```
date,time,network,ssid,measurement,-dBm
2022-03-11,11:26:45.276,WIFI,ALHN-E1DA,RSSI,-47
2022-03-11,11:26:50.288,WIFI,ALHN-E1DA,RSSI,-48
2022-03-11,11:26:55.302,WIFI,ALHN-E1DA,RSSI,-43
2022-03-11,11:27:00.317,WIFI,ALHN-E1DA,RSSI,-46
2022-03-11,11:27:05.324,WIFI,ALHN-E1DA,RSSI,-52
2022-03-11,11:27:11.986,WIFI,EDGE-F52s,RSSI,-55
2022-03-11,11:27:17.021,WIFI,EDGE-F52s,RSSI,-56
2022-03-11,11:27:22.042,WIFI,EDGE-F52s,RSSI,-55
2022-03-11,11:27:27.064,WIFI,EDGE-F52s,RSSI,-56
2022-03-11,11:27:32.077,WIFI,EDGE-F52s,RSSI,-51
2022-03-11,11:27:37.090,WIFI,EDGE-F52s,RSSI,-55
```

## Help

```
% iosrssi help
OVERVIEW: A Swift command-line tool to parse iOS device sysdiagnose log files and retrieve the wifi network RSSI statistics.

USAGE: iosrssi <subcommand>

OPTIONS:
  -h, --help              Show help information.

SUBCOMMANDS:
  parse                   Parse the wifi sysdiagnose log file to retrieve RSSI statistics.

  See 'iosrssi help <subcommand>' for detailed help.
```

```
% iosrssi help parse
OVERVIEW: Parse the wifi sysdiagnose log file to retrieve RSSI statistics.

USAGE: iosrssi parse <input> <output> [--since <since>] [--till <till>] [--verbose]

ARGUMENTS:
  <input>                 The input file path for the sysdiagnose file
  <output>                The output file path for the parsed result file, should be a .csv format file

OPTIONS:
  -s, --since <since>     The starting date and time of the logs when to start parsing. Format is "MM/dd/yyyy HH:mm:ss.SSS". For example: 03/11/2022 11:40:13.277
  -t, --till <till>       The ending date and time of the logs when to stop parsing. Format is "MM/dd/yyyy HH:mm:ss.SSS". For example: 03/11/2022 14:50:09.002
  --verbose               Show extra logging for debugging purposes
  -h, --help              Show help information.
```
