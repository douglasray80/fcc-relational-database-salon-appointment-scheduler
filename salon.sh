#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

MAIN_MENU() {
  # print any arguments
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  # get available services from db
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo -e "\nWelcome to My Salon, how can I help you?"
  # print available services
  echo "$AVAILABLE_SERVICES" | while IFS='|' read ID NAME
  do
    echo "$ID) $NAME"
  done
  # get customer input for service
  read SERVICE_ID_SELECTED
  # retrieve service name from db
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME ]]
  then
    # return to service select menu
    MAIN_MENU "That is not a valid option."
  else
    # prompt customer to input phone number
    echo -e "\nPlease enter your phone number:"
    read CUSTOMER_PHONE
    # get existing customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    # if customer doesn't exist
    if [[ -z $CUSTOMER_ID ]]
    then
      # get new customer name
      echo -e "\nPlease enter your name:"
      read CUSTOMER_NAME
      # insert new customer info
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      # get customer_id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    else
      # get customer name
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
    fi
    # get appointment time
    echo -e "\nHi $CUSTOMER_NAME, What time would you like your $SERVICE_NAME appointment to be?"
    read SERVICE_TIME
    # insert new appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    # print confirmation
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi

}

MAIN_MENU
