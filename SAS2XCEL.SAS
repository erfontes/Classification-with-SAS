  /*****************************************************************/
  /***SAS2XCEL.SAS                                                ***/
  /***   SAS Macro to dump the contents of a SAS Data Set to a   ***/
  /***       CSV File for input to an Excel Spread Sheet         ***/
  /***                                                           ***/
  /***   Macro Vars                                              ***/
  /***       VAR1   = SAS Dataset name ( CFDATA.AAAlines)      ***/
  /***       VAR2 = CSV File ("userdisk1:[name]aaalines.csv")***/
  /***       VAR3 = Y or N (Place Var Names and Labels on    ***/
  /***                          1st and 2nd line of CSV File)    ***/
  /***       MOD      = MOD (Need to Append output to existing   ***/
  /***                        CSV File)                          ***/
  /*****************************************************************/

%MACRO SAS2XCEL(VAR1,VAR2, VAR3, MOD);
   FILENAME OUTFILE &VAR2 LRECL=8000 RECFM=V ;

   PROC CONTENTS DATA=&VAR1
   OUT=_TEMP_(KEEP=NAME TYPE VARNUM LABEL FORMAT FORMATD FORMATL) NOPRINT;
   RUN;

   PROC SORT DATA=_TEMP_ OUT=_TEMP_; BY VARNUM; RUN;

   DATA _NULL_; SET _TEMP_ END=EOF;
    CALL SYMPUT('ZVR'||(LEFT(PUT(_N_,5.))),NAME);
    CALL SYMPUT('TYP'||(LEFT(PUT(_N_,5.))),LEFT(PUT(TYPE,8.)));
    IF LABEL = ' ' THEN LABEL = NAME;
    CALL SYMPUT('LBL'||(LEFT(PUT(_N_,5.))),LEFT(LABEL));
    CALL SYMPUT('FMT'||(LEFT(PUT(_N_,5.))),LEFT(FORMAT));
    CALL SYMPUT('FMD'||(LEFT(PUT(_N_,5.))),PUT(FORMATD,BEST.));
    CALL SYMPUT('FML'||(LEFT(PUT(_N_,5.))),PUT(FORMATL,BEST.));
    IF EOF THEN CALL SYMPUT('TOTAL',LEFT(PUT(_N_,8.)));
   RUN;

  DATA _NULL_;
   %DO ZI=1 %TO &TOTAL;
     LENGTH  TMP&ZI $40 ;
     TMP&ZI = "&&FMT&ZI" || "&&FML&ZI" || "." || "&&FMD&ZI";
     if compress("&&FML&ZI") = "0" then do;
       TMP&ZI = "&&FMT&ZI" || ".";
     end;
     TMP&ZI = COMPRESS(TMP&ZI);
     IF "&&FMT&ZI" = " " THEN TMP&ZI = 'BEST.' ;
     CALL SYMPUT("FMT&ZI", TMP&ZI);
   %END;
  RUN;

   DATA _NULL_;
    FILE OUTFILE  NOPRINT NOTITLES &MOD;
    SET &VAR1;
    FORMAT _NUMERIC_ BEST12.;
     IF _N_ = 1 THEN PUT 'SEP=;';
    %IF &VAR3 EQ Y %THEN %DO;
       IF _N_ = 1 THEN DO;
        PUT
       %DO YI =1 %TO &TOTAL;
         %CMPRES("'&&ZVR&YI") +(1) ';'
       %END;
       +(-1)' '; /* REMOVE LAST HANGING COMMA DELIMITER */
      END;
       IF _N_ = 1 THEN DO;
        PUT
       %DO XI =1 %TO &TOTAL;
         %CMPRES("'&&LBL&XI") +(1) ';'
       %END;
       +(-1)' '; /* REMOVE LAST HANGING COMMA DELIMITER */
      END;
    %END;
    PUT
     %DO WI=1 %TO &TOTAL;
       %IF &&TYP&WI=1 %THEN %DO;  /* IF NUMERIC VARIABLE */
           &&ZVR&WI  &&FMT&WI +(1) ';'
       %END;
       %ELSE %DO;   /* IF CHARACTER VARIABLE */
          " "  &&ZVR&WI  +(-1) ";"
       %END;
     %END;
     +(-1) ' '; /* REMOVE THE EXTRA COMMA AT THE END */
   RUN;

%MEND SAS2XCEL;

