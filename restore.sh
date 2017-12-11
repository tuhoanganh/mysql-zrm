#!/bin/bash

export red='\033[0;91m'
export green='\033[0;92m'
export yellow='\033[0;93m'
export nc='\033[0m'

export FILE=$(echo '/tmp/temp-zrm')
export FILE1=$(echo '/tmp/restore-zrm')
export OPT=0

echo -e "${green}[INFO  ]${nc} ======================================${green}CREDIT${nc}========================================"
echo -e "${green}[INFO  ]${nc} Don't remove the credit, thanks"
echo -e "${green}[INFO  ]${nc} ===================================================================================="
echo -e "${green}[INFO  ]${nc}"
echo -e "${green}[INFO  ]${nc} ======================================${green}AUTHOR${nc}========================================"
echo -e "${green}[INFO  ]${nc} Name  		: Hoang Anh Tu"
echo -e "${green}[INFO  ]${nc} Email 		: hoang.anh.tu.1102@gmail.com"
echo -e "${green}[INFO  ]${nc} Job title 	: DBA"
echo -e "${green}[INFO  ]${nc} ===================================================================================="
echo -e "${green}[INFO  ]${nc}"
echo -e "${green}[INFO  ]${nc} ===================================${green}INFORMATION${nc}======================================"
echo -e "${green}[INFO  ]${nc} This script will help you to restore the database was backuped by MySQL-ZRM with"
echo -e "${green}[INFO  ]${nc} level 0 and level 1 many times per day. For example:"
echo -e "${green}[INFO  ]${nc}   + 07:00 level 0"
echo -e "${green}[INFO  ]${nc}   + 09:00, 11:00, 13:00, 15:00, 17:00 level 1"
echo -e "${green}[INFO  ]${nc}   + 19:00 level 0"
echo -e "${green}[INFO  ]${nc}   + 21:00, 23:00, 01:00, 03:00, 05:00 level 1"
echo -e "${green}[INFO  ]${nc}"
echo -e "${green}[INFO  ]${nc} In a bad day, at 18:00, you lost all the data in the database (- _  -' )!!!"
echo -e "${green}[INFO  ]${nc} To restore database to 17:00 (latest backup), you have to restore to level 0"
echo -e "${green}[INFO  ]${nc} backup at 07:00 then level 1 backup at 09:00, 11:00, 13:00, 15:00 and 17:00"
echo -e "${green}[INFO  ]${nc} To do this, you have to type the restore command by hand and choose the right"
echo -e "${green}[INFO  ]${nc} directory... time by time."
echo -e "${green}[INFO  ]${nc}"
echo -e "${green}[INFO  ]${nc} It's very annoying."
echo -e "${green}[INFO  ]${nc}"
echo -e "${green}[INFO  ]${nc} With this script, you simply choose the level 0 at 07:00 (menu list 1)"
echo -e "${green}[INFO  ]${nc} and pick the level 1 at 17:00 (menu list 2) to do all the job."
echo -e "${green}[INFO  ]${nc} ===================================================================================="
echo -e "${green}[INFO  ]${nc}"
echo -e "${green}[INFO  ]${nc} ===================================${green}REQUIREMENTS${nc}======================================"
echo -e "${green}[INFO  ]${nc} - You have to install MySQL-ZRM version 3.0 at http://www.zmanda.com/download-zrm.php"
echo -e "${green}[INFO  ]${nc} - Configure MySQL-ZRM and let it run/backup for a few days."
echo -e "${green}[INFO  ]${nc} - Verify that all your backups is not FAILED or ERROR"
echo -e "${green}[INFO  ]${nc} ===================================================================================="
echo -e "${green}[INFO  ]${nc}"
echo -e "${green}[INFO  ]${nc} ====================================${green}HOW TO USE${nc}======================================="
echo -e "${green}[INFO  ]${nc} - Run this script by command: sh restore.sh"
echo -e "${green}[INFO  ]${nc} - Input your Backupset and Database's name you want to restore"
echo -e "${green}[INFO  ]${nc} - Please report any issues you meet when run this script, i'll try to fix this. Thanks"
echo -e "${green}[INFO  ]${nc}"
echo -e "${green}[INFO  ]${nc} =================================${green}IMPORTANT NOTE${nc}====================================="
echo -e "${green}[INFO  ]${nc} Test this script in a Demo Database that have closest state with your real one first"
echo -e "${green}[INFO  ]${nc} for ensuring the result is as expected"
echo -e "${green}[INFO  ]${nc} ===================================================================================="
echo -e "${green}[INFO  ]${nc}"

