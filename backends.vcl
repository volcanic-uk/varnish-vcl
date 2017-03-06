import directors;
import saintmode;

backend server1 {
  .host = "54.206.16.209";
  .port = "80";
  .probe = {
    .url = "/health";
    .timeout = 1s;
    .interval = 10s;
    .window = 5;
    .threshold = 3;
  }
}

sub vcl_init {
    # set up each server for saintmode
    new sm1 = saintmode.saintmode(server1, 10);
    
    # add saintmoded backends to round_robin director
    new brr = directors.round_robin();
    brr.add_backend(sm1.backend());
}

acl purgers {
    "127.0.0.1";
    "86.155.199.228";
}