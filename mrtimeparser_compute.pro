; docformat = 'rst'
;
; NAME:
;       MrTimeParser_Compute
;
;*****************************************************************************************
;   Copyright (c) 2016, Matthew Argall                                                   ;
;   All rights reserved.                                                                 ;
;                                                                                        ;
;   Redistribution and use in source and binary forms, with or without modification,     ;
;   are permitted provided that the following conditions are met:                        ;
;                                                                                        ;
;       * Redistributions of source code must retain the above copyright notice,         ;
;         this list of conditions and the following disclaimer.                          ;
;       * Redistributions in binary form must reproduce the above copyright notice,      ;
;         this list of conditions and the following disclaimer in the documentation      ;
;         and/or other materials provided with the distribution.                         ;
;       * Neither the name of the <ORGANIZATION> nor the names of its contributors may   ;
;         be used to endorse or promote products derived from this software without      ;
;         specific prior written permission.                                             ;
;                                                                                        ;
;   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY  ;
;   EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES ;
;   OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT  ;
;   SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,       ;
;   INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED ;
;   TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR   ;
;   BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN     ;
;   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN   ;
;   ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH  ;
;   DAMAGE.                                                                              ;
;*****************************************************************************************
;
; PURPOSE:
;+
;   The purpose of this function is to breakdown time strings in any format and optionally
;   rebuild them into any other format. Components of time strings are recognized by
;   tokens, each of which begin with "%". The defined tokens are below. Furthermore, there
;   are pre-defined patterns, listed below the tokens, that can be used.
;
;   LIST OF TOKENS::
;       %Y      -   Four-digit year: 2012, 2013, etc.
;       %y      -   Two-digit year: 60-59
;       %M      -   Two-digit month: 01-12
;       %C      -   Calendar month: January, Feburary, etc.
;       %c      -   Abbreviated calendar month: Jan, Feb, etc.
;       %d      -   Day of month: 01-31
;       %D      -   Day of year: 000-366
;       %W      -   Week day: Monday, Tuesday, etc.
;       %w      -   Abbreviated week day: Mon, Tue, etc.
;       %H      -   Hour on a 24-hour clock: 00-24
;       %h      -   Hour on a 12-hour clock: 01-12
;       %m      -   Minute: 00-59
;       %S      -   Seconds: 00-59
;       %f      -   Fractions of a second: Decimal point followed by any number of digits.
;       %1      -   Milli-seconds: 000-999
;       %2      -   Micro-seconds: 000-999
;       %3      -   Nano-seconds: 000-999
;       %4      -   Pico-seconds: 000-999
;       %A      -   A.M. or P.M. on a 12-hour clock
;       %z      -   Time Zone, abbreviated name
;       %o      -   Offset from UTC
;       %?      -   Any single, unknown character
;       %(      -   Anything between "%(" and "%)" is ignored.
;       %)      -   Anything between "%(" and "%)" is ignored.
;       \%      -   The "%" character.
;
;   NOTES:
;       If "z" or "o" appear in the input pattern, but not in the output pattern, the
;       offset from UTC is lost. No coversion between time zones takes place.
;
;       The tokens "%(" and "%)" can be used, for example, to encase regular expressions.
;       As such, the MrTimeTokensToRegex will produce a regular expression that matches
;       your criteria while allowing easy extraction of date and time information via
;       MrTimeParser (by not generating an unknown number of subexpressions if "(" and ")"
;       are included in the regular expression string). See the examples.
;
;   PRE-DEFINED PATTERNS::
;        1: 1951-01-09T08:21:10Z                    ISO-8601
;        2: 09-Jan-1951 08:21:10.000                CDF_EPOCH
;        3: 09-Jan-1951 08:21:10.000.000.000.000    CDF_EPOCH16
;        4: 1951-01-09T08:21:10.000000000           CDF_TIME_TT2000
;        5: 09 Jan 1951
;        6: 09 Jan 1951 08:21:10
;        7: 09 Jan 1951 08h 21m 10s
;        8: 09 January 1951
;        9: 09 January 1951 08:21:10
;       10: 09 January 1951 08h 21m 10s
;       11: Jan 09, 1951
;       12: Jan 09, 1951 08:21:10
;       13: Jan 09, 1951 08h 21m 10s
;       14: Jan 09, 1951
;       15: January 09, 1951 08:21:10
;       16: January 09, 1951 08h 21m 10s
;       17: January 09, 1951 08:21:10
;       18: 1951-009
;       19: 1951-009 08:21:10
;       20: 1951-009 08h 21m 10s
;       21: 009-1951
;       22: 009-1951 08:21:10
;       23: 009-1951 08h 21m 10s
;       24: 19510109
;       25: 09011951
;       26: 01091951
;       27: Tuesday, January 09, 1951
;       28: Tuesday, January 09, 1951 08:21:10
;       29: Tuesday, January 09, 1951 08h 21m 10s
;       30: Tue, Jan 09, 1951
;       31: Tue, Jan 09, 1951 08:21:10
;       32: Tue, Jan 09, 1951 08h 21m 10s
;
; :Uses:
;   Uses the following external programs::
;       cgErrorMSG.pro
;       MrIsMember.pro
;       MG_StReplace.pro
;       MonthNameToNumber.pro
;       MonthNumberToName.pro
;       MrDayOfWeek.pro
;       MrTimeTokensToRegex.pro
;       MrTimeZoneNameToOffset.pro
;       MrTimeZoneOffsetToName.pro
;       MrWeekDayToName.pro
;       MrWeekNameToDay.pro
;       Year_Day.pro
;
; :Author:
;   Matthew Argall::
;       University of New Hampshire
;       Morse Hall, Room 348
;       8 College Rd.
;       Durham, NH, 03824
;       matthew.argall@unh.edu
;
; :History:
;   Modification History::
;       2014-03-15  -   Written by Matthew Argall.
;       2016-10-27  -   Extracted from MrTimeParser. - MRA
;-
;*****************************************************************************************
;+
;   Convert a four-digit year to a two-digit year and vice versa
;
; :Params:
;       DOY:        in, required, type=string
;                   Day of the year, from 0-366
;       MONTH:      out, optional, type=string
;                   Month corresponding to `DOY`.
;       DAY:        out, optional, type=string
;                   Day of the `MONTH` corresponding to `DOY`.
;
; :Keywords:
;       YEAR:       in, optional, type=string/strarr, default='2001'
;                   Year in which `DOY` occurs. Necessary for determining leap year.
;                       Non-leap year is assumed.
;-
pro MrTimeParser_DissectDOY, doy, month, day, $
YEAR=year
	compile_opt strictarr
	on_error, 2

	;Year given?
	if n_elements(year) gt 0 then begin
		_year = year
	
		;Was a year given?
		iBlank = where(_year eq '', count)
		if count gt 0 then begin
			_year[iBlank] = '2001'
			message, 'No year given. Converting %D to %M for non-leap year.', /INFORMATIONAL
		endif
	
		;Two digit years?
		iTwo = where(strlen(_year) eq 2, count)
		if count gt 0 $
			then _year[iTwo] = MrTimeParser_YearToYr(_year[iTwo], /FROM_YR)
		
	;No year given?
	endif else begin
		message, 'No year given. Converting %D to %M for non-leap year.', /INFORMATIONAL
		_year = replicate('2001', n_elements(doy))
	endelse

	;Get the month and day
	monthday = year_day(doy, YEAR=year, /TO_MODAY)
	month = strmid(monthday, 0, 2)
	day   = strmid(monthday, 3, 2)
