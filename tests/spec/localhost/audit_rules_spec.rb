require 'spec_helper'

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-a always,exit -F arch=b64 -S clock_settime -k time-change') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-a always,exit -F arch=b32 -S clock_settime -k time-change') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-w /etc/localtime -p wa -k time-change') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-w /etc/group -p wa -k identity') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-w /etc/passwd -p wa -k identity') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-w /etc/gshadow -p wa -k identity') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-w /etc/shadow -p wa -k identity') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-w /etc/security/opasswd -p wa -k identity') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-a exit,always -F arch=b64 -S sethostname -S setdomainname -k system-locale') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-a exit,always -F arch=b32 -S sethostname -S setdomainname -k system-locale') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-w /etc/issue -p wa -k system-locale') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-w /etc/issue.net -p wa -k system-locale') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-w /etc/hosts -p wa -k system-locale') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-w /etc/network -p wa -k system-locale') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-w /etc/selinux/ -p wa -k MAC-policy') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-w /var/log/faillog -p wa -k logins') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-w /var/log/lastlog -p wa -k logins') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-w /var/log/tallylog -p wa -k logins') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=500 -F auid!=4294967295 -k perm_mod') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=500 -F auid!=4294967295 -k perm_mod') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=500 -F auid!=4294967295 -k perm_mod') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S lchown -F auid>=500 -F auid!=4294967295 -k perm_mod') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=500 -F auid!=4294967295 -k perm_mod') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-a always,exit -F arch=b32 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=500 -F auid!=4294967295 -k perm_mod') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=500 -F auid!=4294967295 -k access') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=500 -F auid!=4294967295 -k access') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=500 -F auid!=4294967295 -k access') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=500 -F auid!=4294967295 -k access') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-a always,exit -F arch=b32 -S mount -F auid>=500 -F auid!=4294967295 -k mounts') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-a always,exit -F arch=b64 -S mount -F auid>=500 -F auid!=4294967295 -k mounts') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=500 -F auid!=4294967295 -k delete') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=500 -F auid!=4294967295 -k delete') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-w /etc/sudoers -p wa -k scope') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-w /sbin/insmod -p x -k modules') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-w /sbin/rmmod -p x -k modules') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-w /sbin/modprobe -p x -k modules') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-a always,exit arch=b64 -S init_module -S delete_module -k modules') }
end

describe file('/etc/audit/audit.rules') do
  its(:content) { should match('-e 2') }
end

