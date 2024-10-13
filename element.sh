#!/bin/bash

PSQL="psql -U freecodecamp -d periodic_table -X --no-align -tc"

# global variable
CONDITION=NULL

# select a search condition from atomic_number, symbol or name.
CASE_CONDITION (){
  case $1 in 
  [[:alpha:]]|[[:alpha:]][[:alpha:]]) CONDITION="symbol=initcap('$1')" ;;
  [[:digit:]]|[[:digit:]][[:digit:]]|[[:digit:]]|[[:digit:]]|[[:digit:]]) CONDITION="atomic_number=$1" ;;
  *) CONDITION="name=initcap('$1')" ;;
  esac
}

#  , 

DATA_OUTPUT (){
  # request from elements.
  ELEMENT=$($PSQL "SELECT * FROM elements WHERE $CONDITION";)

  if [[ -z $ELEMENT ]]
  then
    echo "I could not find that element in the database."
  else
    echo "$ELEMENT" | while IFS="|" read ATOMIC_NUM SYM NAM
    do 
      # request from properties.
      PROPERTIES=$($PSQL "SELECT * FROM properties WHERE atomic_number='$ATOMIC_NUM';")
      
      echo "$PROPERTIES" | while IFS="|" read ATOMIC_NUM MASS MELT_P BOI_P TYP_ID
      do
        TYP=$($PSQL "SELECT type FROM types WHERE type_id=$TYP_ID;")
        MSG_OUTPUT $ATOMIC_NUM $NAM $SYM $MASS $MELT_P $BOI_P $TYP
      done
    done
  fi
} 

# The output message.
MSG_OUTPUT(){
  echo "The element with atomic number $1 is $2 ($3). It's a $7, with a mass of $4 amu. $2 has a melting point of $5 celsius and a boiling point of $6 celsius."
}

# switch case for conditions select.
MAIN_MENU(){
  if [[ -z $1 ]]
  then
    echo -e "Please provide an element as an argument." 
  else
    CASE_CONDITION $1
    DATA_OUTPUT
  fi

}

MAIN_MENU $1