end


;+
;   Get (or calculate) the calendar month name.
;
; :Returns:
;       CMONTH:     The calendar month name.
;-
function MrTimeParser_GetCMonth, cmonth, month, calmo, doy, year, yr
	compile_opt idl2
	on_error, 2

	;Calculate from 2-digit month number, abbreviated calendar month name, or day-of-year
	if cmonth[0] eq '' then begin
		case 1 of
			month[0]  ne '': cmonth = MonthNumberToName(month)
			calmo[0]  ne '': cmonth = MonthNameToNumber( MonthNumberToName(calmo), /ABBR )
			doy[0]    ne '': begin
				MrTimeParser_ParseDOY, doy, year, yr, month, day
				cmonth = MonthNumberToName(month)
			endcase
			else: message, 'Cannot form "%C". Must give %M, %C, %c or %D.'
		endcase
	endif
	
	return, cmonth
end


;+
;   Get (or calculate) the abbreviated calendar month name.
;
; :Returns:
;       CALMO:      The abbreviated calendar month name.
;-
function MrTimeParser_GetCalMo, calmo, month, cmonth, doy, year, yr
	compile_opt idl2
	on_error, 2

	;Calculate from 2-digit month number, abbreviated calendar month name, or day-of-year
	if cmonth[0] eq '' then begin
		case 1 of
			month[0]  ne '': cmonth = MonthNumberToName(month, /ABBR)
			calmo[0]  ne '': cmonth = MonthNameToNumber( MonthNumberToName(calmo) )
			doy[0]    ne '': begin
				MrTimeParser_ParseDOY, doy, year, yr, month, day
				cmonth = MonthNumberToName(month, /ABBR)
			endcase
			else: message, 'Cannot form "%c". Must give %M and, %C, %c or %D.'
		endcase
	endif
	
	return, cmonth
end


