FROM python:3.10-alpine AS build
RUN apk update && apk add python3-dev
WORKDIR /app
COPY requirements.txt .
RUN python -m venv venv
ENV PATH="/app/venv/bin/:$PATH"
RUN pip install -U pip
RUN pip install -r requirements.txt
FROM python:3.10-alpine
ARG APP_VERSION=dev
ARG NEW_INSTALLATION_ENDPOINT=dev
ARG NEW_HEARTBEAT_ENDPOINT=dev
WORKDIR /app
COPY --from=build /app/venv /app/venv
ENV PATH="/app/venv/bin/:$PATH"
ENV PYTHONPATH /app
ENV NEW_INSTALLATION_ENDPOINT=$NEW_INSTALLATION_ENDPOINT
ENV NEW_HEARTBEAT_ENDPOINT=$NEW_HEARTBEAT_ENDPOINT
ENV APP_VERSION=$APP_VERSION
COPY . /app/
RUN python3 setup.py install
