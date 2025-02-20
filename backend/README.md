# UTMarketplace Mobile Backend Development Guide

## Initial setup

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
python3 -m pip install -r backend/requirements.txt
```

## Running the server

1. Activate venv (ensure that you're in the project root)
```shell
source venv/bin/activate
```

2. Ensure you have an appropriate `.env` file in `backend/`

3. Navigate to `backend/` and run the server with `uvicorn`

```shell
cd backend/
uvicorn app.main:app --reload --port 8000  # you can specify another port if needed
```