;+
;   Get (or calculate) the day-of-month.
;
; :Returns:
;       DAY:        The abbreviated calendar month name.
;-
function MrTimeParser_GetDay, day, doy, year, yr
	compile_opt idl2
	on_error, 2

	;Calculate from day-of-year
	if day[0] eq '' then begin
		case 1 of
			doy[0] ne '': MrTimeParser_ParseDOY, doy, year, yr, month, day
			else: message, 'Cannot form "%d". Must give %d or %D.'
		endcase
	endif
	
	return, day
end


;+
;   Get (or calculate) the day-of-year.
;
; :Returns:
;       DOY:        The day-of-year.
;-
function MrTimeParser_GetDOY, doy, year, yr, month, cmonth, calmo, day
	compile_opt idl2
	on_error, 2

	if doy[0] eq '' then begin
		;Get the month and day
		catch, the_error
		if the_error eq 0 then begin
			month = MrTimeParser_GetMonth(month, cmonth, calmo, doy)
			day   = MrTimeParser_GetDay(day, doy)
		endif else begin
			;Redirect error to parent
			catch, /CANCEL
			on_error, 2
			message, 'Cannot form "%D". Must give %D or [(%M, %C or %c) and %d with optional (%Y or %y)].'
		endelse
		
		;Get the year
		catch, the_error
		if the_error eq 0 then begin
			year = MrTimeParser_GetYear(year, yr)
			date = year + '-' + month + '-' + day
		endif else begin
			MrPrintF, 'LogWarn', 'Year not given. Finding DOY with non-leap year.'
			date = '2001-' + month + '-' + day
		endelse
		catch, /CANCEL
		on_error, 2

		;Finally, create DOY
		doy = MrDate2DOY(date)
	endif
	
	return, day
end


;+
;   Get (or calculate) the fractional number of seconds.
;
; :Returns:
;       DAY:        The abbreviated calendar month name.
;-
function MrTimeParser_GetFraction, decimal, milli, micro, nano, pico
	compile_opt idl2
	on_error, 2
	
	;Milli, etc. given?
	if decimal[0] eq '' then if milli[0] ne '' then begin
		decimal = strmid(milli + '000', 0, 3)
		if micro[0] ne '' then decimal += micro
		if nano[0]  ne '' then decimal += nano
		if pico[0]  ne '' then decimal += pico
	endif else begin
		decimal = '0'
	endelse
	
	return, '.' + decimal
end


;+
;   Get (or calculate) the hour on a 24-hour clock.
;
; :Returns:
;       DAY:        The abbreviated calendar month name.
;-
function MrTimeParser_GetHour, hour, hr, am_pm
	compile_opt idl2
	on_error, 2

	;12-Hour clock?
	if hour[0] eq '' then if hr[0] ne '' then begin
		hour = hr
		
		;AM/PM -- assume AM if not given
		if am_pm[0] eq '' then begin
			message, '%A not given. Assuming AM.', /INFORMATIONAL
		
		;Convert to 24-hour clock by adding 12 to the hours 1-11pm
		endif else begin
			iPM = where(am_pm eq 'PM', nPM)
			if nPM gt 0 then begin
				iPNoon = where(fix(hr[iPM]) lt 12, nPNoon)
				if nPNoon gt 0 then hour[iPM[iPNoon]] = string(fix(hr[iPM[iPNoon]]) + 12, FORMAT='(i02)')
			endif
		endelse
	
	;Cannot determine
	endif else begin
		message, 'Cannot form "%H". Must give %H or %h.'
	endelse
	
	return, hour
end


;+
;   Get (or calculate) the hour on a 12-hour clock. Will also set AM_PM
;   if it was not previously given.
;
; :Returns:
;       DAY:        The abbreviated calendar month name.
;-
function MrTimeParser_GetHr, hr, hour, am_pm
	compile_opt idl2
	on_error, 2
	
	;24-hour clock?
	if hr[0] eq '' then if hour[0] ne '' then begin
		;From 24 to 12
		hr = hour
		iPM = where(fix(hour) ge 12, nPM)
		if nPM gt 0 then hr[iPM] = string(fix(hour[iPM]) - 12, FORMAT='(i02)')
		
		;AM or PM?
		if am_pm[0] eq '' then begin
			am_pm = strarr(n_elements(hr)) + 'AM'
			if nPM gt 0 then am_pm[iPM] = 'PM'
		endif
	
	;Cannot determine
	endif else begin
		message, 'Cannot form "%h". Must give %H or %h (with optional %A).'
	endelse
	
	return, hr
end


;+
;   Get (or calculate) the number of milli-seconds.
;
; :Returns:
;       DAY:        The abbreviated calendar month name.
;-
function MrTimeParser_GetMilli, milli, decimal
	compile_opt idl2
	on_error, 2
	
	if milli[0] eq '' then if decimal[0] ne '' $
		then milli = strmid(decimal + '000', 0, 3) $
		else milli = '000'
	
	return, milli
end


