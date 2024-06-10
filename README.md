# Network Research (Remote Access)

## Project Objective

1. **Installations and Anonymity Check**

    1.1 Install the needed applications:
    - Ensure that required tools like `nmap`, `whois`, and SSH clients are installed.
    - Use package managers such as `apt`, `yum`, or `brew` to install the necessary applications.

    1.2 If the applications are already installed, don’t install them again:
    - Check the system for existing installations before attempting to install new software.

    1.3 Check if the network connection is anonymous; if not, alert the user and exit:
    - Use services or APIs to check the anonymity status of the network connection.
    - Example: Use `curl` with `ipinfo.io` or `ipstack.com` to verify the current IP address location and anonymity status.

    1.4 If the network connection is anonymous, display the spoofed country name:
    - Parse the response from the IP checking service to display the spoofed country.

    1.5 Allow the user to specify the address to scan via remote server; save into a variable:
    - Prompt the user to input the address to be scanned.
    - Save the input address into a variable for later use.

2. **Automatically Connect and Execute Commands on the Remote Server via SSH**

    2.1 Display the details of the remote server (country, IP, and Uptime):
    - Use SSH to connect to the remote server and retrieve details like country, IP address, and uptime.
    - Example commands: `hostname -I`, `curl ipinfo.io`, and `uptime`.

    2.2 Get the remote server to check the Whois of the given address:
    - Execute the `whois` command on the remote server for the specified address.

    2.3 Get the remote server to scan for open ports on the given address:
    - Use `nmap` to scan the specified address for open ports and services.

3. **Results**

    3.1 Save the Whois and Nmap data into files on the local computer:
    - Transfer the results of the `whois` and `nmap` commands from the remote server to the local machine.
    - Use `scp` or other file transfer methods to save the data locally.

    3.2 Create a log and audit your data collecting:
    - Maintain a log of the actions performed, including timestamps and details of the data collected.
    - Ensure that the log includes information on any errors encountered and how they were resolved.

## How to Run the Script

1. Save the script to a file, for example, `network_research.sh`.
2. Make the script executable:
   ```bash
   chmod +x network_research.sh
   ```
3. Run the script:
   ```bash
   ./network_research.sh
   ```

By following the steps and using the provided script, you will be able to automate the tasks involved in network research and remote access efficiently.
