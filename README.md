# Downloads Folder Archiving Script

## Overview

This PowerShell script automates the process of archiving and cleaning up the Downloads folder on a Windows system. It performs the following tasks:

1. Copies the current contents of the Downloads folder to a new folder named with today's date within an Archive directory.
2. Moves the original files in the Downloads folder to the Recycle Bin.
3. Empties the Recycle Bin to complete the cleanup.

## Usage

Before running the script, ensure that you have PowerShell installed on your system.

1. Download the script file (archive_downloads.ps1) to your computer.

2. Open PowerShell as an administrator.

3. Navigate to the directory where you saved the script using the `cd` command.

4. Run the script by typing `.\archive_downloads.ps1` and pressing Enter.

5. The script will display a notification window with a progress bar. It will copy the contents of your Downloads folder to an Archive folder, move the original files to the Recycle Bin, and then empty the Recycle Bin.

6. After the script completes, you will see a confirmation message.

## Disclaimer

Use this script at your own risk. Make sure to review the script and understand its functionality before running it on your system. The script is provided as-is without any warranties.
