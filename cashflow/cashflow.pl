#!/usr/bin/perl -w
#use Finance::OFX::Parse::Simple;
#use Finance::OFX::Parse;

#use HTML::Stream;
use Date::Parse;
use POSIX 'strftime';
#use GD::Graph::pie;
use strict;

# ####################################################################
#
# TODO


# create webpage that displays pie chart and break down for each cat
# in each class

# update final totals in report

# group cats together and make a pie chart for each cat group.. shows
# breakdown of things.. like car gas, maint, etc.

# figure out how to make webpage more readable.

#
# ####################################################################

my $verbose = 0;

my $cat_filename = "cashflow.cat";

my $capone_filename = "capone-2013.csv";
my $dcu_filename = "dcu-checking-2013.csv";
my $ing_csv_filename = "orange-savings-2013.csv";

#my @txn_key_names = "DATE:INFO:AMT:CHECK:BALANCE";
#my @txn_key_names = qw(DATE INFO AMT CHECK BALANCE);
my @txn_key_names = ("DATE","INFO","AMT","CHECK","BALANCE");

my @unmatch_txns = ();

my %categories;
my %category_totals;

my $withdraw = 0;
my $purchase = 0;
my $draft = 0;
my $deposit = 0;
my $ing_xfer_to_dcu = 0;
my $fee = 0;
my $transfer_in = 0;
my $transfer_out = 0;
my $credit_payment = 0;
my $credit_purchase = 0;

# assume that we start doing budgeting after one month passes
my $numweeks = 4;
my $nummonths = 1;

#my $html_fh;
#my $HTML;

# #################################################################
# INPUT:
# OUTPUT:
sub dbg($$) {
    my ($level, $msg) = @_;
    if ($level <= $verbose) {
	printf($msg);
    }
}


# #################################################################
# INPUT: a ref to txn hash
# OUTPUT: none
#
sub cmp_date_asc($$) {
    my($a, $b) = @_;
    $$a{DATE} cmp $$b{DATE};
}

# #################################################################
# INPUT: a ref to txn hash
# OUTPUT: none
#
sub print_txn($) {
    my ($ref) = @_;
    my %txn = %$ref;
    printf("TXN ");
    foreach my $key (keys %txn) {
	printf("$key=[$txn{$key}] ");
    }
    printf("\n");
}

sub print_txn_order($) {
    my ($ref) = @_;
    my %txn = %$ref;
    printf("TXN ");
    printf("DATE=[%10s] ", $txn{DATE});
    printf("SRC=[%5s] ", $txn{SRC});
    printf("AMT=[%7s] ", $txn{AMT});
    printf("INFO=[$txn{INFO}] ");
    printf("BALANCE=[$txn{BALANCE}] ");
    if ($txn{CHECK}) {
	printf("CHECK=[$txn{CHECK}] ");
    }
    printf("\n");
}


# #################################################################
# INPUT: none
# OUTPUT: hash containing all categories, keyed by category name.
#  Each category is a hash itself.
sub init_categories() {
    my %category = (
	NAME => '',
	PATTERN => '',
	TOTAL => 0,
	ITEMS => []
	);
    my %hoh;
    my @cat_total_names;
    open(CAT, "$cat_filename") or die "cant open $cat_filename: $!";
    while(<CAT>) {
	chomp;
	my $line = $_;
	if (/#/) {
	} elsif (/=/) {
	    my ($name, $pattern) = split(/=/, $line);
	    if ($name =~ /cat/) {
		push @cat_total_names, $pattern;
	    } else {
		dbg(1, "name=[$name] pat=[$pattern]\n");
		$hoh{$name}{NAME} = $name;
		$hoh{$name}{PATTERN} = $pattern;
		$hoh{$name}{TOTAL} = 0;
		$hoh{$name}{ITEMS} = [];
	    }
	}
    }
    close(CAT) or warn "error closing cat file:$!";

    # create hash of hash which contains cat total name as key and
    # hash contains total and array of category names.
    my %cathoh;
    my @keys = sort keys %hoh;
    foreach my $name (@cat_total_names) {
	my @cats;
	foreach my $key (@keys) {
	    #print "$name == $key\n";
	    if ($key =~ /^$name/  ) {
		#print "$key starts with $name\n";
		push @cats, $key;
		# remove key from keys?
	    }
	}
	#print "@cats\n";
	$cathoh{$name}{CATNAMES} = [ @cats ];
	$cathoh{$name}{CATTOTAL} = 0;
	#print "$name=@{$cathoh{$name}{CATNAMES}}\n";
    }
    %category_totals = %cathoh;

    # todo, why is check misc blank pattern? it messes up matching
    #
    my $check_misc = "check_misc";
    $hoh{$check_misc}{NAME} = $check_misc;
    # $hoh{$name}{PATTERN} = 
    $hoh{$check_misc}{TOTAL} = 0;
    $hoh{$check_misc}{ITEMS} = [];
    $hoh{$check_misc}{check} = undef;
    return %hoh;
}


