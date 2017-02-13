import directors;

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
    new brr = directors.round_robin();
    brr.add_backend(server1);
}