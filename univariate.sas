********************************************************* ;
  ********************************************************* ;
  ********                                       ********** ;
  ********   EXPLORATORY STATISTICAL ANALYSIS    ********** ;
  ********                                       ********** ;
  ********************************************************* ;
  ********************************************************* ;


 /* ****************************************************************\
 |   THE EDA.SAS PROGRAM PRODUCES THE MOST COMMON STATISTICS         |
 |   FOR DISTINGUISHING BETWEEN TWO DISTRIBUTIONS.                   |
 |   THE OUTPUT OF THE PROGRAM MAY CONTAIN THE FOLLOWING:            |
 |                                                                   |
 |       1- KOLMOGOROV-SMIRNOV, D STATISTICS, KULLBACK -LEIBLER      |
 |          INFORMATION, INFORMATION VALUE, DIVERGENCE, THE MEAN     |
 |          AND STANDARD DEVIATION OF THE VARIABLES BY GOOD AND      |
 |          BAD INDICATOR, AND THE DISTRIBUTION OF THE CONTINUOUS    |
 |          OR DISCRETE VARIABLES.                                   |
 |                                                                   |
 |       2- THE MEANS OF THE VARIABLES BY DEPENDENT                  |
 |          VARIABLE (MEANSBAD.SAS)                                  |
 |                                                                   |
 |       3- THE RANK AND PLOTS (RANKPLOT.SAS)                        |
 |                                                                   |
 |       4- THE FREQUENCIES OF THE VARIABLES (FREQ.SAS)              |
 |                                                                   |
 | THE PROGRAM MAY EXCUTE THE FOLLOWING STEPS:                       |
 |                                                                   |
 | STEP 1 --- THE PROGRAM EXCECUTES THE MACRO STATSCC.MAC            |
 |            WHICH REQUIRES THE FOLLOWING:                          |
 |                  FILENM : THE SAS INPUT DATA DATA SET             |
 |                  OUTFNM : THE SAS OUTPUT DATA DATA SET            |
 |                  DEPVAR : DEPENDENT VARIABLE ( 1= BAD , 0=GOOD )  |
 |                  EXPVAR : EXPLANATORY VARIABLE                    |
 |                  EXPDESC: EXPLANATORY VARIABLE S DESCRIPTION      |
 |                  PROJECT: THE NAME OF THE PROJECT;                |
 |                                                                   |
 | STEP 2  - THE PROGRAM INCLUDES THE FORMAT FOR STANDARD            |
 |           DISCRETE VARIABLES TO BE USED BY THE MACRO STATSCD.MAC.;|
 |                                                                   |
 \***************************************************************** */


* *************   PLEASE PROVIDE THE FOLLOWING   **************  ;


    OPTION MPRINT;


   filename  OUT    '/erfontes/model';  * Directory name for output;


    %LET PROJECT = MODEL ; * Name of the project  ;
    %LET FILENM  = TEMP      ;    * Name of the final data set;
    %LET DEPVAR  = TARGET;                    * Name of dependent variable;
    %LET OUTFNM  = OUT ;                   * Name of the output file ;
    %LET WEIGHT  = WGT   ;                   * Name of the weight variable;


**************       THE MAIN PROGRAM    ***************  ;




    TITLE     "MODEL A" ;
    filename  macpath  '/macro/';




RUN;


%INCLUDE macpath(statscc.mac) / SOURCE ;


%unianac(age, age);
%unianac(tenure, tenure);




%INCLUDE MACPATH(dformat.mac) / SOURCE ;
%INCLUDE MACPATH(statscd.mac) / SOURCE ;


%unianad(prodcd, Produto, 5, prod.);
%unianad(zip_1, Zip Code, 10, zip.);




%MEND UNIANAD;






PROC SORT DATA=STATSK;
                BY DESCENDING INFO_VAL ;
TITLE ' TABLE 1 ';
PROC PRINT DATA=STATSK LABEL
                SPLIT='*' UNIFORM NOOBS HEADING=HORIZONTAL;


  LABEL    EXPVAR='VARIABLE'
          EXPDESC='DESCRIPTION'
         INFO_VAL='INFORMATION*VALUE'
              KSD= 'KOLMOGOROV*-SMIRNOV*D STATISIC'
              KLD='KULLBACK*-LEIBLER*INFORMATION'
                D='DIVERGENCE'
            XBARG="MEAN/FREQ* OF 'GOODS'"
             STDG="STANDARD*DEVIATION*OF 'GOODS'"
            XBARB="MEAN/FREQ* OF  'BADS ' "
             STDB="STANDARD*DIVIATION*   OF 'BADS'"
             ;

             ;

   VAR  EXPVAR EXPDESC INFO_VAL KSD KLD D
        XBARG STDG XBARB STDB ;
RUN;QUIT;

          ;

   VAR  EXPVAR EXPDESC INFO_VAL KSD KLD D
        XBARG STDG XBARB STDB ;
RUN;QUIT;


<!--stackedit_data:
eyJoaXN0b3J5IjpbLTUzNjA0NDgxOV19
-->
