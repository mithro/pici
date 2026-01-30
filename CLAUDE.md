# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PICI (Providing Infrastructure for FPGA Continuous Integration) manages Raspberry Pi units connected to Arty FPGA boards for remote CI testing and interactive use. Pis have no local storage -- they network-boot from a central server via PXE/NFS. A Django web app controls FPGA demos, bitstream uploads, camera streaming, and PoE power management via SNMP.

Full documentation: https://github.com/CarlFK/pici/wiki

## Key Commands

### Ansible Deployment

```bash
# Full deployment to a specific host (run from repo root)
ansible-playbook ansible/site.yml --inventory-file ansible/inventory/hosts --user root --limit <host>

# Pi-specific deployment (must be in maintenance mode first)
sudo maintenance.sh   # on the server, enables read-write NFS
ansible-playbook ansible/site.yml -vv --inventory-file ansible/inventory/hosts --user root --limit pi
sudo production.sh    # switch back to read-only NFS + overlayroot
```

### Django (on the server at /srv/www/pib)

```bash
python manage.py runserver        # dev server
python manage.py makemigrations
python manage.py migrate
python manage.py collectstatic
```

The Django project is `pib`, settings at `ansible/roles/site/files/pib/pib/settings.py`. Production overrides live in `local_settings.py` (gitignored).

## Architecture

### Host Groups (ansible/inventory/hosts)

| Group | Role | Description |
|-------|------|-------------|
| `nbp` | firewall, nfs, img, fixpi, pxe | Network boot server -- serves Pi root filesystems via NFS, runs DHCP/TFTP |
| `uhubctl` | uhubctl | USB hub power control |
| `pig` | site, wssh, cam/stream-server, ci | Django web gateway -- hosts all web apps, camera stream aggregation, CI |
| `onpi` (pi) | cam/pi, onpi | Individual Pi+FPGA units -- camera capture, FPGA loading, TFTP, pistat |

### Django Apps (ansible/roles/site/files/pib/)

| App | URL | Purpose |
|-----|-----|---------|
| `pibfpgas` | `/fpgas/` | Board listing, per-Pi control pages, demo launcher |
| `pibup` | `/pibup/` | Bitstream upload via SFTP to individual Pis |
| `snmp_switch` | `/snmp/` | PoE port power on/off via SNMP (Netgear switches) |
| `pistat` | `/pistat/` | Real-time Pi status via WebSockets (Channels + Redis) |
| `pibdemos` | (internal) | Demo execution -- triggers openFPGALoader/LiteX on Pis |

Root `/` redirects to `/fpgas/`. ASGI via Daphne with Redis channel layer on `127.0.0.1:6379`.

### Network Layout

- Subnet `10.21.0.0/24`, Pi IPs assigned as `10.21.0.{100+port}`
- Server has two interfaces: `eth-uplink` (internet) and `eth-fpga` (local PoE switch), named via udev rules
- Pis boot diskless over NFS; production mode uses overlayroot (tmpfs overlay on read-only NFS root)

### Ansible Roles (ansible/roles/)

- **site** -- Django deployment (apt, nginx, certbot, daphne/gunicorn/uvicorn)
- **nfs** -- NFS server for Pi root filesystems
- **pxe** -- PXE/DHCP/TFTP boot infrastructure
- **fixpi** -- Base Pi OS config (boot params, SSH, hostname, NFS mounts, overlayroot)
- **onpi** -- On-Pi services (FPGA loading scripts, pistat, TFTP, tmux)
- **cam** -- Camera streaming (`cam/pi` for capture, `cam/stream-server` for RTMP/HLS aggregation via nginx-rtmp)
- **ci** -- CI tests (t1: GPIO wire test, f4pga: toolchain build test)
- **firewall** -- nftables rules
- **img** -- SD card image processing
- **wssh** -- Browser-based SSH terminal

### FPGA Workflow

1. User builds bitstream locally (F4PGA toolchain, `TARGET="arty_35" make -C counter_test`)
2. Uploads `.bit` file via web UI or SCP to Pi
3. Loads onto Arty board: `openFPGALoader -b arty Uploads/top.bit`
4. Observes results via camera stream (HLS, ~30-60s latency)

## Tech Stack

- **Python/Django 4.1** with Channels/Daphne for WebSocket support
- **Ansible** for all infrastructure automation
- **nginx** as reverse proxy + RTMP streaming server
- **SQLite** database (Pi model with port, MAC, serial, location, cable_color)
- **Paramiko** for SFTP transfers, **pysnmp** for switch control
- **Hatchling** build backend for Python sub-packages

## Known Issues (TECHDEBT.md)

- Ethernet interface naming instability between onboard and USB dongle (mitigated by udev rules)
- Occasional boot failures possibly related to PoE power delivery; `core_freq` tuning in config.txt
- Camera errors on specific Pi+camera combos below `core_freq=500`
