#!/usr/bin/env python3
"""
Script to upload knowledge articles to Salesforce org
"""

import json
import subprocess
import sys
from pathlib import Path

# Knowledge articles data
ARTICLES = [
    {
        "title": "How to Reset Your Password",
        "urlName": "how-to-reset-your-password",
        "summary": "Step-by-step guide for resetting your account password.",
        "body": """If you've forgotten your password, follow these steps:

1. Go to the login page and click "Forgot Password"
2. Enter the email address associated with your account
3. Check your email for a password reset link (arrives within 5 minutes)
4. Click the link and create a new password
5. Your new password must be at least 8 characters with one uppercase letter, one number, and one special character

If you don't receive the email:
- Check your spam/junk folder
- Verify you're using the correct email address
- Contact support if the issue persists

For security reasons, password reset links expire after 24 hours."""
    },
    {
        "title": "Billing and Payment FAQ",
        "urlName": "billing-and-payment-faq",
        "summary": "Common questions about billing, invoices, and payment methods.",
        "body": """Q: What payment methods do you accept?
A: We accept Visa, MasterCard, American Express, ACH bank transfers, and wire transfers for enterprise accounts.

Q: When are invoices generated?
A: Invoices are generated on the 1st of each month and sent via email. You can also access them in your account dashboard under Billing > Invoices.

Q: How do I update my payment method?
A: Go to Settings > Billing > Payment Methods > Add New Method. Your new method will be used for the next billing cycle.

Q: Can I get a refund?
A: Refund requests must be submitted within 30 days of the charge. Contact our billing team at billing@company.com with your invoice number.

Q: How do I switch to annual billing?
A: Annual billing offers a 15% discount. Contact your account manager or go to Settings > Billing > Switch to Annual."""
    },
    {
        "title": "Product Return Policy",
        "urlName": "product-return-policy",
        "summary": "Guidelines for returning products and requesting replacements.",
        "body": """Our return policy covers all products purchased within the last 30 days.

Eligibility:
- Product must be in original packaging
- Must include proof of purchase (order number or receipt)
- Custom or personalized items are non-returnable

How to initiate a return:
1. Log into your account and go to Orders > Select Order > Request Return
2. Choose the items you want to return and select a reason
3. Print the prepaid shipping label
4. Ship the items within 7 business days

Refund timeline:
- Refunds are processed within 5-7 business days after we receive the item
- Original shipping costs are non-refundable
- Refund is credited to the original payment method

For damaged or defective items, contact support immediately for a replacement."""
    },
    {
        "title": "How to Upgrade Your Plan",
        "urlName": "how-to-upgrade-your-plan",
        "summary": "Instructions for upgrading your subscription plan.",
        "body": """To upgrade your plan:

1. Navigate to Settings > Subscription > Current Plan
2. Click "View Available Plans"
3. Compare features across Starter, Professional, and Enterprise tiers
4. Click "Upgrade" on your preferred plan
5. Review the prorated charges for the remainder of your billing cycle
6. Confirm payment and your new features will activate immediately

Plan comparison:
- Starter: Up to 5 users, 10GB storage, email support
- Professional: Up to 25 users, 50GB storage, phone support, API access
- Enterprise: Unlimited users, 500GB storage, 24/7 priority support, custom integrations

Downgrades take effect at the start of the next billing cycle. Data beyond the new plan's storage limit will be preserved for 30 days."""
    },
    {
        "title": "Troubleshooting Connection Issues",
        "urlName": "troubleshooting-connection-issues",
        "summary": "How to resolve common connection and login problems.",
        "body": """If you're experiencing connection issues, try these steps in order:

Step 1 - Check service status:
Visit status.company.com to check if there's an ongoing outage.

Step 2 - Clear browser cache:
Clear your browser cache and cookies, then try again. Press Ctrl+Shift+Delete (Windows) or Cmd+Shift+Delete (Mac).

Step 3 - Try a different browser:
Test with Chrome, Firefox, or Edge to rule out browser-specific issues.

Step 4 - Disable browser extensions:
Ad blockers and VPN extensions can sometimes interfere with our platform.

Step 5 - Check your network:
Ensure you have a stable internet connection. Try accessing other websites. If your company uses a firewall, ask IT to whitelist *.company.com.

Step 6 - Flush DNS:
Open Command Prompt (Windows) or Terminal (Mac) and run: ipconfig /flushdns (Windows) or sudo dscacheutil -flushcache (Mac).

If none of these steps resolve the issue, contact support with your browser version, OS, and a screenshot of any error messages."""
    },
    {
        "title": "Getting Started with Our Platform",
        "urlName": "getting-started-guide",
        "summary": "A beginner's guide to setting up and navigating the platform.",
        "body": """Welcome to our platform! Here's how to get started:

1. Complete your profile: Go to Settings > Profile and add your name, role, and department.
2. Set up your dashboard: Click "Customize Dashboard" to add the widgets most relevant to your role.
3. Connect your data: Navigate to Integrations > Add Connection to link your existing tools.
4. Invite your team: Go to Admin > Users > Invite to add team members.
5. Explore tutorials: Visit the Learning Center for interactive walkthroughs.

Key navigation tips:
- Use the search bar (Ctrl+K) to quickly find any feature
- Star frequently used pages for quick access
- Set up keyboard shortcuts in Settings > Preferences

Need help? Click the blue chat icon in the bottom-right corner for live support."""
    },
    {
        "title": "How to Export and Backup Your Data",
        "urlName": "data-export-backup",
        "summary": "Guide for exporting your data and setting up automated backups.",
        "body": """You can export your data at any time.

Manual export:
1. Go to Settings > Data Management > Export
2. Select the data types you want to export (contacts, reports, files)
3. Choose format: CSV, JSON, or Excel
4. Click "Start Export" — you'll receive a download link via email

Automated backups:
1. Go to Settings > Data Management > Scheduled Backups
2. Set frequency: Daily, Weekly, or Monthly
3. Choose destination: Email, SFTP, or cloud storage (S3, Google Cloud)
4. Backups run at 2:00 AM in your timezone

Data retention: Deleted records are kept in the recycle bin for 15 days. After that, they can be recovered by support for up to 90 days."""
    },
    {
        "title": "API Integration Quick Start",
        "urlName": "api-integration-guide",
        "summary": "How to connect to our REST API for custom integrations.",
        "body": """Our REST API allows you to integrate with external systems.

Authentication:
- All API requests require an OAuth 2.0 bearer token
- Generate your API key: Settings > Developer > API Keys > Generate New Key
- Include the token in headers: Authorization: Bearer YOUR_TOKEN

Base URL: https://api.company.com/v2/

Rate limits:
- Starter: 100 requests/hour
- Professional: 1,000 requests/hour
- Enterprise: 10,000 requests/hour

Common endpoints:
- GET /accounts — List all accounts
- POST /cases — Create a new case
- GET /contacts?account_id=123 — Get contacts for an account
- PATCH /opportunities/456 — Update an opportunity

For full API documentation, visit developers.company.com/docs."""
    },
    {
        "title": "Setting Up Two-Factor Authentication",
        "urlName": "two-factor-authentication-setup",
        "summary": "How to enable and manage two-factor authentication for your account.",
        "body": """Two-factor authentication (2FA) adds an extra layer of security to your account.

To enable 2FA:
1. Go to Settings > Security > Two-Factor Authentication
2. Choose your method: Authenticator App (recommended) or SMS
3. Scan the QR code with Google Authenticator, Authy, or Microsoft Authenticator
4. Enter the 6-digit verification code to confirm
5. Save the backup recovery codes in a secure location

If you lose access to your authenticator:
- Use one of your backup recovery codes to log in
- Contact support with your account email and identity verification to reset 2FA

Enterprise admins can enforce 2FA for all users: Admin > Security Policies > Require 2FA."""
    },
    {
        "title": "How to Deactivate Your Account",
        "urlName": "account-deactivation",
        "summary": "Steps for deactivating your account and requesting data deletion.",
        "body": """To deactivate your account:

1. Go to Settings > Account > Deactivation
2. Select your reason for leaving
3. Download your data export (recommended before deactivation)
4. Confirm by entering your password
5. Your account will be deactivated immediately

Important notes:
- Deactivated accounts can be reactivated within 30 days by contacting support
- After 30 days, all data is permanently deleted per our data retention policy
- If you're the only admin, you must transfer admin rights before deactivating
- Active subscriptions will be cancelled and prorated refunds issued

For GDPR/CCPA data deletion requests, email privacy@company.com with subject "Data Deletion Request" and your account email."""
    },
    {
        "title": "Mobile App Installation Guide",
        "urlName": "mobile-app-setup",
        "summary": "How to install and configure the mobile application.",
        "body": """Our mobile app is available for iOS and Android.

Installation:
- iOS: Search "CompanyApp" in the App Store (requires iOS 15+)
- Android: Search "CompanyApp" in Google Play Store (requires Android 11+)

Setup:
1. Open the app and tap "Sign In"
2. Enter your email and password (same as web login)
3. Complete 2FA verification if enabled
4. Allow notifications for real-time alerts
5. Enable biometric login (Face ID / fingerprint) for quick access

Offline mode:
The app caches your most recent data for offline viewing. Changes made offline sync automatically when you reconnect.

Troubleshooting:
- App crashing: Update to the latest version
- Slow performance: Clear app cache in Settings > Storage
- Login issues: Ensure your device clock is set to automatic"""
    },
    {
        "title": "Service Level Agreement Overview",
        "urlName": "sla-overview",
        "summary": "Overview of support response times and uptime guarantees.",
        "body": """Our SLA guarantees are based on your support tier:

Response times:
- Platinum: Critical 15 min, High 1 hour, Medium 4 hours, Low 8 hours
- Gold: Critical 30 min, High 2 hours, Medium 8 hours, Low 24 hours
- Silver: Critical 1 hour, High 4 hours, Medium 24 hours, Low 48 hours
- Bronze: Critical 4 hours, High 8 hours, Medium 48 hours, Low 72 hours

Uptime guarantee:
- All tiers: 99.9% monthly uptime (excludes scheduled maintenance)
- Scheduled maintenance windows: Sundays 2-6 AM ET (notified 48 hours in advance)

SLA credits:
- Below 99.9%: 10% credit on monthly invoice
- Below 99.5%: 25% credit on monthly invoice
- Below 99.0%: 50% credit on monthly invoice

To check current uptime, visit status.company.com."""
    }
]

