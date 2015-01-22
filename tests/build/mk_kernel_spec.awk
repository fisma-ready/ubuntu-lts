BEGIN {
  FS="="
  print("describe 'linux kernel parameters' do");
}

/^net/ {parameter = $1; 
	value = $2
	printf "  context linux_kernel_parameter('%s') do\n    its(:value) {should eq %s}\n  end\n\n", parameter, value }

END {
  print "end";
}

