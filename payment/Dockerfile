FROM python:3.13.17-slim-bookworm

EXPOSE 8080

WORKDIR /app

RUN apt-get update && \
    apt-get upgrade -y && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd --gid 10001 app && \
    useradd --uid 10001 --gid app --create-home --shell /usr/sbin/nologin app

COPY requirements.txt ./
RUN pip install --no-cache-dir --requirement requirements.txt

COPY --chown=10001:10001 *.py ./

LABEL org.opencontainers.image.source="https://github.com/0x52616469616e74/robot-shop"

ENV SHOP_PAYMENT_PORT=8080 \
    PYTHONUNBUFFERED=1

USER 10001:10001

CMD ["gunicorn", "payment:app", "--bind", "0.0.0.0:8080", "--workers", "2", "--access-logfile", "-", "--error-logfile", "-"]

