#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.12.0
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

#RequireAdmin

Run("C:\Program Files\UnrealIRCd 4\UnrealIRCd.exe","C:\Program Files\UnrealIRCd 4\")
Sleep(10000)
Run("C:\Program Files\Anope\bin\anope.exe","C:\Program Files\Anope\bin\")
Sleep(10000)

Run("C:\Game\mIRC-BOT\mIRC_HD.exe","C:\Game\mIRC-BOT\",@SW_MINIMIZE)
Sleep(8000)

Run("D:\Software\policyserver\policyserver.exe","D:\Software\policyserver\",@SW_MINIMIZE)
Sleep(2000)