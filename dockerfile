#base image
#-slim tag means it is a lightweight, stripped-down version
FROM python:3.12.7-slim

#set up working directory
WORKDIR /app

#copy file into the container docker image that has been create
COPY . .

#instal dependency : requirements.txt
#download and install packages from scratch without saving them to your local storage
RUN pip install --no-cache-dir -r requirements.txt

#run the scripts
CMD ["python", "app.py"]
