#!/bin/bash
cd "$(dirname "$0")/backend"
source venv/bin/activate
exec uvicorn main:app --host 0.0.0.0 --port 8000