# #################################################################
# INPUT: verbosity = 0, 1, 2.
#  hash reference to a category hash
# OUTPUT:
#
sub print_category($$) {
    my ($print_txns, $rcat) = @_;
    my $msg = "";

    return if ($rcat->{TOTAL} == 0);

    if ($rcat->{NAME} =~ /bank_atm_with/) {
	$rcat->{NAME} = $rcat->{NAME} . " adjusted for hockey"
    }
    $msg = sprintf("total=% 10.2f     name=%s\n",
		   $rcat->{TOTAL},
		   $rcat->{NAME});
    # if ($rcat->{TOTAL} != 0) {
    #     $HTML->text($msg);
    #     $HTML->BR();
    # }
    printf($msg);

    if ($print_txns == 1) {

	my @sorted = sort cmp_date_asc @{$rcat->{ITEMS}};
	if ($rcat->{PATTERN}) {
	    $msg = "pattern=$rcat->{PATTERN}\n";
	    # if ($rcat->{TOTAL} != 0) {
	    #     $HTML->text($msg);
	    #     $HTML->BR();
	    # }
	    printf($msg);
	} else {
	    $msg = "pattern=no pattern defined\n";
	    # if ($rcat->{TOTAL} != 0) {
	    #     $HTML->text($msg);
	    #     $HTML->BR();
	    # }
	    printf($msg);
	}
	# if ($rcat->{TOTAL} != 0) {
	#     $HTML->TABLE(border=>1)->TH->t("DATE")->_TH->TH->t("SRC")->_TH->TH->t("AMT")->_TH->TH->t("INFO")->_TH->TH->t("CHECK #")->_TH;
	# }
	foreach my $item (@sorted) {
	    #print_txn($item);
	    $msg = sprintf("date=[%10s] src=[%s] amt=[%10.2f] ".
			   "info=[%s]",
			   $item->{DATE},
			   $item->{SRC},
			   $item->{AMT},
			   $item->{INFO});
	    printf($msg);
	    # if ($rcat->{TOTAL} != 0) {
	    #     $HTML->TR;
	    #     $HTML->TD->t($item->{DATE})->_TD;
	    #     $HTML->TD->t($item->{SRC})->_TD;
	    #     $HTML->TD->t($item->{AMT})->_TD;
	    #     $HTML->TD->t($item->{INFO})->_TD;
	    # }
	    if ($item->{CHECK}) {
		$msg = sprintf(" check=[%d]", $item->{CHECK});
		# if ($rcat->{TOTAL} != 0) {
		#     $HTML->TD->t($item->{CHECK})->_TD;
		# }
		printf($msg);
	    } else {
		# if ($rcat->{TOTAL} != 0) {
		#     $HTML->TD->t("--")->_TD;
		#     #$HTML->TD->_TD;
		# }
	    }
	    printf("\n");
	    # if ($rcat->{TOTAL} != 0) {
	    #     $HTML->_TR;
	    # }
	}
	if ($rcat->{TOTAL} != 0) {
	    $msg = sprintf("date=[%10s] src=[   ] amt=[%10.2f] info=[%s]\n",
			   "--", $rcat->{TOTAL}, "TOTAL");
	    printf($msg);
	    # $HTML->TR;
	    # $HTML->TD->t("TOTAL")->_TD;
	    # $HTML->TD->t($rcat->{TOTAL})->_TD;
	    # $HTML->TD->t($rcat->{NAME})->_TD;
	    # $HTML->TD->t("--")->_TD;
	}
	
	printf("-------------------------------------------------------\n");
	# if ($rcat->{TOTAL} != 0) {
	#     $HTML->_TABLE;
	#     $HTML->HR();
	#     $HTML->BR();
	# }
    }
}

# #################################################################
# INPUT: hash reference to hash of all categories
# OUTPUT:
#
sub print_categories($$) {
    my ($lvl, $rhoh) = @_;
    for my $name ( sort keys %$rhoh ) {
	print_category($lvl, $rhoh->{$name});
    }
}

# #################################################################
# INPUT: hash reference to hash of all categories
#        hash ref to category hash       
# OUTPUT:
#
sub total_categories($$) {
    my ($rhohcattotal, $rhoh) = @_;

    for my $cattotalname (sort keys %$rhohcattotal) {
	my $total = 0;
	foreach my $cat (@{$rhohcattotal->{$cattotalname}{CATNAMES}}) {
	    #print "cat=$cat $rhoh->{$cat}{TOTAL} ";
	    $total += $rhoh->{$cat}{TOTAL};
	}

	$rhohcattotal->{$cattotalname}{CATOTAL} = $total;
	print"$cattotalname=$total :: @{$rhohcattotal->{$cattotalname}{CATNAMES}}\n";
    }
}

