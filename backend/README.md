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

## Generating code from OpenAPI specification file

This will output the FastAPI boilerplate to `app_draft`.
```shell
cd backend/
fastapi-codegen --input OpenAPI.yaml --output app_draft
```

After generating the code, copy-paste the necessary snippets from `app_draft/` to `app/` (this includes the models and the endpoint definitions)

## Recipe for OpenAPI specification

### POST Request OpenAPI specification recipe

Sample request body definition
```
/sign-up:
    post:
      summary: Sign up a new user
      description: Registers a new user using an email and password.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - email
                - password
              properties:
                email:
                  type: string
                  format: email
                  example: "student@utoronto.ca"
                  description: "Must be a valid University of Toronto email (utoronto.ca or mail.utoronto.ca)."
                password:
                  type: string
                  format: password
                  example: "P@ssword123"
                  description: "Must be at least 8 characters, contain 1 uppercase letter, 1 number."
```

Things to notice:
- Always include `summary`, `description`, and `requestBody`.
  - `summary` is a one-line summary of the endpoint
  - `description` is a full description of the behaviour of that response (e.g., if the endpoint has pagination and how clients should work with it)
- For `requestBody`
  - make sure it is `required` for POST
  - we always use JSON, specify what schema property are required
  - for each schema property, specify `type`, `format` (if applicable), `example`, and `description`.

