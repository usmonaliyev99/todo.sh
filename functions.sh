#!/bin/bash

# Initial function
init() {

  # Create db file, if it does not exist
  if [[ ! -f $DB_FILE ]]; then

    touch $DB_FILE
  fi
}


# main menu
menu() {

  pos=1

  while true;
  do
    # print menu
    show_menu $pos

    # read movement
    read -n 1 key

    # limit for movemment
    if [[ ($pos == 1 && $key == "k") || ($pos == 5 && $key == "j") ]]; then
      continue
    fi

    # movemment
    if [[ $key == "j" ]]; then
      pos=$((pos + 1))
    elif [[ $key == "k" ]]; then
      pos=$((pos - 1))
    fi

    # when user press enter or l button
    if [[ $key == "l" || $key == "" ]]; then
      case $pos in
        1) add_task ;;
        2) show_tasks TODO true;;
        3) mark ;;
        4) delete ;;
        5) show_tasks DONE true ;;
      esac
    fi

  done
}


# print main menu
show_menu() {
  # clearing window
  clear

  local pos=$1

  # title of main menu
  echo "TO-DO cli tool:"
  
  if [[ $pos == 1 ]]; then
    echo ">>  1. ADD"
  else
    echo "    1. ADD"
  fi

  if [[ $pos == 2 ]]; then
    echo ">>  2. LIST"
  else
    echo "    2. LIST"
  fi

  if [[ $pos == 3 ]]; then
    echo ">>  3. MARK DONE"
  else
    echo "    3. MARK DONE"
  fi

  if [[ $pos == 4 ]]; then
    echo ">>  4. DELETE"
  else
    echo "    4. DELETE"
  fi

  if [[ $pos == 5 ]]; then
    echo ">>  5. LIST OF DONE TASKS"
  else
    echo "    5. LIST OF DONE TASKS"
  fi

}


# generate a new id
id() {
  # get last id from db file
  id=$(tail -n 1 $DB_FILE | cut -d '|' -f 1)

  echo $((id+1))
}


# adding new task
add_task() {
  # clearing window
  clear

  # header
  echo -e "--- ADD NEW TASK ---\n"

  local id=$(id)
  read -p "Enter task: " name

  # insert new line to db file as new task
  echo "$id|$name|TODO" >> $DB_FILE

  # waiting to see about new task
  echo -e "\nNew task is added."
  echo "Press any key to continue..."

  read -n 1
}


# print todos which are in $1 status
show_tasks() {
  # clearing window
  clear

  local status=$1
  local wait=$2

  # print todos which are only in TODO status
  grep -e "|${status}$" -e 'ID|NAME' $DB_FILE | cut -d '|' -f 1,2 | column -s '|' -t

  if [[ $wait == true ]]; then
    echo -e "\nPress any key to continue..."
    read -n 1
  fi
}

mark() {
  # print all tasks which are in todo
  show_tasks TODO false
  
  if [[ -z $1 ]]; then
    local status='DONE'
  else
    local status=$1
  fi

  echo ''
  read -p "Enter id of todo to mark: " todo_id

  # replace the status of todo
  sed -i "s/^$todo_id|\(.*\)|TODO/$todo_id|\1|DONE/" $DB_FILE

  # waiting to see about new task
  echo -e "\nTask is done."
  echo "Press any key to continue..."
  read -n 1
}


# delete task
delete() {
  # print all tasks which are in todo
  show_tasks TODO false

  echo ''
  read -p "Enter id of todo to delete: " todo_id

  sed -i "/^$todo_id|/d" $DB_FILE

  # waiting to see about new task
  echo -e "\nTask is deleted."
  echo "Press any key to continue..."
  read -n 1
}