# #################################################################
# INPUT: title of graph. filename for graph. rdata is array of data
# for x,y axes. for example
#    my @data = ([@pie slice name], [@pie slice value]);
#
#
sub print_a_pie_graph($$$) {
    # my ($title, $filename, $rdata) = @_;

    # my $mygraph = GD::Graph::pie->new(800, 800);
    # $mygraph->set(
    #     title       => $title,
    #     ) or warn $mygraph->error;
    # $mygraph->set_value_font(GD::gdMediumBoldFont);
    # print STDERR "graph: $title\n";
    # my $myimage = $mygraph->plot($rdata) or die $mygraph->error;
    # open(PIE, ">$filename") or die("Cannot open file for writing");
    # binmode PIE;
    # # Convert the image to PNG and print it to the file PIE
    # print PIE $myimage->png;
    # close PIE;

    # $HTML->A(HREF=>$filename)->t($title)->_A;
    # $HTML->BR();

}

my $pie_catotals = "pie-catotals.png";
my $title_catotals = "Bundtpiwo category totals";
my $pie_debits = "pie-debits.png";
my $title_debits = "Debit totals";

# #################################################################
# INPUT: ref to hash of hash that contains cat totals:
# catname->total. skip array ref contains list of cat names to skip.
#
# OUTPUT:
#
sub print_total_category_graph($$$) {
    my ($graphname, $rhohcattotal, $skip_cat_names) = @_;
    my @totals;
    my @names;
    my @debit_totals;
    my @debit_names;


    for my $cat (sort keys %$rhohcattotal) {
	my $total = $rhohcattotal->{$cat}{CATOTAL};
	#if ($total == 0) {
	if ($total > -999 && $total < 0) {
	    dbg(0, "999 total=$total cat=$cat\n");
	    next;
	}
	my $skipit = 0;
	foreach my $skip (@$skip_cat_names) {
	    if ($skip eq $cat) {
		dbg(1, "skip=$skip cat=$cat\n");
		$skipit = 1;
		last;
	    }
	}
	if ($skipit == 1) {
	    $skipit = 0;
	    next;
	}
	if ($total < 0) {
	    $total *= -1;
	    push @debit_totals, $total;
	    push @debit_names, $cat.":".int($total+1);
	}
	#push @totals, $total;
	#push @names, $cat;
	#print "$cat == $total\n";
    }
    #my @data = ([@names], [@totals]);
    #print_a_pie_graph($title_catotals, $pie_catotals, \@data);

    my @data = ([@debit_names], [@debit_totals]);
    print_a_pie_graph($graphname, $graphname.".png", \@data);

}

# #################################################################
# figure out which week of the year a date is in.
#
sub figure_out_numweeks($) {
    no warnings 'uninitialized';
    my ($date) = @_;
    #my ($ss,$mm,$hh,$day,$month,$year,$zone) = strptime($date);

    my @lastdate = strptime($date);
    #print STDERR "date=$date \n";
    #print STDERR "date=$date last=[@lastdate]\n";
    my $nweeks = strftime('%V', @lastdate);
    #print STDERR "nw=$nweeks numw=$numweeks date=[$date] last=[@lastdate]\n";
    if ($nweeks > $numweeks) {
	print STDERR "nw=$nweeks numweek=$numweeks\n";
	#print STDERR "date=$date last=[@lastdate]\n";
	$numweeks = $nweeks;
    }
    my $nmonths = $lastdate[4];
    if ($nmonths > $nummonths) {
	print STDERR "nm=$nmonths nummonth=$nummonths\n";
	$nummonths = $nmonths;
    }
}


# #################################################################
# decrease cat total for atm withdrawl by estimate for weekly hockey.
# figure 30 weeks for tues AM and 50 for fri AM
#
# INPUT: none
# OUTPUT: none
#
sub adjust_for_hockey() {
    #my $tuesam = 15 * 30;
    #my $friam = 15 * 50;
    #my $totam = $tuesam + $friam;

    my $tuesam = 15 * $numweeks;
    if ($nummonths > 4 && $nummonths < 9) {
	
    }
    my $friam = 15 * $numweeks;
    my $totam = $tuesam + $friam;
    printf("numweek=$numweeks tues=$tuesam fri=$friam \n");
    my $atmcat = "bank_atm_with";
    my $hockeycat = "sport_hockey";

    if (!defined $categories{$hockeycat}) {
	print STDERR "$hockeycat cat not found\n";
    } else {
	if (!defined $categories{$atmcat}) {
	    print STDERR "$atmcat cat not found\n";
	} else {
	    printf("atm total=%s hockey total=%s\n",
		   $categories{$atmcat}{TOTAL},
		   $categories{$hockeycat}{TOTAL});
	    printf("decrease atm by am hockey total=%s\n", $totam);
	    $categories{$atmcat}{TOTAL} += $totam;
	    $categories{$hockeycat}{TOTAL} -= $totam;
	    printf("new atm total=%s hockey total=%s\n",
		   $categories{$atmcat}{TOTAL},
		   $categories{$hockeycat}{TOTAL});
	}
    }
}


