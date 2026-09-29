FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . /app

RUN pip install --no-cache-dir -e .

RUN mkdir -p /app/workspace /app/skills /app/.openspace /app/logs

ENV PYTHONUNBUFFERED=1
ENV OPENSPACE_WORKSPACE=/app/workspace
ENV OPENSPACE_HOST_SKILL_DIRS=/app/skills

EXPOSE 8080

CMD ["openspace-mcp", "--transport", "sse", "--host", "0.0.0.0", "--port", "8080"]
