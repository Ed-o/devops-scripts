## logstamp : The checksum creator for log files

  usage -

  logstamp.sh filename                                  Create a checksum of the file

  logstamp.sh --append filename                         Create the checksum and add it to the end of the file

  logstamp.sh filename >> filename                      Same as above (make sure you use double >>)

  logstamp.sh --test "2023-12-11 20:30:40" filename     Logs for that line and tests up to there




    Example -
  
      set a cron job to add a line to your log file every ten minutes
        0/10  *  *  *  *  /usr/local/bin/logstamp  /var/log/mylog.log  >> /var/log/mylog.log
  
      This will stamp the log file with a line like this :
        [2023-12-11 20:30:40] Checksum ea4f99eda1a1ef87bd6c2e99190517ae563f50b50b5d50c59d8a802f73139583
  
      You can verify the file is the same as your backup copy to any point by doing a test :
        logstamp --test "2023-12-11 20:30:40" /var/log/mylog.log
  
        note - you will need the double quotes and you do not need the square brackets just the date and time
  
        this will then output something like :
  
        Does this ==>
        [2023-12-11 23:03:29] Checksum ea4f99eda1a1ef87bd6c2e99190517ae563f50b50b5d50c59d8a802f73139583
        Match this ==>
        ea4f99eda1a1ef87bd6c2e99190517ae563f50b50b5d50c59d8a802f73139583
  
        If the two strings match then the file has not been changed since that point and your backup is confirmed as untouched (at least at this point)



