#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Lily's Beauty Salon ~~~~~\n"
MAIN_MENU() {
  # if main menu is printing an argument 
  if [[ $1 ]]
  then 
    echo -e "\n$1\n"
  fi

  # printing the services menu
  echo "How may I help you?"
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
  echo "$SERVICE_ID) $SERVICE_NAME"
   
  done
  # reading the selection
  read SERVICE_ID_SELECTED   

  # if SERVICE_ID_SELECTED IS NOT A INT
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "Please enter a valid service ID"
  else
    # if service is not in the options
    SERVICE_SELECTION_NAME="$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")"
    SERVICE_NAME_FORMAT=$(echo $SERVICE_SELECTION_NAME | sed 's/^ +//g')
    if [[ -z $SERVICE_SELECTION_NAME ]]
    then 
      MAIN_MENU "Please enter a valid service ID"
    else
      # get customer phone
      echo -e "\nWhat is your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_PHONE_RESULT="$($PSQL "SELECT phone FROM customers WHERE phone= '$CUSTOMER_PHONE'")"

      # if number does not exist
      if [[ -z $CUSTOMER_PHONE_RESULT ]]
      then 
        echo -e "\nI don't have that phone number register, What's your name?"
        read CUSTOMER_NAME

        ADD_CUSTOMER_RESULT="$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")"
        CUSTOMER_ID="$($PSQL "SELECT customer_id FROM customers WHERE name = '$CUSTOMER_NAME'")"

        echo -e "\nWhat time would you like your $SERVICE_NAME_FORMAT, $CUSTOMER_NAME?"
        read SERVICE_TIME

        # printing final message
        INSERT_APPOINTMENT_RESULT="$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES( $CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME') ")"
        echo -e "\nI have put you down for a $SERVICE_NAME_FORMAT at $SERVICE_TIME, $CUSTOMER_NAME."
        else
        # if the customer is in the database
        # get customer name
        CUSTOMER_NAME="$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")"
        CUSTOMER_NAME_FORMAT=$(echo $CUSTOMER_NAME | sed 's/^ +//g')
        # get customer id 
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    
        echo -e "\nWhat time would you like your $SERVICE_NAME_FORMAT, $CUSTOMER_NAME_FORMAT?"
        read SERVICE_TIME

        # printing final message
        INSERT_APPOINTMENT_RESULT="$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES( $CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME') ")"
        echo -e "\nI have put you down for a $SERVICE_NAME_FORMAT at $SERVICE_TIME, $CUSTOMER_NAME_FORMAT."

    
      fi
    fi

    fi

  

  

  
}

MAIN_MENU 
