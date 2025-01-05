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

dnf module disable nodejs -y &>>$LOG_FILE_NAME
validation $? "disabling nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
validation $? "Enabling nodejs 20"

dnf install nodejs -y &>>$LOG_FILE_NAME
validation $? "Installing nodejs"

id expense &>>$LOG_FILE_NAME
if [ $? -ne 0 ]
then
    useradd expense
    validation $? "Expense user adding"
else
    echo -e "Expense User already Exists.. $R Skipping $N"
fi

mkdir -p /app &>>$LOG_FILE_NAME
validation $? "Creating app Directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE_NAME
validation $? "Downloading expense-backend"

cd /app
rm -rf /app/*

unzip /tmp/backend.zip &>>$LOG_FILE_NAME
validation $? "unzipping backend app"

cd /app

npm install &>>$LOG_FILE_NAME

# validation $? "Installing Dependensis"

# cp /home/ec2-user/expense-bash/backend.service /etc/systemd/system/backend.service

# systemctl daemon-reload &>>$LOG_FILE_NAME
# validation $? "daemon-reloading"

# systemctl start backend &>>$LOG_FILE_NAME
# validation $? "starting backend service"

# systemctl enable backend &>>$LOG_FILE_NAME
# validation $? "enabling backend service"

# dnf install mysql -y &>>$LOG_FILE_NAME
# validation $? "Installing mysql client"

# mysql -h mysql.simplifysuccess.life -uroot -pExpenseApp@1 < /app/schema/backend.sql

# systemctl restart backend &>>$LOG_FILE_NAME
# validation $? "restarting backend service"