def get_org_info():
    """Get org details from SF CLI"""
    try:
        result = subprocess.run(
            ["sf", "org", "display", "--json"],
            capture_output=True,
            text=True,
            cwd="/Users/ashishghaytadak/Desktop/Salesforce Project/Project 360/multi-agent-orchestrator"
        )
        return json.loads(result.stdout)
    except Exception as e:
        print(f"Error getting org info: {e}")
        return None

def create_knowledge_article(access_token, instance_url, article):
    """Create a knowledge article via REST API"""
    import requests
    
    url = f"{instance_url}/services/data/v60.0/sobjects/Knowledge__kav"
    
    # Combine summary and body since the Knowledge__kav object doesn't have a Body field
    full_content = f"{article['summary']}\n\n{article['body']}"
    
    # Summary field has a 1000 character limit, so truncate if needed
    if len(full_content) > 1000:
        full_content = full_content[:997] + "..."
    
    payload = {
        "Title": article["title"],
        "UrlName": article["urlName"],
        "Summary": full_content
    }
    
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }
    
    try:
        response = requests.post(url, json=payload, headers=headers)
        if response.status_code in [200, 201]:
            record_id = response.json().get("id")
            print(f"✓ Created: {article['title']} (ID: {record_id})")
            return record_id
        else:
            print(f"✗ Failed to create '{article['title']}': {response.text}")
            return None
    except Exception as e:
        print(f"✗ Error creating '{article['title']}': {e}")
        return None

