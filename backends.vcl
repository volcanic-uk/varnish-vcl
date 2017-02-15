import directors;
import saintmode;

backend server1 {
  .host = "52.65.165.55";
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