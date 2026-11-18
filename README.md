# Overview

This project is a lightweight backup and recovery utility designed to protect the database used by an x-ui-based system. Its purpose is to create regular, time-stamped backups so that important configuration and service data can be restored quickly in the event of system failure, accidental changes, or data corruption. Rather than acting as a full application, it functions as a practical reliability tool that helps maintain continuity for an operational environment.

The backup process is built around automation and retention management. It creates a fresh backup folder for each date, preserves the database in a safe location, and removes older local copies to prevent unnecessary storage buildup. An extended version of the script also synchronizes these backups to a remote server and deletes outdated remote backups, creating an additional layer of protection. This makes the system more resilient by ensuring that recent backups are available both locally and on a remote machine.

Overall, this repository is focused on disaster recovery and operational stability. It is intended to reduce the risk of data loss while making backup management easier, more consistent, and less dependent on manual intervention.

## Clone a specific branch and directory

```bash
git clone -b <branch-name> --single-branch --depth 1 https://github.com/joy4theluv/mgmt-ray.git
# latest commit
```

```bash
git clone -b <branch-name>ch --depth 1 \

https://github.com/joy4theluv/mgmt-ray.git \

/root/mgmt-ray # Clone to Specific directory

cd /root/mgmt-ray 
```
```bash
git branch --show-current # verify the branch
```

