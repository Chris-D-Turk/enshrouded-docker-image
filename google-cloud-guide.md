# How to run Enshrouded Server in Google Cloud (90 days free trial)
This guide shows how to setup a Enshrouded Dedicated Server in the Google Cloud

Some notes before we start:
- You should be familiar with the Unix Shell and Docker - This guide will not explain the basics of these.
- The server is free for 90 days only. After that you will have to pay a monthly fee based on your VM configuration and up-time (see [VM instances pricing](https://cloud.google.com/compute/vm-instance-pricing) for details)
   - The VM configuration created in this guide costs ~85$ per month, if you run it 24/7
   - But if you run the server only 2 hours a day and use the "Spot" Provisioning Model, its only 3$ per month    
     (Spot VMs may get stopped by Google if the Google Cloud platform runs low on resources - see [What is a preemptible instance?](https://cloud.google.com/compute/docs/instances/preemptible?authuser=1#what_is_a_preemptible_instance) )
   - **Note:** After your free trial, you will be charged only if you upgrade to a paid account (see [Billing](https://console.cloud.google.com/billing))  

## Start Google Cloud Trial
- Goto https://console.cloud.google.com/ and login to your google account
- Follow the instructions to setup your free trial. You will need to enter payment info - but you will not be charged before explicitly activating billing in the Cloud Console.

## Create VM
- Goto https://console.cloud.google.com/compute/instances 
- Click "Create Instance"
- Enter a suitable name like "enshrouded"
- Select a region based on your players' location
- Select a machine configuration - "e2-highcpu-4" is sufficient for 4-5 players based on my experience.  
You can also select a bigger configuration, as your first 90 days are free nonetheless.  
**Note:** You can upgrade the machine type anytime, if the VM runs low on resources (see [Changing the machine type of a VM instance](https://cloud.google.com/compute/docs/instances/changing-machine-type-of-stopped-instance))
- Select "Container-Optimized OS" / 40 GB as Boot Disk
- Enter the Network tag "enshrouded" under "Networking"
- Under "Metadata" add a new entry with key "user-data" and add the contents of user-data.yml as value  
This script will install a systemd service that automatically starts the docker container on system boot.  
Note that this systemd service will also shutdown the VM when the dedicated server stops. You can disable this by removing the `shutdown -h now` from the script
- Optional: Select "Spot" as VM provisioning model (this reduces costs by allowing Google to stop your VM when the Cloud platform needs compute resources)
- Click "Create"

## Connect via SSH
For some of the following steps you will need a SSH connection to your VM (to execute shell commands)
- Goto https://console.cloud.google.com/compute/instances 
- Click "SSH" next to your VM
The remote shell should open in a new browser window

## Port Forwarding
You need to forward the TCP and UDP ports 15636-15637 in the firewall settings to allow players to connect:
- Goto https://console.cloud.google.com/networking/firewalls
- Click "Create Firewall Rule"
- Enter a suitable name like "enshrouded"
- Select "Specified target tags" as Targets and enter the tag "enshrouded" (same as the VM's network tag)
- Select "IP ranges" as Source filter and enter the range "0.0.0.0/0"
- Check "TCP" and enter the range 15636-15637
- Check "UDP" and enter the range 15636-15637
- Click "Create"

## Optional: Setup Static IP
If you want your server to always have the same IP:
- Goto https://console.cloud.google.com/networking/addresses
- Click "Reserve" next to the IP address currently used by your VM 
❗ **Note:** Static IPs increase the monthly fee (after trial phase) 

## Optional: Setup DynDNS
Instead of a static IP you can setup a DynDNS service so that your server is always reachable at the same host name.  
- Goto https://www.noip.com/remote-access (up to 3 DNS entries for free - but the entries need to be "confirmed" every 30 days)
- Create an account
- After you verified your account, you will be asked to create your first DNS entry (e.g. "epicenshrouded.hopto.org")
- Create a group for your DNS entry and make a note of user and password (you will need those later): https://my.noip.com/dynamic-dns/groups

## Optional: Create mega.nz account
You can skip this step, if you don't want the server to automatically backup your savegame to the [mega.nz Cloud](https://mega.nz/)
- Goto https://mega.nz/ and create new account (20GB free space)

## Optional: Schedule Start/Stop
The entrypoint.sh script automatically performs a savegame backup on shutdown.
So to perform a backup at least once a day, you should schedule an automatic shutdown.  
You can skip this step, if you don't want automatic backups and want the VM to run 24/7 (ok during the free trial)

First you need to grant the default service account the permission to start/stop your VM: 
- Goto https://console.cloud.google.com/iam-admin
- Select the checkbox "Include Google-provided role grants"
- Edit the account ending with "@compute-system.iam.gserviceaccount.com"
- Add the role "Compute Instance Admin (v1)" and save

Then create the schedule and assign your VM to it:
- Open your VM from https://console.cloud.google.com/compute/instances  
- Select "Instance Schedule" and click "Create Schedule"
- Enter a suitable name like "stop-at-4am"
- Select your region
- Enter a stop time
- Optional: Enter a start time
- Enter your timezone
- Enter "Repeat daily" as frequency
- Click "Create"

## Create the Docker Container
In this step you will need to clone this git repository to the VM, build the docker image and create the docker container from the built image
- Clone GIT repo using `git clone https://github.com/Chris-D-Turk/enshrouded-docker-image`
- Configure environment variables (you can also change these later within the running container): `vim enshrouded-docker-image/container/proton/enshrouded-server-env.sh`
- Build the docker image and create the container:
```bash
docker volume create enshrouded-persistent-data
docker build enshrouded-docker-image/container/proton
docker run \
  --detach \
  --name enshrouded-server-proton \
  --mount type=volume,source=enshrouded-persistent-data,target=/home/steam/enshrouded/savegame \
  --publish 15636:15636/udp \
  --publish 15637:15637/udp \
  {IMAGE_ID_FROM_DOCKER_BUILD}
```
The docker should appear as running: `docker ps -a`  
The Enshrouded Dedicated Server will be installed using SteamCMD on first boot - you can monitor the progress using: `docker logs -f enshrouded-server-proton`  
When this is done, you should be able to connect to the server using the public IP (see VM instances) 

## Optional: Upload your existing savegame
- Stop the server: `systemctl stop enshrouded-server`
- Upload your savegame using the SSH window upload function
- Copy and replace the existing savegame files
```bash
cp ~/{SAVEGAME_ID} /var/lib/docker/volumes/enshrouded-persistent-data/_data/3ad85aea
cp ~/{SAVEGAME_ID}_info /var/lib/docker/volumes/enshrouded-persistent-data/_data/3ad85aea_info
```
- Restart the server: `systemctl start enshrouded-server`

## Troubleshoot
Useful commands:
- query the systemd service status: `systemctl status enshrouded-server`
- start the systemd service: `systemctl start enshrouded-server`
- stop the systemd service: `systemctl stop enshrouded-server`
- check the logs: `docker logs -f enshrouded-server-proton`
- open a shell in the running container (to update the enshrouded-server-env.sh for example): `docker exec -it enshrouded-server-proton bash`