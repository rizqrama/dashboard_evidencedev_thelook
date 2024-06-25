# The Look eCommerce Sales Report
*by rizqrama*

## Introduction
This is a repository for storing queries and markdown files to make the reporting dashboard using Evidence. To put it simple, we can say that [Evidence](https://www.evidence.dev) is a "BI tool as Code" that based on markdown files. 

The Look eCommerce itself is a fictitious eCommerce clothing site developed by the Looker team. The dataset contains information about customers, products, orders, logistics, web events, and digital marketing campaigns. The contents of this dataset are synthetic and are provided to industry practitioners for the purpose of product discovery, testing, and evaluation. (*source: [Google Cloud Marketplace](https://console.cloud.google.com/marketplace/product/bigquery-public-data/thelook-ecommerce?hl=en-GB)*)


## How to Develop/Run this locally
The easiest way to get started is using the [VS Code Extension](https://marketplace.visualstudio.com/items?itemName=evidence-dev.evidence):

1. Install the extension from the VS Code Marketplace
2. Clone this dashboard's repository
```bash
git clone https://github.com/rizqrama/dashboard_evidencedev_thelook
cd /your/path/dashboard_evidencedev_thelook
```
3. Install all dependencies (Make sure that you already have Node v18 or v20 in your device)
```bash
npm install
```
4. Read the sources and run the development. You will be redirected to [localhost:3000](localhost:3000) in your default browser and see the dashboard running
```bash
npm run sources
npm run dev 
```
5. You can edit the markdown files and then save it `ctrl/cmd + S` and see the changes directly in your browser

## Learning More

- [Docs](https://docs.evidence.dev/)
- [Github](https://github.com/evidence-dev/evidence)
- [Slack Community](https://slack.evidence.dev/)
- [Evidence Home Page]
