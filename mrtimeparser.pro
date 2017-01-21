; docformat = 'rst'
;
; NAME:
;       MrTimeParser
;
;*****************************************************************************************
;   Copyright (c) 2014, Matthew Argall                                                   ;
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
;       2014-03-21  -   Removed function MrTimeParser_Token2Regex to its own file
;                           (named MrTimeTokensToRegex.pro as of this date). - MRA
;       2014-04-29  -   Added support for the "%f" token. Weekdays and Wkdays are now
;                           handled. Added helper functions MrTimeParser_YearToYr and
;                           MrTimeParser_DissectDOY. Added patterns 27-32. - MRA
;       2014-04-03  -   Typo when converting %c to %W or %w. Fixed. - MRA
;       2014-05-10  -   Added ISMATCH keyword to return the match status without issuing
;                           an error message. - MRA.
;       2014-05-11  -   Added support for "%z" and "%o". New TIME_ZONE and OFFSET keywords. - MRA
;       2014-06-29  -   Added support for "\%", "%(" and "%)". - MRA
;       2014-06-30  -   Removed MrTimeParser_ExtractTokens and incorporated MrTokens_Extract. - MRA
;       2015-04-30  -   Was dissecting DOY incorrectly. Fixed. - MRA
;       2015-08-21  -   Fixed logic that caused error when converting %D -> %D. - MRA
;-
;*****************************************************************************************
;+
;   The initialization method. Here, a directory and filename can be given with a date
;   and time code embedded.
;
;   Calling Sequence::
;       MrTimeParser, timeIn, patternIn[, /BEAKDOWN], ...
;       MrTimeParser, timeIn, patternIn, ISMATCH=isMatch, ...
;       MrTimeParser, timeOut[, /COMPUTE], ...
;       MrTimeParser, timeIn, patternIn, patternOut, timeOut, ...
;       
;
; :Params:
;       TIME:           in, out, required, type=string/strarr
;                       Time strings. If COMPUTE is set, this is an output and the
;                           keywords below will be used to build it. If BREAKDOWN is
;                           set, then TIME will be broken into its date and time
;                           components.
;       PATTERNIN:      in, required, type=string
;                       The pattern used to breakdown or compute `TIME`. See the file
;                           header for token options.
;       PATTERNOUT:     in, optional, type=string
;                       If `TIME` is to be converted from one format to another, then this
;                           pattern defines the output format. See the `BOOLEAN` keyword
;                           for exceptions.
;       TIMEOUT:        out, optional, type=string/strarr
;                       Reformatted `TIME` based on `PATTERNOUT`. Required if `PATTERNOUT`
;                           is present.
;
; :Keywords:
;       BOOLEAN:            in, optional, type=boolean, default=0
;                           If set, `TIME` will be compared to `PATTERNIN`. If the
;                               the pattern matches the time, 1 is returned. 0 is returned
;                               otherwise.
;       BREAKDOWN:          in, optional, type=boolean
;                           If set, `TIME` will be broken down into its components.
;                               Automatically set if `TIME` is given.
;       COMPUTE:            in, optional, type=boolean
;                           If set, `TIME` will be built from components given.
;                               Automatically set if `TIME` is not give.
;       ISMATCH:            out, optional, type=boolean
;                           Returns 1 if `TIME` matches `PATTERN` and 0 otherwise. If
;                               ISMATCH=0, `TIME` will not be broken down and all
;                               keywords will be empty. If, in addition, no variable is
;                               present, an error will be issued.
;       YEAR:               in, out, optional, type=strarr
;                           4-digit year that matches a %Y token.
;       YR:                 in, out, optional, type=strarr
;                           2-digit year that matches a %y token.
;       DOY:                in, out, optional, type=strarr
;                           3-digit day-of-year that matches a %D.
;       MONTH:              in, out, optional, type=strarr
;                           2-digit month that matches a %M token.
;       CMONTH:             in, out, optional, type=strarr
;                           Calendar month name (e.g. January, February, etc.) that
;                               matches a %C tokenl.
;       CALMO:              in, out, optional, type=strarr
;                           3-character abbreviated calendar month name (e.g. Jan, Feb, ...)
;                               that matches a %c token.
;       WEEKDAY:            in, out, optional, type=strarr
;                           Weekday (e.g. Monday, Tuesday, etc.) that matches a %W token
;                               for the [start, end] of the file interval.
;       WKDAY:              in, out, optional, type=strarr
;                           3-character abbreviated week day (e.g. Mon, Tue, etc.) that
;                               matches a %M token.
;       DAY:                in, out, optional, type=strarr
;                           2-digit day that matches a %d token.
;       HOUR:               in, out, optional, type=strarr
;                           2-digit hour on a 24-hour clock that matches a %H token.
;       HR:                 in, out, optional, type=strarr
;                           2-digit hour on a 12-hour clock that matches a %h token.
;       MINUTE:             in, out, optional, type=strarr
;                           2-digit minute that matches a %m token.
;       SECOND:             in, out, optional, type=strarr
;                           2-digit second that matches a %S token.
;       DECIMAL:            in, optional, type=strarr
;                           Fraction of a second that matches the %f token.
;       MILLI:              in, out, optional, type=strarr
;                           3-digit milli-second that matches a %1 token.
;       MICRO:              in, out, optional, type=strarr
;                           3-digit micro-second that matches a %2 token.
;       NANO:               in, out, optional, type=strarr
;                           3-digit nano-second that matches a %3 token.
;       PICO:               in, out, optional, type=strarr
;                           3-digit pico-second that matches a %4 token.
;       AM_PM:              in, out, optional, type=strarr
;                           "AM" or "PM" string that matches a %A.
;       OFFSET:             in, out, optional, type=string
;                           Offset from UTC. (+|-)hh[:][mm]. Matches %o.
;       TIME_ZONE:          in, out, optional, type=string
;                           Time zone abbreviated name. Matches %z.
;-
pro MrTimeParser, time, patternIn, patternOut, timeOut, $
ISMATCH=isMatch, $
BREAKDOWN=breakdown, $
COMPUTE=compute, $
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
AM_PM=am_pm, $
OFFSET=offset, $
TIME_ZONE=time_zone, $

