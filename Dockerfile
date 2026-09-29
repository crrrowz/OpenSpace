# Stage 1: Build the React Dashboard GUI
FROM node:20-slim AS frontend-builder
WORKDIR /app/apps/dashboard
COPY apps/dashboard/package*.json ./
RUN npm install
COPY apps/dashboard/ ./
RUN npm run build

# Stage 2: Runtime Environment for OpenSpace MCP & Dashboard
FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    build-essential \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . /app
COPY --from=frontend-builder /app/apps/dashboard/dist /app/apps/dashboard/dist
COPY --from=frontend-builder /app/apps/dashboard/dist /app/openspace/packaged/dashboard

RUN pip install --no-cache-dir -e .

RUN mkdir -p /app/workspace /app/skills /app/.openspace /app/logs /var/log/supervisor

ENV PYTHONUNBUFFERED=1
ENV OPENSPACE_WORKSPACE=/app/workspace
ENV OPENSPACE_HOST_SKILL_DIRS=/app/skills

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 8080 7788

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
