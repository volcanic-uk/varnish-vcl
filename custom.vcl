sub vcl_recv {
    unset req.http.Cookie;
}

# sub vcl_hit {
#     set resp.http.X-Varnish-Cache = "hit";
# }
# 
# sub vcl_miss {
#     set resp.http.X-Varnish-Cache = "miss";
# }
# 
# sub vcl_pass {
#     set resp.http.X-Varnish-Cache = "pass";
# }

sub vcl_backend_response {
    unset beresp.http.Set-Cookie;
    unset beresp.http.Cookie;
    set beresp.http.Cache-Control = "public, no-cache";
    
    if (bereq.http.Cookie ~ "(UserID|_session)") {
        set beresp.http.X-Cacheable = "NO:Got Session";
        set beresp.uncacheable = true;
        return (deliver);

    } elsif (beresp.ttl <= 0s) {
        # Varnish determined the object was not cacheable
        set beresp.http.X-Cacheable = "NO:Not Cacheable";

    } elsif (beresp.http.set-cookie) {
        # You don't wish to cache content for logged in users
        set beresp.http.X-Cacheable = "NO:Set-Cookie";
        set beresp.uncacheable = true;
        return (deliver);

    } elsif (beresp.http.Cache-Control ~ "private") {
        # You are respecting the Cache-Control=private header from the backend
        set beresp.http.X-Cacheable = "NO:Cache-Control=private";
        set beresp.uncacheable = true;
        return (deliver);

    } else {
        # Varnish determined the object was cacheable
        set beresp.http.X-Cacheable = "YES";
    }

    
    # Compress response if not compressed
    if (beresp.http.content-type ~ "text") {
        set beresp.do_gzip = true;
    }
}
