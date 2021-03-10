DM LOG 'CLEAR'; DM OUTPUT 'CLEAR';
libname local 'C:\Users\User\Desktop\sas\sasprojectdata';


/*economics index data*/
PROC IMPORT DATAFILE="C:\Users\User\Desktop\sas\sasprojectdata\sheet3.xlsx" OUT=WORK.macro_economics_index DBMS=EXCEL REPLACE ;
SHEET="sheet1" ;
RUN; 

data md1;
set macro_economics_index;
month2=month(month);
year=year(month);
proc sort;
by  month; 
run;
data md2;
set md1(drop=month);
run;

proc transpose data=md2 out=transposed_index;
id  varaible;
by  year month2;
run;

data md25;
set transposed_index(keep=month2 year taiwan_cpi taiwan_unemployee_rate taiwan_confidence_rate taiwan_salary);
run;
data md3;
set md25;
proc sort;
by desending year month2;
run;

proc means data=md3 noprint;
var taiwan_cpi taiwan_unemployee_rate taiwan_confidence_rate taiwan_salary;
output out=summary_index;

/*²Î¤@data*/
PROC IMPORT DATAFILE="C:\Users\User\Desktop\sas\sasprojectdata\sheet2.xlsx" OUT=WORK.main_monthly_product_sales  DBMS=EXCEL REPLACE ;
SHEET="sheet1" ;
RUN; 

data d1;
set main_monthly_product_sales(keep=product month monthly_growth_rate);
month2=month(month);
year=year(month);
proc sort ;
by  month;
run;
data d2;
set d1(drop=month);
run;

proc transpose data=d2 out=transposed_sales_data;
id product;
by  year month2;
proc sort;
by decending year month2; 
run;

data d3;
set transposed_sales_data;
keep month bread dairy feed flour juice drink  imported_product oil instant_food sauce health_food;
proc means data=d3 noprint;
var bread dairy feed flour juice drink  imported_product oil instant_food sauce health_food;
output out=summary_product;
run;

/*merge d3_md3*/
data merge_d3_md3;
merge d3 md3;
drop year month2;
run;
%macro if_function(product);
if &product>1then &product=1;
else if &product<-1then &product=0;
else &product='none';
%mend;

data merge_d3_md32;
set merge_d3_md3;
%if_function(bread);
%if_function(dairy);
%if_function(feed);
%if_function(flour);
%if_function(juice);
%if_function(drink);   
%if_function( imported_product);
%if_function( oil );
%if_function( sauce );
%if_function( health_food );
%if_function( instant_food );
run;




/*%macro tree(product)*/
%macro tree(product);
proc hpsplit data=merge_d3_md32 maxdepth=10;
   class bread dairy feed flour juice drink  imported_product oil instant_food sauce health_food;
   model &product(event='1') = taiwan_cpi taiwan_unemployee_rate taiwan_confidence_rate taiwan_salary; /* feed flour imported_product oil instant_food sauce health_food;*/
   partition fraction(validate=0.3 seed=123);
run;
%mend

%tree(dairy);
%tree(drink);
%tree(instant_food);









