FROM python:3
COPY requirements.txt /tmp
COPY scripts /tmp
WORKDIR /tmp
RUN pip install -r requirements.txt
