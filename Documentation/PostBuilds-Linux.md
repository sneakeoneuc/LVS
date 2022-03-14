# 1	MOUNT DATADRIVE – LINUX
#### (IF APPLICABLE)

Once the end protection is installed, we need to mount the data disk, and run the Disk Encryption command:

1.	SSH to the server, then run fdisk:

`sudo fdisk /dev/sdc`

Run the following steps in fdisk:

```bash
Command (m for help): n
Partition type:
   p   primary (0 primary, 0 extended, 4 free)
   e   extended
Select (default p): p
Partition number (1-4, default 1): 1
First sector (2048-629145599, default 2048): (press enter)
Using default value 2048
Last sector, +sectors or +size{K,M,G} (2048-629145599, default 629145599): (press enter)
Using default value 629145599
Partition 1 of type Linux and of size 300 GiB is set


Command (m for help): p

Disk /dev/sdc: 322.1 GB, 322122547200 bytes, 629145600 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disk label type: dos
Disk identifier: 0xbdf15bb2

   Device Boot      Start         End      Blocks   Id  System
/dev/sdc1            2048   629145599   314571776   83  Linux


Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.
````

2.	Run mkfs, and use ext4:
```bash
sudo mkfs -t ext4 /dev/sdc1`

mke2fs 1.42.9 (28-Dec-2013)
Discarding device blocks: done
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
19660800 inodes, 78642944 blocks
3932147 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=2227175424
2400 block groups
32768 blocks per group, 32768 fragments per group
8192 inodes per group
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208,
        4096000, 7962624, 11239424, 20480000, 23887872, 71663616

Allocating group tables: done
Writing inode tables: done
Creating journal (32768 blocks): done
Writing superblocks and filesystem accounting information: done
```


3.	Create a new folder and Mount it to the new partition.  We mount data drives directly under **/.**
```bash

[root@AZVM-CNC-EQB-HUB-ES-03 ~]# mkdir /datadrive
[root@AZVM-CNC-EQB-HUB-ES-03 ~]# sudo mount /dev/sdc1 /datadrive
```

4.	Get the UUID of the disk

 ```bash
[root@AZVM-CNC-EQB-HUB-ES-03 ~]# sudo -i blkid

/dev/sda1: UUID="0caac3ee-ef91-4c0b-bdef-3cf3dc1a0ab7" TYPE="xfs"
/dev/sda2: UUID="ee857b79-91d4-47d6-aa3f-18e51732fee6" TYPE="xfs"
/dev/sdc1: UUID="12f598d7-e48c-4617-8bbd-e3ffd7e2a58e" TYPE="ext4"
/dev/sdb1: UUID="2b04aeee-d71c-4cf8-ada7-8b7336111bda" TYPE="ext4"
```

5.	Add the UUID and line to /etc/fstab using this line and save:

```bash
UUID=0866fc81-f0c5-49e3-92e4-c3fc3f015a0f /datadrive   ext4   defaults,nofail   1   2
```

Use **vi** to add it. – **sudo vi /etc/fstab**

6.	Then run **fstrim**

 `[root@AZVM-CNC-EQB-HUB-ES-03 ~]# sudo fstrim /datadrive`



# **2	AUTOMATED SHELL SCRIPT PROCESS**

Once the Linux VM is built, you can run the **Function* Run-AzureRunCommand ***. It will automatically run all scripts in a particular folder. 

Function: [CMP-LVSDE-TF-VM >TF >Az_LinuxVM_v3 >PowershellScript >AzureRunCommand.ps1 ](https://lvs1code.visualstudio.com/CloudManagementPlatform/_git/CMP-LVSDE-TF-VM?path=/TF/Az_LinuxVM_v3/PowershellScript/AzureRunCommand.ps1 "AzureRunCommand.ps1")

**Script Folder: **[CMP-LVSDE-TF-VM > TF > Az_LinuxVM_v3 > ShellScripts](https://lvs1code.visualstudio.com/CloudManagementPlatform/_git/CMP-LVSDE-TF-VM?path=/TF/Az_LinuxVM_v3/ShellScripts "TF > Az_LinuxVM_v3 > ShellScripts")

| Script Name  | Function  |
| :------------ | :------------ |
|  install_qualys.sh |  Download Qualys and Install + Registration  |
|  manual_hardening_steps.sh | Hardens the OS according to EQ specs  |
|  MicrosoftDefenderATPOnboardingLinuxServer.py |  Installs Microsoft Defender ATP for Linux  |
| sentinelone_agent_install.sh   |  Installs SentinelOne  (MDATP is replacing this)|
  set_snmp.sh |Sets SNMP string for LogicMonitor monitoring|

It looks in folder above for shell scripts then runs a remote Azure Run Command for shell scripts and does a for each loop for each script in that folder. 

How to Run Script:

1. Navigate to Function Folder (in Powershell 7, or in Terminal (**bash**))
2. Run AzureRunCommand.ps1
3. The example below shows the command so you can run the Powershell Function

```bash
    Run-AzureRunCommand -subscription -ResourceGroup bobprodtesting -VMName bmprodlinux2 -RunShellScripts RunShellScript -pathToScripts C:\GitRepo\CMP-LVSDE-TF-VM\TF\EQBank_Az_LinuxVM_v1\Shell
```Scripts

**Note:** update Subscription, RG, VMname