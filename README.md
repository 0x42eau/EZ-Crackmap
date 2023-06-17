# scripts
repo for being lazy


lazy-cme.sh
script to enumerate domain with crackmapexec
  - Logs into a master log file and each step is put into a respective output file for later checks
  - checks for null sessions/anon login
  - verified supplied user creds
  - once verified: grabs users, password policy, shares, and spiders the SYSVOL share for passwords and admins.  (It also uses the native gpp-autologin and gpp-password in CME.)
  - Searches for common exploits: zerologon, nopac, petitpotam, shadowcoerce, and looks for webdav
  - Checks for RDP access
  - Checks for asrep/kerberoasting
  - Checks for local admin and dumps LSA/SAM

TO DO:
  - add PTH functionality
  - Automate share crawling
  - automate SYSVOL script/policy download
  - (maybe) add sleep between commands to slow down
