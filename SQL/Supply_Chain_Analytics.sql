use supply_chain_project;

select * from inventory ;

select* from vendor_delivery ;

alter table vendor_delivery rename column part_no to material_code;

set sql_safe_updates =0;
SET SQL_SAFE_UPDATES = 1;

UPDATE vendor_delivery
SET
    order_Date = STR_TO_DATE(order_Date, '%m/%d/%Y'),
    expected_delivery_date = STR_TO_DATE(expected_delivery_date, '%m/%d/%Y'),
    actual_delivery_date = STR_TO_DATE(actual_delivery_date, '%m/%d/%Y');
    
ALTER TABLE vendor_delivery
MODIFY COLUMN order_Date DATE,
MODIFY COLUMN expected_delivery_date DATE,
MODIFY COLUMN actual_delivery_date DATE;

select count(*) as total_row from inventory;

select count(*) as total_row from vendor_delivery;

select * from inventory limit 10 ;

select * from vendor_delivery limit 10;

alter table inventory rename column `opening_stock ( month)` to opening_month_stock;

select 
count( case when material_code is null then 1 end ) as null_material_code,
count( case when material_name is null then 1 end ) as null_material_name,
count( case when month_year is null then 1 end ) as null_month_year,
count( case when actual_consumption_qty is null then 1 end ) as null_actual_consumption_qty,
count( case when lead_time_days is null then 1 end ) as null_lead_time_days,
count( case when safety_stock_level is null then 1 end ) as null_safety_stock_level ,
count( case when carrying_cost_per_unit is null then 1 end ) as null_carrying_cost_per_unit ,
count( case when stock_status is null then 1 end ) as null_stock_status,
count( case when opening_month_stock is null then 1 end ) as null_opening_month_stock 
from inventory ;

select material_code, material_name, Month_year,count(*) as duplicate_count 
from inventory 
group by material_code, material_name, month_year having count(*)>1;

select count(distinct material_code) as Unique_material_count from inventory;

select material_code, count(*) as record_count from inventory group by material_code;

select material_code, material_name, count(*) as record_count from inventory group by material_code, material_name;

select material_code, material_name, opening_month_stock ,stock_status ,
sum(actual_consumption_qty) as total_consumption 
from inventory 
group by material_code, material_name ,opening_month_stock, stock_status
order by total_consumption desc limit 10;

select material_code, material_name, lead_time_days from inventory
where  lead_time_days >30 order by lead_time_days desc;

select material_code, material_name, avg(lead_time_days) as 
avg_lead_time from inventory group by material_code, material_name HAVING AVG(lead_time_days) > 30 order by avg_lead_time desc ;

SELECT v. vendor_name, i. material_code, i. material_name, i. lead_time_days
from inventory i inner join vendor_delivery v 
ON i.material_code = v.material_code;

SELECT vendor_name, 
sum(ordered_quantity) as total_ordered_qty,
sum(received_quantity) as total_received_quantity,
(sum(ordered_quantity) - sum(received_quantity)) as quantity_gap
from vendor_delivery group by vendor_name;

select vendor_name, 
sum(ordered_quantity) as total_ordered_quantity,
sum(received_quantity) as total_recevied_quantity,
round((sum(received_quantity) / sum(ordered_quantity)) * 100, 2) as delivery_completion_pct
from vendor_delivery
where vendor_name = 'JSW Steel Ltd.'
group by vendor_name;

select vendor_name, 
sum(ordered_quantity) as total_ordered_quantity,
sum(received_quantity) as total_recevied_quantity,
round((sum(received_quantity) / sum(ordered_quantity)) * 100, 2) as delivery_completion_pct,
case 
when round((sum(received_quantity) / sum(ordered_quantity)) * 100, 2) = 100 then 'Excellent'
when round((sum(received_quantity) / sum(ordered_quantity)) * 100, 2) > 98 then 'Good'
when round((sum(received_quantity) / sum(ordered_quantity)) * 100, 2) > 95 then 'acceptable'
else 'Need Improvement' end as vendor_status
from vendor_delivery
group by vendor_name;

select po_number,  Vendor_name, expected_delivery_date, actual_delivery_date, 
case when actual_delivery_date <= expected_delivery_date then 'On Time'
else 'Delayed' end as delivery_statues from vendor_delivery;

select po_number, vendor_name, expected_delivery_date, actual_delivery_date,
case when actual_delivery_date > expected_delivery_date then datediff(actual_delivery_date, expected_delivery_date)
else 0 end as Delay_days
from vendor_delivery;

select vendor_name,
count(po_number) as total_orders,
sum(case when actual_delivery_date <= expected_delivery_date then 1 else 0 end ) as on_time_orders,
round((sum(case when actual_delivery_date<= expected_delivery_date then 1 else 0 end) / count(po_number))*100, 2) as on_time_delivery_pct,
case 
when round((sum(case when actual_delivery_date<= expected_delivery_date then 1 else 0 end) / count(po_number))*100, 2) = 80 then 'Excellent'
when round((sum(case when actual_delivery_date<= expected_delivery_date then 1 else 0 end) / count(po_number))*100, 2) > 78 then 'Good'
when round((sum(case when actual_delivery_date<= expected_delivery_date then 1 else 0 end) / count(po_number))*100, 2) > 75 then 'acceptable'
else 'Need Improvement' end as vendor_status
from vendor_delivery
group by vendor_name;

