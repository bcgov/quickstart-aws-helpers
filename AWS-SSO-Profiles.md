
# 🚀 AWS SSO Configuration Guide

*Streamline your AWS CLI authentication with Single Sign-On profiles*

---

## 📋 Overview

This guide walks you through configuring AWS CLI with SSO for seamless environment access. Follow these steps for each environment your team manages.

---

## ⚙️ Configuration Steps

### 🔧 **Step 1: Configure SSO Profile**

**Quick Setup (Interactive):**
```bash
aws configure sso --profile <environment>-admin
```

**One-liner (Non-interactive):**
```bash
aws configure set sso_session bcgov-<environment>-admin --profile <environment>-admin && \
aws configure set sso_start_url https://bcgov.awsapps.com/start/# --profile <environment>-admin && \
aws configure set sso_region ca-central-1 --profile <environment>-admin && \
aws configure set sso_account_id ████████████ --profile <environment>-admin && \
aws configure set sso_role_name BCGOV_LZA_Admin --profile <environment>-admin && \
aws configure set region ca-central-1 --profile <environment>-admin && \
aws configure set output json --profile <environment>-admin
```

**Configuration Parameters:**
```
┌─────────────────────┬──────────────────────────────────────┐
│ Parameter           │ Value                                │
├─────────────────────┼──────────────────────────────────────┤
│ SSO session name    │ bcgov-<environment>-admin            │
│ SSO start URL       │ https://bcgov.awsapps.com/start/#    │
│ SSO region          │ ca-central-1                         │
│ Account ID          │ ████████████                         │
│ Role                │ BCGOV_LZA_Admin                      │
│ Default region      │ ca-central-1                         │
│ Output format       │ json                                 │
└─────────────────────┴──────────────────────────────────────┘
```

### 🔐 **Step 2: Authenticate**

Initialize your SSO session:
```bash
aws sso login --profile <environment>-admin
```

### ✅ **Step 3: Verify Access**

Confirm successful authentication:
```bash
aws sts get-caller-identity --profile <environment>-admin
```

---

## 🔄 **Multi-Environment Setup**

> **📝 Important:** Repeat the above configuration steps for each environment your team manages (dev, staging, prod, etc.). Simply replace `<environment>` with your specific environment name.

**Example environments:**
- `dev-admin`
- `test-admin` 
- `tools-admin` 
- `prod-admin`

---

## 💡 **Pro Tips**

- 🎯 Always use `--profile <environment>-admin` with AWS CLI commands
- 🔄 Re-authenticate when your session expires
- 📋 Use the same SSO session name across all profiles for convenience
- ⚡ Use the one-liner for automated setups or CI/CD pipelines

