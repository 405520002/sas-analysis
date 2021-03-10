DM LOG 'CLEAR'; DM OUTPUT 'CLEAR';
libname local 'C:\Users\User\Desktop\sas\sasprojectdata';

proc datasets library=work kill noprint;
run;
quit;

PROC IMPORT DATAFILE="C:\Users\User\Desktop\sas\sasprojectdata\monthly_sales.xlsx" OUT=WORK.monthly_total_sales  DBMS=EXCEL REPLACE ;
SHEET="sheet1" ;
RUN; 

data t1;
set monthly_total_sales;
keep company date total_product_sales;
proc sort;
by date company;
run;

data first_company;
set t1;
by date company;
if first.company then output;
run;
data first_company2;
set  first_company;
proc sort;
by date company total_product_sales;
proc sort;
by company;
run;

proc transpose data=first_company2 out=transposed_sales_data;
var total_product_sales;
id date;
by company;
run;
proc means  data=transposed_sales_data  noprint;
output out=summary; 
run;
data d2;
set summary;
drop _TYPE_  _FREQ_;
run;
proc transpose data=d2 out=mean_data;
id _stat_;
run;

data result;
set mean_data;
total_sales= MEAN*7;
lag_total_sales=lag(total_sales);
total_sales_growth_rate=(lag_total_sales-total_sales)/total_sales;
if total_sales_growth_rate='none' then  total_sales_growth_rate=0;
keep 	MEAN total_sales lag_total_sales total total_sales_growth_rate ;
run;
proc means data=result noprint;
var total_sales_growth_rate;
output out=summary;
run;



