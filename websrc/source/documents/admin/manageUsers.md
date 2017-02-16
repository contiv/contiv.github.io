---
layout: "documents"
page_title: "User Management"
sidebar_current: "Administrator Guide"
description: |-
  User Management
---

# Managing Users

By default, Contiv provides an admin user to provide access to the administrator functionality.  You can work from this account or create your own accounts.  

You can create additional administrators for Contiv or your network users locally with Contiv or set up LDAP authentication for your container Network access. For small projects, you can use local users, but as your networking needs grow, an outside authentication method that supports group authentication is more practical.

## Creating a Local User

Create local users for small or proof of concept projects. For larger projects, you can use LDAP users and groups to save on time and data entry. 

To create a local user:

1. From **Settings >  User Management**, click **Create User**.
2. Enter a unique username. Avoid using <, >, {, or }.
3. Enter a unique password.
4. If you plan to have multiple local users, include a First and Last name to help clarify the users later.
   Note: While you can edit the username or password later, this will be your last chance to add a First Name or Last name to the record.
5. If you do not want to enable this user currently, but reserve the username for the future, you can select Disable. 
6. Click Save to save your new user.

You can now authorize this user for the Tenants you created in Create Tenants. 

## Editing a Local User

If a local user needs to be disabled or requests edits to the their username or password, you can make these changes from the User Management tab.

To edit a local user:

1. From Settings > User Management, select the username from the list. If you  have a long list of local users, you can use the filter string option to narrow your search.
2. Select the username to edit.
   The user record displays.
3. Click Edit.
4. Change the username, password, or user status as needed.
5. Click Save.

## Removing a Local User

Any local user you create can be removed from Contiv. The admin user, provided to you by default, cannot be removed  

To remove a local user:

1. From Settings > User Management, select the user you want to remove.
   The user record displays.
2. Click Remove.
3. Click Yes to confirm you want to remove the user.
   You should receive a confirmation message declaring the user has been successfully removed.

