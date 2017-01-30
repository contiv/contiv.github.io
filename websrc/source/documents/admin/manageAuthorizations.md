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

* _Admin_ - Superuser able to access any tenant and modify user access to any tenant.
* _DevOps_ - Able to create and set network policies, service load balancers, application groups and network policies within the tenant or tenants assigned to them.

Limit the number of Admin users you create to ensure that passwords and access to tenants remains secure.

## Authorizing Users

If you are authorizing a user for a particular tenant, make sure you've created the tenant before you begin. 

To authorize a user:

1. From **Settings > Authorizations** click **Create Authorization**.
2. Choose whether you are authorizing a Local User or an LDAP Group.
3. Select Role. 
   If this user or group will receive Admin privileges, select **Admin** and **Save** to complete the authorization.
   If this user or group will receive DevOps privileges, select **DevOps**, the tenant, and **Save** to complete the authorization.

## Removing Authorizations

Authorizations cannot be modified. You can remove authorizations and create new ones as needed.

To remove an Authorization:

1. From **Settings > Authorizations** click the name of the authorization you want to remove.
   If you have a long list of authorizations, you can filter by username, role, or tenant name.
2. Click **Remove**.
3. Confirm that you want to delete the authorization by clicking **Delete**.

 
