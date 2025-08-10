# Hopefully part of Raku core at some point
use nqp;

class ForwardIterables:ver<0.0.4>:auth<zef:lizmat> does Iterator {
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

# vim: expandtab shiftwidth=4
