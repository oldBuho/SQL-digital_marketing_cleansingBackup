-- first, CRETE TABLE with the fields needed, then:

COPY public.data_range_list
FROM 'C:\Users\Public\date_range.csv'
CSV HEADER;

/*



use this path in order to do not get this error:

ERROR:  could not open file "some_root\blabla.csv" 
for reading: Permission denied

*/


/* option b

COPY public.campaign_definitions
FROM 'C:\Users\Public\campaign_def.csv'
DELIMITER ';'
CSV HEADER;

*/