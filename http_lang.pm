package http_lang;

use nginx;
use I18N::LangTags qw(:ALL);

sub quality {
    my $lang = shift;

    if ($lang =~ /;q=(\d\.\d+)$/) {
        return $1;
    }
    else {
        return 1.0;
    }
}

sub lang_only {
    my $lang = shift;
    if ($lang =~ /^([a-z]{2})[-;]/) {
        return $1;
    }
    else {
        return $lang;
    }
}

sub choose {
    my @requested = split(/,\s*/, shift);
    my @supported = split(/,\s*/, shift);
		my @supportedLocales = split(/,\s*/, shift);

		my %locales;
		$locales{$_}++ for (@supportedLocales);

		my %supportedLang;
		$supportedLang{$_}++ for (@supported);
		
    my @order = sort { quality($b) <=> quality($a) } @requested;		
    foreach my $lang (@order) {
				$locale = lc $lang;
				$choose{locale} = lc $lang;
				$choose{lang} = lang_only($lang);
				if((!$locales{$locale})){
					$choose{locale} = $choose{lang};
					$choose{locale} = 'en-us' if(!$locales{$choose{lang}});
				} 
        return $choose if ($supportedLang{$choose{'lang'}});
    }

		return $supported[0];
}

sub handler {
    my $r = shift;

		my $supported = $r->variable('SUPPORTED_LANG') or "en";
		my $supportedLocales = $r->variable('SUPPORTED_LOCALES') or "en-us";
    my $requested = $r->header_in('Accept-Language') or "en-US";

		my $choose = choose($requested, $supported, $supportedLocales);

		$r->internal_redirect('/redirect-' . $choose{locale} . $r->uri);
    return OK;
}

sub debug {
    my $r = shift;

    my $supported = $r->variable('SUPPORTED_LANG') or "en";
		my $supportedLocales = $r->variable('SUPPORTED_LOCALES') or "en";
    my $requested = $r->header_in('Accept-Language') or "en-US";

		$r->send_http_header("text/plain");
    return OK if $r->header_only;

		my $choose = choose($requested, $supported, $supportedLocales);

		$r->print('$requested = ' . $requested . "\n");
		$r->print('Redirect lang: ' . '/' .$choose{lang}  . "\n");
    $r->print('Redirect to: ' . '/'. $choose{locale} . $r->uri . "\n");

    return OK;
}

1;
__END__
