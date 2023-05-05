		REM TITLE: Remove default extensions in the "new file" context menu
			REM LINK: 
				REM OPTIONS: "reg delete" to delete the extension. "REG ADD" to add
					reg delete "HKCR\.accdb\Access.Application.16\ShellNew"  /F 1>NUL 2>&1
					reg delete "HKCR\.mdb\ShellNew"  /F 1>NUL 2>&1
					reg delete "HKCR\.bmp\ShellNew" /F 1>NUL 2>&1
					reg delete "HKCR\.docx\Word.Document.12\ShellNew" /F 1>NUL 2>&1
					reg delete "HKCR\.xlsx\Excel.Sheet.12\ShellNew" /v "FileName" /T REG_SZ /D "C:\Program Files\Microsoft Office\Root\VFS\Windows\ShellNew\excel12.xlsx" /F 1>NUL 2>&1
					reg delete "HKCR\.pptx\PowerPoint.Show.12\ShellNew" /F 1>NUL 2>&1
					reg delete "HKCR\.pub\Publisher.Document.16\ShellNew" /F 1>NUL 2>&1
					reg delete "HKCR\.rtf\ShellNew" /F 1>NUL 2>&1
					reg delete "HKCR\.zip\CompressedFolder\ShellNew" /F 1>NUL 2>&1
					reg delete "HKCR\.zip\ShellNew" /F 1>NUL 2>&1
					reg delete "HKEY_CLASSES_ROOT\.contact\ShellNew" /F 1>NUL 2>&1
