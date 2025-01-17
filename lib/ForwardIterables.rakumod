# Hopefully part of Raku core at some point
use nqp;

class ForwardIterables does Iterator {
    has $!iterables is built;
    has $!current;

    method next-iterator() is implementation-detail {
        my $next  := nqp::shift($!iterables);
        $!current := nqp::istype($next,Iterator)
          ?? $next
          !! $next.iterator;
        self
    }

    proto method new(|) {*}
    multi method new()             { ().iterator          }
    multi method new(**@iterables) { self.new(@iterables) }
    multi method new(@iterables) {
        @iterables.iterator.push-all(
          my $iterables := nqp::create(IterationBuffer)
        );
        if nqp::elems($iterables) {
            my $self := nqp::create(self);
            nqp::bindattr($self,ForwardIterables,'$!iterables',$iterables);
            $self.next-iterator
        }
        else {
            ().iterator
        }
    }

    method pull-one() is raw {
        my $pulled := $!current.pull-one;
        nqp::eqaddr($pulled,IterationEnd) && nqp::elems($!iterables)
          # recurse to handle exhaustion
          ?? (return-rw self.next-iterator.pull-one)
          !! $pulled
    }

    method push-all(\target --> IterationEnd) {
        $!current.push-all(target);

        my $iterables := $!iterables;
        nqp::while(
          nqp::elems($iterables),
          nqp::stmts(
            self.next-iterator;
            $!current.push-all(target)
          )
        );
    }

    multi method Seq(ForwardIterables:D:) { Seq.new: self }
}

=begin pod

=head1 NAME

ForwardIterables - turn two or more Iterables into a single iterator

=head1 SYNOPSIS

=begin code :lang<raku>

use ForwardIterables;

my @a = ^5;
my @b = <a b c d e>;
my @c = ForwardIterables.new(@a,@b).Seq;
say @c;  # [0 1 2 3 4 a b c d e]

=end code

=head1 DESCRIPTION

The C<ForwardIterables> distribution provides a C<ForwardIterables>
class that creates a single C<Iterator> from any number C<Iterables>
that will B<lazily> produce values in a "forward" order.

This functionality is similar to the L<C<flat>|https://docs.raku.org/routine/flat>
method, but with the important distinction that it does B<NOT> look
at the containerization of the arguments.  So any iterable such as
a C<Array> or C<List> inside a C<Hash> or an C<Array>, B<will>
produce all of its values.

And it also does B<not> recurse into any C<Iterable> values that it
encounters, so in that aspect it is B<NOT> like C<flat> at all.

It also provides a C<Seq> method, to directly produce a C<Seq> object
from the iterator, so it can be used in expressions.

=head1 PROBABLY NOT USER FACING

This module is probably more useful for module developers, than for
people writing direct Raku production code.

=head2 PERFORMANCE

Depending on the situation, the use of this iterator can be anywhere
from 1.5x to 3x as fast as the equivalent code using C<.flat>.

=head1 AUTHOR

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/OneSeq . Comments and
Pull Requests are welcome.

If you like this module, or what I'm doing more generally, committing to a
L<small sponsorship|https://github.com/sponsors/lizmat/>  would mean a great
deal to me!

=head1 COPYRIGHT AND LICENSE

Copyright 2025 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
