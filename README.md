# 🛒 E-Commerce Sales & Customer Analytics (SQL | Python | Power BI)

## 📌 Project Overview

This project analyzes an Indian e-commerce business dataset to uncover insights into sales performance, profitability, customer behavior, product categories, seasonal trends, and payment methods.

It demonstrates an end-to-end data analytics workflow, covering data cleaning, SQL-based analysis, Python-based customer segmentation, and interactive Power BI dashboards.

The project focuses on answering key business questions:

- What drives revenue and profitability?
- Which product categories generate the highest revenue and profit margins?
- How does sales performance change over time?
- Which customer segments contribute the most revenue?
- Are certain payment methods associated with higher order cancellation or non-delivery rates?

**Dataset disclosure:** This project uses AI-generated synthetic data designed to simulate realistic Indian e-commerce transactions. It is not real company or customer data. The dataset includes deliberately introduced data-quality issues to demonstrate data-cleaning techniques.

---

## 🔄 End-to-End Workflow

1. **SQL (MySQL)** – Data exploration, cleaning, transformation, and business analysis across multiple related tables.
2. **Python (Jupyter Notebook)** – Exploratory data analysis, data validation, and RFM customer segmentation.
3. **Power BI Desktop** – Data modelling, DAX measures, interactive visualizations, and business insights.

---

## 🛠 Tools & Technologies

- **MySQL** – Data cleaning, querying, joins, aggregations, and business analysis.
- **MySQL Workbench** – SQL development environment.
- **Python** – Data analysis and customer segmentation.
  - pandas
  - NumPy
  - Matplotlib
  - Seaborn
- **Jupyter Notebook** – Exploratory analysis and documentation.
- **Power BI Desktop** – Data modelling, DAX, and dashboard development.
- **DAX** – KPI calculations, time intelligence, revenue, profit, margin, and average order value.

---

## 🧹 Data Cleaning & Preparation

The dataset contains multiple related tables covering customers, products, orders, and order items.

Data cleaning and preparation involved:

- Identifying and removing duplicate order-item records.
- Handling missing and inconsistent values.
- Standardizing inconsistent payment-method formatting.
- Cleaning customer and product information.
- Validating relationships between customers, orders, products, and order items.
- Preparing analysis-ready datasets for downstream analysis.

The cleaned datasets were used for SQL analysis and Power BI reporting.

---

## 📊 Dataset Description

The synthetic dataset covers **January 2024 – December 2025** and includes:

| Dataset | Description |
|---|---|
| Customers | Customer IDs, demographics, location, and state |
| Products | Product IDs, categories, pricing, and cost |
| Orders | Order dates, status, payment method, and sales channel |
| Order Items | Product-level order details, quantities, and discounts |
| RFM Segments | Customer recency, frequency, monetary values, scores, and segments |

The data is AI-generated and intended for portfolio demonstration, analytical practice, and business-scenario exploration.

---

## 📈 Key Business Analysis

### 1. Sales & Revenue Analysis
- Total revenue and delivered order performance.
- Average Order Value (AOV).
- Monthly and yearly revenue trends.
- Sales performance by category, state, and channel.

### 2. Product Category & Profitability Analysis
- Revenue and profit comparison across product categories.
- Category-level profit margin analysis.
- Identification of high-revenue and high-margin categories.

### 3. Customer Segmentation (RFM)
- Customer segmentation using Recency, Frequency, and Monetary values.
- Identification of Champions, Loyal, New / Promising, At-risk, Lost, and Needs attention customers.
- Analysis of customer revenue contribution.

### 4. Seasonal & Time-Based Analysis
- Monthly revenue and profit trends.
- Year-over-year performance comparison.
- Identification of seasonal sales patterns.

### 5. Payment Method Analysis
- Order status distribution by payment method.
- Comparison of delivered and non-delivered orders.
- Evaluation of payment-method performance.

---

## 📊 Power BI Dashboard

The interactive Power BI report contains two analytical pages:

### 1. Executive Overview
Provides a high-level view of business performance through:
- Revenue, Profit, Profit Margin, Delivered Orders, and AOV KPIs.
- Monthly Revenue Trend.
- Revenue by Category.
- Revenue by Sales Channel.
- Revenue by State.
- Customer Segmentation (RFM).

### 2. Business Insights
Focuses on business performance and actionable findings through:
- Revenue vs. Profit by Category.
- Profit Margin by Category.
- Revenue Contribution by Customer Segment.
- Monthly Profit Trend.
- Order Status Distribution by Payment Method.
- Key Business Insights and Business Recommendations.

---

## 💡 Key Findings

*Based on the synthetic dataset and delivered-order revenue analysis:*

- **Revenue & Profitability:** Generated approximately ₹152.20M in revenue and ₹23.89M in profit, with an overall profit margin of 15.7%.
- **Order Performance:** Recorded approximately 18.9K delivered orders, with an AOV of approximately ₹8,060.
- **Category Performance:** Electronics contributed approximately 55% of revenue but had a profit margin of only 7.3%.
- **High-Margin Categories:** Fashion and Beauty recorded profit margins of approximately 36.9% and 31.8%, respectively.
- **Customer Concentration:** The top 20% of customers contributed approximately 53.8% of total revenue.
- **Champions Segment:** Champions represented approximately 26% of customers and contributed approximately 52% of revenue.
- **At-Risk Customers:** Approximately 13% of revenue came from the At-risk segment.
- **Seasonality:** October and November together contributed approximately 29.5% of total revenue.
- **Payment Methods:** Non-delivery rates were broadly similar across payment methods, approximately 11–13%, with no clear evidence that Cash on Delivery performed uniquely worse.

---

## 🎯 Business Recommendations

1. **Improve Electronics Profitability:** Review supplier costs, discount strategies, and pricing to improve margins in the highest-revenue category.
2. **Retain High-Value Customers:** Introduce loyalty programmes and personalized offers for Champions.
3. **Win Back At-Risk Customers:** Develop targeted re-engagement campaigns to recover potentially lost revenue.
4. **Expand High-Margin Categories:** Explore opportunities to grow Fashion and Beauty sales.
5. **Prepare for Seasonal Demand:** Align inventory and marketing plans ahead of the October–November peak.
6. **Monitor Payment Performance:** Continue tracking order outcomes across payment methods instead of assuming COD is the primary source of non-delivery.

---

## 📂 Project Structure

```text
Ecommerce_Sales_Analysis/
│
├── data/
│   ├── raw/
│   └── cleaned/
│
├── sql/
│   ├── analysis_ecom.sql
│   ├── data_cleaning.sql
│   ├── data_cleaning_customers.sql
│   ├── Datacleaning_OrderItems.sql
│   ├── Datacleaning_orders.sql
│   ├── DataCleaning_products.sql
│   └── queries.sql
│
├── outputs/
│   └── rfm_segments.csv
│
├── ecommerce_analysis.ipynb
│
├── powerbi/
│   ├── Ecommerce_Sales_Analytics.pbix
│   ├── executive_overview.png
│   └── business_insights.png
│
└── README.md
```

---

## ⚠️ Dataset Disclaimer

This project uses AI-generated synthetic data. The dataset was created to simulate realistic e-commerce business scenarios and demonstrate data analytics techniques. All reported metrics, findings, and recommendations are derived from this synthetic dataset and do not represent the performance of an actual company.