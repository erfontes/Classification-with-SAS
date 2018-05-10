run;quit;
OPTIONS PAGESIZE=59 LINESIZE=80 NOCENTER ;
TITLE "TESTING MACROS";


DATA DUMMIEs;

   SET e.base_model;

/***********   Converting the variables to dummies  */;

   AGE1=0;
   AGE2=0;
   age3=0;
   
   select ;
   when ( age le 40 )  age1=1 ;
   when (age gt 40 and age le 52) age2=1;
   OTHERWISE   age3  = 1 ;
   end;

   ten1=0;
   ten2=0;
   ten3=0;
   
   select ;
   when ( tenure le 29 )  ten1=1 ;
   when (tenure gt 29 and tenure le 93) ten2=1;
   OTHERWISE   ten3  = 1 ;
   end;

   sp1=0;
   sp2=0;
   sp3=0;
   
   select ;
   when ( avg_spend_3 le 162 )  sp1=1 ;
   when (avg_spend_3 gt 162 and avg_spend_3 le 894) sp2=1;
   OTHERWISE   sp3  = 1 ;
   end;

   card1=0;
   card2=0;
   card3=0;
   card4=0;
   card5=0;
   
   select ;
   when (prodcd=100) card1=1 ;
   when (prodcd=101) card2=1;
   when (prodcd=102) card3=1;
   when (prodcd=200) card4=1;
   OTHERWISE   card5  = 1 ;
   end;

   zip1=0;
   zip2=0;
   
   select ;
   when (zip_1 in (0 1 2)) zip1=1 ;
   OTHERWISE   zip2  = 1 ;
   end;

RUN;


option mprint ;
%MACRO VARLIST ;
        age1
	age2
	ten1
	ten2
	sp1
	sp2
	card1
	card2
	card3
	card4
	zip1
%MEND VARLIST ;

PROC LOGISTIC DATA=DUMMIES NOSIMPLE maxiter=40  OUTEST=e.COEF
                                                (KEEP =
                                                 _TYPE_
                                                 _NAME_
                                                 INTERCEP
                                                 %VARLIST
                                                           ) ;

   MODEL target  =  %VARLIST  ;
RUN ;

%MACRO SCORCARD(D,E) ;
/* --------------------------------------------------------------  
 * To produce a scorecard with D point doubling the odds ratio of 2 *
 *  and E points represnting an even odds of 1 to 1 ratio.          *
 --------------------------------------------------------------  */

DATA CARD(KEEP = _TYPE_ _NAME_ INTERCEP %VARLIST) ;
   SET e.COEF  ;
   _NAME_ = "SCORE" ;
   ARRAY VECTOR {*} %VARLIST ;
   DO I = 1 TO DIM(VECTOR) ;
      VECTOR(I) =round( &D * VECTOR(I) / LOG(2), 1) ;
   END ;
   INTERCEP =round ( &D * (INTERCEP - LOG(1)) / LOG(2) + &E, 1 ) ;
RUN ;
PROC TRANSPOSE NAME=VARIABLE
               DATA=card (DROP = _NAME_ _TYPE_)
               OUT=VERTICAL (KEEP=COL1 VARIABLE
                             RENAME=(COL1=POINTS)) ;
RUN ;
PROC PRINT NOOBS DATA=VERTICAL ;
RUN ;
option replace ;
PROC SCORE
           DATA=DUMMIES
           SCORE=CARD
           TYPE=PARMS
           OUT=SCORESET
                             ;
   VAR %VARLIST ;
RUN ;

DATA DUMMIES1 ;
   SET  SCORESET ;

   LOGODDS = (SCORE - &E ) * LOG(2) / &D +  log(1)   ;

   ODDS    = EXP(LOGODDS) ;

   PGOOD   = ODDS / (ODDS + 1) ;

   PBAD = 1 - PGOOD ;
RUN ;

%MEND SCORCARD ;
%SCORCARD(10,100)

/* %MACRO VALRANK(DSN,DEPVAR,PVAR,GROUPS,WEIGHT,TITLE1,TITLE2 ); */


%INCLUDE MACPATH(valrank.mac) / SOURCE ;
  %VALRANK(dummies1 , target , pbad ,100,1,XXX ,YYY);
   run; quit;

%INCLUDE MACPATH(statscr.mac) / SOURCE ;
  %STATSCR(dummies1 ,target ,SCORE,WT,YYY);