UTC=utc, $
TZ_OUT=tz_out
	compile_opt strictarr

	;Error handling
	catch, the_error
	if the_error ne 0 then begin
		catch, /cancel
		timeOut = ''
		isMatch = 0B
		if ~arg_present(isMatch) then MrPrintF, 'LogErr'
		return
	endif

	;Default to converting to an ISO time string
	_patternOut = n_elements(patternOut) eq 0 ? '' : patternOut
	compute     = keyword_set(compute)
	breakdown   = keyword_set(breakdown)
	tz_out      = keyword_set(utc)
	if keyword_set(utc) $
		then tz_out = 'Z' $
		else tz_out = n_elements(tz_out) eq 0 ? '' : tz_out

	;If a pattern was given, set BREAKDOWN and COMPUTE
	;If no pattern was given, only one of BREAKDOWN or COMPUTE may be set.
	;   - Determine which one automatically
	;   - If both were set, it was probably an accident. Otherwise TIME will not change.
	if _patternOut ne '' then begin
		compute   = 1
		breakdown = 1
	endif else if (breakdown + compute) eq 0 then begin
		if n_elements(time) eq 0 then compute = 1 else breakdown = 1
	endif else if (breakdown + compute) eq 2 then begin
		message, 'BREAKDOWN and COMPUTE are mutually exclusive.'
	endif

;-----------------------------------------------------
; Breakdown \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;-----------------------------------------------------

	if breakdown then begin
		MrTimeParser_Breakdown, time, patternIn, isMatch, $
		                        YEAR      = year, $
		                        YR        = yr, $
		                        DOY       = doy, $
		                        MONTH     = month, $
		                        CMONTH    = cMonth, $
		                        CALMO     = calmo, $
		                        WEEKDAY   = weekday, $
		                        WKDAY     = wkday, $
		                        DAY       = day, $
		                        HOUR      = hour, $
		                        HR        = hr, $
		                        MINUTE    = minute, $
		                        SECOND    = second, $
		                        DECIMAL   = decimal, $
		                        MILLI     = milli, $
		                        MICRO     = micro, $
		                        NANO      = nano, $
		                        PICO      = pico, $
		                        AM_PM     = am_pm, $
		                        OFFSET    = offset, $
		                        TIME_ZONE = time_zone

		;Check for matches.
		if isMatch eq 0 then $
			if arg_present(isMatch) eq 0 then message, 'Could not match pattern "' + patternIn + '" to time "' + time[0] + '".'
	endif

