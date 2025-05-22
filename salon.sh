#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# greetings
echo -e "\n~~~~~ MY SALON ~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

SERVICES() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "$($PSQL "SELECT * FROM services")" | while read SERVICE_ID BAR SERVICE_NAME 
  do
    # list all services
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  # receive user's choice
  read SERVICE_ID_SELECTED
  SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  # filter out the input is not a number
  # if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  # then
  #   SERVICES "I could not find that service. What would you like today?"
  # else
  #   SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  # fi
  

  # get service name based on user's choice
  if [[ -z $SERVICE_NAME_SELECTED ]]
  then
    SERVICES "I could not find that service. What would you like today?"
  else
    # get phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    # get customer's name
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_NAME ]]
    then
      # no phone number, ask for name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      # insert phone and name into table customers
      INSERT_CUSTOMER_NAME_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    # trim the output for unused spaces at the begining and the end of string
    CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')
    SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME_SELECTED | sed -r 's/^ *| *$//g')

    # customer exists. Ask for time for this appointment
    echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
    read SERVICE_TIME

    # insert new appoinment time
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
  fi
}

SERVICES