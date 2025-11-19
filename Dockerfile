FROM node:20-bullseye

RUN apt-get update && \
    apt-get install -y postgresql postgresql-contrib && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY app/ ./
RUN npm i -D nodemon

RUN sed -i 's/\r$//' /app/entrypoint.sh && chmod +x /app/entrypoint.sh

ENV PGDATA=/var/lib/postgresql/data
RUN mkdir -p $PGDATA && chown -R postgres:postgres $PGDATA

EXPOSE 3000 5432

ENTRYPOINT ["/bin/bash", "/app/entrypoint.sh"]
