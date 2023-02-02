use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

tell application "Adobe InDesign 2023"
	repeat
		try
			set theResult to do script "app.tightenerTimeslice()" language javascript
			delay 0.1
		end try
	end repeat
end tell