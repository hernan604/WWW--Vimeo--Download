package WWW::Vimeo::Writer;
use Moose;
use Data::Printer;
use File::Slurp;

sub save {
    my ( $self, $item ) = @_; 
    write_file( $item->{ video_id }, $item->{ video } );
}

1;
