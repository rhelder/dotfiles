# When `nomencl` package is used, invoke `MakeIndex` to create nomenclature
# file
add_cus_dep('nlo','nls',0,'nlo2nls');
sub nlo2nls {
	system("makeindex \"$_[0].nlo\" -s nomencl.ist -o \"$_[0].nls\"");
}
