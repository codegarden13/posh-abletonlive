# Helper Functions for Ableton Live (Powershell)
(Powershell Core on MacOS)

Ableton Live doesn't expose a set list. So i parse all projects to get that with metadata.

- *backup-Library*  ($source, $target, $logfile): Differential backuop to my (NFS attached) NAS for offline backups.
- *get-SetsParameters* ($Source): Parses §source, looks for Ableton Live Sets. Found sets are parsed and some metadata are written to csv file.
- *get-abletonsets* ($folder): The latter is the core function. 

This is only for for me, If you find usable code, use it. 