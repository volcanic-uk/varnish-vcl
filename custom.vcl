sub vcl_recv {
    unset req.http.Cookie;
}

sub vcl_hit {
    set resp.http.X-Varnish-Cache = "hit";
}

sub vcl_miss {
    set resp.http.X-Varnish-Cache = "miss";
}

sub vcl_pass {
    set resp.http.X-Varnish-Cache = "pass";
}

sub vcl_backend_response {
    unset beresp.http.Set-Cookie;
    unset beresp.http.Cookie;
    set beresp.http.Cache-Control = "public, no-cache";
}