# #################################################################
#
sub start_web_report() {

    # my $filename = "report.html";
    # $html_fh = new FileHandle;
    # $html_fh->open(">$filename") or die "$filename fail to open ($!)";
    # $HTML = new HTML::Stream $html_fh;

    # $HTML->HTML->HEAD->TITLE->t("Bundtpiwo Annual Report")->_TITLE->_HEAD;
    # $HTML->H1()->t("Bundtpiwo Annual Report")->_H1;
    # $HTML->text($msg);

}

# #################################################################
# INPUT: ref to txn hash. ref to category hash.
# OUTPUT:
#
#sub match_category() {
#    my ($rtxn, $rcat) = @_;
#    my $pattern = $rcat->{PATTERN};
#    if ($rtxn->{INFO} =~ $pattern) {
#	push @{$rcat->{ITEMS}}, $rtxn;
#    }
#}

# #################################################################
# INPUT: txn 
#        categories
# OUTPUT: none
#
sub match_categories($$) {
    my ($rtxn, $rcat) = @_;
    my $found = 0;

    #
    # first see if the pattern contains txn key name and some special
    # flag value to look for in the txn part that matches the key
    # name. If not, then try to match the txn to other patterns.
    #
    for my $catname ( keys %$rcat ) {
	my $pattern = $rcat->{$catname}->{PATTERN};
	my ($cat, $xtra);
	if ($pattern && $pattern =~ /::/) {
	    ($cat, $xtra) = split('::', $pattern);
	    dbg(2, "xtra=[$xtra] cat=[$cat] pat=[$pattern] ".
		"txninfo=[$rtxn->{INFO}] txnamt=[$rtxn->{AMT}]\n");
	    foreach my $key (@txn_key_names) {
		my ($xtra_key, $xtra_val)  = split(':', $xtra);
		my ($cat_key, $cat_val)  = split(':', $cat);
		dbg(2, "key=[$key]".
		    " xtra_key=[$xtra_key] xtra_val=[$xtra_val]".
		    " cat_key=[$cat_key] cat_val=[$cat_val]\n");
		if ($key =~ /$xtra_key/ &&
		    $rtxn->{$xtra_key} == $xtra_val &&
		    $rtxn->{INFO} =~ /$cat_val/) {
		    # dbg(0, "match $rtxn->{INFO}\n");

		    #if ($rtxn->{$name} == $val) {
		    push @{$rcat->{$catname}->{ITEMS}}, $rtxn;
		    $rcat->{$catname}->{TOTAL} += $rtxn->{AMT};
		    $found = 1;
		    last;
		    #}
		}
	    }
	} else {
	    # do nothing
	}
    }
    if ($found == 0) {
	for my $catname ( keys %$rcat ) {
	    my $pattern = $rcat->{$catname}->{PATTERN};
	    # if ($rtxn->{CHECK} != "" && $catname =~ /check/) 
	    if ($pattern && $rtxn->{INFO} =~ /$pattern/) {
		dbg(2, "MAT INFO=[$rtxn->{INFO}] pattern=[$pattern] \n");
		push @{$rcat->{$catname}->{ITEMS}}, $rtxn;
		$rcat->{$catname}->{TOTAL} += $rtxn->{AMT};
		$found = 1;
		last;
	    }
	}
    }
    if ($found == 0) {
	# if ($rtxn->{CHECK} != "") {
	if ($rtxn->{CHECK} ne "") {
	    my $catname = "check_misc";
	    dbg(2, "MAT default to $catname INFO=[$rtxn->{INFO}]\n");
	    push @{$rcat->{$catname}->{ITEMS}}, $rtxn;
	    $rcat->{$catname}->{TOTAL} += $rtxn->{AMT};
	    $found = 1;
	}
    }
    if ($found == 0) {
	#print_txn($rtxn);
    }
    return $found;
}

sub normalize_date($) {
    my ($date) = @_;
    my ($month, $day, $year) = split('/', $date);

    # Stripping leading zeros does not work for sorting. The single
    # digit numbers/dates come after the double digit ones. So make
    # sure every month/day has leading zeros

    #$month =~ s/^0*//;
    #$day  =~ s/^0*//;

    $month = sprintf("%02d", $month);
    $day = sprintf("%02d", $day);
    return join('/', $month, $day, $year);
}

