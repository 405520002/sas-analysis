DM LOG 'CLEAR'; DM OUTPUT 'CLEAR';
libname local 'C:\Users\User\Desktop\sas\sasprojectdata';

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





%macro multi_regression(product);
proc reg data=d3;
model &product= drink dairy instant_food sauce;
run;
%mend;





%multi_regression(flour);
%multi_regression(feed);
%multi_regression(bread);
%multi_regression(juice);
%multi_regression(oil);


%macro single_regression(product1,product2);
proc reg data=d3;
model &product1= &product2;
run;
%mend;

%single_regression(flour,instant_food);
%single_regression(feed,sauce);
%single_regression(bread,dairy);
%single_regression(juice,instant_food);
%single_regression(juice,drink);
%single_regression(juice,dairy);
%single_regression(juice,sauce);
/*oil¥¢±Ñ*/








