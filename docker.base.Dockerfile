FROM python:3.12.2-alpine

# install app dependencies
ENV APPDIR=/srv
ENV FLASKDIR=/srv/www
ENV HOST=0.0.0.0
ENV PORT=8080

WORKDIR $APPDIR
RUN pip install --upgrade pip
COPY requirements.txt .
RUN pip install -r requirements.txt

# setup server runtime
EXPOSE 8080
WORKDIR $FLASKDIR

ENTRYPOINT ["python", "main.py"]