# Helper Functions for Ableton Live (Powershell)
For me, using Powershell Core on MacOS

- *backup-Library*  ($source, $target, $logfile) makes a differential backuop to my NFS attached Nas, because the NAS will do offline backups.
- *get-SetsParameters* ($Source) parses a path, looks for Ableton Live Sets. The Sets are parsed an some metadata are written to a csv file.
- *get-abletonsets* ($folder)

The latter is the core function. 

If you find usable code, use it. 