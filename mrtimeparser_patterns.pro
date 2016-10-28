; docformat = 'rst'
;
; NAME:
;       MrTimeParser_Patterns
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