# #################################################################
# INPUT: a line from dcu csv file
# OUTPUT: a hash containing the comma separated fields in input line
#
sub parse_dcu_line($) {
    my ($line) = @_;

    if ($line =~ /^\"/) {
	return parse_dcu_line2($line);
    }
    if ($line =~ /(\".*,.*\")/) {
	dbg(2, "found , in quotes: [$1]\n");
	my $tmp = $1;
	$tmp =~ s/,/ /;
	$line =~ s/\".*\"/$tmp/;
	dbg(2, "new line [$line]\n");
	
    }
    my @parts = split(',', $line);
    if ($#parts < 1) {
	return;
    }
    $parts[0] = normalize_date($parts[0]);
    my %txn = (
	DATE => $parts[0],
	INFO => $parts[1],
	AMT => $parts[2],
	CHECK => $parts[3],
	BALANCE => $parts[6],
	SRC => "DCU"
	);
    
    $txn{INFO} =~ s/^\s+//;
    $txn{INFO} =~ s/\s+$//;

    return %txn;
}

# #################################################################
# INPUT: a line from dcu csv file
# OUTPUT: a hash containing the comma separated fields in input line
#
sub parse_dcu_line2($) {
    my ($line) = @_;
    #print("line1=[$line]\n");
    $line =~ s/\"//g;
    #print("line2=[$line]\n");
    my @parts = split(',', $line);
    if ($#parts < 1) {
	return;
    }
    #print "dcu2 parts[@parts]\n";

    $parts[1] = normalize_date($parts[1]);
    my %txn = (
	DATE => $parts[1],
	INFO => $parts[3],
	AMT => $parts[5],
	CHECK => $parts[7],
	BALANCE => $parts[6],
	SRC => "DCU"
	);
    if ($parts[4] =~ /^-?\d+\.\d+$/) {
	$txn{AMT} = $parts[4];
    }
    $txn{AMT} =~ s/ //g;
    if ($parts[2] =~ /TRANSFER/) {
	$txn{INFO} = $parts[2]." ".$parts[3];
    }
    if ($txn{INFO} eq "") {
	$txn{INFO} = $parts[2]." ".$parts[3];
    }
    # print "AMT: [$txn{AMT}]\n";
    # print "4: [$parts[4]]\n";
    # print "5: [$parts[5]]\n";
    if (!defined $txn{CHECK}) {
	$txn{CHECK} = "";
    }

    $txn{INFO} =~ s/^\s+//;
    $txn{INFO} =~ s/\s+$//;

    return %txn;
}

# #################################################################
# INPUT: a line from cap one csv file
# OUTPUT: a hash containing the comma separated fields in input line
#
sub parse_capone_line($) {
    my ($line) = @_;

    #print "$line\n";
    $line =~ s/\"//g;
    #print "$line\n";

   if ($line =~ /(\".*,.*\")/) {
	dbg(0, "found , in quotes: [$1]\n");
	my $tmp = $1;
	$tmp =~ s/,/ /;
	$line =~ s/\".*\"/$tmp/;
	dbg(0, "new line [$line]\n");
	
    }
    my @parts = split(',', $line);
    if ($#parts < 1) {
	return;
    }
    my $amt = 0;
    if ($parts[3] =~ /^-?\d+\.\d+$/) {
	$amt = -1 * $parts[3];
	$credit_purchase += $amt;
    } elsif ($parts[4] =~ /^-?\d+\.\d+$/) {
	#$amt = -1 * $parts[4];
	$amt = $parts[4];
	$credit_payment += $amt;
	#print "line=[$line] part4=$parts[4] amt=$amt\n";
    } else {
	warn "no amt for txn: [$line] part3=$parts[3] part4=$parts[4]\n";
	$amt = 0;
    }
    my %txn;
    if ($amt != 0) {
	$parts[0] = normalize_date($parts[0]);
	%txn = (
	    DATE => $parts[0],
	    INFO => $parts[2],
	    AMT =>  $amt,
	    CHECK => "",
	    BALANCE => 0,
	    SRC => "CAP"
	    );
	$txn{INFO} =~ s/^\s+//;
	$txn{INFO} =~ s/\s+$//;
    }
    return %txn;
}

# #################################################################
# INPUT: 
# OUTPUT: 
#
# Read in csv file from dcu. parse each line and match txns against
# categories
#
sub read_dcu() {
    my $filename = $dcu_filename;
    if ($filename eq "") {
	return;
    }
    my @txnlist;
    open(INPUT, "$filename") or die "cant open $filename: $!";
    while(<INPUT>) {
        if (/^#/) {
            next
        }
	chomp;
	my $line = $_;
	my %txn = parse_dcu_line($line);
	# skip lines that were not parsed as a txn
	next unless %txn;
	#print_txn(\%txn);

	if ($txn{AMT} =~ /^-?\d+\.\d+$/) {
	    # $_ = $line;
	    $_ = $txn{INFO};
	    if (/WITHDRAW/) {
		#$withdraw += $txn{AMT};
	    } elsif (/PURCHASE/) {
		#$purchase += $txn{AMT};
	    } elsif (/SH DRAFT/) {
		#$draft += $txn{AMT};
	    } elsif (/DEPOSIT/) {
		if (/ING DIR/) {
		    $ing_xfer_to_dcu += $txn{AMT};
		} else {
		    $deposit += $txn{AMT};
		}
	    } elsif (/TRANSFER FROM/) {
		#$transfer_in += $txn{AMT};
	    } elsif (/TRANSFER TO/) {
		#$transfer_out += $txn{AMT};
	    } elsif (/FEE/) {
		#$fee += $txn{AMT};
	    } else {
		if (1 <= $verbose) {
		    printf("DCU1 OTHER txn type: ");
		    print_txn(\%txn);
		}
		#push(@unmatch_txns, \%txn);
	    }
	    push @txnlist, \%txn;

	} else {
	    printf("not a number: [$txn{AMT}]  [$line]\n");
	}
    }
    my @sorted = sort cmp_date_asc @txnlist;
    figure_out_numweeks($sorted[$#sorted]->{DATE});

    #sort_txn_by_date(\@txnlist);
    foreach my $item (@sorted) {
	my $found = match_categories($item, \%categories);
	if ($found == 0) {
	    printf("DCU2 UNKNOWN: ");
	    print_txn($item);
	    push(@unmatch_txns, $item);
	}
    }
}

# #################################################################
# INPUT: 
# OUTPUT: 
#
# Read in csv file from capone. parse each line and match txns against
# categories
#
sub read_capone() {
    my $filename = $capone_filename;
    if ($filename eq "") {
	return;
    }
    my @txnlist;
    open(INPUT, "$filename") or die "cant open $filename: $!";
    while(<INPUT>) {
        if (/^#/) {
            next
        }
	chomp;
	my $line = $_;
	my %txn = parse_capone_line($line);
	# skip lines that were not parsed as a txn
	next unless %txn;
	#print_txn(\%txn);
	push @txnlist, \%txn;
    }
    my @sorted = sort cmp_date_asc @txnlist;
    figure_out_numweeks($sorted[$#sorted]->{DATE});
    #sort_txn_by_date(\@txnlist);
    foreach my $item (@sorted) {
	my $found = match_categories($item, \%categories);
	if ($found == 0) {
	    if (1 <= $verbose) {
		printf("CAP UNKNOWN: ");
		print_txn($item);
	    }
	    push(@unmatch_txns, $item);
	}
    }
}


sub convert_ing_time($) {
    my ($input) = @_;
    $input =~ /(\d{4})(\d{2])(\d{2})/;
    my $year = $1;
    printf("year=$year\n");
}

# #################################################################
# INPUT: a line from ing orage csv file
# OUTPUT: a hash containing the comma separated fields in input line
#
sub parse_ing_csv_line($) {
    my ($line) = @_;

    #print "$line\n";
    $line =~ s/\"//g;
    #print "$line\n";

    my @parts = split(',', $line);
    if ($#parts < 1) {
	return;
    }
#0 BANK ID,
#1 Account Number,
#2 Account Type,
#3 Balance,
#4 Start Date,
#5 End Date,
#6 Transaction Type,
#7 Transaction Date,
#8 Transaction Amount,
#9 Transaction ID,
#10 Transaction Description
    dbg(2,
	"DATE     7 [$parts[7]]\n".
	"INFO    10 [$parts[10]]\n".
	"AMT      8 [$parts[8]]\n".
	"BALANCE  3 [$parts[3]]\n");

    my %txn;
    if ($parts[8] =~ /^-?\d+\.\d+$/) {
	%txn = (
	    DATE => $parts[7],
	    INFO => "ING ".$parts[10],
	    AMT =>  $parts[8],
	    CHECK => 0,
	    BALANCE => $parts[3],
	    SRC => "ING"
	    );
    }
    return %txn;
}

# #################################################################
# INPUT: none
# OUTPUT: none
#
# Read in csv file from ing. parse each line and match txns against
# categories
#
sub read_ing_csv() {
    my $filename = $ing_csv_filename;
    if ($filename eq "") {
	return;
    }
    open(INPUT, "$filename") or die "cant open $filename: $!";
    while(<INPUT>) {
	chomp;
	my $line = $_;
	my %txn = parse_ing_csv_line($line);
	# skip lines that were not parsed as a txn
	next unless %txn;
	#print_txn_order(\%txn);
	
	my $found = match_categories(\%txn, \%categories);
	if ($found == 0) {
	    printf("ING2 UNKNOWN: ");
	    print_txn(\%txn);
	    push(@unmatch_txns, \%txn);
	}
    }
}

# #################################################################
# INPUT: none
# OUTPUT: none
#
#
sub calculate_summary() {
    my @debit_names;
    my @debit_totals;
    my %fixedoutcats = (
	LOANS => $categories{"loans_school"}{TOTAL},
    );
    my %varoutcats;

    my $otherout = 0;
    my $totalincome = 0;
    my $vzwincome = $categories{"income_vzw"}{TOTAL};

    printf("------------------------------\n");
    printf("deposits should be zero.".
	   "  If diff is negative I'm owed. If positive I owe.\n");
    printf("fmfrr deposits  %10.2f\n", $categories{fmfrr_deposit}{TOTAL});
    printf("fmfrr payments  %10.2f\n", $categories{fmfrr_payment}{TOTAL});
    printf("fmfrr transfer  %10.2f\n", $categories{fmfrr_transfer}{TOTAL});
    printf("fmfrr diff      %10.2f\n",
	   $categories{fmfrr_payment}{TOTAL} + $categories{fmfrr_transfer}{TOTAL});
    printf("------------------------------\n");


    foreach my $cat (keys %categories) {

	if ($cat =~ /income_/ && $categories{$cat}{TOTAL} != 0) {
	    #printf("%10.2f :: %s\n", $categories{$cat}{TOTAL}, $cat);
	    $totalincome += $categories{$cat}{TOTAL};
	}
	elsif ($cat =~ /util_/ && $categories{$cat}{TOTAL} != 0) {
	    $fixedoutcats{UTILS} += $categories{$cat}{TOTAL};
	}
	elsif ($cat =~ /taxes_/) {
	    $fixedoutcats{TAXES} += $categories{$cat}{TOTAL};
	}
	elsif ($cat =~ /mortgage/) {
	    $fixedoutcats{MORTGAGE} += $categories{$cat}{TOTAL};
	}
	elsif ($cat =~ /insurance/) {
	    $fixedoutcats{INSURANCE} += $categories{$cat}{TOTAL};
	}
	elsif ($cat =~ /investment/ && $categories{$cat}{TOTAL} != 0) {
	    $fixedoutcats{INVESTMENT} += $categories{$cat}{TOTAL};
	}
	elsif ($cat =~ /health/) {
	    $varoutcats{HEALTH} += $categories{$cat}{TOTAL};
	}
	elsif ($cat =~ /house/) {
	    $varoutcats{HOUSE} += $categories{$cat}{TOTAL};
	}
	elsif ($cat =~ /grocery/) {
	    # credit amex is costco which is mostly food related stuff
	    $varoutcats{GROCERY} += $categories{$cat}{TOTAL};
	}
	elsif ($cat =~ /car/) {
	    $varoutcats{CAR} += $categories{$cat}{TOTAL};
	}
	elsif ($cat =~ /auto_gas/) {
	    $varoutcats{CARGAS} += $categories{$cat}{TOTAL};
	}
	elsif ($cat =~ /dining/) {
	    $varoutcats{DINING} += $categories{$cat}{TOTAL};
	}
	elsif ($cat =~ /sport/) {
	    $varoutcats{SPORT} += $categories{$cat}{TOTAL};
	}
	elsif ($cat =~ /clothes/) {
	    $varoutcats{CLOTHES} += $categories{$cat}{TOTAL};
	}
	elsif ($cat =~ /beauty/) {
	    $varoutcats{BEAUTY} += $categories{$cat}{TOTAL};
	}
	elsif ($cat =~ /hobby/) {
	    $varoutcats{HOBBY} += $categories{$cat}{TOTAL};
	}
	elsif ($cat =~ /baby/) {
	    $varoutcats{BABY} += $categories{$cat}{TOTAL};
	}
	elsif ($cat =~ /travel/ || $cat =~ /credit_rei/) {
	    # credit rei is lumped under travel b/c in 2010 we used it
	    # only for trip to AZ except for one other purchase Maciej
	    # made for hiking trip at REI.
	    $varoutcats{TRAVEL} += $categories{$cat}{TOTAL};
	}
	elsif ($cat =~ /credit_amex/) {
	    # we only use amex at costco. mostly for groceries, but
	    # sometimes non-grocery purchases so cant lump it into
	    # grocery
	    $varoutcats{COSTCO} += $categories{$cat}{TOTAL};
	}
	elsif ($cat =~ /misc/) {
	    $varoutcats{MISC} += $categories{$cat}{TOTAL};
	}
	elsif ($cat =~ /fmfrr/) {
	    next;
	}
	else {
	    if ($categories{$cat}{TOTAL} > 0 ||
		$cat =~ /transfer_/ || 
		$cat =~ /bank_atm_with/ ||
		$cat =~ /loans_/ ||
		$cat =~ /home_down/) {
		#print "skip $cat $categories{$cat}{TOTAL}\n";
		next;
	    }
	    if ($categories{$cat}{TOTAL} < 0 && $cat !~ /capone/) {
		$otherout += $categories{$cat}{TOTAL};
		printf("%10.2f :: %s\n", $categories{$cat}{TOTAL} , $cat);
	    }
	}
    }
    printf("----------\n");
    printf("%10.2f :: %s\n", $otherout, "TOTAL OTHER OUTCOME");
    printf("------------------------------\n");

    #printf("%10.2f :: %s\n", $ , "");
    my $fixedtotal = 0;
    my $vartotal = 0;
    foreach my $key (sort keys %fixedoutcats) {
	printf("%10.2f :: %s\n", $fixedoutcats{$key} , $key);
	$fixedtotal += $fixedoutcats{$key};
	push @debit_names, $key;
	push @debit_totals, ($fixedoutcats{$key} * -1);
    }
    printf("----------\n");
    printf("%10.2f :: %s\n", $fixedtotal, "FIXED OUTCOME TOTAL");
    printf("------------------------------\n");

    foreach my $key (sort keys %varoutcats) {
	printf("%10.2f :: %s\n", $varoutcats{$key} , $key);
	$vartotal += $varoutcats{$key};
	push @debit_names, $key;
	push @debit_totals, ($varoutcats{$key} * -1);
    }
    printf("----------\n");
    printf("%10.2f :: %s\n", $vartotal, "VARIABLE OUTCOME TOTAL");
    printf("------------------------------\n");

    printf("%10.2f :: %s\n", $fixedtotal + $vartotal ,
	   "FIX+VAR TOTAL OUTCOME");
    printf("----------\n");
    printf("%10.2f :: %s\n", $otherout + $fixedtotal + $vartotal,
	   "TOTAL ALL OUTCOME");

    printf("==============================\n");
    printf("%10.2f :: %s\n", $vzwincome, "VZW");
    printf("%10.2f :: %s\n", $totalincome - $vzwincome, "OTHER INC");
    printf("----------\n");
    printf("%10.2f :: %s\n", $totalincome , "INCOME");

    printf("==============================\n");
    printf("%10.2f :: %s\n",
	   $totalincome + $otherout + $fixedtotal + $vartotal,
	   "NET");

    my $graphname = "summary";
    my @data = ([@debit_names], [@debit_totals]);
    print_a_pie_graph($graphname, $graphname.".png", \@data);
}

# #################################################################
# INPUT: none
# OUTPUT: none
#
# Print out txns that were not matched to category. Only print to
# STDOUT and not html.
#
sub print_unknown_txns() {

    my $unk_total = 0;
    my $unk_withdraw = 0;
    my $unk_deposit = 0;
    foreach my $txn (@unmatch_txns) {
	my $amt = $txn->{AMT};
	$unk_total += $amt;
	if ($amt > 0) {
	    $unk_deposit += $amt;
	} else {
	    $unk_withdraw += $amt;
	}
    }
    printf("===UNMATCH TXN=============================================\n");
    printf("found %d unmatched txns withdraw=%.02f deposit=%.02f total=%.02f\n",
	   $#unmatch_txns+1, $unk_withdraw, $unk_deposit, $unk_total);
    foreach my $txn (@unmatch_txns) {
	print_txn_order($txn);
    }
    printf("===========================================================\n");
}



# #################################################################
# MAIN
# #################################################################

#test_ofx();

dbg(1, "$#ARGV args\n");
my $i;
for ($i = 0; $i < $#ARGV; $i++) {
    printf("$i $ARGV[$i]\n");
}
dbg(1, "\n");
if ($#ARGV > 2) {
    printf("ARGV 1 [$ARGV[1]] \n");
}
dbg(1, "ARGV [@ARGV]\n");

start_web_report();

%categories = init_categories();
# print_categories(0, \%categories);

print "==================================\n";

read_capone();
read_dcu();
read_ing_csv();

adjust_for_hockey();

total_categories(\%category_totals, \%categories);


my @skips = ("home_downpayment", "gym");
print_total_category_graph("debits-1", \%category_totals, \@skips);

push @skips, "house";
print_total_category_graph("debits-2", \%category_totals, \@skips);

####################

printf("===========================================================\n");
print_categories(1, \%categories);
print_categories(0, \%categories);

####################



###################
# display unknown txns so they can be assigned to cats

print_unknown_txns();


calculate_summary();

#$html_fh->close();
