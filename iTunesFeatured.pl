#!/usr/bin/perl

# Created by Ortwin Gentz on 27.04.09.
#
# Copyright 2010 FutureTap. All rights reserved.
# http://www.futuretap.com/blog/scraping-app-store-featured-entries/
#
# This work is licensed under a Creative Commons Attribution-Share Alike 3.0 Unported License
# http://creativecommons.org/licenses/by-sa/3.0/
#
# If you use this script, I'd be glad to know. Just shoot me a tweet @futuretap
# or a mail at info@futuretap.com.


%iso2store = (
	"ar" => 143505,
	"au" => 143460,
	"be" => 143446,
	"br" => 143503,
	"ca" => 143455,
	"cl" => 143483,
	"cn" => 143465,
	"co" => 143501,
	"cr" => 143494,
	"cz" => 143489,
	"dk" => 143458,
	"de" => 143443,
	"sv" => 143506,
	"es" => 143454,
	"fi" => 143447,
	"fr" => 143442,
	"gr" => 143448,
	"gt" => 143504,
	"hk" => 143463,
	"hu" => 143482,
	"in" => 143467,
	"id" => 143476,
	"ie" => 143449,
	"il" => 143491,
	"it" => 143450,
	"kr" => 143466,
	"kw" => 143493,
	"lb" => 143497,
	"lu" => 143451,
	"my" => 143473,
	"mx" => 143468,
	"nl" => 143452,
	"nz" => 143461,
	"no" => 143457,
	"at" => 143445,
	"pk" => 143477,
	"pa" => 143485,
	"pe" => 143507,
	"ph" => 143474,
	"pl" => 143478,
	"pt" => 143453,
	"qa" => 143498,
	"ro" => 143487,
	"ru" => 143469,
	"sa" => 143479,
	"ch" => 143459,
	"sg" => 143464,
	"sk" => 143496,
	"si" => 143499,
	"za" => 143472,
	"lk" => 143486,
	"se" => 143456,
	"tw" => 143470,
	"th" => 143475,
	"tr" => 143480,
	"ae" => 143481,
	"gb" => 143444,
	"ve" => 143502,
	"vn" => 143471,
	"jp" => 143462,
	"us" => 143441
);

my %genres = (
	"Books" => 6018,
	"Business" => 6000,
	"Education" => 6017,
	"Entertainment" => 6016,
	"Finance" => 6015,
	"Games" => 6014,
	"Games/Action"		=> 7001,
	"Games/Adventure"	=> 7002,
	"Games/Arcade"		=> 7003,
	"Games/Board"		=> 7004,
	"Games/Card"		=> 7005,
	"Games/Casino"		=> 7006,
	"Games/Dice"		=> 7007,
	"Games/Educational"	=> 7008,
	"Games/Family"		=> 7009,
	"Games/Kids"		=> 7010,
	"Games/Music"		=> 7011,
	"Games/Puzzle"		=> 7012,
	"Games/Racing"		=> 7013,
	"Games/Role Playing"=> 7014,
	"Games/Simulation"	=> 7015,
	"Games/Sports"		=> 7016,
	"Games/Strategy"	=> 7017,
	"Games/Trivia"		=> 7018,
	"Games/Word"		=> 7019,
	"Health &amp; Fitness" => 6013,
	"Lifestyle" => 6012,
	"Medical" => 6020,
	"Music" => 6011,
	"Navigation" => 6010,
	"News" => 6009,
	"Photography" => 6008,
	"Productivity" => 6007,
	"Reference" => 6006,
	"Social Networking" => 6005,
	"Sports" => 6004,
	"Travel" => 6003,
	"Utilities" => 6002,
	"Weather" => 6001
);

$appId = shift;
$categoryName = shift;
$mode = shift;
$mode = lc$mode;
if($mode eq ""){
    $mode = "iphone";
}

#$debug = 1;

$headers =' -b "groupingPillToken=' . $mode . '" -H "Accept-Encoding: gzip, deflate" --compressed -A "iTunes/10.2.1 (Macintosh; Intel Mac OS X 10.6.7) AppleWebKit/533.21.1" ';


($appId =~ m/^\d+$/) || die "Usage: itFeatured.pl <numerical app ID> <category (Medical, Utilities, Games, Games/Strategy etc.)> [<store (iPad,iPhone)>]\n\n";
$date = `date "+%d.%m.%Y"`;
chomp $date;

