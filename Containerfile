FROM python:3.11-slim

ARG IMAJEV_REF=ccf586d43d2a580319b6535c893668904d909eb9

ENV PATH="/app/imajev/.venv/bin:${PATH}" \
    HF_HOME=/app/imajev/.cache/huggingface \
    HOME=/tmp \
    XDG_CACHE_HOME=/tmp/.cache \
    TRITON_CACHE_DIR=/tmp/.triton \
    CC=/usr/bin/gcc \
    CXX=/usr/bin/g++ \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN apt-get update && \
    apt-get install --no-install-recommends -y build-essential ca-certificates git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone https://github.com/mohit67890/imajev /app/imajev && \
    git -C /app/imajev checkout "${IMAJEV_REF}" && \
    rm -rf /app/imajev/.git

WORKDIR /app/imajev

# OpenShift runs containers with a random UID. Keep runtime download targets
# writable through the root group without making the source tree writable.
RUN mkdir -p adapters .cache/huggingface && \
    chgrp -R 0 artifacts adapters .cache && \
    chmod -R g+rwX artifacts adapters .cache

RUN python -m venv .venv && \
    .venv/bin/pip install --no-cache-dir --upgrade pip && \
    .venv/bin/pip install --no-cache-dir -e ".[serve,torch]"

VOLUME ["/app/imajev/.cache/huggingface", "/app/imajev/adapters"]

EXPOSE 8765

ENTRYPOINT ["sh", "-c", "hf download mohit67890/imajev-4b --local-dir adapters/imajev-4b && python scripts/download_model.py --model 4b && exec python scripts/playground/server.py --backend torch --model-bundle artifacts/model-qwen4b.json --adapter adapters/imajev-4b --calibration adapters/imajev-4b/calibration.json --model-name imajev-4b --host 0.0.0.0 --port 8765"]
