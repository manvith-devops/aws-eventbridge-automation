# 🚀 AWS EventBridge Automation using Terraform & Lambda

## 📌 Overview
This project implements a fully automated AWS resource management system using EventBridge, Lambda, EC2, and SNS, with infrastructure provisioned via Terraform.

The solution focuses on:
- Cost Optimization (snapshot cleanup)
- Operational Efficiency (automated EC2 scheduling)
- Security Compliance (security group monitoring)

---

## 🏗️ Architecture

EventBridge Rules (Schedules)
        │
        ▼
AWS Lambda Functions
        │
        ├── EC2 Scheduler → Start/Stop instances
        ├── Snapshot Cleanup → Delete old snapshots
        └── Security Checker → Detect open SSH ports
        │
        ▼
Amazon SNS → Notifications

---

## ⚙️ Key Features

### 🟢 EC2 Scheduler
- Runs every 5 minutes
- Starts instances at 9 AM
- Stops instances at 6 PM
- Filters instances using:



Environment = Dev



- Sends execution summary via SNS

---

### 🟡 Snapshot Cleanup (Cost Optimization)
- Runs weekly (Sunday 2 AM)
- Deletes snapshots:
- Older than 30 days
- Only if untagged
- Helps reduce AWS storage costs

---

### 🔴 Security Checker (Compliance)
- Runs hourly
- Detects:

0.0.0.0/0 on port 22 (SSH)


- Sends alerts via SNS
- Improves cloud security posture

---

## 🧰 Tech Stack

**Cloud Services:**  
AWS EC2, Lambda, EventBridge, SNS  

**Infrastructure as Code:**  
Terraform  

**Programming Language:**  
Python (boto3)  

---

## 📂 Project Structure


assignment/
│── lambda_src/
│ ├── ec2_scheduler.py
│ ├── snapshot_cleanup.py
│ ├── security_checker.py
│
│── ec2_scheduler/
│── snapshot_cleanup/
│── security_checker/
│
│── main.tf
│── lambda.tf
│── eventbridge.tf
│── iam.tf
│── sns.tf
│── outputs.tf




