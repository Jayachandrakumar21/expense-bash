#!/bin/bash
#Created by : Jayachandra_kumar Date:03-01-2025
#Topic: configuring database server 
#Sub-topic/Scenario: mysql-server



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

dnf install mysql-server -y &>>$LOG_FILE_NAME
validation $? "Installing mysql-server"

systemctl enable mysqld &>>$LOG_FILE_NAME
validation $? "Enabling Mysqld Server"

systemctl start mysqld &>>$LOG_FILE_NAME
validation $? "Starting Mysqld server"

mysql_secure_installation --set-root-pass ExpenseApp@1 -e 'show databases;' &>>$LOG_FILE_NAME
if [ $? -n 0 ]
then
    echo "Mysql server root passwd not set" &>>$LOG_FILE_NAME
    mysql_secure_installation --set-root-pass ExpenseApp@1
    validation $? "Setting-up mysql root password"
else
    echo "MYSQL Root password already set.. $Y Skipping $N "
fi
