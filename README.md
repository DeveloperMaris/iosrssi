# iOSRSSI

A command line tool for parsing iOS sysdiagnose Wi-Fi information and retrieving the RSSI information.

## Installation

To build and install the command line tool yourself, clone the repository and run `make install`:

```bash
git clone https://github.com/DeveloperMaris/iosrssi.git
cd iOSRSSI
make install
```

If you see the `Permission denied` error, please use `sudo make install`.

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
* `iosrssi parse /path/to/wifimanager.log /path/to/output/rssi.csv --since "2022-03-11 11:40:13.277"` parses the log file after the starting date and produces the output of RSSI information into the output CSV file.
* `iosrssi parse /path/to/wifimanager.log /path/to/output/rssi.csv --till "2022-03-11 11:42:13.277"` parses the log file till the ending date and produces the output of RSSI information into the output CSV file.
* `iosrssi parse /path/to/wifimanager.log /path/to/output/rssi.csv --since "2022-03-11 11:40:13.277" --till "2022-03-11 11:42:13.277"` parses the log file in the provided date range and produces the output of RSSI information into the output CSV file.

## Example 

Command-line tool will generate a `.csv` file output, like this:

```
date,rssi,ssid
2022-03-11 11:26:45.276,-47,ALHN-E1DA
2022-03-11 11:26:50.288,-48,ALHN-E1DA
2022-03-11 11:26:55.302,-43,ALHN-E1DA
2022-03-11 11:27:00.317,-46,ALHN-E1DA
2022-03-11 11:27:05.324,-52,ALHN-E1DA
2022-03-11 11:27:11.986,-55,EDGE-F52s
2022-03-11 11:27:17.021,-56,EDGE-F52s
2022-03-11 11:27:22.042,-55,EDGE-F52s
2022-03-11 11:27:27.064,-56,EDGE-F52s
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
