DM LOG 'CLEAR'; DM OUTPUT 'CLEAR';
libname local 'C:\Users\User\Desktop\sas\sasprojectdata';



/*data for competitors*/
proc datasets library=Work kill noprint;
run;
quit;
PROC IMPORT DATAFILE="C:\Users\User\Desktop\sas\sasprojectdata\sheet4.xlsx" OUT=WORK.competitors_products DBMS=EXCEL REPLACE ;
SHEET="sheet1" ;
RUN; 

data cd1;
set competitors_products(keep=month product monthly_growth_rate);
month2=month(month);
year=year(month);
proc sort;
by  month; 
run;
data cd2;
set cd1(drop=month);
run;
proc transpose data=cd2 out=transposed_competitor_product;
id  product;
by  year month2;
run;
data cd3;
set transposed_competitor_product(keep=month2 year _1201can _1201drink _1201health_food _1201juice _1210meat _1210chicken _1210feed _1210oil _1210others _1217dairy _1217dessert _1217drink _1217traditional _1225ceral _1225flour _1225oil _1227dairy _1227drink _1227health_food _1227kitchenfood _1229ceral _1229flour _1229instantfood _1229pizza _1229spaghetti _1229wheat);
proc sort ;
by desending year month2;
drop year month2;
run;
proc means data=cd3 noprint;
var _1201can _1201drink _1201health_food _1201juice _1210meat _1210chicken _1210feed _1210oil _1210others _1217dairy _1217dessert _1217drink _1217traditional _1225ceral _1225flour _1225oil _1227dairy _1227drink _1227health_food _1227kitchenfood _1229ceral _1229flour _1229instantfood _1229pizza _1229spaghetti _1229wheat;
output out=summary_competitors;
run;




/*data for ²Î¤@*/
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

/*growth rate for all food company*/


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
total_sales_growth_rate=((lag_total_sales-total_sales)/total_sales)*100;
if total_sales_growth_rate='none' then  total_sales_growth_rate=0;
keep 	MEAN total_sales lag_total_sales total total_sales_growth_rate ;
run;
data merge_result;
set result;
keep total_sales_growth_rate ;
run;


/*merge d3  cd3 result*/
 data merge_competitors;
 merge d3 cd3 merge_result ;
 drop year month2 _1210oil;
 /*label _1201can='way_chuan_can';
 label _1201drink='way_chuan_drink';
 label _1201health_food='way_chuan_health_food';
 label _1201juice='way_chuan_juice';
 label _1210meat='da_chen_meat';
 label _1210chicken='da_chen_chicken';
 label _1210feed='da_chen_feed';
 label _1210others='da_chen_others';
 label _1217dairy='i_che_way_dairy';
 label _1217dessert='i_che_way_dessert';
 label _1217drink='i_che_way_drink';
 label _1217traditional='i_che_way_traditional';
 label _1225flour='fu_mao_flour';
 label _1225ceral='fu_mao_ceral';
 label _1225oil='fu_mao_oil';
 label _1227drink='jia_ger_drink';
 label _1227health_food='jia_ger_health_food';
 label _1227dairy='jia_ger_dairy';
 label _1227kitchenfood='jia_ger_kitchenfood';
 label _1229ceral='lien_hua_ceral';
 label _1229flour='lien_hua_flour';
 label _1229instantfood='lien_hua_instantfood';
 label _1229pizza='lien_hua_pizza';
 label _1229spaghetti='lien_hua_spaghetti';
 label _1229wheat='lien_hua_wheat';*/
 run;

 /*regression*/
 %macro _1201_regression(product);
 proc reg data=merge_competitors ;
 model &product= _1201can _1201drink _1201health_food _1201juice  total_sales_growth_rate;
%mend;

 %macro _1210_regression(product);
 proc reg data=merge_competitors ;
 model &product= _1210meat  _1210chicken  _1210feed  _1210others total_sales_growth_rate;
run;
%mend;

 %macro _1217_regression(product);
 proc reg data=merge_competitors ;
 model &product=  _1217dairy  _1217dessert  _1217drink  _1217traditional  total_sales_growth_rate;
run;
%mend;

 %macro _1225_regression(product);
 proc reg data=merge_competitors ;
 model &product= _1225ceral  _1225flour  _1225oil  total_sales_growth_rate;
run;
%mend;

 %macro _1227_regression(product);
 proc reg data=merge_competitors ;
 model &product= _1227dairy _1227drink _1227health_food _1227kitchenfood total_sales_growth_rate;
run;
%mend;

 %macro _1229_regression(product);
 proc reg data=merge_competitors ;
 model &product= _1229ceral  _1229flour  _1229instantfood  _1229pizza  _1229spaghetti  _1229wheat total_sales_growth_rate;
run;
%mend;
%_1227_regression(bread);
%_1227_regression(oil);
%_1227_regression(juice);
%_1227_regression(flour);
%_1227_regression(feed);
%_1217_regression(bread);
%_1217_regression(oil);
%_1217_regression(juice);
%_1217_regression(flour);
%_1217_regression(feed);
%_1225_regression(bread);
%_1225_regression(oil);
%_1225_regression(juice);
%_1225_regression(flour);
%_1225_regression(feed);
%_1229_regression(bread);
%_1229_regression(oil);
%_1229_regression(juice);
%_1229_regression(flour);
%_1229_regression(feed);
%_1210_regression(bread);
%_1210_regression(oil);
%_1210_regression(juice);
%_1210_regression(flour);
%_1210_regression(feed);
%_1201_regression(bread);
%_1201_regression(oil);
%_1201_regression(juice);
%_1201_regression(flour);
%_1201_regression(feed);



proc reg data=merge_competitors;
 model bread=/*_1210meat _1210chicken _1210feed _1210others _1217dairy _1217dessert _1217drink _1217traditional  _1225ceral _1225flour _1225oil*/  _1227dairy _1227drink _1227health_food _1227kitchenfood
 /*_1229ceral _1229flour _1229instantfood _1229pizza _1229spaghetti _1229wheat*/  total_sales_growth_rate;
run;


 

 


