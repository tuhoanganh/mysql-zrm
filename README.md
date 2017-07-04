## Automated Restore Script MySQL-ZRM
This script will help you to restore the database was backuped by MySQL-ZRM with level 0 and level 1 many times per day. For example:
+ 07:00 level 0
+ 09:00, 11:00, 13:00, 15:00, 17:00 level 1
+ 19:00 level 0
+ 21:00, 23:00, 01:00, 03:00, 05:00 level 1
In a bad day, at 18:00, you lost all the data in the database (- _  -' )!!!

The db must be restored to 17:00 (latest backup), so you have to begin from level 0 at 07:00 then level 1 at 09:00, 11:00, 13:00, 15:00 and 17:00. So you have to type the command mysql-zrm restore by hand and choose the right directory... time by time. 

It's very annoying.

With this script, you simply choose the level 0 at 07:00 (menu list 1) and pick the level 1 at 17:00 (menu list 2) to do all the job.

## Requirements
- OS: CentOS 7 (do not sure it works in another distro like Ubuntu Server, i'll test it late).
- You have to install MySQL-ZRM version 3.0 at http://www.zmanda.com/download-zrm.php
- Configure MySQL-ZRM and let it run/backup for a few days.
- Verify that there are no backup is FAILED or ERROR.

## Author
Name: Hoang Anh Tu
Email: hoanganhtu1102@Gmail.com

## Important Notes
- Test this script in a Demo Database that have closest state with your real one first for ensuring the result is as expected.
- Please report any issues you meet when run this script, i'll try to fix this, Thanks.
