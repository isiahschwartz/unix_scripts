#This program was written by Isiah Schwartz
#schwartz.isiah@gmail.com
#it checks media wearout and is used for SSDs
#please email about any comments/questions/concerns
#creation date: 20140416
#last updated: 20140416

#!/usr/bin/perl
use strict;
use warnings;
use Mail::Sendmail;

#*******************************STATIC VARIABLE DECLARATION*******************************#
my $test_if_file_exists;
my $test_if_threshold_is_valid;
my $check_media_wearout_command;
my $results_from_media_wearout_command;
my $hostname;
$hostname = `hostname`;

#*******************************get 3 variables we need*******************************#
#get drive to test
my ($varg_1)= $ARGV[0];

#if it is a request for help die and display message
if (($varg_1 eq "") || ($varg_1 eq "-h") || ($varg_1 eq "-help") || ($varg_1 eq "--help")){
	&help_message_and_death;
}

#now check to see if drive exists or not
$test_if_file_exists = 0;
if(-e $varg_1){
	$test_if_file_exists = 1;
}
if($test_if_file_exists == 0){
	print "I could not find $varg_1\n";
	&help_message_and_death;
}

#get threshold value to report problems
my ($varg_2)= $ARGV[1];

#check to make sure it is a number between 0-99
$test_if_threshold_is_valid = 0;

if((0 <= $varg_2) && ($varg_2 <= 99)){
	$test_if_threshold_is_valid = 1;
}
if ($test_if_threshold_is_valid eq "0"){
	print "You need to give me a number for threshold between -1 and 100\n";
	&help_message_and_death;
}
#get email address to send report to
my ($varg_3)= $ARGV[2];

#I am just checking if the email field is blank or not a fully regex to catch every possible error
if($varg_3 eq ""){
	print "You need to give me an email address\n";
	&help_message_and_death;
}

#take all 3 values given it and form the statements to send
$check_media_wearout_command = "smartctl -a $varg_1 | grep Media_Wearout_Indicator";
#run command
$results_from_media_wearout_command = `$check_media_wearout_command`;

#error handling
if($results_from_media_wearout_command eq ""){
	die "When I tried the command smartctl -a $varg_1 | grep Media_Wearout_Indicator I received nothing. You might want to fix this\n";
}

#process results and send email if problem
$results_from_media_wearout_command =~ s/233 Media_Wearout_Indicator 0x00//;
$results_from_media_wearout_command = substr $results_from_media_wearout_command, 5, 3;
$results_from_media_wearout_command =~s/\s+$//;



if($results_from_media_wearout_command <= $varg_2){
&email_sender($varg_3,$varg_3,"media wearout indicator on $varg_1 server $hostname ","The current mediawearout is $results_from_media_wearout_command which is equal to or less than the threshold $varg_2");
}


sub help_message_and_death{

	print "This program reports media wearout on SSDs\n";
	print "The format should be command drive_to_test threshold_value_to_check email_address_to_report_to\n";
	print "it will only send a report if the value is equal to or less than what you tell it\n";
	print "or it got a result that looks wrong\n";
	print "example: media_wearout_watcher /dev/sda 95 root\@mailserver.com\n";	
	die;
}

sub email_sender{
	my ($Send_To,$Send_From,$Subject,$Message) = @_;
	my %mail;
	%mail = ( To      => $Send_To,
        	From    => $Send_From,
		Subject => $Subject,
        	Message => $Message
        	);
	sendmail(%mail) or die $Mail::Sendmail::error;
	}