### Input backupset's name and check ###
printf "${yellow}[PROMPT]${nc} Input your backupset's name: "
read -r BACKUPSET

mysql-zrm-reporter --where backup-set=$BACKUPSET > /dev/null 2>&1 || ERR=1
if [[ $ERR == 1 ]];then
  echo -e "${red}[ERROR ]${nc} There are no backup set with input name. Please, check it and try again later."           
  exit 1;
else
  :
fi

export TIME0=$(mysql-zrm-reporter --fields backup-directory,backup-level,backup-status,backup-date \
--where backup-set=$BACKUPSET \
| awk '{print $2,$3,$5,$6,$7,$8,$9,$10,$11}' \
| awk 'FNR > 2' \
| grep -w 0 \
| sort -s)
export COUNT0=$(mysql-zrm-reporter --fields backup-directory,backup-level,backup-status,backup-date \
--where backup-set=$BACKUPSET \
| awk '{print $2,$3,$5}' \
| awk 'FNR > 2' \
| grep -w 0 \
| wc -l)
export CHECKDATERANGE=$(mysql-zrm-reporter --fields backup-directory,backup-level,backup-status,backup-date \
--where backup-set=$BACKUPSET \
| awk '{print $2}' \
| awk 'FNR > 2' \
| tail -c 15)

### Check config backup-date range ###
RE='^[0-9]{1,15}+$'
if [[ $CHECKDATERANGE =~ $RE ]]; then
  :
else
  echo -e "${red}[ERROR ]${nc} The script can not get the correct directory because the backup-directory or backup-date range in mysql-zrm-reporter is too small and it breaks a line into 2."
  echo -e "${red}[ERROR ]${nc} Please do following task:"
  echo -e "${red}[ERROR ]${nc} - Increase the backup-date range (default value is 25) in /etc/mysql-zrm/mysql-zrm-reporter.conf."
  echo -e "${red}[ERROR ]${nc}   For example: backup-date = 40,<,%c"
  echo -e "${red}[ERROR ]${nc} "
  echo -e "${red}[ERROR ]${nc} - Increase the backup-directory range (default value is 40) in /etc/mysql-zrm/mysql-zrm-reporter.conf."
  echo -e "${red}[ERROR ]${nc}   For example: backup-directory = 70,<"
  echo -e "${red}[ERROR ]${nc} "
  echo -e "${red}[ERROR ]${nc} - Verify that the output of below mysql-zrm-report command is in only 1 line per row"
  echo -e "${red}[ERROR ]${nc}   mysql-zrm-reporter --fields backup-directory,backup-level,backup-status,backup-date --where backup-set=BACKUP_SET_NAME | awk '{print $2}' |awk 'FNR> 2' |tail -c 15"
  echo -e "${red}[ERROR ]${nc} - Try again"
  exit 1;
fi

### Input backupset's database and check ###
printf "${yellow}[PROMPT]${nc} Input your database's name: "
read -r DATABASE

export CHECK_DATABASE=$(mysql-zrm-reporter --fields backup-level,logical-databases --where backup-set=$BACKUPSET |awk '$2 == 0' |awk '$1=$2=""; {print $0}') 

for i in $CHECK_DATABASE
do
if [[ $DATABASE == $i ]]; then
  ERR=0
  break;
else
  :
fi
done

if [[ $ERR == 0 ]]; then
  :
else
  echo -e "${red}[ERROR ]${nc} There are no database with input name or the script can not get the database name from mysql-zrm-report."
  echo -e "${red}[ERROR ]${nc} Please do following task:"
  echo -e "${red}[ERROR ]${nc} - Increase the logical-database range (default value is 20) in /etc/mysql-zrm/mysql-zrm-reporter.conf."
  echo -e "${red}[ERROR ]${nc}   For example: logical-databases  = 50,<"
  echo -e "${red}[ERROR ]${nc} "
  echo -e "${red}[ERROR ]${nc} - Check again and input the right database name."
  exit 1;
fi
### Menu List Backup Level 0 ###
while [ $OPT -le $COUNT0 ] 
echo -e "${green}[INFO  ]${nc} List Backup level [${green}0${nc}]: "
SELECTION=1
while read -r LINE;
do
  echo "$SELECTION) $LINE" 
  ((SELECTION++))
done <<< "$TIME0"

