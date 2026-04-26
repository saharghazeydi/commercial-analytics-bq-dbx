# Commercial Analytics — BigQuery, Databricks & BI

## 🧠 Objective
This project builds an end-to-end commercial analytics workflow to analyze e-commerce performance and support data-driven decision-making.

The goal is to connect user behavior (GA4) with transactional data (Olist) and translate it into business insights, KPIs, and actionable recommendations.

---

## 📊 Data Sources
- **GA4 BigQuery Public Dataset** (user behavior, traffic, events)
- **Olist E-commerce Dataset** (orders, payments, customers, products)
- **Olist Marketing Funnel Dataset** (leads, deals, funnel performance)

> Note: GA4 and Olist are integrated at an aggregated level using documented assumptions, while Olist datasets are joined at row level.

---

## 🏗️ Architecture
- Data ingestion via Databricks (CSV → clean → BigQuery)
- Data warehouse built in BigQuery (staging → marts)
- SQL used for transformations and KPI modeling
- Python used for validation and statistical analysis
- BI dashboards built in Tableau / Power BI

---

## 📈 Key Capabilities
- Multi-source data integration
- KPI framework (conversion rate, AOV, revenue, retention)
- Funnel analysis and channel performance tracking
- Customer behavior analysis
- A/B testing and experiment evaluation

---

## 📊 Outputs
- Structured warehouse tables (fact & dimension models)
- Business-ready KPI layer
- Interactive dashboards
- Experiment readouts with decision recommendations

---

## 🚀 Project Status
Work in progress — currently building GA4 staging layer and validating event-level data.

---

## 📌 Next Steps
- Complete GA4 modeling
- Ingest and clean Olist datasets
- Build star schema
- Develop dashboards
- Implement A/B testing layer

---

## 💼 Business Impact
This project demonstrates how raw behavioral and transactional data can be transformed into decision-ready insights for marketing, product, and commercial teams.