def publish_article(access_token, instance_url, record_id):
    """Publish a knowledge article"""
    import requests
    
    # Get the version ID (articles need to be published)
    url = f"{instance_url}/services/data/v60.0/sobjects/Knowledge__kav/{record_id}"
    
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }
    
    try:
        response = requests.get(url, headers=headers)
        if response.status_code == 200:
            # Publish by setting PublishStatus
            update_payload = {
                "PublishStatus": "Online"
            }
            response = requests.patch(url, json=update_payload, headers=headers)
            if response.status_code == 204:
                print(f"  Published successfully")
                return True
        return False
    except Exception as e:
        print(f"  Error publishing: {e}")
        return False

def main():
    print("🚀 Uploading Knowledge Articles to Salesforce...")
    print()
    
    # Get org info
    org_info = get_org_info()
    if not org_info or "result" not in org_info:
        print("❌ Could not retrieve org information. Make sure you're authenticated.")
        sys.exit(1)
    
    access_token = org_info["result"].get("accessToken")
    instance_url = org_info["result"].get("instanceUrl")
    org_id = org_info["result"].get("id")
    
    if not all([access_token, instance_url]):
        print("❌ Missing authentication details")
        sys.exit(1)
    
    print(f"Connected to org: {org_id}")
    print(f"Instance URL: {instance_url}")
    print()
    
    # Try to import requests, install if needed
    try:
        import requests
    except ImportError:
        print("Installing requests library...")
        subprocess.run([sys.executable, "-m", "pip", "install", "requests"], check=True)
        import requests
    
    # Create articles
    successful = 0
    failed = 0
    
    for i, article in enumerate(ARTICLES, 1):
        print(f"[{i}/{len(ARTICLES)}] Creating: {article['title']}")
        record_id = create_knowledge_article(access_token, instance_url, article)
        if record_id:
            successful += 1
            publish_article(access_token, instance_url, record_id)
        else:
            failed += 1
        print()
    
    # Summary
    print("=" * 60)
    print(f"📊 Summary: {successful} successful, {failed} failed")
    print("=" * 60)
    
    if failed == 0:
        print("✅ All articles uploaded successfully!")
    else:
        print(f"⚠️  {failed} article(s) failed to upload. Check the errors above.")

if __name__ == "__main__":
    main()
