FROM python:3.9-slim

COPY . /app
WORKDIR /app
RUN pip install flask 

EXPOSE 8080 
CMD ["python", "app.py"]
