### Why use multiple partitions?

Partitioning to segregate /tmp /var and other parts of the system is a well-accepted best practice for system security and stability.

A basic list of security benefits:

- Protecting the root file system from space / inode exhaustion by compromised accounts or processes under attack.  This is the most commonly noted reason for separate partitions and probably the most relevant as most everyone has or will experience breaking things by inadvertently filling up /.


- Mitigating some [TOCTOU](http://en.wikipedia.org/wiki/Time_of_check_to_time_of_use) attacks as hardlinks naturally cannot cross filesystems. Though, Ubuntu LTS has had more complete protection against both hard and soft link based attacks fo this sort via fs.protected_(hardlinks|symlinks) since Precise I believe


- The ability to mount those additional filesystems with options like  `noexec`, `nosuid` and `nodev` which prevent execution, privilege escalation and creation of block / character devices respectively.

Beyond security, partitioning greatly simplifies certain parts of system administration, some of which are less relevant these days with fully virtual systems that are trivial to clone or extend.


- Cleanly separating user and system data which greatly simplifies upgrading or rebuilding physical machines.

- Ability to use different filesystems and storage types for portions of the system.

- Independently resizing portions of the system.  

- Snapshotting via LVM or similar.

### How is this different?

A vanilla Ubuntu system uses a single partition without LVM with none of the afforementioned benefits. Of course, it's not that lacking these options leaves a default systems wide-open or that they can't be circumvented once in place. Rather, they're low or no-cost additions to a layered defense.
