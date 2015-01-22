BEGIN {
printf "require \'spec_helper\'\n\n";
mode = "700";
}

/^\// {file = $1; 
	printf "describe file('%s') do\n  it {should be_mode %s}\nend\n\n", file, mode }
