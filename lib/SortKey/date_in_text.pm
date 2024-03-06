package SortKey::date_in_text;

use 5.010001;
use strict;
use warnings;

use DateTime;

our $DATE_EXTRACT_MODULE = $ENV{PERL_DATE_EXTRACT_MODULE} // "Date::Extract";

# AUTHORITY
# DATE
# DIST
# VERSION

sub meta {
    return {
        v => 1,
        args => {
        },
    };
}

my $re_is_num = qr/\A
                   [+-]?
                   (?:\d+|\d*(?:\.\d*)?)
                   (?:[Ee][+-]?\d+)?
                   \z/x;

sub gen_keygen {
    my ($is_reverse, $is_ci) = @_;

    my ($parser, $code_parse);
    unless (defined $parser) {
        my $module = $DATE_EXTRACT_MODULE;
        $module = "Date::Extract::$module" unless $module =~ /::/;
        if ($module eq 'Date::Extract') {
            require Date::Extract;
            $parser = Date::Extract->new();
            $code_parse = sub { $parser->extract($_[0]) };
        } elsif ($module eq 'Date::Extract::ID') {
            require Date::Extract::ID;
            $parser = Date::Extract::ID->new();
            $code_parse = sub { $parser->extract($_[0]) };
        } elsif ($module eq 'DateTime::Format::Alami::EN') {
            require DateTime::Format::Alami::EN;
            $parser = DateTime::Format::Alami::EN->new();
            $code_parse = sub { my $h; eval { $h = $parser->parse_datetime($_[0]) }; $h }; ## no critic: BuiltinFunctions::ProhibitStringyEval
        } elsif ($module eq 'DateTime::Format::Alami::ID') {
            require DateTime::Format::Alami::ID;
            $parser = DateTime::Format::Alami::ID->new();
            $code_parse = sub { my $h; eval { $h = $parser->parse_datetime($_[0]) }; $h }; ## no critic: BuiltinFunctions::ProhibitStringyEval
        } else {
            die "Invalid date extract module '$module'";
        }
        eval "use $module"; die if $@; ## no critic: BuiltinFunctions::ProhibitStringyEval
    }

    sub {
        no strict 'refs'; ## no critic: TestingAndDebugging::ProhibitNoStrict

        my $dt = $code_parse->($_[0]);
        return '' unless $dt;
        "$dt";
    };
}

1;
# ABSTRACT: Date found in text as sort key

=for Pod::Coverage ^(gen_keygen|meta)$

=head1 DESCRIPTION

The generated keygen will extract date found in text (by default extracted using
L<Date::Extract>, but other modules can be used, see
L</PERL_DATE_EXTRACT_MODULE>) and return the date in ISO 8601 format. Will
return empty string if string is not found.


=head1 ENVIRONMENT

=head2 DEBUG => bool

If set to true, will print stuffs to stderr.

=head2 PERL_DATE_EXTRACT_MODULE => str

Can be set to L<Date::Extract>, L<Date::Extract::ID>, or
L<DateTime::Format::Alami::EN>, L<DateTime::Format::Alami::ID>.


=head1 SEE ALSO

Old incarnation: L<Sort::Sub::by_date_in_text>.

L<Comparer> version: L<Comparer::by_date_in_text>.
