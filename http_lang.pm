package http_lang;

use nginx;

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

    my @order = sort { quality($b) <=> quality($a) } @requested;
    foreach my $lang (@order) {
        $lang = lang_only($lang);
        return $lang if ($lang ~~ @supported);
    }

    return $supported[0];
}

sub handler {
    my $r = shift;

    my $supported = $r->variable('SUPPORTED_LANG') or "en";
    my $requested = $r->header_in('Accept-Language') or "en-US";

    my $lang = choose($requested, $supported);

    $r->internal_redirect('/' . $lang . $r->uri);
    return OK;
}

sub debug {
    my $r = shift;

    my $supported = $r->variable('SUPPORTED_LANG') or "en";
    my $requested = $r->header_in('Accept-Language') or "en-US";

    my $lang = choose($requested, $supported);

    $r->send_http_header("text/plain");
    return OK if $r->header_only;

    $r->print('$supported = ' . $supported . "\n");
    $r->print('$requested = ' . $requested . "\n");
    $r->print('Redirect to: ' . '/' . $lang . $r->uri . "\n");
    return OK;
}

1;
__END__
