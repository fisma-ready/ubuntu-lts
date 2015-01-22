BEGIN {
printf "require \'spec_helper\'\n\n";
}

/^-[awe]/ {parameter = $0;
	printf "describe file('/etc/audit/audit.rules') do\n  its(:content) { should match('%s') }\nend\n\n", parameter }
