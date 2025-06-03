# --- Etapa de construcción ---
FROM python:3.11-slim-bookworm AS build

WORKDIR /opt/CTFd

# Instala dependencias de compilación
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        libffi-dev \
        libssl-dev \
        libpq-dev \
        git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && python -m venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

COPY . /opt/CTFd

# Instala requirements + psycopg2-binary explícitamente
RUN pip install --no-cache-dir -r requirements.txt psycopg2-binary \
    && for d in CTFd/plugins/*; do \
        if [ -f "$d/requirements.txt" ]; then \
            pip install --no-cache-dir -r "$d/requirements.txt";\
        fi; \
    done;

# --- Etapa de producción ---
FROM python:3.11-slim-bookworm AS release
WORKDIR /opt/CTFd

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libffi8 \
        libssl3 \
        libpq5 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --chown=1001:1001 . /opt/CTFd
COPY --chown=1001:1001 --from=build /opt/venv /opt/venv

RUN useradd \
    --no-log-init \
    --shell /bin/bash \
    -u 1001 \
    ctfd \
    && mkdir -p /var/log/CTFd /var/uploads \
    && chown -R 1001:1001 /var/log/CTFd /var/uploads /opt/CTFd \
    && chmod +x /opt/CTFd/docker-entrypoint.sh

ENV PATH="/opt/venv/bin:$PATH" \
    DATABASE_URL="postgresql://user:pass@host:5432/db"

USER 1001
EXPOSE 8000
ENTRYPOINT ["/opt/CTFd/docker-entrypoint.sh"]