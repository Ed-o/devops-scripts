#!/bin/bash

# Update all the AWS contacts for the sub AWS ACcounts in your AWS Organisation structure
# note - requires you to have AWS keys for the master account in memory 
#
# By Ed ODonnell
# Version 20241016
#


# Exit on error
set -e

ORG_ACCOUNT="123456789"      # This is the account you are running the script from


# Define the main and alternate contacts
UPDATE_MAIN_CONTACT=false
MAIN_CONTACT_NAME="Main Contact Name"
MAIN_CONTACT_TITLE="Main Contact Title"
MAIN_CONTACT_EMAIL="main.contact@example.com"
MAIN_CONTACT_PHONE="+1-555-555-5555"
MAIN_CONTACT_COMPANY="Company Name"
MAIN_CONTACT_ADDRESS_LINE_1="Company Address"
MAIN_CONTACT_CITY="City"
MAIN_CONTACT_STATE="State"
MAIN_CONTACT_POSTAL_CODE="Postal"
MAIN_CONTACT_COUNTRY_CODE="US"

UPDATE_ALT_TECH_CONTACT=false
ALT_CONTACT_TECH_NAME="Tech Contact Name"
ALT_CONTACT_TECH_TITLE="Tech Contact Title"
ALT_CONTACT_TECH_EMAIL="tech.contact@example.com"
ALT_CONTACT_TECH_PHONE="+1-555-555-5555"

UPDATE_ALT_BILLING_CONTACT=false
ALT_CONTACT_BILLING_NAME="Billing Contact Name"
ALT_CONTACT_BILLING_TITLE="Billing Contact Title"
ALT_CONTACT_BILLING_EMAIL="billing.contact@example.com"
ALT_CONTACT_BILLING_PHONE="+1-555-555-5555"

UPDATE_ALT_SECURITY_CONTACT=false
ALT_CONTACT_SECURITY_NAME="Security Contact Name"
ALT_CONTACT_SECURITY_TITLE="Security Contact Title"
ALT_CONTACT_SECURITY_EMAIL="security.contact@example.com"
ALT_CONTACT_SECURITY_PHONE="+1-555-555-5555"

# Function to update contacts for a given AWS account
update_contacts() {
    local ACCOUNT_ID=$1
    
    echo "Updating contacts for Account ID: $ACCOUNT_ID"
    
    # Update main contact if enabled
    if [ "$UPDATE_MAIN_CONTACT" = true ]; then
        echo "Updating main contact for Account ID: $ACCOUNT_ID"
        aws account put-contact-information --account-id "$ACCOUNT_ID" --contact-information \
            "FullName=$MAIN_CONTACT_NAME,PhoneNumber=$MAIN_CONTACT_PHONE,CompanyName=$MAIN_CONTACT_COMPANY,AddressLine1=$MAIN_CONTACT_ADDRESS_LINE_1,City=$MAIN_CONTACT_CITY,StateOrRegion=$MAIN_CONTACT_STATE,PostalCode=$MAIN_CONTACT_POSTAL_CODE,CountryCode=$MAIN_CONTACT_COUNTRY_CODE"
    else
        echo "Skipping main contact update for Account ID: $ACCOUNT_ID"
    fi
    
    # Update alternate technical contact if enabled
    if [ "$UPDATE_ALT_TECH_CONTACT" = true ]; then
        echo "Updating alternate technical contact for Account ID: $ACCOUNT_ID"
        aws account put-alternate-contact --account-id "$ACCOUNT_ID" --alternate-contact-type "OPERATIONS" \
            --name "$ALT_CONTACT_TECH_NAME" --email-address "$ALT_CONTACT_TECH_EMAIL" \
            --phone-number "$ALT_CONTACT_TECH_PHONE" --title "$ALT_CONTACT_TECH_TITLE"
    else
        echo "Skipping alternate technical contact update for Account ID: $ACCOUNT_ID"
    fi

    # Update alternate billing contact if enabled
    if [ "$UPDATE_ALT_BILLING_CONTACT" = true ]; then
        echo "Updating alternate billing contact for Account ID: $ACCOUNT_ID"
        aws account put-alternate-contact --account-id "$ACCOUNT_ID" --alternate-contact-type "BILLING" \
            --name "$ALT_CONTACT_BILLING_NAME" --email-address "$ALT_CONTACT_BILLING_EMAIL" \
            --phone-number "$ALT_CONTACT_BILLING_PHONE" --title "$ALT_CONTACT_BILLING_TITLE"
    else
        echo "Skipping alternate billing contact update for Account ID: $ACCOUNT_ID"
    fi

    # Update alternate security contact if enabled
    if [ "$UPDATE_ALT_SECURITY_CONTACT" = true ]; then
        echo "Updating alternate security contact for Account ID: $ACCOUNT_ID"
        aws account put-alternate-contact --account-id "$ACCOUNT_ID" --alternate-contact-type "SECURITY" \
            --name "$ALT_CONTACT_SECURITY_NAME" --email-address "$ALT_CONTACT_SECURITY_EMAIL" \
            --phone-number "$ALT_CONTACT_SECURITY_PHONE" --title "$ALT_CONTACT_SECURITY_TITLE"
    else
        echo "Skipping alternate security contact update for Account ID: $ACCOUNT_ID"
    fi

    echo "Contacts updated for Account ID: $ACCOUNT_ID"
}

# Get all AWS accounts from the organization
echo "Fetching all accounts in the organization..."
ACCOUNTS=$(aws organizations list-accounts --query "Accounts[*].Id" --output text)

# Iterate through each account and update contacts
for ACCOUNT_ID in $ACCOUNTS; do
    if [ "$ACCOUNT_ID" != "$ORG_ACCOUNT" ] ; then
        update_contacts "$ACCOUNT_ID"
    else
        echo "Skipping Org account"
    fi
done

echo "All accounts have been processed."


