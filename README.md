# Helper Functions for Ableton Live (Powershell)
For me, using Powershell Core on MacOS

- *backup-Library*  ($source, $target, $logfile): Differential backuop to my (NFS attached) NAS for offline backups.
- *get-SetsParameters* ($Source): Parses §source, looks for Ableton Live Sets. Found sets are parsed and some metadata are written to csv file.
- *get-abletonsets* ($folder): The latter is the core function. 

If you find usable code, use it. 