;+
;   Get (or calculate) the number of micro-seconds.
;
; :Returns:
;       DAY:        The abbreviated calendar month name.
;-
function MrTimeParser_GetMicro, micro, decimal
	compile_opt idl2
	on_error, 2
	
	if micro[0] eq '' then if decimal[0] ne '' $
		then micro = strmid(decimal + '000000', 3, 3) $
		else micro = '000'
	
	return, micro
end


;+
;   Get (or calculate) the 2-digit month number.
;
; :Returns:
;       MONTH:      The 2-digit year
;-
function MrTimeParser_GetMonth, month, cmonth, calmo, doy, year, yr
	compile_opt idl2
	on_error, 2

	;Calculate from (abbreviated) calendar month name or day-of-year
	if month[0] eq '' then begin
		case 1 of
			cmonth[0] ne '': month = MonthNameToNumber(cmonth)
			calmo[0]  ne '': month = MonthNameToNumber(calmo, /ABBR)
			doy[0]    ne '': MrTimeParser_ParseDOY, doy, year, yr, month, day
			else: message, 'Cannot form "%M". Must give (%M, %C, %c or %D).'
		endcase
	endif
	
	return, month
end


;+
;   Get (or calculate) the number of nano-seconds.
;
; :Returns:
;       DAY:        The abbreviated calendar month name.
;-
function MrTimeParser_GetNano, nano, decimal
	compile_opt idl2
	on_error, 2
	
	if nano[0] eq '' then if decimal[0] ne '' $
		then nano = strmid(decimal + '000000000', 6, 3) $
		else nano = '000'
	
	return, nano
end


;+
;   Get (or calculate) the time_zone.
;
; :Returns:
;       DAY:        The abbreviated calendar month name.
;-
function MrTimeParser_GetOffset, offset, time_zone
	compile_opt idl2
	on_error, 2
	
	if offset[0] ne '' then if time_zone[0] ne '' $
		then offset = MrTimeZoneNameToOffset(time_zone) $
		else offset = '+00:00'
	
	return, offset
end


;+
;   Get (or calculate) the number of pico-seconds.
;
; :Returns:
;       DAY:        The abbreviated calendar month name.
;-
function MrTimeParser_GetPico, pico, decimal
	compile_opt idl2
	on_error, 2
	
	if pico[0] eq '' then if decimal[0] ne '' $
		then pico = strmid(decimal + '000000000000', 6, 3) $
		else pico = '000'
	
	return, pico
end


;+
;   Get (or calculate) the time_zone.
;
; :Returns:
;       DAY:        The abbreviated calendar month name.
;-
function MrTimeParser_GetTimeZone, time_zone, offset
	compile_opt idl2
	on_error, 2
	
	if time_zone[0] eq '' then if offset[0] ne '' $
		then time_zone = MrTimeZoneOffsetToName(offset) $
		else time_zone = 'Z'
	
	return, time_zone
end


;+
;   Get (or calculate) the day-of-week.
;
; :Returns:
;       DAY:        The abbreviated calendar month name.
;-
function MrTimeParser_GetWeekDay, weekday, wkday, year, yr, month, cmonth, calmo, doy, day
	compile_opt idl2
	on_error, 2

	;Abbreviated Week Day
	if weekday[0] eq '' then if wkday[0] ne '' then begin
		wkno    = MrWeekDayToNumber(wkday, /ABBR)
		weekday = MrWeekNumberToDay(wkno)

	;Date
	endif else begin
		;Year
		if year[0] eq '' then if yr[0] ne '' $
			then year = MrTimeParser_YearToYr(yr, /FROM_YR) $
			else message, 'Cannot form %W. Must give %W or provice [%Y], [%M, %C, %C], [%D, %d].'
	
		;Month
		if month[0] eq '' then if cmonth[0] ne '' then begin
			month = monthNameToNumber(cmonth)
		endif else if calmo[0] ne '' then begin
			month = monthNameToNumber(calmo)
		endif else begin
			message, 'Cannot form %W. Must give %W or provice [%Y], [%M, %C, %C], [%D, %d].'
		endelse
	
		;DOY
		if doy[0] ne '' then if month[0] eq '' || day[0] eq '' then begin
			if year[0] eq '' $
				then MrTimeParser_DissectDOY, doy, month, day, YEAR=yr $
				else MrTimeParser_DissectDOY, doy, month, day, YEAR=year
		endif
	
		;Day
		if day[0] eq '' then $
			message, 'Cannot form %W. Must give %W or provice [%Y], [%M, %C, %C], [%D, %d].'
	
		;Calculate the week day
		weekday = MrDayOfWeek(year, month, day)
	endelse
	
	return, weekday
end


