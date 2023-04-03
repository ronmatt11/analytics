/* Start by reading in all four data sets. There are a modifications and additions
   you need to make, which I will describe in comments */

data cities;                                             /* Longitude, Latitude, City */
	infile '/folders/myfolders/BAN_130_Project/cities.csv' delimiter=',';
	informat City $32.;                                  /* enough room for all the city names */
	input Longitude 
	      Latitude 
	      City $;
	Region = Round(Longitude,5)*100+Round(Latitude,5);
run;

proc sort data=cities; 
by Region; 								                 /* sort by region */
run; 

Title "Cities";
proc print data=cities;
run;

data battles; 										/* City, Date */
    infile '/folders/myfolders/BAN_130_Project/battles.csv' delimiter=',';
    informat Event $32. 
    		 Date anydtdte12.; 						/* informat for Date should be date9. */
    input Event $ 
          Date;
    City = Event; 									/* create new variable City with the same values 
                                     				as Event (since events are named after their city) */                                
	format Date date9.;
run;

Title "Battles";
proc print data=battles;
run;

data temps; 									/* Longitude, Temperature, Days */
	infile '/folders/myfolders/BAN_130_Project/temps.csv' delimiter=','; /* read infile from temp.csv */
	input Longitude 
		  Temperature 
		  Days;
          Direction=-1;							/* add new variable Direction, equal to -1, since this file is 100% retreat */
          start_date='18OCT1812'd;
	if _n_=1 then Date = start_date;			/* Create new variable Date: */ /*     first one is 18OCT1812 */ /*     then add Days for Date of each further observation */
	else Date+Days;
	drop start_date;
    format Date date9.;
run;

Title "Temperatures";
proc print data=temps;
run;

data troops; 									/* Longitude, Latitude, Troop_Size, CharDirection, Division, Date */
    infile '/folders/myfolders/BAN_130_Project/troops.csv' delimiter=','; /* read infile from troops.csv */
    input Longitude
          Latitude
          Troop_Size
          CharDirection $
          Division
          Date date9.;		                            
    Region = Round(Longitude,5)*100+Round(Latitude,5);	/* set Region same as in cities */
    if CharDirection="A" then NumDirection=1;           /* create numeric Direction variable: */
    else if CharDirection="R" then NumDirection=-1;     /*+1 if CharDirection is 'A', -1 if CharDirection is 'R' */
	format Date date9.;
run;

Title "Troops";
proc print data=troops;
run;

/* Merge troops and cities by region, outer join, including all troops */
/* into new dataset troops_cities */
proc sort data=troops; by Region; 
run; 							     /* sort troops by Region */

proc sort data=cities; by Region;   /* ............. sort cities by region */
run;
								    
data troops_cities;
  merge troops(in=T) cities(in=C); /* merge troops & cities into troops_cities */
  by Region; 					   /* by region */       
  if (T=1); 						/* keeping everything in troops */
run;

proc sort data=troops_cities;      /* sort */
by Division DESCENDING Troop_Size; /* a convenient sort order is first by Division and then Troop_Size (descending) */
run;

Title "Troops_Cities";
proc print data=troops_cities;
run;

proc sort data=battles; by City;
run;

proc sort data=cities; by City;
run;

data battles_cities;
  merge battles(in=B) cities(in=C); 			/* merge battles & cities by City, inner join */
  by City;                          			/* into new dataset battles_cities */
  if B=1 and C=1;
run;

Title "Battles_Cities";
proc print data=battles_cities;
run;

proc sort data=troops_cities; by Date;
run;

proc sort data=battles_cities; by Date;
run;

data troops_battles;
  merge troops_cities(in=TC) battles_cities(in=BC); /* merge troops_cities & battles_cities by Date, outer join, all troops_cities */
  by Date;                                          /* into new dataset troops_battles */   
  if (TC=1);                                        
run;

proc sort data=troops_battles;           		/* keep sorted as before for troops */
by Division DESCENDING Troop_Size; 
run;

Title "Troops_Battles";
proc print data=troops_battles;
run;

proc sort data=troops_battles;
by Date;
run;

proc sort data=temps;
by Date;
run;

data troops_temps;
  merge troops_battles(in=TB) temps(in=TMP);       /* merge troops_battles & temps by Date, outer join, all troops_battles */
  by Date;                                          /* into new dataset troops_temps */
  if (TB=1);                                        /* keep sorted as before for troops */
run;

proc sort data=troops_temps;                       /* keep sorted as before for troops */
by Division DESCENDING Troop_Size; 
run;

Title "Troops_temps";
proc print data=troops_temps;
run;


data troops1;
set troops_temps;                                  /* create new dataset troops1 from troops_temps for Division #1 */
WHERE Division=1;                                  /* use WHERE clause */
Drop division region days Direction CharDirection; /* Optional: drop Division and Region variables they are no longer needed */
run;
title "Troops1";
proc print data=troops1 noobs;
run;


data troops2;
set troops_temps;     
WHERE Division=2;     
Drop division region days Direction CharDirection; 
run;
title "Troops2";
proc print data=troops2 noobs;
run;                                      /* create new dataset troops2 from troops_temps for Division #2 */


data troops3;
set troops_temps;     
WHERE Division=3;     
Drop division region days Direction CharDirection; 
run;
title "Troops3";
proc print data=troops3 noobs;
run;                                       /* create new dataset troops3 from troops_temps for Division #3 */

