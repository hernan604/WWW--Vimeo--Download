package WWW::Vimeo::Parser;
use Moose;

with('HTML::Robot::Scrapper::Parser::HTML::TreeBuilder::XPath');
with('WWW::Vimeo::ParserJson');

has [qw/robot engine/]  => ( is => 'rw' ); 

sub content_types {
    my ( $self ) = @_;
    return {
        'text/html' => [
            {
                parse_method => 'parse_xpath',
                description => q{
                    The method above 'parse_xpath' is inside class:
                    HTML::Robot::Scrapper::Parser::HTML::TreeBuilder::XPath
                },
            }
        ],
        'application/json' => [
            {
                parse_method => 'parse_json',
            }
        ],
    };
}

1;

