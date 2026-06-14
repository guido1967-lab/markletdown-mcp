-- "Converti in Markdown" — wrapper app per convert.command
-- Doppio click  -> converte la cartella di default (definita in convert.command)
-- Trascina file/cartelle sull'icona -> converte quelli, mostrando l'avanzamento in Terminale.

property scriptPath : "/Users/guidocornettone/solongevity-projects/markletdown-mcp/convert.command"

on run
	runWith({})
end run

on open theItems
	set args to {}
	repeat with anItem in theItems
		set end of args to quoted form of POSIX path of anItem
	end repeat
	runWith(args)
end open

on runWith(args)
	set cmd to quoted form of scriptPath
	repeat with a in args
		set cmd to cmd & " " & a
	end repeat
	tell application "Terminal"
		activate
		do script cmd
	end tell
end runWith