foreach $country (sort(keys %iso2store)) {
	my $newStorefront = $iso2store{$country};
	my $switchUrl = "http://itunes.apple.com/WebObjects/MZStore.woa/wa/switchToStoreFront?storeFrontId=$newStorefront&ign-impt=clickRef%3DSwitch%2520Stores-DE";
	DEBUG ($switchUrl);
	`curl -s -H "X-Apple-Store-Front: $newStorefront-1,12" $headers "$switchUrl"`;

	my $matchesRoot = "";
	my $matchesCategory = "";
	$matchesRoot = printFeaturingForAppIdCountryAndCategory($appID, $country, "",$mode);
	$matchesCategory = printFeaturingForAppIdCountryAndCategory($appID, $country, $categoryName,$mode);
	
	if ("$matchesRoot$matchesCategory" ne "") {
		if ($matchesRoot ne "") {
			$matchesRoot = "App Store: $matchesRoot";
		}
		$matchesRoot .= "\t";
		if ($matchesCategory ne "") {
			$matchesCategory = "$categoryName: $matchesCategory";
		}
		print "$date\t" . uc($country) . "\t" . $matchesRoot . $matchesCategory . "\n";
	}
}

exit 0;

sub printFeaturingForAppIdCountryAndCategory {
	my ($appID, $country, $categoryName, $mode) = @_;

	my $storefront = $iso2store{$country};
	my $genreId = $genres{$categoryName};
	
	my $xml = "";
	my $homepageURL = "";
	if ($categoryName eq "") {
		##print "## case 1: ";
		$genreId=36;
	} else {
		##print "## case 2: ";
	}
	DEBUG ("fetching $storefront-1,12 http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewGenre?id=$genreId&mt=8");
	$xml = `curl -s $headers -H "X-Apple-Store-Front: $storefront-1,12"  "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewGenre?id=$genreId&mt=8"`;
	if ($xml =~ m!<key>kind</key><string>Goto</string>\n.+<key>url</key><string>(.+)</string>!) {
		$homepageURL = urldecode($1) . "&pillIdentifier=$mode";
	} else {
		!$debug or die "\nhomepageURL not found for $country $categoryName\n $xml";
		return "\nhomepageURL not found for $country $categoryName\n";
	}
	
	#print "checking $country $homepageURL\n";
	
		
	if($homepageURL) {
		DEBUG ("fetching $storefront-12 $homepageURL");
		$xml = `curl -s $headers -H "X-Apple-Store-Front: $storefront,12"  "$homepageURL"`;
		my $matches = "";
		$xml =~ tr/\n//d; # delete all linebreaks

		if ($xml =~ m!http://itunes.apple.com/../app/.+/id$appId!) {
			$matches .= "Home page ";
		}

		if ($xml =~ m!<h\d>(New and Noteworthy|New &amp; Noteworthy|NEU UND BEACHTENSWERT|Nuevo y notable|NUEVO Y DESTACADO|NUEVO Y DIGNO DE DESTACAR|NUOVE E DEGNE DI NOTA|Nuovi e da segnalare|ニューリリースと注目作品|注目の新作|Nieuw en opmerkelijk|Nouveautés).+?(http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewRoom[^">]+)">!i) {
			##print "## found new\n";
			if (fetchAndGrep($storefront, $2, $appId)) {
				$matches .= "NEW AND NOTEWORTHY ";
			}
		} 
		if ($xml =~ m!<h\d>(What's Hot|TOPAKTUELL|Lo más Hot|Lo último|Più richieste|Nieuw en opmerkelijk|Actualités).+?(http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewRoom[^"]+)!i) {
			##print "## found hot\n";
			if (fetchAndGrep($storefront, $2, $appId)) {
				$matches .= "WHAT'S HOT ";
			}
		} 
		if ($xml =~ m!<h\d>(STAFF FAVORITES|STAFF FAVOURITES|TIPPS DER REDAKTION|Nuestras Favoritas|NUESTRAS SUGERENCIAS|CONSIGLIATI DALLO STAFF|スタッフのおすすめ|FAVORIET BIJ ONZE MEDEWERKERS|Recommandées).+?(http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewRoom[^"]+)!i) {
			##print "## found staff\n";
			if (fetchAndGrep($storefront, $2, $appId)) {
				$matches .= "STAFF FAVORITES ";
			}
		} 
		return $matches;
	} else {
		return "parse error for 'curl -s -H \"X-Apple-Store-Front: $storefront\"  \"$homepageURL\"'\n";
	}
}

sub fetchAndGrep {
	my($storefront, $url, $appid) = @_;
	##print "## fetch and grep for storefront:$storefront, url:$url, appid:$appid\n";
	my $fetchxml;
	DEBUG ("fetching $storefront,12 $url");
	$fetchxml = `curl -s $headers -H "X-Apple-Store-Front: $storefront,12" '$url'`;
	#$xml .= `curl -s -H "X-Apple-Store-Front: $storefront,5" '$url&batchNumber=1'`;
	#$xml =~ tr/\n//d; # delete all linebreaks
	return ($fetchxml =~ m!id$appid!);
}

sub DEBUG {
	my $out = shift;
	
	if ($debug) {
		print $out . "\n";
	}
}

sub urldecode {
	my ($str) = shift;
	$str =~ tr/+/ /;
	$str =~ s/%([a-fA-F0-9]{2,2})/chr(hex($1))/eg;
	$str =~ s/<!–(.|\n)*–>//g;
	$str =~ s/&amp;/&/g;
	return $str;
}
