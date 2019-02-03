<?php

    // get the real ip address
    function getRealIpAddr()
    {
        if (!empty($_SERVER['HTTP_CLIENT_IP']))   //check ip from share internet
        {
            $ip = $_SERVER['HTTP_CLIENT_IP'];
        }
        elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR']))   //to check ip is pass from proxy
        {
            $ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
        }
        else
        {
            $ip = $_SERVER['REMOTE_ADDR'];
        }
        return $ip;
    }

    // reload nginx to apply blocked list
    function reloadNginx()
    {
        $command = "sudo /etc/init.d/nginx reload";
        $escaped_command = escapeshellcmd($command);
        return system($escaped_command);
    }

    // Update an exixtend list
    function updateBlackList($ip)
    {
        $file = fopen('blockips.txt', 'w') or die('Unable to open file!');
        $content = "#deny 127.0.0.1;\n";
        fwrite($file, $content);
        $content = "deny ${ip};\n";
        fwrite($file, $content);
        fclose($file);

    }

    // Send email
    function sendEmail($ip)
    {
        $to = "test@domain.com";
        $subject = "A new IP was Blocked!";
        $message = "This is the new IP blocked by blacklisted path ${ip}";
        $headers = 'From: webmaster@localhost.com' . "\r\n" .
            'Reply-To: webmaster@localhost.com' . "\r\n" .
            'X-Mailer: PHP/' . phpversion();

        mail($to, $subject, $message, $headers);
    }

    // Set Http status code to 444
    function setHttpsStatusCode()
    {
        $ip = getRealIpAddr();
        updateBlackList($ip);
        reloadNginx();
        sendEmail($ip);
        return http_response_code(444);
    }

setHttpsStatusCode();


