# UTMarketplace Mobile Frontend Development Guide

## Installing requirements

1. Clone the repo and create and activate a virtual environment as below.

```shell
git clone <github url> <target>
cd <target>

python3 -m venv venv
# For linux, macos
source venv/bin/activate
# OR Windows Powershell
venv\Scripts\Activate.ps1
```

2. Install requirements
```shell
python3 -m pip install "fastapi[standard]"
python3 -m pip install -r backend/requirements.txt
```
