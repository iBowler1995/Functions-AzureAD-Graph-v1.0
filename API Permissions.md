# Required API permissions for AAD registered app

Note: only one is required from each list. Each list is also sorted from least to most privileged permissions for better clarity. See https://docs.microsoft.com/en-us/graph/permissions-reference for more/better information on Graph API permissions
* Assigning licenses: User.ReadWrite.All, Directory.ReadWrite.All
* Adding user to group(s): GroupMember.ReadWrite.All, Group.ReadWrite.All, Directory.ReadWrite.All, Directory.AccessAsUser.All
* Creating assigned groups: Group.ReadWrite.All, Directory.ReadWrite.All, Directory.AccessAsUser.All
* Creating new user: 	User.ReadWrite.All, Directory.ReadWrite.All, Directory.AccessAsUser.All
* Disable user, Edit user, Enable user, Reset password:: User.ReadWrite, User.ReadWrite.All, User.ManageIdentities.All, Directory.ReadWrite.All, Directory.AccessAsUser.All
* Remove from group: GroupMember.ReadWrite.All, Group.ReadWrite.All, Directory.ReadWrite.All, Directory.AccessAsUser.All
* Terminate user: each of the above 