;+
;   Get (or calculate) the abbreviated day-of-week.
;
; :Returns:
;       DAY:        The abbreviated calendar month name.
;-
function MrTimeParser_GetWkDay, wkday, weekday, year, yr, month, cmonth, calmo, doy, day
	compile_opt idl2
	on_error, 2

	;Abbreviated Week Day
	if wkday[0] eq '' then if weekday[0] ne '' then begin
		wkno  = MrWeekDayToNumber(weekday)
		wkday = MrWeekNumberToDay(wkno, /ABBR)

	;Date
	endif else begin
		;Year
		if year[0] eq '' then if yr[0] ne '' $
			then year = MrTimeParser_YearToYr(yr, /FROM_YR) $
			else message, 'Cannot form %W. Must give %W or provice [%Y], [%M, %C, %C], [%D, %d].'
	
		;Month
		if month[0] eq '' then if cmonth[0] ne '' then begin
			month = monthNameToNumber(cmonth)
		endif else if calmo[0] ne '' then begin
			month = monthNameToNumber(calmo)
		endif else begin
			message, 'Cannot form %W. Must give %W or provice [%Y], [%M, %C, %C], [%D, %d].'
		endelse
	
		;DOY
		if doy[0] ne '' then if month[0] eq '' || day[0] eq '' then begin
			if year[0] eq '' $
				then MrTimeParser_DissectDOY, doy, month, day, YEAR=yr $
				else MrTimeParser_DissectDOY, doy, month, day, YEAR=year
		endif
	
		;Day
		if day[0] eq '' then $
			message, 'Cannot form %W. Must give %W or provice [%Y], [%M, %C, %C], [%D, %d].'
	
		;Calculate the week day
		wkday = MrDayOfWeek(year, month, day, /ABBR)
	endelse
	
	return, wkday
end


;+
;   Get (or calculate) the 4-digit year.
;
; :Returns:
;       YEAR:       The 4-digit year
;-
function MrTimeParser_GetYear, year, yr
	compile_opt idl2
	on_error, 2
	
	;Do not have YEAR
	if year[0] eq '' then begin
		;Must have YR
		if yr[0] eq '' then message, 'Cannot form "%Y". Must give %Y or %y.'
		
		;2-Digit year
		;   00-59 -> 1900-1959
		;   60-99 -> 2060-2099
		i19 = where(fix(yr) ge 60, n19, COMPLEMENT=i20, NCOMPLEMENT=n20)
		year = yr
		if n19 gt 0 then year[i19] = '19' + year[i19]
		if n20 gt 0 then year[i20] = '20' + year[i20]
	endif
	
	return, year
end


;+
;   Get (or calculate) the 2-digit year.
;
; :Returns:
;       YR:         The 2-digit year
;-
function MrTimeParser_GetYr, yr, year
	compile_opt idl2
	on_error, 2

	;Do not have YEAR
	if yr[0] eq '' then begin
		;Must have YEAR
		if year[0] eq '' then message, 'Cannot form "%y". Must give %Y or %y.'
		
		;Issue error (losing information)
		MrPrintF, 'LogWarn', 'Converting 4-digit year to 2-digit year.', /INFORMATIONAL
		
		;Parse YEAR
		yr = stregex(year, '[0-9]{2}([0-9]{2})', /SUBEXP, /EXTRACT)
		yr = reform(yr[1,*])
	endif
	
	return, yr
end


;+
;   Parse the day-of-year into month and day.
;
; :Params:
;       MONTH:      out, optional, type=string
;                   Month corresponding to `DOY`.
;       DAY:        out, optional, type=string
;                   Day of the `MONTH` corresponding to `DOY`.
;-
pro MrTimeParser_ParseDOY, doy, year, yr, month, day
	compile_opt strictarr
	on_error, 2

	;Check if DOY was given
	if doy[0] eq '' then message, 'DOY not given. Cannot parse.'

	;Try to get the year
	case 1 of
		year[0] ne '': monthday = year_day(doy, YEAR=year, /TO_MODAY)
		yr[0]   ne '': monthday = year_day(doy, YEAR=yr, /TO_MODAY)
		else:          monthday = year_day(doy, /TO_MODAY)
	endcase

	;Get the month and day
	month    = strmid(monthday, 0, 2)
	day      = strmid(monthday, 3, 2)
end


