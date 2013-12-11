use WWW::Vimeo::Download;

my $vimeo = WWW::Vimeo::Download->new;
$vimeo->set_video_id( 78276321 );
$vimeo->set_video_id( 78317700 );
$vimeo->download( video => 78276321 );

$vimeo->download( video => "http://vimeo.com/78276321?eee" );
$vimeo->download( video => "http://vimeo.com/78276321?ddd",
                  save_as => "bla" );

$vimeo->download( video => 78276321,
                  save_as => "TEST-{title}.{ext}" );


