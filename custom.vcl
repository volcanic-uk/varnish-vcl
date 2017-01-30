sub vcl_recv {
    unset req.http.Cookie;
}

sub vcl_fetch {
    unset beresp.http.Set-Cookie;
    unset beresp.http.Cookie;
}