;+
;   Look-up function for commonly used patterns.
;
; :Private:
;
; :Params:
;       OPTION:         in, required, type=integer
;                       Number corresponding to the desired pattern.
;
; :Returns:
;       PATTERN:        The pre-defined pattern.
;-
function MrTimeParser_Patterns, option
	compile_opt strictarr
	on_error, 2

	;Was one of the pre-defined patterns given?
	case option of
		 1: pattern = '%Y-%M-%dT%H:%m:%SZ'            ;ISO-8601:        1951-01-09T08:21:10Z
		 2: pattern = '%d-%c-%Y %H:%m:%S.%1'          ;CDF_EPOCH:       09-Jan-1951 08:21:10.000
		 3: pattern = '%d-%c-%Y %H:%m:%S.%1.%2.%3.%4' ;CDF_EPOCH16:     09-Jan-1951 08:21:10.000.000.000.000
		 4: pattern = '%Y-%M-%dT%H:%m:%S.%1%2%3'      ;CDF_TIME_TT2000: 1951-01-09T08:21:10.000000000
		 5: pattern = '%d %c %Y'                      ;09 Jan 1951
		 6: pattern = '%d %c %Y %H:%m:%S'             ;09 Jan 1951 08:21:10
		 7: pattern = '%d %c %Y %Hh %mm %Ss'          ;09 Jan 1951 08h 21m 10s
		 8: pattern = '%d %C %Y'                      ;09 January 1951
		 9: pattern = '%d %C %Y %H:%m:%S'             ;09 January 1951 08:21:10
		10: pattern = '%d %C %Y %Hh %mm %Ss'          ;09 January 1951 08h 21m 10s
		11: pattern = '%c %d, %Y'                     ;Jan 09, 1951
		12: pattern = '%c %d, %Y %H:%m:%S'            ;Jan 09, 1951 08:21:10
		13: pattern = '%c %d, %Y %Hh %mm %Ss'         ;Jan 09, 1951 08h 21m 10s
		14: pattern = '%c %d, %Y'                     ;Jan 09, 1951
		15: pattern = '%C %d, %Y %H:%m:%S'            ;January 09, 1951 08:21:10
		16: pattern = '%C %d, %Y %Hh %mm %Ss'         ;January 09, 1951 08h 21m 10s
		17: pattern = '%C %d, %Y %H:%m:%S'            ;January 09, 1951 08:21:10
		18: pattern = '%Y-%D'                         ;1951-009
		19: pattern = '%Y-%D %H:%m:%S'                ;1951-009 08:21:10
		20: pattern = '%Y-%D %Hh %mm %Ss'             ;1951-009 08h 21m 10s
		21: pattern = '%D-%Y'                         ;009-1951
		22: pattern = '%D-%Y %H:%m:%S'                ;009-1951 08:21:10
		23: pattern = '%D-%Y %Hh %mm %Ss'             ;009-1951 08h 21m 10s
		24: pattern = '%Y%M%d'                        ;19510109
		25: pattern = '%d%M%Y'                        ;09011951
		26: pattern = '%M%d%Y'                        ;01091951
		27: pattern = '%W, %C %d, %Y'                 ;Tuesday, January 09, 1951
		28: pattern = '%W, %C %d, %Y %H:%m:%S'        ;Tuesday, January 09, 1951 08:21:10
		29: pattern = '%W, %C %d, %Y %Hh %mm %Ss'     ;Tuesday, January 09, 1951 08h 21m 10s
		30: pattern = '%w, %c %d, %Y'                 ;Tue, Jan 09, 1951
		31: pattern = '%w, %c %d, %Y %H:%m:%S'        ;Tue, Jan 09, 1951 08:21:10
		32: pattern = '%w, %c %d, %Y %Hh %mm %Ss'     ;Tue, Jan 09, 1951 08h 21m 10s
		else: message, 'Pattern option ' + strtrim(option, 2) + ' not recognized.'
	endcase

	return, pattern
end


;+
;   The purpose of this method is to retreive the order of the embedded date and time
;   codes.
;
; :Private
;
; :Params:
;       TOKEN:          in, required, type=string
;                       A character referencing a portion of a date or time.
;
; :Returns:
;       ORDER:          The order of the date/time code.
;-
function MrTimeParser_TokenOrder, token
	compile_opt strictarr
	on_error, 2

	case token of
		'y': order = 0
		'Y': order = 0
		'M': order = 1
		'C': order = 1
		'c': order = 1
		'D': order = 1
		'd': order = 2
		'W': order = 2
		'w': order = 2
		'H': order = 3
		'h': order = 3
		'm': order = 4
		'S': order = 5
		'f': order = 6
		'1': order = 6
		'2': order = 7
		'3': order = 8
		'4': order = 9
		'A': order = 10
		else: order = -1
	endcase

	return, order
end