with vendorOTIF as ( select vendor_name, round((sum(case when actual_delivery_date <= expected_delivery_date 
and received_quantity >= ordered_quantity then 1 else 0 end) / count(po_number)) * 100, 2) as otif_pct
from vendor_delivery group by vendor_name )
select rank() over( order by otif_pct desc) as rank_no, vendor_name, otif_pct
from vendorOTIF;

WITH VendorOTIF AS ( SELECT vendor_name, ROUND((SUM(CASE WHEN actual_delivery_date <= expected_delivery_date 
AND received_quantity >= ordered_quantity THEN 1 ELSE 0 END) / COUNT(po_Number)) * 100, 2) AS otif_pct
FROM vendor_delivery GROUP BY vendor_name ),
RankedVendors AS ( SELECT RANK() OVER (ORDER BY otif_pct DESC) AS rank_no, vendor_name, otif_pct FROM VendorOTIF )
SELECT * 
FROM RankedVendors
WHERE rank_no <= 3;

WITH MaterialConsumption AS ( SELECT material_code, material_name,
SUM(actual_consumption_qty) AS total_consumption FROM inventory GROUP BY material_code, material_name),
MaterialRanking AS ( SELECT material_code,material_name, total_consumption,
PERCENT_RANK() OVER (ORDER BY total_consumption DESC) AS cumulative_pct
FROM MaterialConsumption)
SELECT material_code, material_name, total_consumption,
CASE WHEN cumulative_pct <= 0.20 THEN 'A_High Priority'
	WHEN cumulative_pct <= 0.50 THEN 'B_Medium Priority'ELSE 'C_Low Priority' END AS abc_category
FROM MaterialRanking;

SELECT 
    material_code,
    material_name,
    opening_month_stock,
    safety_stock_level,
    stock_status
FROM inventory
WHERE opening_month_stock < safety_stock_level;

SELECT material_code,
    material_name,
    opening_month_stock,
    safety_stock_level,
    CASE
	WHEN opening_month_stock < safety_stock_level
	THEN 'Risk'
	ELSE 'Safe'
END AS stock_status
FROM inventory;

SELECT 
    material_code,
    material_name,
    opening_month_stock,
    safety_stock_level,
    CASE 
	WHEN opening_month_stock <= safety_stock_level THEN 'Reorder Required'
	ELSE 'Stock Sufficient'
    END AS reorder_status
FROM inventory;

CREATE VIEW vw_vendor_otif AS
SELECT 
    vendor_name,
    COUNT(po_Number) AS total_orders,
    SUM(CASE WHEN actual_delivery_date <= expected_delivery_date THEN 1 ELSE 0 END) AS on_time_orders,
    SUM(CASE WHEN received_quantity >= ordered_quantity THEN 1 ELSE 0 END) AS in_full_orders,
    SUM(CASE WHEN actual_delivery_date <= expected_delivery_date AND received_quantity >= ordered_quantity THEN 1 ELSE 0 END) AS otif_orders,
    ROUND((SUM(CASE WHEN actual_delivery_date <= expected_delivery_date AND received_quantity >= ordered_quantity THEN 1 ELSE 0 END) / COUNT(po_Number)) * 100, 2) AS otif_pct
FROM vendor_delivery
GROUP BY vendor_name;

select * from vw_vendor_otif ;

drop view if exists vw_vendor_otif;

SELECT month_year,
SUM(actual_consumption_qty) AS total_consumption
FROM inventory
GROUP BY month_year
ORDER BY month_year;

SELECT material_code, material_name,
SUM(carrying_cost_per_unit) AS total_carrying_cost
FROM inventory
GROUP BY material_code, material_name
ORDER BY total_carrying_cost DESC
LIMIT 10;

SELECT material_code, material_name,
AVG(carrying_cost_per_unit) AS avg_carrying_cost
FROM inventory
GROUP BY material_code, material_name;

select material_code, material_name, lead_time_days,
CASE WHEN lead_time_days <= 10 THEN 'Low'
	WHEN lead_time_days BETWEEN 11 AND 20 THEN 'Medium' ELSE 'High'
    END AS lead_time_category
FROM inventory;

 SELECT stock_status, 
 COUNT(*) AS material_count
FROM inventory
GROUP BY stock_status;

SELECT 
	material_code,
    material_name,
    actual_consumption_qty
FROM inventory
WHERE actual_consumption_qty = 0;

SELECT 
RANK() OVER ( ORDER BY (safety_stock_level - opening_month_stock) DESC) AS priority_rank,
material_code,
material_name,
opening_month_stock,
safety_stock_level,
(safety_stock_level - opening_month_stock) AS stock_gap
FROM inventory;

SELECT vendor_name,
AVG(DATEDIFF(actual_delivery_date, expected_delivery_date)) AS avg_delay_days
FROM vendor_delivery
GROUP BY vendor_name;

 SELECT vendor_name,
AVG(DATEDIFF(actual_delivery_date, expected_delivery_date)) AS avg_delay_days
FROM vendor_delivery
GROUP BY vendor_name
ORDER BY avg_delay_days DESC
LIMIT 5;

SELECT i.material_code, i.material_name, i.month_year, i.actual_consumption_qty, v.vendor_name,
v.order_date, v.expected_delivery_date, v.actual_delivery_date, v.delivery_status
FROM inventory i
INNER JOIN vendor_delivery v
ON i.material_code = v.material_code;

