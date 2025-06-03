import os

class Config:
    SECRET_KEY = os.environ.get("SECRET_KEY", "default-insecure-key")
    DATABASE_URL = os.environ.get("DATABASE_URL")
    UPLOAD_FOLDER = os.environ.get("UPLOAD_FOLDER", "/var/uploads")