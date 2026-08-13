# Supply Chain Analytics using SQL & Power BI

## Inventory Optimization & Vendor Performance Evaluation

---

## 📌 Project Overview

This project focuses on analyzing supply chain operations for a manufacturing business using **MySQL/SQL and Microsoft Power BI**.

The objective is to evaluate vendor delivery performance, analyze inventory levels, identify operational bottlenecks, monitor OTIF performance, and generate actionable business insights.

The project follows an end-to-end analytics workflow:

CSV Data → MySQL → Data Cleaning → SQL Analysis → Business KPIs → Power BI Dashboard → Business Insights & Recommendations

---

# 🎯 Business Problem

The manufacturing business faces several supply chain challenges that can increase operational costs and affect production schedules.

### Key Problems

- Delayed and inconsistent vendor deliveries
- Lack of visibility into On-Time In-Full (OTIF) performance
- Stockout risk for critical materials
- Overstocking of slow-moving inventory
- High inventory carrying costs
- Lead-time variability
- Difficulty monitoring vendor performance consistently
- Limited centralized reporting for management decision-making

The project addresses these challenges through SQL-based analysis and interactive Power BI reporting.

---

# 🎯 Project Objectives

The major objectives of this project are:

1. Evaluate vendor delivery performance.
2. Calculate On-Time Delivery, In-Full and OTIF metrics.
3. Analyze inventory consumption and stock levels.
4. Identify materials below safety stock levels.
5. Analyze inventory carrying costs.
6. Identify high-consumption materials.
7. Analyze vendor delivery delays and lead times.
8. Rank vendors based on OTIF performance.
9. Perform ABC inventory classification.
10. Build an interactive Power BI dashboard.
11. Generate actionable business recommendations.

---

# 📊 Dataset Description

The project uses two primary transactional datasets.

## 1. Inventory Dataset

### Table: `inventory`

The inventory dataset contains material-level information related to stock, consumption, lead time and carrying cost.

| Column | Description |
|---|---|
| `material_code` | Material reference code |
| `material_name` | Material name |
| `month_year` | Month/year of inventory record |
| `opening_month_stock` | Opening stock for the month |
| `actual_consumption_qty` | Actual material consumption |
| `lead_time_days` | Material procurement lead time |
| `safety_stock_level` | Required safety stock level |
| `carrying_cost_per_unit` | Carrying cost per unit |
| `stock_status` | Current stock status |

---

## 2. Vendor Delivery Dataset

### Table: `vendor_delivery`

The vendor delivery dataset contains purchase order and supplier delivery information.

| Column | Description |
|---|---|
| `po_number` | Purchase order number |
| `material_code` | Material reference code |
| `vendor_name` | Vendor/supplier name |
| `order_date` | Purchase order date |
| `expected_delivery_date` | Expected delivery date |
| `actual_delivery_date` | Actual delivery date |
| `ordered_quantity` | Quantity ordered |
| `received_quantity` | Quantity received |

---

# 🔗 Data Relationship

The two datasets are logically connected using:

```text
material_code
