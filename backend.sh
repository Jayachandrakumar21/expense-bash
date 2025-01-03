#!/bin/bash
#Created by : Jayachandra_kumar Date:03-01-2025
#Topic: bash script to configure application server
#Sub-topic/Scenario: NodeJS>20



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

dnf module disable nodejs -y
validation $? "disabling nodejs"

dnf module enable nodejs:20 -y
validation $? "Enabling nodejs 20"

dnf install nodejs -y
validation $? "Installing nodejs"

useradd expense

mkdir -p /app

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip

cd /app

unzip /tmp/backend.zip

cd /app

npm install
validation $? "Installing Dependensis"

vim /etc/systemd/system/backend.service
systemctl daemon-reload
validation $? ""
systemctl start backend
validation $? ""
systemctl enable backend
validation $? ""
dnf install mysql -y
validation $? ""
mysql -h mysql.simplifysuccess.life -uroot -pExpenseApp@1 < /app/schema/backend.sql
systemctl restart backend
validation $? ""