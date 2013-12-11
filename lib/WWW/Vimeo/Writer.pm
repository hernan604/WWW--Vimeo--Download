package WWW::Vimeo::Writer;
use Moose;
use Data::Printer;
use File::Slurp;

sub save {
    my ( $self, $item ) = @_; 
    my $filepath = $item->{ options }->{ save_as };
    if ( ! $filepath ) {
        $filepath="{title}.{ext}";
    }
    my $title    = $item->{ metadata }->{ video }->{ title };

    if ( $filepath =~ m/\{title\}/ig ) {
      $filepath =~ s/\{title\}/$title/;
    }

    if ( $filepath =~ m/\{ext\}/ig ) {
        $filepath =~ s/\{ext\}/mp4/ig;
    } elsif ( $filepath !~ m/\.[a-zA-Z0-9]{3}$/ig ) {
        $filepath .= '.mp4';
    }
    write_file( $filepath, $item->{ video } );
}

1;
