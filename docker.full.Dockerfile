# syntax = devthefuture/dockerfile-x
FROM ./docker.base.Dockerfile

WORKDIR $APPDIR

# copy the code base
COPY src $FLASKDIR

# setup server runtime
WORKDIR $FLASKDIR