;+
;   Convert a four-digit year to a two-digit year and vice versa
;
; :Params:
;       YR:         in, required, type=string
;                   The 4-digit year to be converted to a 2-digit year.
;
; :Keywords:
;       FROM_TWO:   in, optional, type=boolean, default=0
;                   If set, convert from a 2-digit year to a 4-digit year.
;-
function MrTimeParser_YearToYr, yr, $
FROM_YR=from_yr
	compile_opt strictarr
	on_error, 2

	;2-Digit year to 4-Digit year
	if keyword_set(from_yr) then begin
		;2-Digit year
		;   00-59 -> 1900-1959
		;   60-99 -> 2060-2099
		i19 = where(fix(yr) ge 60, n19, COMPLEMENT=i20, NCOMPLEMENT=n20)
		year = yr
		if n19 gt 0 then year[i19] = '19' + year[i19]
		if n20 gt 0 then year[i20] = '20' + year[i20]
	
	;4-Digit year to 2-Digit year
	endif else begin
		message, 'WARNING: Converting 4-digit year to 2-digit year.', /INFORMATIONAL
		yr = stregex(year, '[0-9]{2}([0-9]{2})', /SUBEXP, /EXTRACT)
		yr = reform(yr[1,*])
	endelse

	return, year
end


;+
;   Given a pattern with tokens, build a time string given its components.
;
; :Private:
;
; :Params:
;       PATTERN:            in, required, type=string
;                           Pattern describing how `TIME` should be built.
;
; :Keywords:
;       YEAR:               in, optional, type=strarr
;                           4-digit year that matches a %Y token.
;       YR:                 in, optional, type=strarr
;                           2-digit year that matches a %y token.
;       DOY:                in, optional, type=strarr
;                           3-digit day-of-year that matches a %D.
;       MONTH:              in, optional, type=strarr
;                           2-digit month that matches a %M token.
;       CMONTH:             in, optional, type=strarr
;                           Calendar month name (e.g. January, February, etc.) that
;                               matches a %C tokenl.
;       CALMO:              in, optional, type=strarr
;                           3-character abbreviated calendar month name (e.g. Jan, Feb, ...)
;                               that matches a %c token.
;       WEEKDAY:            in, optional, type=strarr
;                           Weekday (e.g. Monday, Tuesday, etc.) that matches a %W token
;                               for the [start, end] of the file interval.
;       WKDAY:              in, optional, type=strarr
;                           3-character abbreviated week day (e.g. Mon, Tue, etc.) that
;                               matches a %M token.
;       DAY:                in, optional, type=strarr
;                           2-digit day that matches a %d token.
;       HOUR:               in, optional, type=strarr
;                           2-digit hour on a 24-hour clock that matches a %H token.
;       HR:                 in, optional, type=strarr
;                           2-digit hour on a 12-hour clock that matches a %h token.
;       MINUTE:             in, optional, type=strarr
;                           2-digit minute that matches a %m token.
;       SECOND:             in, optional, type=strarr
;                           2-digit second that matches a %S token.
;       DECIMAL:            in, optional, type=strarr
;                           Fraction of a second that matches the %f token.
;       MILLI:              in, optional, type=strarr
;                           3-digit milli-second that matches a %1 token.
;       MICRO:              in, optional, type=strarr
;                           3-digit micro-second that matches a %2 token.
;       NANO:               in, optional, type=strarr
;                           3-digit nano-second that matches a %3 token.
;       PICO:               in, optional, type=strarr
;                           3-digit pico-second that matches a %4 token.
;       AM_PM:              in, optional, type=strarr
;                           "AM" or "PM" string that matches a %A.
;       OFFSET:             in, optional, type=string
;                           Offset from UTC. (+|-)hh[:][mm]. Matches %o.
;       TIME_ZONE:          in, optional, type=string
;                           Time zone abbreviated name. Matches %z.
;
; :Returns:
;       TIME:               out, required, type=string/strarr
;                           Result of combining the date and time elements via `PATTERN`.
;-
function MrTimeParser_Compute, pattern, $
YEAR=year, $
YR=yr, $
DOY=doy, $
MONTH=month, $
CMONTH=cMonth, $
CALMO=calmo, $
WEEKDAY=weekday, $
WKDAY=wkday, $
DAY=day, $
HOUR=hour, $
HR=hr, $
MINUTE=minute, $
SECOND=second, $
DECIMAL=decimal, $
MILLI=milli, $
MICRO=micro, $
NANO=nano, $
PICO=pico, $
AM_PM=am_pM, $
TIME_ZONE=time_zone, $
OFFSET=offset
	compile_opt strictarr
	on_error, 2

