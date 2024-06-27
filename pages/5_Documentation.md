---
title: Documentation
---

# Introduction

## Background

The Look eCommerce is a *(fictional)* eCommerce that operates from January 2019 until now, already having customers from 15 country around the world and selling more than 20 product categories. This dashboard is developed to help business stakeholders understand more about the sales performance of The Look eCommerce

## Research Questions

1. How much does The Look sell in all time?
2. How has the sales performance trended over the past month?
3. How does each country contribute to the sales?
3. How does each product category contribute to the sales?

## Scope

1. Analytics will focus on sales performance in general with additional focus on country and product category
2. The dataset used are sourced from [The Look eCommerce](https://console.cloud.google.com/marketplace/product/bigquery-public-data/thelook-ecommerce?hl=en-GB) that have been modified in the author's GCP
4. The dataset will ranged from January 2019 until 25 June 2024

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