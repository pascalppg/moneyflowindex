#base image
FROM python:3.12.7-slim

#set up working directory
WORKDIR /app

#copy file into the container
COPY . .

#instal dependency : requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

#run the scripts
CMD ["python", "app.py"]