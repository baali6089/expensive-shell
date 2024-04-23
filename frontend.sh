#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
echo "please enter db password:"
read mysql_root_password


VALIDATE(){
    if [ $1 -ne 0 ]
    then
         echo -e "$2.... $R failure $N"
         exit 1
    else
         echo -e "$2....$G success $N"   
    fi       
}

if [ $USERID -ne 0 ]
then 
     echo "please run this script with root access."
     exit 1 #manually exit .if error comes
else
     echo "you are super user" 
fi

dnf install nginx -y &>>$LOGFILE 
VALIDATE $? "installing nginx"

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "enabling nginx"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "starting nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
VALIDATE $? "removing exist content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
VALIDATE $? "downloading frontend code"

cd /usr/share/nginx/html &>>$LOGFILE
unzip /tmp/frontend.zip &>>$LOGFILE
VALIDATE $? "extrating frontend code"

cp /home/ec2-user/expensive-shell/expense.conf etc/nginx/default.d/expense.conf &>>$LOGFILE
VALIDATE $? "copied expense conf"

systemctl restart nginx &>>$LOGFILE
VALIDATE $? "restarting nginx"