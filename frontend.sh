#!/bin/bash
#Created by : Jayachandra_kumar Date:03-01-2025
#Topic: bash script to configure web-server
#Sub-topic/Scenario: Nginx



USERID=$( id -u ) # command to check root user id

# colors
R="\e[31m" #red
G="\e[32m" #Green
Y="\e[33m" #yellow
N="\e[0m" #Default color

# Redirctores
LOGS_FOLDER="/var/log/expense-bash-logs"
LOG_FILE="$(echo $0 | cut -d "." -f1)"
TIMESTAMP="$(date +%Y-%m-%d-%H-%M-%S)"
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

# Funtion
validation(){
     if [ $1 -ne 0 ]
    then
        echo -e "$2 ...$R Failure $N"
        exit 1
    else
        echo -e "$2... $G Success $N"
    fi
}

mkdir -p $LOGS_FOLDER

echo "Script started Executing at :$TIMESTAMP" &>>$LOG_FILE_NAME

if [ $USERID -ne 0 ]
then
    echo -e "$R Error::You should have sudo permission to exicute script $N"
    exit 1 #other then 0 will exit the script
fi

dnf install nginx -y &>>$LOG_FILE_NAME
validation $? "installing nginx server"

systemctl enable nginx &>>$LOG_FILE_NAME
validation $? "enabling nginx server"

systemctl start nginx &>>$LOG_FILE_NAME
validation $? "starting nginx server"

rm -rf /usr/share/nginx/html/*
validation $? "clearing html folder"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE_NAME
validation $? "Downloading frontend"

cd /usr/share/nginx/html
validation $? "Change directory"

unzip /tmp/frontend.zip &>>$LOG_FILE_NAME
validation $? "unzipping frontend"

cp /home/ec2-user/expense-bash/expense.conf /etc/nginx/default.d/expense.conf &>>$LOG_FILE_NAME
validation $? "Coping expense conf file"

systemctl restart nginx &>>$LOG_FILE_NAME
validation $? "restarting nginx server"