;-----------------------------------------------------
; Compute \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;-----------------------------------------------------
	if compute then begin
		timeOut = MrTimeParser_Compute( patternOut, $
		                                YEAR      = year, $
		                                YR        = yr, $
		                                DOY       = doy, $
		                                MONTH     = month, $
		                                CMONTH    = cMonth, $
		                                CALMO     = calmo, $
		                                WEEKDAY   = weekday, $
		                                WKDAY     = wkday, $
		                                DAY       = day, $
		                                HOUR      = hour, $
		                                HR        = hr, $
		                                MINUTE    = minute, $
		                                SECOND    = second, $
		                                DECIMAL   = decimal, $
		                                MILLI     = milli, $
		                                MICRO     = micro, $
		                                NANO      = nano, $
		                                PICO      = pico, $
		                                AM_PM     = am_pm, $
		                                OFFSET    = offset, $
		                                TIME_ZONE = time_zone )

		;Make sure we return values properly
		if n_params() ne 4 then message, 'Incorrect number of parameters.'
	endif
end



;---------------------------------------------------
; Main Level Example Program (.r MrTimeParser) /////
;---------------------------------------------------
;EXAMPLE 1
;   Create a fake time with all of the time codes in it. Break down the time to
;   check if all components are parsed correctly.
timeIn = '2014-14-03-March-Mar-078-19-Saturday-SatT23:11:26:31.123456789000PM'
patternIn  = '%Y-%y-%M-%C-%c-%D-%d-%W-%wT%H:%h:%m:%S.%1%2%3%4%A'
MrTimeParser, timeIn, patternIn, /BREAKDOWN, $
              YEAR=year, YR=yr, MONTH=month, CMONTH=cmonth, CALMO=calmo, DOY=doy, $
              DAY=day, WEEKDAY=weekday, WKDAY=wkday, $
              HOUR=hour, HR=hr, MINUTE=minute, SECOND=second, $
              MILLI=milli, MICRO=micro, NANO=nano, PICO=pico, AM_PM=am_pm

;Display the results.
print, '--------------------------------------------'
print, 'Example 1'
print, '--------------------------------------------'
print, 'Test Time:    ', timeIn
print, 'Test Pattern: ', patternIn
print, 'Parsed:'
print, year,    FORMAT='(%"   Year         = %i")'
print, yr,      FORMAT='(%"   2-Digit Year = %i")'
print, month,   FORMAT='(%"   Month        = %i")'
print, cmonth,  FORMAT='(%"   Month Name   = %s")'
print, calmo,   FORMAT='(%"   Abbr. Month  = %s")'
print, doy,     FORMAT='(%"   Day-of-Year  = %i")'
print, day,     FORMAT='(%"   Day          = %i")'
print, weekday, FORMAT='(%"   Weekday      = %s")'
print, wkday,   FORMAT='(%"   Wkday        = %s")'
print, hour,    FORMAT='(%"   24-Hour      = %i")'
print, hr,      FORMAT='(%"   12-Hour      = %i")'
print, minute,  FORMAT='(%"   Minute       = %i")'
print, second,  FORMAT='(%"   Second       = %i")'
print, milli,   FORMAT='(%"   Milliseconds = %i")'
print, micro,   FORMAT='(%"   Microseconds = %i")'
print, nano,    FORMAT='(%"   Nanoseconds  = %i")'
print, pico,    FORMAT='(%"   Picoseconds  = %i")'
print, am_pm,   FORMAT='(%"   AM/PM        = %s")'
print, ''
      
