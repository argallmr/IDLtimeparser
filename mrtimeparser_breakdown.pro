; docformat = 'rst'
;
; NAME:
;       MrTimeParser_Breakdown
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
;   Given a pattern with tokens, breakdown a time string into its components.
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
; :Params:
;       TIME:               in, required, type=string/strarr
;                           Time strings (without tokens) that match `PATTERN`.
;       PATTERN:            in, required, type=string
;                           Pattern containing tokens that identify different date and
;                               time elements within `TIME`.
;       ISMATCH:            out, optional, type=boolean
;                           Returns 1 if `TIME` matches `PATTERN` and 0 otherwise. If
;                               ISMATCH=0, `TIME` will not be broken down and all
;                               keywords will be empty. If, in addition, no variable is
;                               present, an error will be issued.
;
; :Keywords:
;       YEAR:               out, optional, type=strarr
;                           4-digit year that matches a %Y token.
;       YR:                 out, optional, type=strarr
;                           2-digit year that matches a %y token.
;       DOY:                out, optional, type=strarr
;                           3-digit day-of-year that matches a %D.
;       MONTH:              out, optional, type=strarr
;                           2-digit month that matches a %M token.
;       CMONTH:             out, optional, type=strarr
;                           Calendar month name (e.g. January, February, etc.) that
;                               matches a %C tokenl.
;       CALMO:              out, optional, type=strarr
;                           3-character abbreviated calendar month name (e.g. Jan, Feb, ...)
;                               that matches a %c token.
;       WEEKDAY:            out, optional, type=strarr
;                           Weekday (e.g. Monday, Tuesday, etc.) that matches a %W token
;                               for the [start, end] of the file interval.
;       WKDAY:              out, optional, type=strarr
;                           3-character abbreviated week day (e.g. Mon, Tue, etc.) that
;                               matches a %M token.
;       DAY:                out, optional, type=strarr
;                           2-digit day that matches a %d token.
;       HOUR:               out, optional, type=strarr
;                           2-digit hour on a 24-hour clock that matches a %H token.
;       HR:                 out, optional, type=strarr
;                           2-digit hour on a 12-hour clock that matches a %h token.
;       MINUTE:             out, optional, type=strarr
;                           2-digit minute that matches a %m token.
;       SECOND:             out, optional, type=strarr
;                           2-digit second that matches a %S token.
;       DECIMAL:            out, optional, type=strarr
;                           Fraction of a second that matches the %f token.
;       MILLI:              out, optional, type=strarr
;                           3-digit milli-second that matches a %1 token.
;       MICRO:              out, optional, type=strarr
;                           3-digit micro-second that matches a %2 token.
;       NANO:               out, optional, type=strarr
;                           3-digit nano-second that matches a %3 token.
;       PICO:               out, optional, type=strarr
;                           3-digit pico-second that matches a %4 token.
;       AM_PM:              out, optional, type=strarr
;                           "AM" or "PM" string that matches a %A.
;       OFFSET:             out, optional, type=string
;                           Offset from UTC. (+|-)hh[:][mm]. Matches %o.
;       TIME_ZONE:          out, optional, type=string
;                           Time zone abbreviated name. Matches %z.
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
pro MrTimeParser_Breakdown, time, pattern, tf_match, $
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
TIME_ZONE=time_zone
	compile_opt strictarr
	on_error, 2

	nTimes  = n_elements(time)
	boolean = keyword_set(boolean)
	
	if MrIsA(pattern, /INTEGER) $
		then outPattern = MrTimeParser_Patterns(pattern) $
		else outPattern = pattern

;-----------------------------------------------------
;Tokens and File Parts \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;-----------------------------------------------------
	;Convert to a regular expression
	regex_str = MrTokens_ToRegex(outPattern, /IGNORE_PARENS)

	;Get the tokens
	tokens = MrTokens_Extract(outPattern, COUNT=nTokens, REPLACE_PARENS='.*', OPATTERN=_pattern)

	;Apply Regex
	;   - Check the overall match to determine success, then remove it (only interested in the pieces).
	parts    = stregex(time, regex_str, /SUBEXP, /EXTRACT, /FOLD_CASE)
	tf_match = parts[0] eq '' ? 0 : 1
	parts    = parts[1:*,*]

	;If no match was found, decide what to do.
	if tf_match eq 0 then begin
		if n_params() eq 3 $
			then return $
			else message, 'Could not match pattern "' + pattern + '" to time "' + time[0] + '".'
	endif

;-----------------------------------------------------
; Allocate Memory \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;-----------------------------------------------------
	year      = strarr(nTimes)
	yr        = strarr(nTimes)
	doy       = strarr(nTimes)
	month     = strarr(nTimes)
	cmonth    = strarr(nTimes)
	calmo     = strarr(nTimes)
	weekday   = strarr(nTimes)
	wkday     = strarr(nTimes)
	day       = strarr(nTimes)
	hour      = strarr(nTimes)
	hr        = strarr(nTimes)
	minute    = strarr(nTimes)
	second    = strarr(nTimes)
	decimal   = strarr(nTimes)
	milli     = strarr(nTimes)
	micro     = strarr(nTimes)
	nano      = strarr(nTimes)
	pico      = strarr(nTimes)
	am_pm     = strarr(nTimes)
	offset    = strarr(nTimes)
	time_zone = strarr(nTimes)

;-----------------------------------------------------
; Match Tokens to Pattern Parts \\\\\\\\\\\\\\\\\\\\\\
;-----------------------------------------------------
	for i = 0, nTokens - 1 do begin
		;Extract the file name values
		case tokens[i] of
			'Y': year      = reform(parts[i,*])
			'y': yr        = reform(parts[i,*])
			'D': doy       = reform(parts[i,*])
			'M': month     = reform(parts[i,*])
			'C': cmonth    = reform(parts[i,*])
			'c': calMo     = reform(parts[i,*])
			'd': day       = reform(parts[i,*])
			'W': weekday   = reform(parts[i,*])
			'w': wkday     = reform(parts[i,*])
			'H': hour      = reform(parts[i,*])
			'h': hr        = reform(parts[i,*])
			'm': minute    = reform(parts[i,*])
			'S': second    = reform(parts[i,*])
			'f': decimal   = reform(parts[i,*])
			'1': milli     = reform(parts[i,*])
			'2': micro     = reform(parts[i,*])
			'3': nano      = reform(parts[i,*])
			'4': pico      = reform(parts[i,*])
			'A': am_pm     = reform(parts[i,*])
			'o': offset    = reform(parts[i,*])
			'z': time_zone = reform(parts[i,*])
			else: message, 'Token "' + tokens[i] + '" not recognized.', /INFORMATIONAL
		endcase
	endfor

	;Return scalars
	if nTimes eq 1 then begin
		year       = year[0]
		yr        = yr[0]
		doy       = doy[0]
		month     = month[0]
		cmonth    = cmonth[0]
		calMo     = calMo[0]
		day       = day[0]
		weekday   = weekday[0]
		wkday     = wkday[0]
		hour      = hour[0]
		hr        = hr[0]
		minute    = minute[0]
		second    = second[0]
		decimal   = decimal[0]
		milli     = milli[0]
		micro     = micro[0]
		nano      = nano[0]
		pico      = pico[0]
		am_pm     = am_pm[0]
		offset    = offset[0]
		time_zone = time_zone[0]
	endif
end