# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More;

BEGIN { use_ok('WWW::Vimeo::Download'); }

my $vimeo = WWW::Vimeo::Download->new();
isa_ok( $vimeo, 'WWW::Vimeo::Download' );


$vimeo->download( video => 78276321 );
ok( -e "10 Second Dance.mp4", 'downloaded file 1 with success' );
unlink( "10 Second Dance.mp4" );

$vimeo->download( video => "http://vimeo.com/78276321" );
ok( -e "10 Second Dance.mp4", 'downloaded file 2 with success' );
unlink( "10 Second Dance.mp4" );

$vimeo->download( video => "http://vimeo.com/78276321",
                  save_as => "bla" );
ok( -e "bla.mp4", 'downloaded file 2 with success' );
unlink( "bla.mp4" );

$vimeo->download( video => 78276321,
                  save_as => "TEST-{title}.{ext}" );
ok( -e "TEST-10 Second Dance.mp4", 'downloaded file 3 with success' );
unlink( "TEST-10 Second Dance.mp4" );

done_testing;
