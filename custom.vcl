sub vcl_recv {
    unset req.http.Cookie;
}

sub vcl_backend_response {
    unset beresp.http.Set-Cookie;
    unset beresp.http.Cookie;
    set beresp.http.Cache-Control = "public, no-cache";
}