do
  printf "${yellow}[PROMPT]${nc} Choose Backup level [${green}0${nc}] (Full Backup) in above list: "
  read -r OPT

  ### Check if the input is 0 ###
  if [[ $OPT == 0 ]]; then
    export OPT=0
    echo -e "${red}[ERROR ]${nc} Input must not be 0, please try again."  
    echo ""
  fi
  
  ### Check if the input is blank when enter ###
  if [[ -z ${OPT} ]]; then
    export OPT=0
    echo -e "${red}[ERROR ]${nc} Input must not be blank, please try again."
    echo ""
  fi
  
  ### Check if the input is not an integer
  if ! [[ $OPT =~ ^-?[0-9]+$ ]] ; then
    export OPT=0
    echo -e "${red}[ERROR ]${nc} Input must be an integer, please try again."
    echo ""
  fi
  
  if [[ $OPT -le $COUNT0 ]]; then
    if [[ `seq 1 $SELECTION` =~ $OPT ]]; then
      export BACKUP=$(sed -n "${OPT}p" <<< "$TIME0")
      export BACKUP0=$(echo ${BACKUP} |awk '{print $1}')
      export BACKUP0_TIME=$(echo ${BACKUP0} |tail -c 15)
      export STEP=$(mysql-zrm-reporter --fields backup-directory,backup-level,backup-status,backup-date \
        --where backup-set=$BACKUPSET \
	| awk '{print $2,$3}' \
        | awk 'FNR > 2' \
        | sort -s \
        | sed -n "/${BACKUP0_TIME}/,\$p" \
        | awk 'FNR > 1' \
        | sed '/ 0/q' \
        | grep -v ' 0' \
        | wc -l )
	
      export BACKUP1=$(mysql-zrm-reporter --fields backup-directory,backup-level,backup-status \
        --where backup-set=${BACKUPSET} \
	| awk '{print $2,$3}' \
        | awk 'FNR > 2' \
        | grep -B ${STEP} ${BACKUP0} \
        | grep -v ${BACKUP0} \
        | grep -w 1)
      
      export TIMEREPORT0=$(mysql-zrm-reporter --fields backup-directory,backup-level,backup-status,backup-date \
        --where backup-set=${BACKUPSET} \
        | grep -w ${BACKUP0} \
        | awk '{print $6,$7,$8,$9,$10,$11,$12}')

      #### Check if the level 0 backup is the lastest backup and do not have any level 1 backup later ###
      if [[ -z ${BACKUP1} ]]; then
	echo -e "${green}[INFO  ]${nc} ====================================================================================================="
        echo -e "${green}[INFO  ]${nc} IMPORTANT: This level 0 backup is the latest backup and there aren't anything level 1 after this."
        echo -e "${green}[INFO  ]${nc} Please verify the information before restore process begin."
        echo -e "${green}[INFO  ]${nc} The database ${green}${DATABASE}${nc} will be restore to [${green}${TIMEREPORT0}${nc}]."
        echo -e "${green}[INFO  ]${nc} Are you sure to restore database ${green}${DATABASE}${nc} to that moment."
        printf "${green}[INFO  ]${nc} choose ${green}Y${nc} or ${green}y${nc}, anything else mean ${red}NO${nc}: "
        read -r REPLY
	if [[ $REPLY =~ ^[Yy]$ ]]
        then
          export DIRECTORY=$BACKUP0
          for i in $DIRECTORY
          do
            echo -e "${green}[INFO  ]${nc} Restoring Database ${DATABASE} with file ${i}. Please wait and do nothing."
            mysql-zrm --action restore --source-directory ${i} --database ${DATABASE} --backup-set ${BACKUPSET} || ERR=1
            if [[ $ERR == 1 ]];then
              echo -e "${red}[ERROR ]${nc} Something wrong. Please read above logs for more information"
              exit 1;
            else
              :
            fi
          done
          echo -e "${green}[INFO  ]${nc} The database ${green}${DATABASE}${nc} completed successfully to [${green}${TIMEREPORT0}${nc}]."
          find $FILE -delete 2> /dev/null
          find $FILE1 -delete 2> /dev/null
          exit 1
        else
          find $FILE -delete 2> /dev/null
          find $FILE1 -delete 2> /dev/null
          exit 1
        fi
      fi
     
      ### Cut the '1' from BACKUP level 1 variable ###
      for i in {1..${STEP}}; 
      do 
        export BACKUP1=$(echo $BACKUP1 | sed -e 's/ 1//g')
      done

      ### Create file with BACKUP level 1 ###    
      cat /dev/null > $FILE
      for i in $BACKUP1
      do 
        echo $i >> $FILE
      done
      
      ### Choose the BACKUP level 1 that need restore to point in time ###
      export TIMEREPORT=$(mysql-zrm-reporter --fields backup-directory,backup-level,backup-status,backup-date \
        --where backup-set=${BACKUPSET} \
        | awk '{print $2}' \
        | grep -w ${BACKUP0} ) 
      echo -e "${green}[INFO  ]${nc} Backup ${green}[${TIMEREPORT}]${nc} has been choosen."
      export TIME1=$(cat $FILE | sort -s)
      export COUNT1=$(cat $FILE | wc -l)
      export OPT1=0
      
      while [ $OPT1 -le $COUNT1 ] 
      SELECTION1=1
      echo -e "${green}[INFO  ]${nc} List Backup level [${green}1${nc}]: "
      while read -r LINE;
      do
        echo "$SELECTION1) $LINE"
        ((SELECTION1++))
      done <<< "$TIME1"
  
      do
        printf "${yellow}[PROMPT]${nc} Choose Backup level [${green}1${nc}] (Incremental Backup) (1 or 2...) in above list: "
        read -r OPT1

        ### Check if the input is 0 ###
        if [[ $OPT1 == 0 ]]; then
        export OPT1=0
        echo -e "${red}[ERROR ]${nc} Input must not be 0, please try again."
        echo ""
      fi

       ### Check if the input is blank when enter ###
       if [[ -z ${OPT1} ]]; then
         export OPT1=0
         echo -e "${red}[ERROR ]${nc} Input must not be blank, please try again."
         echo ""
       fi
     
       ### Check if the input is not an integer
       if ! [[ $OPT1 =~ ^-?[0-9]+$ ]] ; then
         export OPT1=0
         echo -e "${red}[ERROR ]${nc} Input must be an integer, please try again."
         echo ""
       fi

       if [[ $OPT1 -le $COUNT1 ]]; then
         if [[ `seq 1 $SELECTION1` =~ $OPT1 ]]; then
           export BACKUP1=$(sed -n "${OPT1}p" <<< "$TIME1")
           echo $BACKUP0 > $FILE1
           cat $FILE | tail -${OPT1} | sort -s >> $FILE1
           ### Begin Restore ###
           export TIMEREPORT1=$(mysql-zrm-reporter --fields backup-directory,backup-level,backup-status,backup-date \
             --where backup-set=${BACKUPSET} \
             | grep -w ${BACKUP1} \
             | awk '{print $6,$7,$8,$9,$10,$11,$12}')

	   echo -e "${green}[INFO  ]${nc} ===================================================================================="
           echo -e "${green}[INFO  ]${nc} Please verify the information before restoring:"
           echo -e "${green}[INFO  ]${nc} The database ${green}${DATABASE}${nc} will be restore to [${green}${TIMEREPORT1}${nc}]."
	   echo -e "${green}[INFO  ]${nc} Are you sure to restore database ${green}${DATABASE}${nc} to that moment."
           printf "${green}[INFO  ]${nc} choose ${green}Y${nc} or ${green}y${nc} for ${green}YES${nc}, anything else for ${red}NO${nc}: "
           read -r REPLY
           if [[ $REPLY =~ ^[Yy]$ ]]
           then
             export DIRECTORY=$(cat $FILE1)
             for i in $DIRECTORY
             do
               echo -e "${green}[INFO  ]${nc} Restoring Database ${green}${DATABASE}${nc} with file ${green}${i}${nc}. Please wait and do nothing."
               mysql-zrm --action restore --source-directory ${i} --database ${DATABASE} --backup-set ${BACKUPSET} || ERR=1
	       if [[ $ERR == 1 ]];then
                 echo -e "${red}[ERROR ]${nc} Something wrong. Please read above logs for more information"
	         exit 1;
               else
                 :
               fi
             done
             echo -e "${green}[INFO  ]${nc} The database ${green}${DATABASE}${nc} completed successfully to [${green}${TIMEREPORT1}${nc}]."
             find $FILE -delete 2> /dev/null
             find $FILE1 -delete 2> /dev/null
             exit 1
           else
             find $FILE -delete 2> /dev/null
             find $FILE1 -delete 2> /dev/null
             exit 1
           fi
           
           break
         fi
       else
         export OPT=0
         echo -e "${red}[ERROR ]${nc} Input must be an integer in list, please try again."
         echo ""
       fi
       done 

      break
    fi
  ### Check if the input is larger than the number of menu ###
  else
    export OPT=0
    echo -e "${red}[ERROR ]${nc} Input must be an integer in list, please try again."
    echo ""
  fi
done
