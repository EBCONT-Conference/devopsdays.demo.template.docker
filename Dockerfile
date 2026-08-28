FROM python:3.14.7-slim

WORKDIR /app

COPY src /app

RUN apt-get update -y
RUN apt-get install curl nano -y

EXPOSE 80

HEALTHCHECK --interval=10s --timeout=10s --start-period=5s --retries=3 CMD curl --fail http://localhost:80/index.html || exit 1

CMD ["python", "-m", "http.server", "80"]