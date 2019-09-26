' source: Daz >>> http://forums.mydigitallife.info/showpost.php?p=109027&postcount=12
Set WshShell = CreateObject("WScript.Shell")
key = "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\"
digitalId = WshShell.RegRead(key & "DigitalProductId")

ProductName = "Product Name : " & WshShell.RegRead(key & "ProductName") & vbNewLine
ProductId = "Product Id : " & WshShell.RegRead(key & "ProductId") & vbNewLine
ProductKey = "Install Key : " & Converted(digitalId)

ProductId = ProductName & ProductId & ProductKey

boutons = vbYesNo + vbQuestion
If vbYes = MsgBox(ProductId & vblf & vblf & "Save to a file ?", boutons, "Windows Infos") then
Save ProductId
End if

Function Converted(id)
Const OFFSET = 52
i = 28
Chars = "BCDFGHJKMPQRTVWXY2346789"
Do
Cur = 0
x = 14
Do
Cur = Cur * 256
Cur = id(x + OFFSET) + Cur
id(x + OFFSET) = (Cur \ 24) And 255
Cur = Cur Mod 24
x = x -1
Loop While x >= 0
i = i - 1
Converted = Mid(Chars, Cur + 1, 1) & Converted
If (((29 - i) Mod 6) = 0) And (i <> -1) Then
i = i -1
Converted = "-" & Converted
End If
Loop While i >= 0
End Function

Function Save(data)
Const ForWRITING = 2
Const asASCII = 0
Dim fso, f, fName, ts

today = FormatDateTime(Date, vbLongDate) & vbnewline
fName = "OS Key.txt"

Set fso = CreateObject("Scripting.FileSystemObject")
fso.CreateTextFile fName
Set f = fso.GetFile(fName)
Set f = f.OpenAsTextStream(ForWRITING, asASCII)
f.Writeline today
f.Writeline data
f.Close
End Function