;EXAMPLE 2
;   Take a time string and convert it to all of the different pre-defined formats.
timeIn    = '19-March-2014 23:26:31.12'
patternIn = '%d-%C-%Y %H:%m:%S.%1'
timeOut   = strarr(32)
for i = 0, 31 do begin
    MrTimeParser, timeIn, patternIn, i+1, tOut
    timeOut[i] = tOut
endfor

print, '--------------------------------------------'
print, 'Example 2'
print, '--------------------------------------------'
print, 'Starting Time String:'
print, '    ' + timeIn
print, 'Results:'
print, '    ' + transpose(timeOut)
print, ''
      
      
;EXAMPLE 3
;   Convert an array of times
timeIn    = ['2001-12-03T10:55:00', '2001-12-03T11:00:00']
patternIn = '%Y-%M-%dT%H:%m:%S'
MrTimeParser, timeIn, patternIn, 2, timeOut

print, '---------------------------------------'
print, 'Example 3'
print, '---------------------------------------'
print, 'Starting Time String:'
print, timeIn, FORMAT='(%"   [%s, %s]")'
print, 'Results:'
print, timeOut, FORMAT='(%"   [%s, %s]")'
print, ''
      
      
;EXAMPLE 4
;   Example using the %f token
timeIn     = '2001-12-03T10:55:00.123456'
patternIn  = '%Y-%M-%dT%H:%m:%S%f'
patternOut = '%D-%Y %hh %mm %S.%1%2%3s %A'
MrTimeParser, timeIn, patternIn, patternOut, timeOut

print, '---------------------------------------'
print, 'Example 4'
print, '---------------------------------------'
print, 'Starting Time String:'
print, timeIn, FORMAT='(%"   %s")'
print, 'Results:'
print, timeOut, FORMAT='(%"   %s")'
print, ''
      
      
;EXAMPLE 5
;   Example using the ISMATCH keyword.
timeIn     = '2001-12-03T10:55:00.123456'
patternIn  = '%Y-%D %Hh %mm %Ss'
MrTimeParser, timeIn, patternIn, ISMATCH=isMatch

print, '---------------------------------------'
print, 'Example 5'
print, '---------------------------------------'
print, 'Starting Time String:    ' + timeIn
print, 'Pattern to match:        ' + patternIn
print, 'Successful Match?        ' + (isMatch ? 'Yes' : 'No')
      
;EXAMPLE 6
;   Example using %z and %o.
timeIn     = '2001-12-03 10:55:00 GMT'
patternIn  = '%Y-%M-%d %H:%m:%S %z'
patternOut = '%Y-%D %Hh %mm %Ss %o'
MrTimeParser, timeIn, patternIn, patternOut, timeOut

print, '---------------------------------------'
print, 'Example 6'
print, '---------------------------------------'
print, 'Starting Time String:'
print, FORMAT='(%"   %s")', timeIn
print, 'Results:'
print, FORMAT='(%"   %s")', timeOut
print, ''


;EXAMPLE 5
;   - Ignore the contents of %( and %)
filenames = ['rbspa_def_MagEphem_TS04D_20140331_v1.1.1.h5', $
             'rbspb_def_MagEphem_TS04D_20140331_v1.1.1.h5']
pattern    = 'rbsp%(%Y(a|b)%o%)_def_MagEphem_TS04D_%Y%M%d_v*.h5'
patternOut = 'rbsp%(%y(a|b)%z%)_def_MagEphem_TS04D_%Y-%D_v*.h5'
MrTimeParser, filenames, pattern, YEAR=year, MONTH=month, DAY=day, /BREAKDOWN
MrTimeParser, filenames, pattern, patternOut, fileOut

;Print results
print, '---------------------------------------'
print, 'Example 3'
print, '---------------------------------------'
print, 'Pattern: ' + pattern
print, 'Filenames:'
print, '  ' + filenames[0]
print, '  ' + filenames[1]
print, 'Time Components:'
print, FORMAT='(%"  Year:  [%s, %s]")', year
print, FORMAT='(%"  Month: [  %s,   %s]")', month
print, FORMAT='(%"  Day:   [  %s,   %s]")', day
print, 'Out Pattern: ' + patternOut
print, 'Output:'
print, '  ' + fileOut[0]
print, '  ' + fileOut[1]


end