---
layout: "documents"
page_title: "Manage Authorizations"
sidebar_current: "administrator-"
description: |-
  Managing Authorizations.
---

# Managing Authorizations

For security reasons, practice role-based access control for you container networks. 

Contiv provides two roles:

* **Admin** - Superuser able to access any tenant and modify user access to any tenant.
* **DevOps** - Able to create and set network policies, service load balancers, application groups and network policies within the tenant or tenants assigned to them.

Note: Limit the number of Admin users you create to ensure that passwords and access to tenants remains secure.

## Authorizing Users

If you are authorizing a DevOps user, you will select the specific tenant as part of the authorization. Make sure you've created the tenant you want before you begin these steps.

If you have set up Active Directory (AD) authentication and are authorizing users through their AD groups, be aware that Contiv cannot authorize users based on their primary AD group. There is no straight-froward mechanism to retrieve a user's primary group from AD and authorize it. Authorize users against another group. For more information on this issue, see this [thread](http://lists.freeradius.org/pipermail/freeradius-users/2012-August/062055.html).

To authorize a user:

1. From **Settings > Authorizations** click **Create Authorization**.
2. Choose whether you are authorizing a **Local User** or an **LDAP Group**.
3. Select **Role**.<br>
   If this user or group will receive Admin privileges, select **Admin** and **Save** to complete the authorization.<br>
   If this user or group will receive DevOps privileges, select **DevOps**, the tenant, and **Save** to complete the authorization.<br>

## Removing Authorizations

Authorizations cannot be modified. You can remove authorizations and create new ones as needed.

To remove an authorization:

1. From **Settings > Authorizations** click the name of the authorization you want to remove.<br>
   If you have a long list of authorizations, you can filter by username, role, or tenant name.
2. Click **Remove**.
3. Confirm that you want to delete the authorization by clicking **Delete**.

 
