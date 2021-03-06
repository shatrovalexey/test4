use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";


# use this block if you don't need middleware, and only have a single target Dancer app to run here
use Test::App;

Test::App->to_app;

use Plack::Builder;

builder {
    enable 'Deflater';
    Test::App->to_app;
}



=begin comment
# use this block if you want to include middleware such as Plack::Middleware::Deflater

use Test::App;
use Plack::Builder;

builder {
    enable 'Deflater';
    Test::App->to_app;
}

=end comment

=cut

=begin comment
# use this block if you want to include middleware such as Plack::Middleware::Deflater

use Test::App;
use Test::App_admin;

builder {
    mount '/'      => Test::App->to_app;
    mount '/admin'      => Test::App_admin->to_app;
}

=end comment

=cut