;----------------------------------------------------------
; Inputs //////////////////////////////////////////////////
;----------------------------------------------------------
	;Was one of the pre-defined patterns given?
	if MrIsA(pattern, /INTEGER) $
		then inPattern = MrTimeParser_Patterns(pattern) $
		else inPattern = pattern
	
	;Make sure everything is defined
	if n_elements(year)      eq 0 then year      = ''
	if n_elements(yr)        eq 0 then yr        = ''
	if n_elements(doy)       eq 0 then doy       = ''
	if n_elements(month)     eq 0 then month     = ''
	if n_elements(cMonth)    eq 0 then cMonth    = ''
	if n_elements(calmo)     eq 0 then calmo     = ''
	if n_elements(weekday)   eq 0 then weekday   = ''
	if n_elements(wkday)     eq 0 then wkday     = ''
	if n_elements(day)       eq 0 then day       = ''
	if n_elements(hour)      eq 0 then hour      = ''
	if n_elements(hr)        eq 0 then hr        = ''
	if n_elements(minute)    eq 0 then minute    = ''
	if n_elements(second)    eq 0 then second    = ''
	if n_elements(decimal)   eq 0 then decimal   = ''
	if n_elements(milli)     eq 0 then milli     = '000'
	if n_elements(micro)     eq 0 then micro     = '000'
	if n_elements(nano)      eq 0 then nano      = '000'
	if n_elements(pico)      eq 0 then pico      = '000'
	if n_elements(am_pm)     eq 0 then am_pm     = ''
	if n_elements(time_zone) eq 0 then time_zone = 'Z'
	if n_elements(offset)    eq 0 then offset    = '+00:00'

;----------------------------------------------------------
; Compute Time ////////////////////////////////////////////
;----------------------------------------------------------
	;Extract the tokens
	tokens = MrTokens_Extract(inPattern, COUNT=nTokens, POSITIONS=positions)

	;Step through each token
	curPos  = 0
	timeOut = ''
	for i = 0, nTokens - 1 do begin
	;----------------------------------------------------------
	; Replace Token with Time /////////////////////////////////
	;----------------------------------------------------------
		case tokens[i] of
			'Y': substr = MrTimeParser_GetYear(year, yr)
			'y': substr = MrTimeParser_GetYr(yr, year)
			'M': substr = MrTimeParser_GetMonth(month, cmonth, calmo, doy, year, yr)
			'C': substr = MrTimeParser_GetCMonth(cmonth, month, calmo, doy, year, yr)
			'c': substr = MrTimeParser_GetCalMo(calmo, month, cmonth, doy, year, yr)
			'd': substr = MrTimeParser_GetDay(day, doy, year, yr)
			'D': substr = MrTimeParser_GetDOY(doy, year, yr, month, cmonth, calmo, day)
			'W': substr = MrTimeParser_GetWeekDay(weekday, wkday, year, yr, month, cmonth, calmo, doy, day)
			'w': substr = MrTimeParser_GetWkDay(wkday, weekday, year, yr, month, cmonth, calmo, doy, day)
			'H': substr = MrTimeParser_GetHour(hour, hr, am_pm)
			'h': substr = MrTimeParser_GetHr(hr, hour, am_pm)
			'm': if minute[0] eq '' then message, 'Cannot form "%m". Must give %m.' else subStr = minute
			'S': if second[0] eq '' then message, 'Cannot form "%S". Must give %S.' else subStr = second
			'f': substr = MrTimeParser_GetFraction(decimal, milli, micro, nano, pico)
			'1': substr = MrTimeParser_GetMilli(milli, decimal)
			'2': substr = MrTimeParser_GetMicro(micro, decimal)
			'3': substr = MrTimeParser_GetNano(nano, decimal)
			'4': substr = MrTimeParser_GetPico(pico, decimal)
			'A': if am_pm[0]  eq '' then message, 'Cannot form "%A". Must give %A.' else subStr = am_pm
			'z': substr = MrTimeParser_GetTimeZone(time_zone, offset)
			'o': substr = MrTimeParser_GetOffset(offset, time_zone)
		
			;Ignore parentheses
			'(': subStr = strmid(pattern, positions[i]+2, positions[i+1]-positions[i]-2)
		
			else: message, 'Token "' + tokens[i] + '" not recognized.'
		endcase
	
	;----------------------------------------------------------
	; Piece Together Result ///////////////////////////////////
	;----------------------------------------------------------
		;Allocate memory
		;   - Do not know initially which keywords were given (to check number of elements).
		;   - If the first token is "%(", SUBSTR does not have any time information and
		;       is a scalar. Must wait for a different token.
		if n_elements(timeOut) eq 1 && n_elements(subStr) gt 1 $
			then timeOut = replicate(timeOut, n_elements(subStr))

		;Take pieces between tokens from the pattern
		;   - CURPOS is the position after the previous token
		;   - POSITIONS[i]-CURPOS are the number of characters trailing the previous token.
		timeOut += strmid(inPattern, curPos, positions[i]-curPos) + subStr

		;Skip over the current token
		;   - Must also skip over the characters after the last token.
		curPos += 2 + positions[i] - curPos
	
		;Skip over ')'
		if tokens[i] eq '(' then begin
			i += 1
			if i lt nTokens-1 then curPos = positions[i] + 2
		endif
	endfor

	;Include the substring trailing the final token
	tail = strmid(inPattern, positions[i-1]+2)
	if tail ne '' then timeOut += tail

	if n_elements(timeOut) eq 1 then timeOut = timeOut[0]
	return, timeOut
end