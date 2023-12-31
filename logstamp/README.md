# logstamp : The checksum creator for log files

      This script was written for a very specific use case.
      If you produce log files and they get backed up every few lines by an automated
      service like logTosser or to CloudWatch etc, and you may at a future time have to prove
      that the backed up logs are exactly the same and not edited (maybe for an audit), 
      then this may be the tool for you (or maybe it isn't).

  usage -

  logstamp.sh filename                                    
      Create a checksum of the file

  logstamp.sh --append filename                                    
      Create the checksum and add it to the end of the file

  logstamp.sh filename >> filename                                    
      Same as above (make sure you use double >>)

  logstamp.sh --test "2023-12-11 20:30:40" filename                                    
      Logs for that line and tests up to there




##    Example -
  
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


## Requirements

This script uses sha256 to generate the stamp hash number (the checksum of the file so far)

This command should be on most linuxes.  If you dont have it you can add it or change the command to something similar like md5sum 
(which will do a smaller similar checksum, but a smart auditor will say md5 is a bit old and cracked now you should use sha or similar).

