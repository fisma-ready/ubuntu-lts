BEGIN {
owner = "root";

printf "require \'spec_helper\'\n\n";
}

/^\// {file = $1; 
	printf "describe file('%s') do\n  it { should be_owned_by '%s' }\nend\n\n", file, owner }
