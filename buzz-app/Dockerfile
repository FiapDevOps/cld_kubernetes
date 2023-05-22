FROM python:3.8-alpine

COPY requirements.txt /src/requirements.txt
RUN pip install -r /src/requirements.txt

COPY app.py /src
COPY buzz /src/buzz

CMD ["python", "/src/app.py"]