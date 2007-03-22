# $Id$
#
# SQL::Tidy -- tidy up SQL statements
#
# Author: Dmitri Tikhonov <dtikhonov at yahoo.com>

package SQL::Tidy;

use strict;
use warnings;

our $VERSION = 0.01;

use SQL::Tokenizer;

use constant KEYWORDS => (
    'select', 'from', 'where', 'order', 'group', 'join',
);

sub new {
    my $class = shift;
    my %args = (
        # Some defaults
        indent => '  ',
        width  => 75,
        keywords => [ KEYWORDS ],
        margin => '',

        @_
    );

    my $self = bless {}, ref($class) || $class;

    my $keywords = delete($args{'keywords'});

    while (my ($k, $v) = each(%args)) {
        $self->$k($v);
    }
    $self->add_keywords(@$keywords);

    return $self;
}

sub add_keywords {
    my ($self, @keywords) = @_;
    for my $keyword (@keywords) {
        $self->{'_keywords'}{lc($keyword)} = 1;
    }
    return;
}

sub _is_keyword { exists(shift->{'_keywords'}{lc(shift)}) }

sub tidy {
    my ($self, $query) = @_;
    my @tokens = grep !/^\s+$/, SQL::Tokenizer->tokenize($query);

    my $retval;
    my $level = 0;
    my $column = length($self->margin);

    for my $token (@tokens) {
        my $newline = 0;
        if ($self->_is_keyword($token)) {
            $retval .= "\n";
            if ($level) {
                --$level;
            }
            $newline = 1;
        } elsif ('(' eq $token) {
            ++$level;
        } elsif (')' eq $token) {
            --$level if $level > 0;
        }

        if (!$newline && length($token) + $column + 1 > $self->width) {
            ++$level;
            $retval .= "\n";
            $newline = 1;
        }

        if ($newline) {
            my $prefix = $self->margin . ($self->indent x $level);
            $column = length($prefix);
            $retval .= $prefix;
        }

        unless ($newline || ',' eq $token) {
            $retval .= ' ';
            ++$column;
        }

        $retval .= $token;
        $column += length($token);
    }

    $retval .= "\n";

    return $retval;
}

# Generate accessors:
for my $method (qw(width indent margin keywords)) {
    no strict 'refs';
    *{$method} = sub {
        my $self = shift;
        if (@_) {
            $self->{'_' . $method} = shift;
        }
        return $self->{'_' . $method};
    };
}

1;

__END__

=head1 NAME

SQL::Tidy -- tidy up SQL statements.

=head1 SYNOPSYS

  use SQL::Tidy;
  my $tidy = SQL::Tidy->new;
  print $tidy->tidy("select xyz from abc");

=head1 DESCRIPTION

SQL::Tidy will (hopefully) make your SQL statement look prettier.

=head1 METHODS

=head2 new

Constructor.  It can take a bunch of options (see L<OPTIONS> below).

=head2 tidy

Takes an SQL statement (a string) and returns a tidied up version of the
same.

=head2 add_keywords(qw(keyword1 keyword2))

Add keywords to those already in the instance.

=head1 OPTIONS

The options can be either passed to the constructor or be changed later
as method calls on the tidy object:

  # One way
  $tidy = SQL::Tidy->new(width => 75);

  # Another way
  $tidy->width(75);

=head2 indent

Specifies the indent string.  The default is two spaces, '  '.

=head2 keywords

An array reference to override the default list of keywords.

=head2 margin

Start each new line with this string.  The default it an empty string.

=head2 width

Page width.  The default is 75 characters.

=head1 BUGS

=head2 Completeness

I cannot vouch for the completeness of the keywords.  Hopefully, as this
module matures, the list of test cases will grow.

=head2 Unicode

I have not tested with UTF-8.

=head1 LICENSE

This module is licensed under the terms of the Artistic License that
covers Perl.

=head1 SEE ALSO

L<SQL::Tokenizer>

=head1 AUTHOR

Dmitri Tikhonov E<lt>dtikhonov@yahoo.comE<gt>

=cut
